# /// script
# requires-python = ">=3.14"
# dependencies = ["rich"]
# ///
#
# Report template scaffolding — unused imports intentional.
# Trim suppressions and/or imports once script's shape settles.
#
# ruff: noqa: F401
# pyright: reportMissingImports=false, reportUnknownVariableType=false, reportUnknownMemberType=false
"""Analyse peak-ctx.tsv: <terse description>."""

import csv
import json
import statistics
from collections import Counter, defaultdict
from datetime import date, datetime
from pathlib import Path
from typing import TypedDict

from rich.console import Console
from rich.panel import Panel
from rich.table import Table

console = Console()

TSV = Path("peak-ctx.tsv")
LIMIT_200K = 200_000  # Standard context window.
LIMIT_1M = 1_000_000  # 1M-context window.

# Colour bands for "% of window" cells.
THRESHOLD_RED = 50
THRESHOLD_AMBER = 25
THRESHOLD_OK = 10

MIN_ROWS_FOR_STATS = 2  # statistics.stdev() needs N >= 2.
PEAK_CTX_CEILING = 65_000  # Personal ceiling


class Row(TypedDict):
    """Shape of one row after load(). Every section_* gets a list[Row]."""

    peak: int
    start: datetime
    mtime: datetime
    date: date
    project: str
    title: str
    file: str


def short_project(path: str) -> str:
    """Extract a friendly project name from a session file path."""
    parent = Path(path).parent.name  # e.g. "-home-mp-projects-FOO"
    parts = parent.split("-projects-")
    return parts[-1] if len(parts) > 1 else parent.lstrip("-")


def colour_for_pct(pct: float) -> str:
    """Return a Rich colour name for a "% of window" cell."""
    if pct >= THRESHOLD_RED:
        return "red"
    if pct >= THRESHOLD_AMBER:
        return "yellow"
    if pct >= THRESHOLD_OK:
        return "green"
    return "cyan"


def bar(value: float, max_value: float, width: int = 24, char: str = "█") -> str:
    """Render a solid ASCII bar of `width` cells, filled proportional to value/max."""
    if max_value <= 0:
        return ""
    filled = max(0, min(width, round((value / max_value) * width)))
    return char * filled + "·" * (width - filled)


def _nice_bucket_width(peaks: list[int], target_buckets: int = 10) -> int:
    """Pick a 'nice' bucket width (1, 2, 5, 10, ... x1000) for ~target_buckets bins."""
    span = max(peaks) - min(peaks)
    if span == 0:
        return 1_000
    raw = span / target_buckets
    nice = [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000]
    return next(n * 1_000 for n in nice if n * 1_000 >= raw)


def load() -> list[Row]:
    """Read peak-ctx.tsv and normalise each row into the Row shape."""
    rows: list[Row] = []
    with TSV.open() as fh:
        for r in csv.DictReader(fh, delimiter="\t"):
            start = datetime.fromisoformat(r["main_session_start"])
            rows.append(
                {
                    "peak": int(r["peak_ctx"]),
                    "start": start,
                    "mtime": datetime.fromisoformat(r["last_modified"]),
                    "date": start.date(),
                    "project": short_project(r["session_file"]),
                    "title": r["title_custom_ai"],
                    "file": r["session_file"],
                },
            )
    return rows


def section_overall(rows: list[Row]) -> None:
    """Render the overall peak-context percentile table."""
    peaks = sorted(r["peak"] for r in rows)
    q = statistics.quantiles(peaks, n=100)  # q[i] = (i+1)th percentile

    metrics: list[tuple[str, int]] = [
        ("Min", peaks[0]),
        ("Median (P50)", int(statistics.median(peaks))),
        ("Mean", int(statistics.mean(peaks))),
        ("P75", int(q[74])),
        ("P90", int(q[89])),
        ("P95", int(q[94])),
        ("P99", int(q[98])),
        ("Max", peaks[-1]),
        ("Std-dev", int(statistics.stdev(peaks))),
    ]

    t = Table(
        title="📊 Overall Peak-Context Distribution",
        title_justify="left",
        title_style="bold cyan",
        header_style="bold",
    )
    t.add_column("Metric", style="cyan")
    t.add_column("Peak CTX", justify="right")
    t.add_column("% 200k", justify="right")
    t.add_column("% 1M", justify="right")

    for label, val in metrics:
        pct200 = 100 * val / LIMIT_200K
        pct1m = 100 * val / LIMIT_1M
        t.add_row(
            label,
            f"{val:,}",
            f"[{colour_for_pct(pct200)}]{pct200:5.1f}%[/]",
            f"{pct1m:5.1f}%",
        )
    console.print(t)


