# unsuite — The Un-Series Procedural Asset Generator Suite

> A coordinated family of 34 pure-Go procedural generator libraries that together produce every asset needed for a complete 3D game — characters, creatures, terrain, buildings, weapons, materials, audio, narrative, VFX, and more. Zero external dependencies. Deterministic. The first 3D entry in the opd-ai procedural game suite, targeting the [Kaiju engine](https://kaijuengine.com).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Overview

[`unpeople`](https://github.com/opd-ai/unpeople) proved that **deterministic, stdlib-only procedural mesh generation works at scale**: 10 species, 20+ parameters, 4 export formats, <100 ms per character, 87% test coverage. Now we're expanding that proven pattern to cover **every asset category a 3D game needs** — terrain, vegetation, architecture, creatures, weapons, clothing, materials, audio, narrative, VFX, vehicles, and lore.

The goal: **a seed number and a set of parameters produce an entire game world.**

---

## Existing Procedural Game Suite

The existing opd-ai games are **Ebitengine-based 2D** titles. The un-series is the first part of the suite to move into **3D** territory, targeting the [Kaiju engine](https://kaijuengine.com):

| Repo | Engine | Description |
|------|--------|-------------|
| [venture](https://github.com/opd-ai/venture) | Ebitengine | 2D procedural RPG — source of reusable terrain, building, quest, and dialog logic |
| [violence](https://github.com/opd-ai/violence) | Ebitengine | Procedural raycaster — reusable audio and rendering pipeline |
| [velocity](https://github.com/opd-ai/velocity) | Ebitengine | Procedural racing game |
| [vania](https://github.com/opd-ai/vania) | Ebitengine | Procedural metroidvania — seed mixing, caching, and validation patterns |
| [way](https://github.com/opd-ai/way) | Ebitengine | Procedural road/path game |
| [where](https://github.com/opd-ai/where) | Ebitengine | Procedural exploration game |
| [whack](https://github.com/opd-ai/whack) | Ebitengine | Procedural action game |
| [wyrm](https://github.com/opd-ai/wyrm) | Ebitengine | Procedural first-person survival RPG |

---

## Design Principles

All 34 generators share the same architecture contract inherited from `unpeople`:

1. **Pure Go, zero external dependencies** — stdlib + custom PRNG only; no CGo, no vendored C libraries.
2. **Deterministic** — identical seed + params always produce bit-identical output across platforms and Go versions.
3. **Kaiju-compatible vertex layout** — native support for the [Kaiju engine](https://kaijuengine.com) mesh format; pluggable adapter for other engines.
4. **Export formats** — OBJ, glTF 2.0, GLB, binary where applicable.
5. **`<100 ms` generation time** per asset on modern hardware.
6. **Table-driven tests** covering every enum value and parameter range.
7. **CI** — `go vet`, `go test -race -cover`, codecov badge on every repo.
8. **Independent Go modules** — each generator is its own `go.mod`; import only what you need.

---

## Priority Tiers

| Tier | Label | Generators | Rationale |
|------|-------|-----------|-----------|
| **P0** | Core (ship-blocking) | `unlands`, `unbuildings`, `unflora`, `unsurfaces`, `unblades`, `unthings` | Terrain, buildings, vegetation, materials, weapons, and props are required before a 3D world can be rendered |
| **P1** | Alive World | `unbeasts`, `unmotions`, `unsounds`, `unquests`, `unwords`, `unnames` | NPCs and creatures need to move, make noise, give quests, and have names |
| **P2** | Rich World | `undepths`, `untowns`, `unpaths`, `unstones`, `unwaters`, `unskies` | Dungeons, cities, roads, geology, water, and sky complete the environment |
| **P3** | Equipped World | `ungarments`, `unwards`, `ungoods`, `untrinkets`, `unrides` | Characters need clothing, shields, consumables, jewelry, and vehicles |
| **P4** | Atmospheric | `unmelodies`, `unvoices`, `unsparks`, `unspells`, `unmarks`, `uncrests` | Music, voice, VFX, decals, and heraldry for atmosphere and polish |
| **P5** | Lore | `untexts`, `unmaps`, `unfibers` | In-world books, cartography, and cosmetic hair/fur — the final layer of depth |

---

## Generator Summary

See [`GENERATORS.md`](GENERATORS.md) for the full canonical reference table. Quick overview:

| # | Repo | Category | Priority | Description |
|---|------|----------|----------|-------------|
| 1 | [unpeople](https://github.com/opd-ai/unpeople) | Characters | P0 | Bipedal humanoid meshes (10 species) |
| 2 | unbeasts | Creatures | P1 | Quadruped/flying/swimming animals & monsters |
| 3 | unmotions | Characters | P1 | Procedural locomotion animation cycles |
| 4 | ungarments | Characters | P3 | Clothing & armor fitted to unpeople bodies |
| 5 | unfibers | Characters | P5 | Procedural hair, beards, and fur |
| 6 | unlands | Terrain | P0 | Multi-biome terrain heightmaps |
| 7 | unflora | Terrain | P0 | Trees, bushes, grass, flowers, mushrooms |
| 8 | unstones | Terrain | P2 | Boulders, cliffs, crystals, stalagmites |
| 9 | unwaters | Terrain | P2 | Rivers, lakes, oceans, waterfalls |
| 10 | unskies | Terrain | P2 | Skybox, clouds, rain, snow, fog, lightning |
| 11 | unbuildings | Architecture | P0 | Houses, shops, temples, castles, ruins |
| 12 | undepths | Architecture | P2 | Dungeons, caves, rooms, corridors |
| 13 | untowns | Architecture | P2 | Cities, settlements, road networks |
| 14 | unthings | Architecture | P0 | Furniture and props |
| 15 | unpaths | Architecture | P2 | Roads and bridges |
| 16 | unblades | Items | P0 | Swords, axes, bows, staves, guns |
| 17 | unwards | Items | P3 | Shields and off-hand items |
| 18 | ungoods | Items | P3 | Consumables and containers |
| 19 | untrinkets | Items | P3 | Jewelry and trinkets |
| 20 | unsurfaces | Materials | P0 | Tileable PBR material sets |
| 21 | unmarks | Materials | P4 | Decals and graffiti textures |
| 22 | uncrests | Materials | P4 | Heraldry and emblems |
| 23 | unsounds | Audio | P1 | Sound effects (footsteps, impacts, ambient) |
| 24 | unmelodies | Audio | P4 | Adaptive music tracks |
| 25 | unvoices | Audio | P4 | NPC vocal bark synthesis |
| 26 | unquests | Narrative | P1 | Branching quest graphs |
| 27 | unwords | Narrative | P1 | NPC dialog trees |
| 28 | untexts | Narrative | P5 | In-world books and inscriptions |
| 29 | unnames | Narrative | P1 | NPC names and fictional language fragments |
| 30 | unmaps | Narrative | P5 | In-world cartographic maps |
| 31 | unsparks | VFX | P4 | Particle systems (fire, smoke, sparks) |
| 32 | unspells | VFX | P4 | Magic and spell VFX graphs |
| 33 | unrides | Vehicles | P3 | Carts, ships, hovercrafts, mechs |
| 34 | *(mounts)* | Vehicles | — | Covered as a subset of `unbeasts` |

---

## Existing Suite Reuse

Before writing new code, extract and adapt logic already present in the existing suite:

| Existing Repo | Reusable Logic | Target Generators |
|---------------|---------------|-------------------|
| [venture](https://github.com/opd-ai/venture) | `pkg/procgen/` — terrain, buildings, entities, factions, quests, dialog | `unlands`, `unbuildings`, `untowns`, `unquests`, `unwords` |
| [wyrm](https://github.com/opd-ai/wyrm) | ECS systems for weather, audio, factions, economy, vehicles | `unskies`, `unsounds`, `unmelodies`, `unrides` |
| [violence](https://github.com/opd-ai/violence) | Raycasting renderer, procedural audio, combat | `unsounds`, rendering pipeline |
| [vania](https://github.com/opd-ai/vania) | Seed mixing, caching, validation patterns | Shared infrastructure for all generators |
| [unpeople](https://github.com/opd-ai/unpeople) | Primitive mesh assembly, OBJ/glTF/GLB export, skeleton, skinning | Architecture template for **all** mesh generators |

---

## How to Contribute

1. **Each generator lives in its own repo** under `opd-ai` (e.g., `github.com/opd-ai/unblades`).
2. **Follow the `unpeople` architecture pattern** — same package layout, same export interface, same test conventions.
3. **Open an issue here** in `unsuite` to claim a generator, then link your new repo in a PR that updates [`GENERATORS.md`](GENERATORS.md).
4. **Milestone tracking** is managed in [`ROADMAP.md`](ROADMAP.md).
5. All code is MIT licensed — match the license in your new repo.

---

## License

MIT — see [LICENSE](LICENSE).
