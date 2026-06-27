# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///
"""Cost report for one or two Claude Code sessions.

Run `uv run cost_report.py --help` for usage — argparse in main() is the single
source of truth for the CLI surface.

Methodology: tokens deduped by `message.id` (parallel tool-call shards repeat the same
usage); 5m / 1h cache-creation tokens read directly from `usage.cache_creation`;
pricing per-model from rates.json (override with `--rates`). Raises KeyError on any
model not in the loaded rates — better to crash than silently mis-cost.
"""

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import TYPE_CHECKING, Any, TypedDict, cast

if TYPE_CHECKING:
    from collections.abc import Iterable

DEFAULT_RATES_PATH = Path(__file__).parent / "rates.json"

BUCKETS: tuple[str, ...] = (
    "input_tokens",
    "cache_create_5m",
    "cache_create_1h",
    "cache_read",
    "output_tokens",
)

type Bucket = dict[str, int]
type ByModel = dict[str, Bucket]
type RateTable = dict[str, dict[str, float]]

ZERO: Bucket = dict.fromkeys(BUCKETS, 0)


def _path_arg(s: str) -> Path:
    """Argparse type: convert string to Path with `~` expanded.."""
    return Path(s).expanduser()


def _session_path_arg(s: str) -> Path:
    """Argparse type for session paths. Tolerates an optional `.jsonl` suffix.

    User passes `<root>/<session-id>` (or `<root>/<session-id>.jsonl`); the script
    reads the orchestrator transcript at `<path>.jsonl` and the subagent
    transcripts under `<path>/subagents/`.
    """
    p = _path_arg(s)
    if p.suffix == ".jsonl":
        p = p.with_suffix("")
    return p


def _print_rates_table(rates: RateTable) -> None:
    """Print `rates` as a markdown table — same layout as the doc's pricing section."""
    print("| Model | " + " | ".join(BUCKETS) + " |")
    print("|:--|" + "|".join("--:" for _ in BUCKETS) + "|")
    for mk, buckets in rates.items():
        cells = " | ".join(f"${buckets[k]:.2f}" for k in BUCKETS)
        print(f"| `{mk}` | {cells} |")


def _load_rates(path: Path) -> RateTable:
    """Load $/MTok rates from a JSON file.

    Schema: `{model: {input_tokens, cache_create_5m, cache_create_1h, cache_read,
    output_tokens}}`. Validates every model has all five buckets. Raises
    `TypeError` on wrong-shape JSON, `ValueError` on missing buckets — consistent
    with the 'crash rather than silently mis-cost' policy.
    """
    with path.open() as f:
        data = json.load(f)
    if not isinstance(data, dict):
        msg = f"{path}: top-level must be a dict, got {type(data).__name__}"
        raise TypeError(msg)
    rates: RateTable = {}
    for mk, buckets in cast("dict[str, object]", data).items():
        if not isinstance(buckets, dict):
            msg = f"{path}: rates for {mk!r} must be a dict"
            raise TypeError(msg)
        typed_buckets = cast("dict[str, float]", buckets)
        missing = [b for b in BUCKETS if b not in typed_buckets]
        if missing:
            msg = f"{path}: model {mk!r} missing buckets: {missing}"
            raise ValueError(msg)
        rates[mk] = {b: float(typed_buckets[b]) for b in BUCKETS}
    return rates


class _SkillEntry(TypedDict):
    """Per-skill aggregation: wrapper/sidechain token totals and call counts."""

    w: ByModel
    s: ByModel
    wc: int
    sc: int


def _new_skill_entry() -> _SkillEntry:
    """Return a zeroed `_SkillEntry` for use as a `defaultdict` factory."""
    return {"w": {}, "s": {}, "wc": 0, "sc": 0}


def _try_parse_json(line: str) -> dict[str, Any] | None:
    """Parse a JSONL line; return None on JSON errors so callers can silently skip."""
    try:
        return json.loads(line)
    except json.JSONDecodeError:
        return None


def _text_blocks(content: Iterable[object]) -> list[str]:
    """Return the `text` field of every 'text'-type block in a JSON content list."""
    out: list[str] = []
    for c in content:
        if not isinstance(c, dict):
            continue
        block = cast("dict[str, Any]", c)
        if block.get("type") == "text":
            out.append(block.get("text", ""))
    return out


def _model_key(m: str | None) -> str:
    """Strip optional -YYYYMMDD suffix from a Claude model id.

    'claude-haiku-4-5-20251001' -> 'claude-haiku-4-5'.
    """
    return re.sub(r"-\d{8}$", "", m or "unknown")


def cost_usd(by_model: ByModel, rates: RateTable) -> float:
    """Compute USD cost for `by_model`. KeyError on unknown model is intentional."""
    total = 0.0
    for mk, b in by_model.items():
        r = rates[mk]
        total += sum(b[k] * r[k] for k in BUCKETS)
    return total / 1_000_000