def section_buckets(rows: list[Row]) -> None:
    """Render an adaptive-width histogram of peak-context values."""
    peaks = [r["peak"] for r in rows]
    bucket_width = _nice_bucket_width(peaks)

    counts: defaultdict[int, int] = defaultdict(int)
    for p in peaks:
        counts[(p // bucket_width) * bucket_width] += 1

    lo_floor = (min(peaks) // bucket_width) * bucket_width
    hi_ceil = (max(peaks) // bucket_width + 1) * bucket_width
    max_count = max(counts.values())
    width_label = f"{bucket_width // 1000}k"

    t = Table(
        title=f"🎯 Where do my sessions land? ({width_label} buckets)",
        title_justify="left",
        title_style="bold magenta",
        header_style="bold",
    )
    t.add_column("Peak CTX", style="cyan")
    t.add_column("Sessions", justify="right")
    t.add_column("Histogram", style="magenta")
    t.add_column("% Total", justify="right")

    total = len(rows)
    for lo in range(lo_floor, hi_ceil, bucket_width):
        n = counts.get(lo, 0)
        share = 100 * n / total
        t.add_row(
            f"{lo // 1000:>4}k-{(lo + bucket_width) // 1000:>4}k",
            str(n) if n else "·",
            bar(n, max_count, width=40) if n else "",
            f"{share:5.1f}%" if n else "  ·  ",
        )
    console.print(t)


def section_by_project(rows: list[Row]) -> None:
    """Render per-project aggregates: sessions, mean/median/max, big-session share."""
    by_proj: defaultdict[str, list[int]] = defaultdict(list)
    for r in rows:
        by_proj[r["project"]].append(r["peak"])

    t = Table(
        title="📁 Per-project Peak CTX Breakdown",
        title_justify="left",
        title_style="bold green",
        header_style="bold",
    )
    t.add_column("Project", style="cyan")
    t.add_column("Sessions", justify="right")
    t.add_column("Mean peak", justify="right")
    t.add_column("Median peak", justify="right")
    t.add_column("Max peak", justify="right")
    t.add_column(f"Share ≥{PEAK_CTX_CEILING // 1000}k", justify="right")

    for project, peaks in sorted(by_proj.items(), key=lambda kv: -len(kv[1])):
        big = sum(1 for p in peaks if p >= PEAK_CTX_CEILING)
        share = 100 * big / len(peaks)
        t.add_row(
            project,
            str(len(peaks)),
            f"{int(statistics.mean(peaks)):,}",
            f"{int(statistics.median(peaks)):,}",
            f"{max(peaks):,}",
            f"{share:5.1f}%",
        )
    console.print(t)


# EXTEND: add more section_* functions here.
#         Helpers to reach for first: bar(), colour_for_pct(), LIMIT_200K, LIMIT_1M.
#         Already imported: json, Counter — use as needed.


def main() -> None:
    """Load the TSV and render each section."""
    rows = load()
    if len(rows) < MIN_ROWS_FOR_STATS:
        console.print("[red]peak-ctx.tsv has fewer than 2 rows[/]")
        return

    span_start = min(r["date"] for r in rows)
    span_end = max(r["date"] for r in rows)
    n_projects = len({r["project"] for r in rows})
    console.print(
        Panel.fit(
            f"[bold]{len(rows)}[/] sessions  ·  "
            f"[dim]{span_start} → {span_end}[/]  ·  "
            f"[bold]{n_projects}[/] projects",
            border_style="cyan",
        ),
    )

    section_overall(rows)
    section_buckets(rows)
    section_by_project(rows)
    # EXTEND: call your new section_* functions here.


if __name__ == "__main__":
    main()
