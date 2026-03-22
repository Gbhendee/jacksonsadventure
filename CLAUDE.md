# JacksonsAdventure — Claude Project Memory

## Project
Godot 3.x 2D side-scrolling platformer. Single level. Jackson is a cat who starts with jump and crouch locked and learns abilities from tutorial NPCs.

**Location:** `C:\git\JacksonsAdventure\JacksonsAdventure\`
**GitHub:** `github.com/gbendee/jacksonsadventure`

---

## Key Files

| File | Purpose |
|------|---------|
| `Scenes/Player/player.gd` | Player logic, freeze/unlock flags, `"player"` group |
| `Scenes/Dialog/Dialog.gd` | Typewriter dialog system, emits `dialog_finished` signal |
| `Scenes/Dialog/Dialog.tscn` | Dialog UI scene, export var `dialogPath` |
| `Scenes/Level1/TutorialNPC.gd` | Base class for all tutorial NPCs |
| `Scenes/Level1/Snickers.gd` | Teaches jump (`unlock_jump`) |
| `Scenes/Level1/Snickers2.gd` | Teaches crouch (`unlock_crouch`) |
| `Scenes/Level1/Level.tscn` | The single level scene |
| `dialog.json` | Snickers1 dialog (keys: `Name`, `Text`) |
| `dialog2.json` | Snickers2 dialog (keys: `Name`, `Text`) |
| `test/unit/` | GUT v9.3.0 unit tests |

---

## Architecture

### Ability Unlock System
- Jackson spawns with `jump_unlocked = false`, `crouch_unlocked = false`, `frozen = false`
- Jump/crouch input gated behind unlock flags in `player.gd`
- Player is in group `"player"` — NPCs find it via `get_tree().get_nodes_in_group("player")[0]`

### TutorialNPC Pattern (for all tutorial NPCs)
1. Player touches Area2D → NPC calls `player.freeze()`
2. NPC shows `$Dialog` node
3. Player presses `ui_accept` (Space/Enter) to advance lines
4. Dialog emits `dialog_finished` → NPC calls `player.unfreeze()` + `_on_tutorial_complete()`
5. `dialog_played = true` prevents re-trigger crash on second touch

### Dialog JSON Format
```json
[
  { "Name": "Snickers:", "Text": "Dialog line here." }
]
```

### Adding a New Tutorial NPC
1. Create `NewNPC.gd` extending `TutorialNPC`, override `_on_tutorial_complete()`
2. Create `dialogN.json` with 5–6 lines
3. Add `unlock_X()` method and `x_unlocked` flag to `player.gd`
4. Add Area2D to `Level.tscn` with Dialog child pointing to your JSON

---

## Level Layout
- Viewport: 0–1600 x, 0–768 y
- Jackson spawns: (273, 39)
- Snickers1 (jump tutorial): (330, 119) — right next to spawn
- Snickers2 (crouch tutorial): (42, 680) — lower left section
- Checkpoint: (1544, 648)

---

## Player Inputs
| Action | Keys | Gate |
|--------|------|------|
| Move | ← →, A/D | always |
| Jump | Space/Enter | `jump_unlocked` |
| Crouch | ↓, S | `crouch_unlocked` |

---

## Story & Narrative Design

### Origin & Purpose
This game is a tribute to Jackson — the developer's girlfriend's cat, who died of rare bone cancer at age 7 shortly after development began. The game stars Jackson and is meant to be his journey.

### The Central Metaphor: "The Long Climb"
Jackson's Adventure is a metaphor for Jackson's journey after death — finding his way somewhere better. The mountain is the central image: ascending = moving toward peace, warmth, and rest. Each stage takes place at higher elevation. The mood shifts from uncertain and foggy at the start to warm, open, and luminous near the summit.

### Narrative Arc
- Jackson arrives in an unfamiliar world, unsure how to move through it
- He literally cannot jump at the start — **this is intentional and thematic**, not just a tutorial mechanic. He doesn't yet know how to rise
- The cats he meets along the way (Snickers, etc.) are cats who have passed before him; they linger to guide others upward
- Each cat teaches Jackson a new ability, restoring him to himself one skill at a time
- By the summit, Jackson is fully himself, and the destination feels unmistakably like arrival

### Mechanics That Serve the Story
- **Jump locked until Snickers teaches it** = Jackson learning to rise
- **Crouch locked until Snickers2 teaches it** = learning to navigate tight places
- This pattern must continue for any new abilities added — each unlock is a moment of restoration, not just a tutorial gate

### Tone
- Not overtly sad or sentimental — gentle, warm, quietly meaningful
- The cats are written with dry, affectionate wit (see existing dialog) — maintain this throughout
- The ending should feel **earned, not announced**; no explicit statement of what the journey meant

### Stage Mood Progression
| Stage | Mood & Visual Direction |
|-------|------------------------|
| Early | Muted colors, unfamiliar terrain, Jackson still finding his footing |
| Mid | More open, warmer light; cats he meets feel familiar and unhurried |
| Summit | Warm, sun-drenched, still — "a forever nap in the sun" quality |

### Writing New NPC Dialog
- NPCs are cats who've been here longer; they're calm, not somber
- Dry wit is appropriate — Snickers' existing voice is the reference
- Avoid heavy-handed metaphor in dialog; let the mechanics carry the meaning
- Dialog should feel like a brief, warm encounter, not an exposition dump

---

## Workflow
- **Always use a feature branch** — never commit directly to `main`
- `gh` CLI is installed (Chocolatey) and authenticated to `gbendee`
- **Test manually in Godot** before merging to `main`
- Run GUT tests: `godot --script addons/gut/gut_cmdln.gd`
- Merge only after manual testing passes, then delete feature branches

## Common Gotchas
- Godot **3.x** — use `KinematicBody2D`, `yield()`, not Godot 4 equivalents
- Always check `is_instance_valid($Dialog)` before accessing — Dialog `queue_free()`s itself
- `Dialog._process` has `if not visible: return` guard — don't remove it
- GUT tests use `yield(get_tree(), "idle_frame")` not `await`
