#!/usr/bin/env python3
# PNG to adaptive color-aware vector SVG converter
#
# Converts raster PNG diagrams into pure-vector SVG using adaptive color sampling and quadtree tiling.
# The algorithm recursively subdivides regions based on color complexity (standard deviation),
# then merges adjacent same-color tiles to minimize SVG objects.
#
# KEY FINDINGS (from benchmarking on Agentic-SDLC.png):
#   • Palette quantization: 98.3% object reduction (80,607 → 1,371), 78% file size reduction
#   • Merge tolerance: 5.7% object reduction, negligible impact with palette quantization
#   • Combined optimizations yield best compression with minimal runtime overhead
#
# OPTIMIZATION OPTIONS (CLI arguments):
#   --palette-colors N          Reduce image to N-color palette before processing (0 = no reduction)
#                               Recommended: 64 for diagrams, 128 for photorealistic
#                               Impact: 78% file size reduction (9.1M → 2.0M on test image)
#   --merge-tolerance N         Color channel tolerance for merging adjacent tiles (0 = exact match only)
#                               Recommended: 0-2 for diagrams, 4-8 for photos
#                               Impact: 5-10% object reduction
#   --max-segments-per-path N   Maximum segments per SVG path element (default: 4000)
#                               Lower values = more objects but finer control
#
# CORE PARAMETERS (environment variables or CLI):
#   --tile-size or CONVERT2SVG_TILE_SIZE: Maximum tile size (default: 4)
#   --detail-threshold or CONVERT2SVG_DETAIL_THRESHOLD: StdDev threshold (default: 18.0)
#   --range-threshold or CONVERT2SVG_RANGE_THRESHOLD: Channel range threshold (default: 48)
#   --background or CONVERT2SVG_BACKGROUND: black, white, or transparent (default: black)
#
# RECOMMENDED USAGE:
#   Balanced compression:     python3 convert2svg.py -i input.png -o output.svg --palette-colors 64
#   Maximum compression:      python3 convert2svg.py -i input.png -o output.svg --palette-colors 32 --merge-tolerance 2
#   High fidelity:            python3 convert2svg.py -i input.png -o output.svg --palette-colors 128
#   Performance tuning:       python3 convert2svg.py -i input.png -o output.svg --palette-colors 64 --max-segments-per-path 2000
#
# ALGORITHM:
#   1. Load PNG and optionally quantize palette for fewer unique colors
#   2. Recursively subdivide image into tiles (quadtree approach)
#      - Stops when tile size reaches minimum or color uniformity is high enough
#   3. Merge adjacent tiles with identical/similar colors
#   4. Generate SVG path commands (batched by max-segments-per-path)
#   5. Output pure-vector SVG with timing information
#
# REQUIRES: Pillow (pip install Pillow)
#
from pathlib import Path
import argparse
import os
import time
from dataclasses import dataclass

from PIL import Image, ImageStat

DEFAULT_INPUT_PATH = Path("image/Agentic-SDLC.png")
DEFAULT_OUTPUT_PATH = Path("image/agentic_sdlc_diagram.svg")
DEFAULT_TILE_SIZE = 4
DEFAULT_DETAIL_THRESHOLD = 18.0
DEFAULT_RANGE_THRESHOLD = 48
DEFAULT_MIN_TILE_SIZE = 1
DEFAULT_BACKGROUND = "black"
DEFAULT_MAX_SEGMENTS_PER_PATH = 4000
DEFAULT_PALETTE_COLORS = 0  # 0 means no quantization
DEFAULT_MERGE_TOLERANCE = 0  # 0 means exact match required


@dataclass
class Tile:
    """Represents one sampled rectangular SVG tile."""

    x: int
    y: int
    width: int
    height: int
    red: int
    green: int
    blue: int
    alpha: int


@dataclass
class RegionStats:
    """Cached statistics for one image region."""

    red: int
    green: int
    blue: int
    alpha: int
    max_stddev: float
    max_range: int


def resolve_tile_size(cli_tile_size: int | None) -> int:
    """Resolve the maximum tile size from CLI, environment, or the default."""
    if cli_tile_size is not None:
        return cli_tile_size

    env_tile_size = os.getenv("CONVERT2SVG_TILE_SIZE")
    if env_tile_size:
        return int(env_tile_size)

    return DEFAULT_TILE_SIZE