def _usage_to_buckets(usage: dict[str, Any]) -> Bucket:
    """Map raw transcript `message.usage` field names to BUCKETS keys.

    Single-message extractor — no dedup. Preserves the `cache_creation` null guard
    (older transcripts may emit `null` rather than the object).
    """
    cache_creation: Any = usage.get("cache_creation") or {}
    return {
        "input_tokens": usage.get("input_tokens", 0),
        "cache_create_5m": cache_creation.get("ephemeral_5m_input_tokens", 0),
        "cache_create_1h": cache_creation.get("ephemeral_1h_input_tokens", 0),
        "cache_read": usage.get("cache_read_input_tokens", 0),
        "output_tokens": usage.get("output_tokens", 0),
    }


def _first_record(fp: Path) -> dict[str, Any]:
    """Return the first JSON object in `fp`, with a multi-line decode fallback."""
    with fp.open() as f:
        line = f.readline()
        try:
            return json.loads(line)
        except json.JSONDecodeError:
            f.seek(0)
            buf = f.read()
            idx = 0
            while idx < len(buf) and buf[idx] in " \r\n\t":
                idx += 1
            return json.JSONDecoder().raw_decode(buf, idx)[0]


def bucket_sums(fp: Path) -> ByModel:
    """Dedup by message.id, split cache_creation into 5m/1h, group by model."""
    seen: set[str] = set()
    by_model: defaultdict[str, Bucket] = defaultdict(lambda: dict(ZERO))
    with fp.open() as f:
        for line in f:
            rec = _try_parse_json(line)
            if rec is None:
                continue
            msg: Any = rec.get("message") or {}
            mid: Any = msg.get("id")
            u: Any = msg.get("usage")
            if not (u and mid) or mid in seen:
                continue
            seen.add(mid)
            mk = _model_key(msg.get("model"))
            delta = _usage_to_buckets(u)
            b = by_model[mk]
            for k in BUCKETS:
                b[k] += delta[k]
    return dict(by_model)


def _price_stdin(rates: RateTable) -> None:
    """Read JSONL `{model, usage}` lines from stdin; print one USD value per line.

    Each input line: `{"model": "<key>", "usage": <raw_message.usage_object>}`.
    Output: one float (`%.6f`) per line, in input order. Used by `orient.sh`
    and `diagnose.sh` so all pricing flows through one implementation.
    """
    for raw in sys.stdin:
        line = raw.strip()
        if not line:
            continue
        rec = json.loads(line)
        mk = _model_key(rec.get("model"))
        usage: dict[str, Any] = rec.get("usage") or {}
        b = _usage_to_buckets(usage)
        print(f"{cost_usd({mk: b}, rates):.6f}")


def _add(a: ByModel, b: ByModel) -> ByModel:
    """Return per-model bucket sums for `a + b`, union of model keys."""
    out: ByModel = {mk: dict(buckets) for mk, buckets in a.items()}
    for mk, buckets in b.items():
        if mk in out:
            out[mk] = {k: out[mk][k] + buckets[k] for k in BUCKETS}
        else:
            out[mk] = dict(buckets)
    return out


def _tok_total(by_model: ByModel) -> int:
    """Return the grand total: sum every bucket across every model."""
    return sum(sum(b.values()) for b in by_model.values())


def classify_subagents(
    session_path: Path,
) -> tuple[
    defaultdict[str, _SkillEntry],
    defaultdict[str, int],
    list[tuple[str, str, ByModel]],
]:
    """Return (per_skill, models_seen, unclassified) for one session.

    per_skill: {skill_name: {'w': by_model, 's': by_model, 'wc': int, 'sc': int}}
    """
    per_skill: defaultdict[str, _SkillEntry] = defaultdict(_new_skill_entry)
    models_seen: defaultdict[str, int] = defaultdict(int)
    unclassified: list[tuple[str, str, ByModel]] = []

    for fp in sorted((session_path / "subagents").glob("agent-*.jsonl")):
        rec = _first_record(fp)
        content: Any = rec.get("message", {}).get("content", "")
        text: str = (
            content if isinstance(content, str) else " ".join(_text_blocks(content))
        )
        by_model = bucket_sums(fp)

        for mk, b in by_model.items():
            models_seen[mk] += sum(b.values())

        m = re.search(r"(ff-\d+-[\w-]+)", text)
        skill = m.group(1) if m else "unknown"

        if text.startswith("Invoke `/find-font:") or "using the Skill tool" in text[:200]:
            per_skill[skill]["w"] = _add(per_skill[skill]["w"], by_model)
            per_skill[skill]["wc"] += 1
        elif text.startswith("Base directory for this skill:"):
            per_skill[skill]["s"] = _add(per_skill[skill]["s"], by_model)
            per_skill[skill]["sc"] += 1
        else:
            unclassified.append((fp.name, text[:80].replace("\n", " "), by_model))

    return per_skill, models_seen, unclassified


