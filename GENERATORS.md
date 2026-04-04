# GENERATORS.md — Canonical Reference Table

This is the authoritative catalog of all 34 generator entries in the `unsuite` family. Standalone generators are (or will be) independent Go modules under the `opd-ai` organisation; some entries may remain subsets of larger generators until extracted into their own modules.

**Status legend:**
- 🟢 Complete — released, CI green
- 🟡 Partial — reusable logic exists in the existing suite; needs extraction/adaptation
- 🔴 Planned — to be built

---

## Characters & Creatures

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 1 | **unpeople** | [opd-ai/unpeople](https://github.com/opd-ai/unpeople) | Characters | P0 | 🟢 Complete | Bipedal humanoid character meshes — 10 species, 20+ parameters | `Seed`, `Species`, `Build`, `Age`, `FaceParams` | `Mesh` (vertices, indices, skeleton) OBJ / glTF / GLB | — | Primitive-based procedural assembly; per-species morph tables; custom PRNG |
| 2 | **unbeasts** | opd-ai/unbeasts | Creatures | P1 | 🔴 Planned | Quadruped, flying, swimming animals & monsters | `Seed`, `BodyPlan`, `LimbCount`, `Size`, `SkinType`, `Archetype` | `Mesh` + skeleton + skin texture | `unpeople` mesh & export pipeline | Body-plan grammar; limb socket attachment; skin/scale/feather texture from noise |
| 3 | **unmotions** | opd-ai/unmotions | Characters | P1 | 🔴 Planned | Procedural locomotion animation cycles (walk, run, fly, swim, attack, idle) | `Skeleton`, `GaitType`, `Speed`, `Mass`, `AnimationType` | BVH joint keyframe sequence | `unbeasts` skeleton output | IK foot-planting; gait pattern library; blend weight generation |
| 4 | **ungarments** | opd-ai/ungarments | Characters | P3 | 🔴 Planned | Clothing & armor meshes that conform to `unpeople` body shapes | `Seed`, `BodyMesh`, `GarmentType`, `Material`, `Era`, `Coverage` | `Mesh` (fitted) + UV map | `unpeople` body mesh; `unsurfaces` textures | Shrink-wrap projection onto body mesh; seam-based UV unwrap |
| 5 | **unfibers** | opd-ai/unfibers | Characters | P5 | 🔴 Planned | Procedural hair styles, beards, and creature fur | `Seed`, `Length`, `Curl`, `Density`, `Species`, `Style` | Strand/card mesh + texture | `unpeople` scalp geometry | Strand simulation (rest pose); card mesh fallback for LOD; noise-driven curl |

---

## Terrain & World

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 6 | **unlands** | opd-ai/unlands | Terrain | P0 | 🟡 Partial | Multi-biome terrain heightmaps with erosion and optional cave geometry | `Seed`, `Biome`, `Scale`, `ErosionPasses`, `MoistureMap`, `CaveFrequency` | Heightmap (float32 grid) + splat map (RGBA) + cave mesh | `venture` `pkg/procgen/` terrain logic | Fractional Brownian motion; hydraulic & thermal erosion; biome blending via splat maps |
| 7 | **unflora** | opd-ai/unflora | Terrain | P0 | 🔴 Planned | Trees, bushes, grass tufts, flowers, mushrooms as 3D meshes | `Seed`, `Species`, `Climate`, `Age`, `Season`, `LODLevels` | `Mesh` array (per LOD) + billboard texture | `unpeople` export pipeline | L-system branching; space colonisation for canopy; per-season morph |
| 8 | **unstones** | opd-ai/unstones | Terrain | P2 | 🔴 Planned | Boulders, cliff faces, crystal formations, stalactites, stalagmites | `Seed`, `RockType`, `Weathering`, `Scale`, `ClusterCount` | `Mesh` + normal map | — | Voronoi fracture; noise displacement; crystal facet generation |
| 9 | **unwaters** | opd-ai/unwaters | Terrain | P2 | 🔴 Planned | River, lake, ocean, and waterfall surface meshes with flow maps | `Seed`, `BodyType`, `FlowRate`, `Depth`, `ShorelineComplexity` | Surface mesh + flow map (RG texture) | `unlands` heightmap | Heightmap intersection for shoreline; waterfall cascade mesh; flow map generation |
| 10 | **unskies** | opd-ai/unskies | Terrain | P2 | 🟡 Partial | Procedural skybox, clouds, rain, snow, fog, and lightning particle configs | `Seed`, `TimeOfDay`, `Season`, `Climate`, `StormIntensity` | Skybox cubemap texture + cloud mesh + particle emitter configs | `wyrm` weather ECS | Atmospheric scattering approximation; Worley noise clouds; particle config serialisation |

---

## Architecture & Structures

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 11 | **unbuildings** | opd-ai/unbuildings | Architecture | P0 | 🟡 Partial | Houses, shops, temples, castles, and ruins as 3D meshes with interior layout | `Seed`, `Style`, `Size`, `Era`, `Material`, `Function`, `Ruin` | `Mesh` (exterior + interior) + layout graph JSON | `venture` building generators | 2D footprint extrusion; roof style library; era/function-driven feature placement |
| 12 | **undepths** | opd-ai/undepths | Architecture | P2 | 🟡 Partial | Underground dungeons, natural caves, rooms, and corridors | `Seed`, `Depth`, `Theme`, `Difficulty`, `RoomCount`, `ConnectivityStyle` | Room graph + 3D mesh (walls, floors, ceilings) | `venture` dungeon logic | BSP room placement; graph connectivity validation; theme-driven decoration hooks |
| 13 | **untowns** | opd-ai/untowns | Architecture | P2 | 🟡 Partial | Town and city layouts: road networks, lot subdivision, districts, walls | `Seed`, `Population`, `Era`, `Terrain`, `Faction`, `WallStyle` | 2D layout map + 3D placement map for `unbuildings` | `venture` city logic | L-system road growth; Voronoi lot subdivision; zoning rules |
| 14 | **unthings** | opd-ai/unthings | Architecture | P0 | 🔴 Planned | Furniture and props: tables, chairs, barrels, crates, lanterns, signs | `Seed`, `ItemType`, `Era`, `Material`, `WearLevel` | `Mesh` + AABB collision box | `unpeople` export pipeline | Primitive composition grammar; material variation via `unsurfaces` hooks; AABB generation |
| 15 | **unpaths** | opd-ai/unpaths | Architecture | P2 | 🔴 Planned | Terrain-conforming roads, cobbled paths, and bridges | `Seed`, `RoadType`, `Terrain`, `Width`, `Material`, `BridgeStyle` | Spline + surface mesh | `unlands` heightmap | A* pathfinding on heightmap; spline-to-mesh extrusion; bridge span generation |

---

## Items & Equipment

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 16 | **unblades** | opd-ai/unblades | Items | P0 | 🔴 Planned | Swords, axes, bows, staves, and genre-dependent ranged weapons | `Seed`, `WeaponClass`, `Material`, `Length`, `Enchantment`, `Era` | `Mesh` + grip/impact attachment point metadata | `unpeople` export pipeline | Parametric cross-section library; spline-based blade extrusion; guard/pommel sub-mesh attachment |
| 17 | **unwards** | opd-ai/unwards | Items | P3 | 🔴 Planned | Shields, spell tomes, orbs, and bucklers | `Seed`, `Type`, `Material`, `Emblem`, `Size` | `Mesh` + attachment point | `unpeople` export pipeline; `uncrests` emblem texture | Parametric shape generation; emblem texture projection |
| 18 | **ungoods** | opd-ai/ungoods | Items | P3 | 🔴 Planned | Potions, scrolls, food, chests, bags, and keys | `Seed`, `ItemType`, `Rarity`, `Contents`, `LabelSeed` | `Mesh` + icon texture (64×64 RGBA) | `unpeople` export pipeline | Primitive shape composition; label decal generation; rarity-driven variation |
| 19 | **untrinkets** | opd-ai/untrinkets | Items | P3 | 🔴 Planned | Rings, amulets, crowns, and gems with procedural faceting | `Seed`, `Type`, `Metal`, `GemType`, `Enchantment` | `Mesh` (small-scale, high-detail) | `unpeople` export pipeline | Small-scale mesh generation; gem faceting algorithm; metal surface variation |

---

## Materials & Textures

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 20 | **unsurfaces** | opd-ai/unsurfaces | Materials | P0 | 🔴 Planned | Tileable PBR material sets: albedo, normal, roughness, metallic maps | `Seed`, `MaterialType`, `Resolution`, `TileScale`, `Weathering` | Texture atlas (RGBA) — albedo+normal packed, roughness+metallic packed | — | Perlin + Worley noise combination; seamless tiling; material-type preset tables |
| 21 | **unmarks** | opd-ai/unmarks | Materials | P4 | 🔴 Planned | Decals and graffiti: blood, cracks, runes, posters | `Seed`, `Type`, `Age`, `Faction`, `Size` | Decal texture (RGBA) + placement metadata | `unsurfaces` noise pipeline | Procedural stamp/pattern generation; age-driven fading; faction-themed motif library |
| 22 | **uncrests** | opd-ai/uncrests | Materials | P4 | 🔴 Planned | Heraldry and emblems: faction banners, shield crests, flags | `Seed`, `Faction`, `Colors`, `Charges`, `DivisionStyle` | Rasterised heraldic texture (RGBA, power-of-two) | — | Rule-based heraldic composition; tincture + ordinary + charge grammar; raster renderer |

---

## Audio

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 23 | **unsounds** | opd-ai/unsounds | Audio | P1 | 🟡 Partial | Sound effects: footsteps, impacts, ambient, magic, doors | `Seed`, `SoundClass`, `Material`, `Intensity`, `Duration` | PCM audio buffer (float32, mono/stereo, 44100 Hz) | `wyrm` audio system; `violence` procedural audio | Oscillator bank; ADSR envelope; material-aware filter presets |
| 24 | **unmelodies** | opd-ai/unmelodies | Audio | P4 | 🟡 Partial | Adaptive music tracks for combat, exploration, town, menu | `Seed`, `Genre`, `Mood`, `Tempo`, `Intensity`, `Duration` | PCM audio buffer or MIDI-like note stream | `wyrm` music logic | Rule-based algorithmic composition; chord progression tables; adaptive intensity mixing |
| 25 | **unvoices** | opd-ai/unvoices | Audio | P4 | 🔴 Planned | NPC vocal barks, grunts, laughter, pain sounds — no ML required | `Seed`, `Species`, `Age`, `Emotion`, `Pitch`, `BarkType` | PCM audio buffer | `unsounds` synthesis pipeline | Formant synthesis; prosody rules; species-specific vocal tract parameters |

---

## Narrative & Data

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 26 | **unquests** | opd-ai/unquests | Narrative | P1 | 🟡 Partial | Branching quest graphs with objectives, rewards, and failure states | `Seed`, `Difficulty`, `Faction`, `QuestType`, `ObjectiveCount` | Quest graph struct (JSON-serialisable) | `venture` quest logic | DAG-based quest generation; objective type library; reward scaling |
| 27 | **unwords** | opd-ai/unwords | Narrative | P1 | 🟡 Partial | NPC dialog trees with skill checks and faction-aware branches | `Seed`, `NPCPersonality`, `Topic`, `Faction`, `SkillChecks` | Dialog tree struct (JSON-serialisable) | `venture` dialog generators | Personality-driven tone tables; skill-check nodes; faction relation modifiers |
| 28 | **untexts** | opd-ai/untexts | Narrative | P5 | 🔴 Planned | In-world books, scrolls, notes, and stone inscriptions | `Seed`, `Topic`, `Era`, `Author`, `Length`, `Format` | Text string + optional `Mesh` (book/scroll) | `unnames` vocabulary; `unquests` lore hooks | Template-based text generation; era-appropriate vocabulary tables; named entity substitution |
| 29 | **unnames** | opd-ai/unnames | Narrative | P1 | 🔴 Planned | NPC names, place names, and fictional language fragments | `Seed`, `Species`, `Culture`, `NameType`, `Length` | String | — | Markov chain over phonotactic rule tables; place name prefix/root/suffix composition |
| 30 | **unmaps** | opd-ai/unmaps | Narrative | P5 | 🔴 Planned | In-world cartographic maps: overworld, dungeon, treasure maps | `Seed`, `Region`, `Style`, `Accuracy`, `Age`, `Annotations` | 2D texture (RGBA) + annotation struct | `unlands` heightmap; `undepths` room graph; `untowns` layout | Stylised rendering of world data; accuracy degradation for old/imprecise maps; annotation placement |

---

## VFX & Particles

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 31 | **unsparks** | opd-ai/unsparks | VFX | P4 | 🔴 Planned | Particle systems: fire, smoke, magic dust, sparks, blood, water splash | `Seed`, `EffectType`, `Intensity`, `ColorScheme`, `Duration` | Particle emitter config struct (JSON/binary) | — | Emitter parameter tables; colour gradient generation; lifetime/velocity curve encoding |
| 32 | **unspells** | opd-ai/unspells | VFX | P4 | 🔴 Planned | Magic spell VFX: casting visuals, projectile trails, impact effects | `Seed`, `Element`, `PowerLevel`, `School`, `CastStyle` | VFX graph struct + procedural textures | `unsparks` emitter configs; `unsurfaces` noise pipeline | VFX graph node composition; element-driven colour/motion rules; procedural texture generation |

---

## Vehicles

| # | Generator | Repo | Category | Priority | Status | Description | Key Params | Output Format | Reuses From | Technical Approach |
|---|-----------|------|----------|----------|--------|-------------|------------|---------------|-------------|-------------------|
| 33 | **unrides** | opd-ai/unrides | Vehicles | P3 | 🔴 Planned | Genre-dependent vehicles: carts, ships, hovercrafts, mechs | `Seed`, `VehicleClass`, `Era`, `Size`, `ArmorLevel` | `Mesh` + physics param struct + mount-point metadata | `unpeople` export pipeline; `wyrm` vehicle ECS | Parametric vehicle assembly grammar; era/class-driven component selection; physics param tables |
| 34 | ***(mounts)*** | *(subset of unbeasts)* | Vehicles | — | — | Horses, wolves, lizards, and other rideable creatures — a subset of `unbeasts` generation | `Seed`, `MountType`, `Saddle` | `Mesh` + mount-point annotations | `unbeasts` | Mount-point annotation on `unbeasts` output; saddle sub-mesh attachment |

---

## Summary by Priority

| Priority | Generators | Count |
|----------|-----------|-------|
| P0 — Core (ship-blocking) | `unpeople`, `unlands`, `unbuildings`, `unflora`, `unsurfaces`, `unblades`, `unthings` | 7 |
| P1 — Alive World | `unbeasts`, `unmotions`, `unsounds`, `unquests`, `unwords`, `unnames` | 6 |
| P2 — Rich World | `undepths`, `untowns`, `unpaths`, `unstones`, `unwaters`, `unskies` | 6 |
| P3 — Equipped World | `ungarments`, `unwards`, `ungoods`, `untrinkets`, `unrides` | 5 |
| P4 — Atmospheric | `unmelodies`, `unvoices`, `unsparks`, `unspells`, `unmarks`, `uncrests` | 6 |
| P5 — Lore | `untexts`, `unmaps`, `unfibers` | 3 |

---

## Summary by Status

| Status | Generators |
|--------|-----------|
| 🟢 Complete | `unpeople` |
| 🟡 Partial (logic in existing suite) | `unlands`, `unskies`, `unbuildings`, `undepths`, `untowns`, `unsounds`, `unmelodies`, `unquests`, `unwords` |
| 🔴 Planned (new) | All remaining generators not listed above |

---

*For phased delivery milestones and effort estimates, see [`ROADMAP.md`](ROADMAP.md).*  
*For overall project context and design principles, see [`README.md`](README.md).*
