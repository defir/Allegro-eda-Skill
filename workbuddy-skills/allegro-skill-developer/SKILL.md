---
name: allegro-skill-developer
description: This skill should be used when creating, modifying, reviewing, debugging, or validating Cadence Allegro PCB Editor SKILL code, including .il commands, database queries, forms, reports, geometry checks, visibility/selection behavior, XNet/DiffPair traversal, and version-dependent axl APIs. It is not for generic Lisp or non-Allegro PCB automation.
agent_created: true
disable: false
---

# Allegro SKILL Developer

Produce maintainable Allegro PCB Editor SKILL code and evidence-backed diagnoses. Prefer database APIs over UI-dependent selection, verify API behavior against the installed Cadence documentation, and distinguish static validation from execution in a licensed Allegro session.

## Route the task

- For code creation or modification, follow **Implementation workflow** below.
- For bug diagnosis or review, inspect the complete data path and read [references/database-and-api-patterns.md](references/database-and-api-patterns.md).
- For forms, reports, geometry, selection, units, or compatibility questions, read the matching sections in [references/database-and-api-patterns.md](references/database-and-api-patterns.md).
- For validation, load failures, undefined functions, crashes, or version differences, read [references/testing-and-compatibility.md](references/testing-and-compatibility.md).
- For a new command, copy or adapt [assets/allegro-command-template.il](assets/allegro-command-template.il) instead of recreating registration, local scope, reporting, and error handling.

## Implementation workflow

1. Inspect the target `.il`, related `.form`, logs, command registration, and calling context before editing.
2. Locate the installed Cadence root. Prefer its function documentation and shipped examples over memory or web snippets:

   ```text
   <CDSROOT>/share/pcb/examples/skill/DOC/FUNCS
   <CDSROOT>/share/pcb/examples/skill
   ```

   For edited files, run `scripts/check-allegro-api-names.ps1` to catch case-only `axl*` spelling errors against the installed documentation.

3. Confirm the database object hierarchy involved. Treat DiffPair members as possible Net or XNet objects; traverse every Net branch when collecting routed figures.
4. Define the invariant being checked. For geometry, distinguish "near", "intersects", "contains the center", and "fully encloses a clearance region"; do not substitute one for another.
5. Implement with procedure-local variables via `let`, guarded optional APIs, deterministic database access, and explicit reports.
6. Preserve user state when UI APIs are unavoidable: visibility, find filter, selection set, and highlights. Avoid changing those states for read-only audits when a database API exists.
7. Validate proportionally using [references/testing-and-compatibility.md](references/testing-and-compatibility.md). Report exactly which validation ran and what could not run.
8. Explain command name, generated files, assumptions, exclusions, and known compatibility limits.

## Non-negotiable Allegro invariants

- Traverse all `net->branches`; never assume `car(net->branches)` represents the whole net.
- Handle XNet membership before reading Net-only fields such as `branches`.
- Use `axlMKS2UU("30 mils")` or another explicit conversion for physical distances; bare numbers are design units.
- Use direct database queries such as `axlDBGetShapes` for audits. Do not make correctness depend on visible layers, zoom, trap size, selection direction, or the current Find Filter.
- Remember that `axlAddSelectBox` returns objects intersecting the box. It does not prove that a shape contains a point.
- Use `axlGeoPointInShape` when the invariant is point containment, and account for voids deliberately.
- Guard optional/version-dependent functions with `isCallable` or `fboundp` before invoking them. `errset` is not a substitute when repeated undefined-function messages would flood the console.
- Treat `isCallable('name) == nil` as ambiguous until the exact case-sensitive spelling has been checked. During verification, log once whether each optional API is enabled or skipped.
- Deduplicate DBIDs before reporting or modifying objects.
- Keep project policy (network-name exclusions, severity thresholds, and layer rules) separate from database traversal and geometry logic.
- Prefer native Allegro text reports for coordinate-oriented review unless the user explicitly requests another format.
- Never claim runtime verification when only the standalone SKILL engine loaded the file.

## Review checklist

Check for these recurring defects:

- Only the first branch or first group member is inspected.
- XNet is treated as Net.
- A nearby/intersecting keepout is treated as covering a Via.
- Mil/mm conversion is omitted.
- Layer matching is broader or narrower than the stated rule.
- A missing API is called inside a large loop.
- Variables leak into global scope.
- The script consumes its result list while reporting.
- Visibility, filters, selection, or highlighting are not restored.
- The report repeats family-level facts for every child item or buries the highest-risk results.
- Name-based policy silently overrides a stronger electrical/property requirement.

## Validation helper

On Windows, run the bundled loader check:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-allegro-skill.ps1 -SkillFile path\to\command.il
```

Treat this as syntax/top-level-load validation only. It stubs `axlCmdRegister`; it does not provide a board database or prove runtime correctness.

When Cadence documentation is installed, also check `axl*` capitalization:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-allegro-api-names.ps1 -SkillFile path\to\command.il
```

This check reports case-only mismatches as errors. Names absent from the local documentation are reported separately because they may be release-specific or project-defined wrappers.

## Response expectations

- Lead with the diagnosed cause or completed behavior.
- Cite concrete file locations and relevant procedures or lines.
- Separate confirmed defects from design-policy choices.
- When a Cadence license or target board is unavailable, provide a concise in-editor verification procedure rather than guessing.
- For generated code, include a user-visible command, useful messages, a stable report location, and safe behavior when no matching objects exist.