def step_rollup(session_path: Path) -> tuple[list[tuple[str, ByModel]], ByModel]:
    """Return (rows, total_by_model). rows = [(step, by_model), ...] in order."""
    orchestrator = bucket_sums(session_path.with_suffix(".jsonl"))
    per_skill, _, _ = classify_subagents(session_path)

    rows: list[tuple[str, ByModel]] = [("Orchestrator", orchestrator)]
    total = orchestrator
    for skill in sorted(per_skill):
        skill_total = _add(per_skill[skill]["w"], per_skill[skill]["s"])
        rows.append((skill, skill_total))
        total = _add(total, skill_total)
    return rows, total


def _fmt_pct(run1: float, run2: float) -> str:
    """Format the % delta from Run 1 → Run 2. Returns '   n/a' when `run1` == 0."""
    if run1 == 0:
        return "   n/a"
    return f"{(run2 - run1) / run1 * 100:+6.1f}%"


def report_session(
    session_path: Path,
    rates: RateTable,
) -> tuple[list[tuple[str, ByModel]], ByModel]:
    """Print per-session blocks for `session_path` and return (rows, total)."""
    print(f"\n========== Session: {session_path.name} ==========\n")

    rows, total = step_rollup(session_path)
    print("--- Per-step rollup (fills §2 row 2, §3) ---")
    print(f"{'Step':<32} {'Tokens':>12} {'$':>10}")
    for step, bm in rows:
        print(f"{step:<32} {_tok_total(bm):>12,} ${cost_usd(bm, rates):>9.4f}")
    print(
        f"{'Total (run-wide)':<32} {_tok_total(total):>12,} "
        f"${cost_usd(total, rates):>9.4f}"
    )

    orchestrator = bucket_sums(session_path.with_suffix(".jsonl"))
    print("\n--- Orchestrator bucket detail (fills §4) ---")
    print(f"{'Token Bucket':<16} {'Tokens':>12} {'$':>10}")
    for bucket in BUCKETS:
        tok = sum(b[bucket] for b in orchestrator.values())
        usd = (
            sum(b[bucket] * rates[mk][bucket] for mk, b in orchestrator.items())
            / 1_000_000
        )
        print(f"{bucket:<16} {tok:>12,} ${usd:>9.4f}")
    print(
        f"{'Total':<16} {_tok_total(orchestrator):>12,} "
        f"${cost_usd(orchestrator, rates):>9.4f}"
    )

    per_skill, models_seen, unclassified = classify_subagents(session_path)
    print("\n--- Per-skill wrapper/sidechain (fills §5) ---")
    print(
        f"{'Skill':<32} {'Calls':>6} {'WrapTok':>10} {'SideTok':>10} "
        f"{'TotalTok':>10} {'$':>10}"
    )
    for skill in sorted(per_skill):
        x = per_skill[skill]
        wt = _tok_total(x["w"])
        st = _tok_total(x["s"])
        skill_total = _add(x["w"], x["s"])
        print(
            f"{skill:<32} {x['wc']:>6} {wt:>10,} {st:>10,} {wt + st:>10,} "
            f"${cost_usd(skill_total, rates):>9.4f}"
        )

    print("\nModels seen (token total per model):")
    for mk, n in sorted(models_seen.items(), key=lambda kv: -kv[1]):
        print(f"  {mk:<28} {n:>12,}")

    total_1h = sum(
        b["cache_create_1h"]
        for bm in [orchestrator]
        + [_add(per_skill[s]["w"], per_skill[s]["s"]) for s in per_skill]
        for b in bm.values()
    )
    if total_1h:
        print(
            f"\nNOTE: {total_1h:,} cache_create_1h tokens seen "
            f"(priced at 2.0x base input_tokens)."
        )
    if unclassified:
        print(
            f"\nWARN: {len(unclassified)} subagent file(s) unclassified "
            f"— counted in NEITHER wrapper NOR sidechain:"
        )
        for name, snip, bm in unclassified:
            print(f"  - {name}  cost=${cost_usd(bm, rates):.4f}  first80={snip!r}")

    return rows, total


