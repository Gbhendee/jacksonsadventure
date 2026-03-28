"""
Palette swap: cat04 → jax color mapping
Run from the jax_spritesheets directory or any location.
"""
from PIL import Image
import os
import sys

SPRITE_DIR = os.path.dirname(os.path.abspath(__file__))

# (source_rgb) -> (target_rgb)
COLOR_MAP = [
    ((143, 155, 169), (240, 229, 229)),  # main body fur: medium gray → warm cream
    ((117, 127, 139), (252, 252, 252)),  # belly/highlights: light gray → near-white
    ((87,  37,  59),  (189, 136, 121)),  # nose/tongue/inner ear: dark maroon → pinkish brown
]

TOLERANCE = 3

FILES = [
    ("cat04_attack_strip7.png",            "jax_attack_strip7.png"),
    ("cat04_crouch_strip8.png",            "jax_crouch_strip8.png"),
    ("cat04_dash_strip9.png",              "jax_dash_strip9.png"),
    ("cat04_die_strip8.png",               "jax_die_strip8.png"),
    ("cat04_fright_strip8.png",            "jax_fright_strip8.png"),
    ("cat04_hurt_strip4.png",              "jax_hurt_strip4.png"),
    ("cat04_idle_strip8.png",              "jax_idle_strip8.png"),
    ("cat04_land_strip2.png",              "jax_land_strip2.png"),
    ("cat04_ledgeclimb_strip11.png",       "jax_ledgeclimb_strip11.png"),
    ("cat04_ledgeclimb_struggle_strip12.png", "jax_ledgeclimb_struggle_strip12.png"),
    ("cat04_ledgegrab_strip5.png",         "jax_ledgegrab_strip5.png"),
    ("cat04_ledgeidle_strip8.png",         "jax_ledgeidle_strip8.png"),
    ("cat04_liedown_strip24.png",          "jax_liedown_strip24.png"),
    ("cat04_sit_strip8.png",               "jax_sit_strip8.png"),
    ("cat04_walk_strip8.png",              "jax_walk_strip8.png"),
    ("cat04_wallclimb_strip8.png",         "jax_wallclimb_strip8.png"),
    ("cat04_wallgrab_strip8.png",          "jax_wallgrab_strip8.png"),
]


def matches(pixel_rgb, target_rgb, tol):
    return all(abs(pixel_rgb[i] - target_rgb[i]) <= tol for i in range(3))


def swap_palette(src_path, dst_path, sanity_file=None):
    img = Image.open(src_path).convert("RGBA")
    pixels = img.load()
    w, h = img.size
    changed = 0

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue  # skip fully transparent
            for src_rgb, dst_rgb in COLOR_MAP:
                if matches((r, g, b), src_rgb, TOLERANCE):
                    pixels[x, y] = (dst_rgb[0], dst_rgb[1], dst_rgb[2], a)
                    changed += 1
                    break

    img.save(dst_path, "PNG")
    return changed, w * h


total_files = 0
for src_name, dst_name in FILES:
    src = os.path.join(SPRITE_DIR, src_name)
    dst = os.path.join(SPRITE_DIR, dst_name)
    if not os.path.exists(src):
        print(f"  MISSING: {src_name}")
        continue
    changed, total = swap_palette(src, dst)
    pct = 100.0 * changed / total if total else 0
    print(f"  {dst_name}: {changed}/{total} pixels changed ({pct:.1f}%)")
    total_files += 1

print(f"\nDone: {total_files} files converted.")
