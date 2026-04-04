# unsuite — Development Roadmap

> From `unpeople` to `unsuite`: scaling the proven procedural generation pattern to cover every asset category required for a complete 3D game.

---

## Vision

`unpeople` demonstrated that a single, well-structured Go module — pure stdlib, deterministic, sub-100 ms — can produce high-quality procedural 3D meshes for an entire species family. The `unsuite` project applies that exact pattern to **every asset category a 3D game requires**: terrain, vegetation, architecture, creatures, weapons, clothing, materials, audio, narrative, VFX, vehicles, and lore.

The existing opd-ai game suite (venture, vania, wyrm, violence, velocity, way, where, whack) are **Ebitengine-based 2D** games. The un-series is the first to move into **3D**, targeting the [Kaiju engine](https://kaijuengine.com). The end state: **one seed number + a parameter struct → a complete, playable 3D game world** renderable in Kaiju.

---

## Phase 0 — Foundation Already Laid ✅ DONE

**All new generators follow this blueprint.**

`unpeople` established and validated the architecture template every subsequent generator must follow:

| Artifact | What was proved |
|----------|----------------|
| Package layout | `generator/`, `mesh/`, `export/`, `params/` separation |
| Export pipeline | OBJ, glTF 2.0, GLB, binary — all from the same `Mesh` struct |
| Testing patterns | Table-driven tests over all enum values; golden-file mesh regression |
| CI setup | `go vet`, `go test -race -cover`, codecov |
| Performance | <100 ms per asset on modest hardware |
| Determinism | Bit-identical output across platforms given identical seed + params |
| Module isolation | Independent `go.mod`; zero external dependencies |

**Validation criterion:** `unpeople` is tagged `v1.0.0` and CI is green.

---

## Phase 1 — Core World (P0)

**Prerequisite for any rendered 3D world.** These six generators are ship-blocking: no terrain means no world, no buildings means no settlements, no vegetation means barren landscapes, no materials means untextured geometry.

**Estimated total effort:** 12–16 developer-weeks  
**Dependency:** Phase 0 complete

---

### `unlands` — Terrain Heightmaps

**Description:** Multi-biome terrain generation producing heightmaps, splat maps, and optional cave geometry.

**Reuses:** `venture` `pkg/procgen/` terrain logic — extend from 2D tile maps to 3D heightmaps with biome blending and hydraulic erosion.

**Key technical challenges:**
- Hydraulic and thermal erosion simulation at acceptable performance
- Seamless biome blending via splat maps
- Cave geometry as a secondary signed-distance-field layer

**Key params:** `Seed`, `Biome`, `Scale`, `ErosionPasses`, `MoistureMap`, `CaveFrequency`

**Output:** Heightmap (float32 grid) + splat map (RGBA) + optional cave mesh

**Validation criteria:**
- All biome enum values produce valid non-flat heightmaps
- Erosion runs in <100 ms for a 256×256 grid
- Output is deterministic across 3 runs with the same seed
- `go test -race -cover` ≥ 80%

---

### `unbuildings` — Buildings

**Description:** Parametric buildings (houses, shops, temples, castles, ruins) output as 3D meshes with interior layout graphs.

**Reuses:** `venture` building generators — lift 2D footprint logic, extrude to 3D, add roofing styles, windows, and doors as separate mesh components.

**Key technical challenges:**
- Roof style selection (gabled, hipped, flat, dome) and watertight mesh joining
- Interior floor/ceiling/wall mesh generation
- Era and function-driven stylistic variation without branching explosion

**Key params:** `Seed`, `Style`, `Size`, `Era`, `Material`, `Function`, `Ruin`

**Output:** `Mesh` (exterior + interior) + layout graph JSON

**Validation criteria:**
- All `Style` × `Era` combinations produce watertight meshes
- Interior layout graph is connected (no isolated rooms)
- <100 ms for a medium house

---

### `unflora` — Vegetation & Flora

**Description:** Trees, bushes, grass tufts, flowers, mushrooms as 3D meshes using L-system and space-colonisation algorithms.

**Key technical challenges:**
- L-system rule tables for realistic branching diversity
- LOD (level-of-detail) mesh generation — high-poly for near, billboard for far
- Seasonal variation (bare, budding, full, autumn, snow-covered)

**Key params:** `Seed`, `Species`, `Climate`, `Age`, `Season`, `LODLevels`

**Output:** `Mesh` array (one per LOD) + billboard texture

**Validation criteria:**
- All `Species` × `Season` combinations render without degenerate geometry
- LOD chain — each step is at least 50% fewer triangles than the previous
- <50 ms for a medium tree (3 LOD levels)

---

### `unsurfaces` — PBR Materials

**Description:** Tileable PBR material sets (albedo, normal, roughness, metallic maps) generated via procedural noise.

**Key technical challenges:**
- Perlin/Worley noise combination for believable material variation
- Seamless tileability (no visible seams at texture edges)
- Material-type-driven parameter presets (stone, wood, metal, fabric, skin)

**Key params:** `Seed`, `MaterialType`, `Resolution`, `TileScale`, `Weathering`

**Output:** Texture atlas (RGBA) — albedo + normal packed, roughness + metallic packed

**Validation criteria:**
- All `MaterialType` values produce 4-channel output at requested resolution
- Tile seam test: horizontally/vertically mirrored copies show no visible seam at 90° angle
- <100 ms at 512×512 resolution

---

### `unblades` — Weapons

**Description:** Swords, axes, bows, staves, guns (genre-dependent) generated via parametric cross-section extrusion along a spline.

**Key technical challenges:**
- Cross-section library (blade profiles, haft profiles, bow limb curves)
- Guard and pommel sub-mesh attachment with correct pivot points
- Grip point metadata for animation IK targets

**Key params:** `Seed`, `WeaponClass`, `Material`, `Length`, `Enchantment`, `Era`

**Output:** `Mesh` + grip/impact attachment point metadata

**Validation criteria:**
- All `WeaponClass` × `Era` combinations produce valid meshes with no degenerate triangles
- Grip points are within the mesh bounding box
- <50 ms per weapon

---

### `unthings` — Furniture & Props

**Description:** Tables, chairs, barrels, crates, lanterns, signs — a library of parametric primitives composed via placement rules.

**Key technical challenges:**
- Primitive composition grammar (attach leg to table top, add handle to barrel lid)
- Material variation consistent with `unsurfaces` material types
- Collision AABB generation alongside mesh

**Key params:** `Seed`, `ItemType`, `Era`, `Material`, `WearLevel`

**Output:** `Mesh` + AABB collision box

**Validation criteria:**
- All `ItemType` values produce valid meshes
- AABB fully encloses mesh vertices
- <30 ms per prop

---

## Phase 2 — Alive World (P1)

**These generators make the world inhabited.** Creatures move, make noise, give quests, and have names.

**Estimated total effort:** 14–20 developer-weeks  
**Dependency:** Phase 1 complete (creatures need terrain to place on; audio needs materials)

---

### `unbeasts` — Creature Meshes

**Description:** Quadrupeds, flying creatures, swimming creatures, and monsters. Body-plan-driven generation with variable limb counts.

**Key technical challenges:**
- Body plan grammar (central body, limb attachment sockets, head placement)
- Skin/scale/feather texture generation compatible with `unsurfaces`
- Skeleton generation matching the body plan for use by `unmotions`

**Key params:** `Seed`, `BodyPlan`, `LimbCount`, `Size`, `SkinType`, `Archetype`

**Output:** `Mesh` + skeleton + skin texture

**Validation criteria:**
- All `BodyPlan` × `Archetype` combinations produce non-intersecting meshes
- Skeleton joint count matches limb count
- <100 ms per creature

---

### `unmotions` — Procedural Animations

**Description:** Locomotion cycles (walk, run, fly, swim, attack, idle) generated from skeleton + gait rules via inverse kinematics.

**Key technical challenges:**
- Foot-planting IK for terrain-conforming walk cycles
- Gait pattern library (trot, gallop, slither, flap)
- Blend weight generation for animation state machine

**Key params:** `Skeleton`, `GaitType`, `Speed`, `Mass`, `AnimationType`

**Output:** BVH joint keyframe sequence

**Validation criteria:**
- All `GaitType` × `AnimationType` combinations produce valid keyframe sequences
- No joint exceeds anatomical rotation limits
- <50 ms per animation cycle (60-frame loop)

---

### `unsounds` — Sound Effects

**Description:** Footsteps, impacts, doors, magic effects, ambient sounds generated via oscillator + ADSR envelope + filter synthesis.

**Reuses:** `wyrm` audio system logic; `violence` procedural audio pipeline.

**Key technical challenges:**
- Material-aware footstep synthesis (stone, wood, water, sand)
- Convincing impact transient generation
- PCM output without any external audio library

**Key params:** `Seed`, `SoundClass`, `Material`, `Intensity`, `Duration`

**Output:** PCM audio buffer (float32, mono/stereo, 44100 Hz)

**Validation criteria:**
- All `SoundClass` × `Material` combinations produce non-silent output
- Output duration matches requested duration ±5 ms
- <20 ms generation time per 1-second sound

---

### `unquests` — Quest Graphs

**Description:** Branching quest lines with objectives, rewards, and failure states generated as directed acyclic graphs.

**Reuses:** `venture` quest generation logic.

**Key technical challenges:**
- DAG validity (no cycles, all nodes reachable from root)
- Objective type diversity (kill, fetch, escort, discover, craft)
- Reward scaling consistent with difficulty parameter

**Key params:** `Seed`, `Difficulty`, `Faction`, `QuestType`, `ObjectiveCount`

**Output:** Quest graph struct (serialisable to JSON)

**Validation criteria:**
- All generated quest graphs are valid DAGs (verified by DFS cycle check)
- All `QuestType` values produce at least 2 branching paths
- <10 ms per quest graph

---

### `unwords` — Dialog Trees

**Description:** NPC conversation trees with skill checks, faction reactions, and branching outcomes.

**Reuses:** `venture` dialog generator.

**Key technical challenges:**
- Personality-driven tone variation without a language model
- Skill-check node integration
- Faction relationship modifiers on dialog branch availability

**Key params:** `Seed`, `NPCPersonality`, `Topic`, `Faction`, `SkillChecks`

**Output:** Dialog tree struct (serialisable to JSON)

**Validation criteria:**
- All `NPCPersonality` × `Topic` combinations produce trees with ≥3 nodes
- Every leaf node has a resolution type (accept, reject, quest, trade, info)
- <10 ms per dialog tree

---

### `unnames` — Names & Languages

**Description:** NPC names, place names, and fictional language fragments generated via Markov chains and phonotactic rules.

**Key technical challenges:**
- Per-species phonotactic rule tables
- Place name composition (prefix + root + suffix from terrain type)
- Fictional language fragment consistency (same species = same phoneme inventory)

**Key params:** `Seed`, `Species`, `Culture`, `NameType`, `Length`

**Output:** String (name or phrase)

**Validation criteria:**
- All `Species` × `NameType` combinations return non-empty strings
- Names for the same species share detectable phoneme patterns
- <1 ms per name

---

## Phase 3 — Rich World (P2)

**These generators fill in the environmental detail** — dungeons to explore, cities to visit, roads to travel, geology to appreciate, water to cross, skies to watch.

**Estimated total effort:** 14–18 developer-weeks  
**Dependency:** Phases 1 and 2 complete

---

### `undepths` — Dungeons & Interiors

**Description:** Underground labyrinths, natural caves, rooms, and corridors generated via BSP room placement and graph connectivity.

**Reuses:** `venture` dungeon generation logic.

**Key params:** `Seed`, `Depth`, `Theme`, `Difficulty`, `RoomCount`, `ConnectivityStyle`

**Output:** Room graph + 3D mesh (walls, floors, ceilings)

**Key technical challenges:** Watertight room-to-corridor mesh joins; theme-driven decoration placement hooks.

**Validation criteria:** All generated graphs are fully connected; <200 ms for 20-room dungeon.

---

### `untowns` — Cities & Settlements

**Description:** Town layouts (road networks, lot subdivision, district assignment, walls) generated via L-system road growth and Voronoi lot subdivision.

**Reuses:** `venture` city generation logic.

**Key params:** `Seed`, `Population`, `Era`, `Terrain`, `Faction`, `WallStyle`

**Output:** 2D layout (roads + lots) → 3D placement map for `unbuildings`

**Key technical challenges:** Road network growth respecting terrain slope; district zoning rules.

**Validation criteria:** All roads form a connected graph; all lots are convex polygons; <500 ms for a 200-building town.

---

### `unpaths` — Roads & Bridges

**Description:** Terrain-conforming paths, cobbled roads, and bridges generated as splines projected onto heightmaps.

**Key params:** `Seed`, `RoadType`, `Terrain`, `Width`, `Material`, `BridgeStyle`

**Output:** Spline + surface mesh

**Key technical challenges:** A* pathfinding on heightmap to find natural road routes; bridge span mesh generation.

**Validation criteria:** Road mesh follows terrain within ±0.5 m vertical tolerance; no road segment exceeds 45° slope.

---

### `unstones` — Rocks & Geological Features

**Description:** Boulders, cliff faces, crystal formations, stalactites, and stalagmites via Voronoi fracture and noise displacement.

**Key params:** `Seed`, `RockType`, `Weathering`, `Scale`, `ClusterCount`

**Output:** `Mesh` + normal map

**Key technical challenges:** Voronoi fracture producing believable rock face detail; crystal facet generation.

**Validation criteria:** All `RockType` values produce watertight meshes; <50 ms per rock.

---

### `unwaters` — Water Bodies

**Description:** River, lake, ocean, and waterfall surface meshes with flow maps for shader-driven animation.

**Key params:** `Seed`, `BodyType`, `FlowRate`, `Depth`, `ShorelineComplexity`

**Output:** Surface mesh + flow map (RG texture)

**Key technical challenges:** Shoreline mesh generation from heightmap intersection; waterfall cascade mesh.

**Validation criteria:** All `BodyType` values produce valid surface meshes; flow map vectors are normalised.

---

### `unskies` — Weather & Sky

**Description:** Procedural skybox textures, cloud meshes, and particle system configurations for rain, snow, fog, and lightning.

**Reuses:** `wyrm` weather ECS system configuration.

**Key params:** `Seed`, `TimeOfDay`, `Season`, `Climate`, `StormIntensity`

**Output:** Skybox cubemap texture + cloud mesh + particle emitter configs

**Key technical challenges:** Atmospheric scattering approximation in pure Go; cloud shape variation.

**Validation criteria:** All `Climate` × `Season` combinations produce distinct skybox outputs; <100 ms generation.

---

## Phase 4 — Equipped World (P3)

**Characters need gear.** Clothing, shields, consumables, jewelry, and vehicles.

**Estimated total effort:** 10–14 developer-weeks  
**Dependency:** Phases 1 and 2 complete; `ungarments` requires `unpeople` body meshes

---

### `ungarments` — Armor & Clothing

Shrink-wrap projection of clothing/armor geometry onto `unpeople` body meshes. Genre-spanning from fantasy robes to sci-fi exosuits.

**Key params:** `Seed`, `BodyMesh`, `GarmentType`, `Material`, `Era`, `Coverage`

**Output:** `Mesh` (fitted to body) + UV map

---

### `unwards` — Shields & Off-hand Items

Parametric shape generation for shields, spell tomes, orbs, and bucklers.

**Key params:** `Seed`, `Type`, `Material`, `Emblem`, `Size`

**Output:** `Mesh` + attachment point

---

### `ungoods` — Consumables & Containers

Potions, scrolls, food items, chests, bags, and keys composed from primitive shapes with label/decal texture hooks.

**Key params:** `Seed`, `ItemType`, `Rarity`, `Contents`, `LabelSeed`

**Output:** `Mesh` + icon texture (64×64 RGBA)

---

### `untrinkets` — Jewelry & Trinkets

Rings, amulets, crowns, and gems using small-scale mesh generation with procedural gem faceting.

**Key params:** `Seed`, `Type`, `Metal`, `GemType`, `Enchantment`

**Output:** `Mesh` (small-scale, high-detail)

---

### `unrides` — Vehicles

Genre-dependent parametric vehicle assembly: carts and ships for fantasy; hovercrafts and mechs for sci-fi.

**Reuses:** `wyrm` vehicle ECS configuration.

**Key params:** `Seed`, `VehicleClass`, `Era`, `Size`, `ArmorLevel`

**Output:** `Mesh` + physics param struct + mount-point metadata

---

## Phase 5 — Atmospheric (P4)

**Atmosphere and polish** — music, voice, VFX, decals, and heraldry.

**Estimated total effort:** 14–20 developer-weeks  
**Dependency:** Phases 1–4 complete

---

### `unmelodies` — Music

Adaptive algorithmic music tracks (combat, exploration, town, menu) via rule-based composition.

**Reuses:** `wyrm` music system logic.

**Key params:** `Seed`, `Genre`, `Mood`, `Tempo`, `Intensity`, `Duration`

**Output:** PCM audio buffer or MIDI-like note stream

---

### `unvoices` — Voice/Bark Synthesis

NPC vocal barks, grunts, laughter, and pain sounds via formant synthesis and prosody rules. No speech-to-text or ML required.

**Key params:** `Seed`, `Species`, `Age`, `Emotion`, `Pitch`, `BarkType`

**Output:** PCM audio buffer

---

### `unsparks` — Particle Systems

Fire, smoke, magic dust, sparks, blood, and water splash via emitter configuration generation.

**Key params:** `Seed`, `EffectType`, `Intensity`, `ColorScheme`, `Duration`

**Output:** Particle emitter config struct (serialisable to JSON/binary)

---

### `unspells` — Magic/Spell VFX

Spell casting visuals, projectile trails, and impact effects via VFX graph + procedural texture generation.

**Key params:** `Seed`, `Element`, `PowerLevel`, `School`, `CastStyle`

**Output:** VFX graph struct + procedural textures

---

### `unmarks` — Decals & Graffiti

Blood splatters, structural cracks, rune inscriptions, and wanted posters as procedural stamp/pattern textures.

**Key params:** `Seed`, `Type`, `Age`, `Faction`, `Size`

**Output:** Decal texture (RGBA) + placement metadata

---

### `uncrests` — Heraldry & Emblems

Faction banners, shield emblems, and flags via rule-based heraldic composition (tinctures, ordinaries, charges, divisions).

**Key params:** `Seed`, `Faction`, `Colors`, `Charges`, `DivisionStyle`

**Output:** Rasterised heraldic texture (RGBA, power-of-two)

---

## Phase 6 — Lore (P5) + Integration

**The final depth layer** — in-world texts, cartography, and cosmetic detail — plus the integration milestone that wires everything together.

**Estimated total effort:** 8–12 developer-weeks  
**Dependency:** All previous phases complete

---

### `untexts` — Lore & Books

In-world books, scrolls, notes, and stone inscriptions via template-based text generation with era-appropriate vocabulary.

**Key params:** `Seed`, `Topic`, `Era`, `Author`, `Length`, `Format`

**Output:** Text string + optional book/scroll `Mesh`

---

### `unmaps` — Maps & Cartography

In-world cartographic maps (overworld, dungeon, treasure) as stylised 2D texture renders of world data.

**Key params:** `Seed`, `Region`, `Style`, `Accuracy`, `Age`, `Annotations`

**Output:** 2D texture (RGBA) + annotation struct

---

### `unfibers` — Hair & Fur

Procedural hair styles, beards, and creature fur via strand-based or card-based mesh generation.

**Key params:** `Seed`, `Length`, `Curl`, `Density`, `Species`, `Style`

**Output:** Strand/card mesh + texture

---

### 🏁 Integration Milestone

**All 34 generators wired together.** A single `WorldSeed` struct passed through a `WorldBuilder` orchestrator produces:

- Terrain heightmap (`unlands`)
- Biome splat map → material assignment (`unsurfaces`)
- Vegetation placement (`unflora`)
- Town layout → building meshes (`untowns` + `unbuildings`)
- Dungeon map (`undepths`)
- NPC characters with names, dialog, quests (`unpeople` + `unnames` + `unwords` + `unquests`)
- Creature population (`unbeasts` + `unmotions`)
- Weather and sky (`unskies`)
- Ambient audio (`unsounds` + `unmelodies`)

**Validation criterion:** A single seed value produces a complete, Kaiju-renderable game world in under 10 seconds on a single CPU core.

---

## Milestone Summary

| Phase | Generators | Effort | Status |
|-------|-----------|--------|--------|
| Phase 0 — Foundation | `unpeople` | Done | ✅ Complete |
| Phase 1 — Core World | `unlands`, `unbuildings`, `unflora`, `unsurfaces`, `unblades`, `unthings` | 12–16 wks | 🔴 Planned |
| Phase 2 — Alive World | `unbeasts`, `unmotions`, `unsounds`, `unquests`, `unwords`, `unnames` | 14–20 wks | 🔴 Planned |
| Phase 3 — Rich World | `undepths`, `untowns`, `unpaths`, `unstones`, `unwaters`, `unskies` | 14–18 wks | 🔴 Planned |
| Phase 4 — Equipped World | `ungarments`, `unwards`, `ungoods`, `untrinkets`, `unrides` | 10–14 wks | 🔴 Planned |
| Phase 5 — Atmospheric | `unmelodies`, `unvoices`, `unsparks`, `unspells`, `unmarks`, `uncrests` | 14–20 wks | 🔴 Planned |
| Phase 6 — Lore + Integration | `untexts`, `unmaps`, `unfibers` + wiring | 8–12 wks | 🔴 Planned |

---

*For the full generator reference, see [`GENERATORS.md`](GENERATORS.md).*
