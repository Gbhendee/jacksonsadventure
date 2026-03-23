tool
# =============================================================================
# build_cave_tileset.gd — Cave TileSet Regeneration Tool
# =============================================================================
# HOW TO RUN:
#   1. Open the Godot editor with the JacksonsAdventure project loaded.
#   2. Open this file in the Script editor (double-click it in the FileSystem).
#   3. Go to  File > Run  (or press Ctrl+Shift+X).
#
# WHAT IT DOES:
#   Regenerates  res://Scenes/Level2/Cave_TileSet.tres  from scratch, registering
#   all 198 tiles (9 content rows × 22 columns) from:
#       res://Assets/Art/tilesets/Terrain (16x16).png   (352×176 px)
#
#   Tile layout in the source image:
#       Rows 0–2  (y=  0, 16, 32): Terrain variant A
#       Row  3    (y= 48)         : empty/transparent — SKIPPED
#       Rows 4–6  (y= 64, 80, 96): Terrain variant B
#       Row  7    (y=112)         : empty/transparent — SKIPPED
#       Rows 8–10 (y=128,144,160): Terrain variant C
#
#   Tile ID assignment (left-to-right, top-to-bottom, skipping empty rows):
#       ID   0 = row 0, col  0  ← top-left of variant A (used by existing floor)
#       ID   1 = row 0, col  1
#       ...
#       ID  21 = row 0, col 21
#       ID  22 = row 1, col  0
#       ...
#       ID 197 = row 10, col 21
#
#   Each tile gets a RectangleShape2D collision shape covering the full 16×16 cell.
#
# AFTER RUNNING:
#   The Ground TileMap in Level2.tscn already references Cave_TileSet.tres and
#   uses tile ID 0 for all floor cells — no manual scene edits are required.
# =============================================================================

extends EditorScript

func _run():
	var texture_path := "res://Assets/Art/tilesets/Terrain (16x16).png"
	var texture = load(texture_path)
	if texture == null:
		push_error("build_cave_tileset: Could not load texture at " + texture_path)
		return

	var ts := TileSet.new()

	# Content rows only — rows 3 and 7 are empty/transparent and are skipped.
	var content_rows := [0, 1, 2, 4, 5, 6, 8, 9, 10]
	var num_cols     := 22
	var tile_size    := 16

	var id := 0
	for row in content_rows:
		for col in range(num_cols):
			ts.create_tile(id)
			ts.tile_set_name(id, "tile_c%d_r%d" % [col, row])
			ts.tile_set_texture(id, texture)
			ts.tile_set_region(id, Rect2(col * tile_size, row * tile_size, tile_size, tile_size))

			# Full-tile collision box: extents Vector2(8,8) → 16×16 box centred at origin.
			# Offset Vector2(8,8) shifts that centre to the middle of the tile cell.
			var shape := RectangleShape2D.new()
			shape.extents = Vector2(8, 8)
			ts.tile_set_shape(id, 0, shape)
			ts.tile_set_shape_offset(id, 0, Vector2(8, 8))

			id += 1

	var save_path := "res://Scenes/Level2/Cave_TileSet.tres"
	var err := ResourceSaver.save(save_path, ts)
	if err != OK:
		push_error("build_cave_tileset: Failed to save TileSet (error %d)" % err)
	else:
		print("build_cave_tileset: Saved %d tiles to %s" % [id, save_path])