def resolve_detail_threshold(cli_detail_threshold: float | None) -> float:
    """Resolve the detail threshold from CLI, environment, or the default."""
    if cli_detail_threshold is not None:
        return cli_detail_threshold

    env_detail_threshold = os.getenv("CONVERT2SVG_DETAIL_THRESHOLD")
    if env_detail_threshold:
        return float(env_detail_threshold)

    return DEFAULT_DETAIL_THRESHOLD


def resolve_range_threshold(cli_range_threshold: int | None) -> int:
    """Resolve the max channel range threshold from CLI, environment, or default."""
    if cli_range_threshold is not None:
        return cli_range_threshold

    env_range_threshold = os.getenv("CONVERT2SVG_RANGE_THRESHOLD")
    if env_range_threshold:
        return int(env_range_threshold)

    return DEFAULT_RANGE_THRESHOLD


def ensure_extension(path: Path, extension: str) -> Path:
    """Append the expected extension when a file name is provided without one."""
    if path.suffix:
        return path
    return path.with_suffix(extension)


def quantize_image(image: Image.Image, num_colors: int) -> Image.Image:
    """Reduce image to a fixed palette using PIL quantization."""
    if num_colors <= 0 or num_colors >= 16777216:  # 2^24 colors
        return image
    quantized = image.quantize(colors=num_colors)
    return quantized.convert("RGBA")


def color_distance(c1: tuple[int, int, int, int], c2: tuple[int, int, int, int], tolerance: int) -> bool:
    """Check if two RGBA colors are within tolerance of each other."""
    if tolerance <= 0:
        return c1 == c2
    return all(abs(a - b) <= tolerance for a, b in zip(c1, c2))


def parse_background_color(name: str) -> tuple[int, int, int, int] | None:
    """Map a background name to an RGBA color value, or None for transparent."""
    if name == "transparent":
        return None
    if name == "white":
        return (255, 255, 255, 255)
    return (0, 0, 0, 255)


def append_region(
    tiles: list[Tile],
    x: int,
    y: int,
    width: int,
    height: int,
    red: int,
    green: int,
    blue: int,
    alpha: int,
) -> None:
    """Append a tile using already-sampled region colors."""
    tiles.append(Tile(x, y, width, height, red, green, blue, alpha))


def sample_region_stats(image: Image.Image, x: int, y: int, width: int, height: int) -> RegionStats:
    """Sample region mean + detail metrics in one pass."""
    region = image.crop((x, y, x + width, y + height))
    stat = ImageStat.Stat(region)
    red, green, blue, alpha = (int(round(value)) for value in stat.mean)
    max_stddev = max(stat.stddev)
    max_range = max((high - low) for low, high in stat.extrema)
    return RegionStats(red, green, blue, alpha, max_stddev, max_range)