def report_comparison(
    rows1: list[tuple[str, ByModel]],
    total1: ByModel,
    rows2: list[tuple[str, ByModel]],
    total2: ByModel,
    rates: RateTable,
) -> None:
    """Print a Δ comparison table between two sessions to stdout."""
    print("\n========== Comparison: Run 1 vs Run 2 ==========\n")
    print("--- §3 Step-level Δ ---")
    print(
        f"{'Step':<32} {'R1 tok':>10} {'R1 $':>9} {'R2 tok':>10} {'R2 $':>9} "
        f"{'Δ tok':>10} {'Δ $':>9} {'Δ %':>8}"
    )

    by_step1 = dict(rows1)
    by_step2 = dict(rows2)
    empty: ByModel = {}
    for step in sorted(set(by_step1) | set(by_step2)):
        bm1 = by_step1.get(step, empty)
        bm2 = by_step2.get(step, empty)
        t1 = _tok_total(bm1)
        t2 = _tok_total(bm2)
        c1 = cost_usd(bm1, rates)
        c2 = cost_usd(bm2, rates)
        print(
            f"{step:<32} {t1:>10,} ${c1:>8.4f} {t2:>10,} ${c2:>8.4f} "
            f"{t2 - t1:>+10,} ${c2 - c1:>+8.4f} {_fmt_pct(c1, c2):>8}"
        )

    t1 = _tok_total(total1)
    t2 = _tok_total(total2)
    c1 = cost_usd(total1, rates)
    c2 = cost_usd(total2, rates)
    print(
        f"{'Total (run-wide)':<32} {t1:>10,} ${c1:>8.4f} {t2:>10,} ${c2:>8.4f} "
        f"{t2 - t1:>+10,} ${c2 - c1:>+8.4f} {_fmt_pct(c1, c2):>8}"
    )


def main() -> None:
    """Parse CLI args and run a one- or two-session report."""
    parser = argparse.ArgumentParser(
        prog="cost_report.py",
        description=(
            "Cost / token breakdown for one or two Claude Code sessions. "
            "Reads JSONL transcripts and prints to stdout.\n\n"
            "1 session:  per-step rollup (orchestrator + each ff-N skill), "
            "orchestrator bucket detail, per-skill wrapper/sidechain split.\n"
            "2 sessions: same blocks per session plus a Δ table "
            "(Run 2 minus Run 1)."
        ),
        epilog=(
            "Examples:\n"
            "  uv run cost_report.py <session>                      "
            "# single session report\n"
            "  uv run cost_report.py <session> <compare-session>    "
            "# adds Δ table\n"
            "  uv run cost_report.py --show-rates                   "
            "# rate table, no session needed\n"
            '  echo \'{"model":"<m>","usage":{...}}\' | \\\n'
            "    uv run cost_report.py --price-stdin                "
            "# JSONL pricer used by orient.sh / diagnose.sh\n\n"
            "<session> is a path like "
            "~/.claude/projects/<encoded-cwd>/<uuid>"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "session_path_1",
        metavar="SESSION",
        nargs="?",
        type=_session_path_arg,
        help=(
            "<root>/<session-id> — reads orchestrator at <session>.jsonl "
            "and subagents under <session>/subagents/. "
            "A trailing '.jsonl' is tolerated."
        ),
    )
    parser.add_argument(
        "session_path_2",
        metavar="COMPARE",
        nargs="?",
        type=_session_path_arg,
        help="Second session. Triggers Δ table. Same format as SESSION.",
    )
    parser.add_argument(
        "--rates",
        type=_path_arg,
        default=DEFAULT_RATES_PATH,
        metavar="PATH",
        help=(
            "$/MTok rate table JSON. Run --show-rates to see schema and "
            "active values. Default: %(default)s"
        ),
    )
    parser.add_argument(
        "--show-rates",
        action="store_true",
        help="Print active rate table (markdown) and exit. Honours --rates.",
    )
    parser.add_argument(
        "--price-stdin",
        action="store_true",
        help=(
            "Read JSONL `{model, usage}` lines from stdin and print one USD "
            "value per line. Honours --rates. Used by orient.sh and "
            "diagnose.sh so all pricing shares one implementation."
        ),
    )
    args = parser.parse_args()
    rates = _load_rates(args.rates)

    if args.show_rates:
        _print_rates_table(rates)
        return

    if args.price_stdin:
        _price_stdin(rates)
        return

    if args.session_path_1 is None:
        parser.error("SESSION is required unless --show-rates or --price-stdin is given")

    for label, p in (
        ("SESSION", args.session_path_1),
        ("COMPARE", args.session_path_2),
    ):
        if p is None:
            continue
        transcript = p.with_suffix(".jsonl")
        if not transcript.is_file():
            parser.error(f"{label}: transcript not found at {transcript}")

    if args.session_path_2 is None:
        report_session(args.session_path_1, rates)
    else:
        rows1, total1 = report_session(args.session_path_1, rates)
        rows2, total2 = report_session(args.session_path_2, rates)
        report_comparison(rows1, total1, rows2, total2, rates)


if __name__ == "__main__":
    main()
