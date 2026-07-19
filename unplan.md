You are a senior Go systems engineer planning a procedural asset generator. You are given the documentation (or lack thereof) for one generator in the unsuite suite (a collection of 3D procedural content tools for the Kaiju engine).

Design Principles (must be reflected in the plan):
- Interface-first, type-safe design: define clear interfaces and structs before any implementation
- Clear over clever: straightforward, readable code; no premature optimization
- DRY and KISS: no duplication, minimal branching, keep each function single-purpose
- Pure Go stdlib only; deterministic; <100 ms per asset target

Context: The unsuite architecture (proven by `unpeople`):
- Package layout: generator/, mesh/, export/, params/
- Export pipeline: OBJ, glTF 2.0, GLB, binary
- Testing: table-driven over all enum values, golden-file mesh regression
- CI: go vet, go test -race -cover, codecov

**Status Legend:**
- 🟢 Complete — released, CI green
- 🟡 Partial — reusable logic exists in the existing suite; needs extraction/adaptation
- 🔴 Planned — to be built

**Phase Mapping:**
Phase 0 (Foundation): unpeople
Phase 1 (Core World): unlands, unbuildings, unflora, unsurfaces, unblades, unthings
Phase 2 (Alive World): unbeasts, unmotions, unsounds, unquests, unwords, unnames
Phase 3 (Rich World): undepths, untowns, unpaths, unstones, unwaters, unskies
Phase 4 (Equipped World): ungarmments, unwards, ungoods, untrinkets, unrides
Phase 5 (Atmospheric): unmelodies, unvoices, unsparks, unspells, unmarks, uncrests
Phase 6 (Lore + Integration): untexts, unmaps, unfibers + final wiring

Task: Given the documentation below, produce a concise development roadmap for this specific repo.

INPUT (documentation for <repo-name>):
<INSERT REPO README OR EQUIVALENT HERE>

First, assess the current state:
- Is this repo a placeholder/template (no go.mod, no code, or just stubs)?
- Does it already have a go.mod, package layout, and implementation?
- Does it have a README and any docs (docs/)?
- Are there any tests or CI workflows?

Then produce a phased plan:

1. **Repo & Purpose** – one sentence: what this generator does and what it produces.
2. **Phase & Dependencies** – which phase it belongs to and any prerequisites.
3. **Work required** – if the repo is a template/placeholder, explicitly state that both documentation and implementation are needed. If it already has code/docs, note what is missing.
4. **Effort Estimate** – give a range (e.g., 6–9 weeks).
5. **Implementation Checklist** – a checklist of 6–9 concrete, ordered items. Each item should be a short phrase (e.g., "Define `Generator` interface and `Params` struct").
6. **Validation Criteria** – 3–5 concrete, measurable checks.
7. **Integration Notes** – 1–2 bullets on how this repo's output feeds into other generators.

Keep the tone technical and direct. No fluff.