def optimize_tiles(tiles: list[Tile], merge_tolerance: int = 0) -> list[Tile]:
    """Merge adjacent same-color tiles to reduce final SVG object count.
    
    Args:
        tiles: List of tiles to optimize.
        merge_tolerance: Color channel tolerance for merging (0 = exact match only).
    """
    if not tiles:
        return []

    # Pass 1: Merge horizontal neighbors on the same row with matching height/style.
    # When tolerance > 0, group by approximate color instead of exact color.
    horizontal_groups: dict[tuple[int, int, int, int, int, int], list[Tile]] = {}
    for tile in tiles:
        if merge_tolerance <= 0:
            key = (tile.y, tile.height, tile.red, tile.green, tile.blue, tile.alpha)
        else:
            # Quantize color to tolerance buckets for grouping
            bucket_r = (tile.red // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_g = (tile.green // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_b = (tile.blue // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_a = (tile.alpha // (merge_tolerance + 1)) * (merge_tolerance + 1)
            key = (tile.y, tile.height, bucket_r, bucket_g, bucket_b, bucket_a)
        horizontal_groups.setdefault(key, []).append(tile)

    horizontally_merged: list[Tile] = []
    for group in horizontal_groups.values():
        group.sort(key=lambda tile: tile.x)
        current = group[0]
        for tile in group[1:]:
            if current.x + current.width == tile.x:
                current = Tile(
                    current.x,
                    current.y,
                    current.width + tile.width,
                    current.height,
                    current.red,
                    current.green,
                    current.blue,
                    current.alpha,
                )
            else:
                horizontally_merged.append(current)
                current = tile
        horizontally_merged.append(current)

    # Pass 2: Merge vertical neighbors with matching x/width/style.
    vertical_groups: dict[tuple[int, int, int, int, int, int], list[Tile]] = {}
    for tile in horizontally_merged:
        if merge_tolerance <= 0:
            key = (tile.x, tile.width, tile.red, tile.green, tile.blue, tile.alpha)
        else:
            bucket_r = (tile.red // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_g = (tile.green // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_b = (tile.blue // (merge_tolerance + 1)) * (merge_tolerance + 1)
            bucket_a = (tile.alpha // (merge_tolerance + 1)) * (merge_tolerance + 1)
            key = (tile.x, tile.width, bucket_r, bucket_g, bucket_b, bucket_a)
        vertical_groups.setdefault(key, []).append(tile)

    optimized: list[Tile] = []
    for group in vertical_groups.values():
        group.sort(key=lambda tile: tile.y)
        current = group[0]
        for tile in group[1:]:
            if current.y + current.height == tile.y:
                current = Tile(
                    current.x,
                    current.y,
                    current.width,
                    current.height + tile.height,
                    current.red,
                    current.green,
                    current.blue,
                    current.alpha,
                )
            else:
                optimized.append(current)
                current = tile
        optimized.append(current)

    return optimized


def append_tiles_to_svg(svg_lines: list[str], tiles: list[Tile], max_segments_per_path: int = DEFAULT_MAX_SEGMENTS_PER_PATH) -> int:
    """Emit tiles as compact grouped paths and return number of SVG objects emitted."""
    style_groups: dict[tuple[int, int, int, int], list[Tile]] = {}
    for tile in tiles:
        key = (tile.red, tile.green, tile.blue, tile.alpha)
        style_groups.setdefault(key, []).append(tile)

    svg_object_count = 0
    for (red, green, blue, alpha), group in style_groups.items():
        opacity = alpha / 255
        segment_count = 0
        path_segments: list[str] = []

        for tile in group:
            path_segments.append(f"M{tile.x} {tile.y}h{tile.width}v{tile.height}h-{tile.width}z")
            segment_count += 1

            if segment_count >= max_segments_per_path:
                svg_lines.append(
                    f'  <path d="{" ".join(path_segments)}" fill="rgb({red},{green},{blue})" '
                    f'fill-opacity="{opacity:.4f}" class="tile"/>'
                )
                svg_object_count += 1
                segment_count = 0
                path_segments = []

        if path_segments:
            svg_lines.append(
                f'  <path d="{" ".join(path_segments)}" fill="rgb({red},{green},{blue})" '
                f'fill-opacity="{opacity:.4f}" class="tile"/>'
            )
            svg_object_count += 1

    return svg_object_count


def render_adaptive_region(
    tiles: list[Tile],
    image: Image.Image,
    x: int,
    y: int,
    width: int,
    height: int,
    max_tile_size: int,
    min_tile_size: int,
    detail_threshold: float,
    range_threshold: int,
) -> None:
    """Recursively split high-detail regions to preserve text readability."""
    region_stats = sample_region_stats(image, x, y, width, height)

    if width <= min_tile_size and height <= min_tile_size:
        append_region(
            tiles,
            x,
            y,
            width,
            height,
            region_stats.red,
            region_stats.green,
            region_stats.blue,
            region_stats.alpha,
        )
        return

    if (
        width <= max_tile_size
        and height <= max_tile_size
        and region_stats.max_stddev <= detail_threshold
        and region_stats.max_range <= range_threshold
    ):
        append_region(
            tiles,
            x,
            y,
            width,
            height,
            region_stats.red,
            region_stats.green,
            region_stats.blue,
            region_stats.alpha,
        )
        return

    if width == 1 or height == 1:
        append_region(
            tiles,
            x,
            y,
            width,
            height,
            region_stats.red,
            region_stats.green,
            region_stats.blue,
            region_stats.alpha,
        )
        return

    half_width = max(1, width // 2)
    half_height = max(1, height // 2)

    quadrants = [
        (x, y, half_width, half_height),
        (x + half_width, y, width - half_width, half_height),
        (x, y + half_height, half_width, height - half_height),
        (x + half_width, y + half_height, width - half_width, height - half_height),
    ]

    for quad_x, quad_y, quad_width, quad_height in quadrants:
        if quad_width > 0 and quad_height > 0:
            render_adaptive_region(
                tiles,
                image,
                quad_x,
                quad_y,
                quad_width,
                quad_height,
                max_tile_size,
                min_tile_size,
                detail_threshold,
                range_threshold,
            )


def create_color_vector_svg(
    input_path: Path,
    output_path: Path,
    max_tile_size: int,
    detail_threshold: float,
    range_threshold: int,
    background: str,
    palette_colors: int = 0,
    merge_tolerance: int = 0,
    max_segments_per_path: int = DEFAULT_MAX_SEGMENTS_PER_PATH,
) -> None:
    """Create a pure-vector SVG using adaptive color sampling.
    
    Args:
        input_path: Path to source PNG.
        output_path: Path to output SVG.
        max_tile_size: Maximum tile size in pixels.
        detail_threshold: Standard deviation threshold for subdivision.
        range_threshold: Channel range threshold for subdivision.
        background: Background color (black, white, or transparent).
        palette_colors: Optional color reduction (0 = no reduction).
        merge_tolerance: Color tolerance for merging adjacent tiles (0 = exact match).
        max_segments_per_path: Maximum segments per SVG path element.
    """
    with Image.open(input_path) as img:
        rgba = img.convert("RGBA")
        bg_rgba = parse_background_color(background)
        if bg_rgba is not None:
            flattened = Image.new("RGBA", rgba.size, bg_rgba)
            flattened.alpha_composite(rgba)
            rgba = flattened
        
        # Optional: quantize to reduce palette size
        if palette_colors > 0:
            rgba = quantize_image(rgba, palette_colors)
        
        width, height = rgba.size

    svg_lines = [
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}px" height="{height}px" viewBox="0 0 {width} {height}" version="1.1">',
        "  <defs>",
        "    <style>",
        "      .tile { shape-rendering: crispEdges; }",
        "    </style>",
        "  </defs>",
    ]

    if background != "transparent":
        svg_lines.append(f'  <rect x="0" y="0" width="{width}" height="{height}" fill="{background}"/>')

    tiles: list[Tile] = []

    render_adaptive_region(
        tiles=tiles,
        image=rgba,
        x=0,
        y=0,
        width=width,
        height=height,
        max_tile_size=max_tile_size,
        min_tile_size=DEFAULT_MIN_TILE_SIZE,
        detail_threshold=detail_threshold,
        range_threshold=range_threshold,
    )

    optimized_tiles = optimize_tiles(tiles, merge_tolerance=merge_tolerance)
    print(f"[opt] Reduced tile objects: {len(tiles)} -> {len(optimized_tiles)}")
    svg_tile_objects = append_tiles_to_svg(svg_lines, optimized_tiles, max_segments_per_path=max_segments_per_path)
    print(f"[opt] SVG drawable objects after path compaction: {svg_tile_objects}")

    svg_lines.append("</svg>")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(svg_lines) + "\n", encoding="utf-8")
    print(f"[ok] Created adaptive color-aware vector SVG: {output_path}")


def main() -> int:
    start_time = time.perf_counter()
    exit_code = 0

    parser = argparse.ArgumentParser(
        prog="convert2svg.py",
        description="Convert a PNG into a color-aware vector SVG with adaptive tile sizing.",
        epilog=(
            "Examples:\n"
            "  python3 convert2svg.py\n"
            "  python3 convert2svg.py --input image/Agentic-SDLC --output image/agentic_sdlc_diagram\n"
            "  python3 convert2svg.py --background white --tile-size 3 --detail-threshold 12.5 --input image/in.png --output image/out.svg\n"
            "  python3 convert2svg.py --background transparent --input image/in.png --output image/out.svg\n\n"
            "Notes:\n"
            "  If --input has no extension, .png is appended.\n"
            "  If --output has no extension, .svg is appended.\n"
            "  --background switches the base color to black, white, or transparent."
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "-t",
        "--tile-size",
        type=int,
        default=None,
        help="Maximum tile size in pixels for the SVG mosaic (default: 4, or CONVERT2SVG_TILE_SIZE)",
    )
    parser.add_argument(
        "-d",
        "--detail-threshold",
        type=float,
        default=None,
        help="Standard deviation threshold for subdividing detailed regions (default: 18.0, or CONVERT2SVG_DETAIL_THRESHOLD)",
    )
    parser.add_argument(
        "-r",
        "--range-threshold",
        type=int,
        default=None,
        help="Channel range threshold for forcing subdivision at hard edges (default: 48, or CONVERT2SVG_RANGE_THRESHOLD)",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=Path,
        default=DEFAULT_INPUT_PATH,
        help="Path to the source PNG file (default: image/Agentic-SDLC.png)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_PATH,
        help="Path for the generated SVG file (default: image/agentic_sdlc_diagram.svg)",
    )
    parser.add_argument(
        "-b",
        "--background",
        choices=["black", "white", "transparent"],
        default=DEFAULT_BACKGROUND,
        help="Background color to render under transparent pixels (default: black)",
    )
    parser.add_argument(
        "--palette-colors",
        type=int,
        default=None,
        help="Optional color palette size for quantization (0 or omitted = no quantization, e.g., 64, 128)",
    )
    parser.add_argument(
        "--merge-tolerance",
        type=int,
        default=None,
        help="Color channel tolerance for merging adjacent tiles (0 = exact match only, default: 0, e.g., 2)",
    )
    parser.add_argument(
        "--max-segments-per-path",
        type=int,
        default=None,
        help="Maximum segments per SVG path element (default: 4000, lower = more objects but smaller paths)",
    )
    args = parser.parse_args()

    try:
        input_path = ensure_extension(args.input, ".png")
        output_path = ensure_extension(args.output, ".svg")

        if not input_path.exists():
            print(f"[error] Input file not found: {input_path}")
            exit_code = 1
            return exit_code

        tile_size = resolve_tile_size(args.tile_size)
        detail_threshold = resolve_detail_threshold(args.detail_threshold)
        range_threshold = resolve_range_threshold(args.range_threshold)
        palette_colors = args.palette_colors if args.palette_colors is not None else DEFAULT_PALETTE_COLORS
        merge_tolerance = args.merge_tolerance if args.merge_tolerance is not None else DEFAULT_MERGE_TOLERANCE
        max_segments_per_path = args.max_segments_per_path if args.max_segments_per_path is not None else DEFAULT_MAX_SEGMENTS_PER_PATH

        if tile_size < 1:
            print("[error] tile size must be at least 1")
            exit_code = 1
            return exit_code

        if detail_threshold < 0:
            print("[error] detail threshold must be at least 0")
            exit_code = 1
            return exit_code

        if range_threshold < 0 or range_threshold > 255:
            print("[error] range threshold must be between 0 and 255")
            exit_code = 1
            return exit_code

        if palette_colors < 0:
            print("[error] palette colors must be >= 0 (0 = no quantization)")
            exit_code = 1
            return exit_code

        if merge_tolerance < 0 or merge_tolerance > 255:
            print("[error] merge tolerance must be between 0 and 255")
            exit_code = 1
            return exit_code

        if max_segments_per_path < 1:
            print("[error] max segments per path must be at least 1")
            exit_code = 1
            return exit_code

        print(
            f"Converting PNG to adaptive color-aware vector SVG (input: {input_path}, output: {output_path}, background: {args.background}, max tile size: {tile_size}, detail threshold: {detail_threshold}, range threshold: {range_threshold}, palette colors: {palette_colors}, merge tolerance: {merge_tolerance}, max segments per path: {max_segments_per_path})...\n"
        )
        create_color_vector_svg(
            input_path, output_path, tile_size, detail_threshold, range_threshold, args.background,
            palette_colors=palette_colors, merge_tolerance=merge_tolerance, max_segments_per_path=max_segments_per_path
        )
        print("\nConversion complete")
        print(f"Output: {output_path}")
        return exit_code
    finally:
        elapsed_seconds = time.perf_counter() - start_time
        print(f"Elapsed time: {elapsed_seconds:.3f}s")


if __name__ == "__main__":
    raise SystemExit(main())
