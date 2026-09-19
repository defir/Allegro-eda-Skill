# Testing and compatibility

## Validation levels

### 1. Static inspection

Check balanced delimiters, local variables, command registration, helper-name collisions, report paths, and whether optional APIs are guarded.

Static inspection cannot validate DBID fields or board behavior.

### 2. Standalone SKILL load

Use `cnskill.exe -nongraph` with a wrapper that stubs `axlCmdRegister`, loads the source, prints a marker, and exits. The bundled PowerShell script automates this.

This catches parser errors and top-level evaluation failures. It does not provide Allegro `axl*` runtime APIs or an active design database.

Keep top-level code limited to registration and definitions. Otherwise the standalone loader requires many unsafe stubs and loses value.

### 3. Allegro read-only load

When a license is available, start Allegro in non-graphic, safe, read-only mode with a known board and a startup script that loads the `.il` file. Capture stdout, stderr, and the journal.

Do not treat `No licenses available` as a source failure. State that runtime validation could not run.

### 4. Behavioral board test

Use a copy or read-only board containing controlled cases:

- A Net with multiple branches and a Via outside the first branch.
- DiffPair members represented as Net and XNet.
- Keepout covering the Via center.
- Keepout merely touching/intersecting the search area.
- Keepout with a void containing the Via.
- Metric and mil designs when distances are involved.
- Missing and present optional APIs.
- Empty result sets and report-file failures.

Compare counts, coordinates, highlights, and report grouping to expected values.

## Compatibility procedure

Before using an unfamiliar `axl*` function:

1. Search `<CDSROOT>/share/pcb/examples/skill/DOC/FUNCS/<function>.txt`.
2. Search shipped `.il` examples for realistic usage.
3. Verify the exact capitalization inside the document, not only its filename. Cadence documentation filenames can retain historical capitalization.
4. Run `scripts/check-allegro-api-names.ps1` when the installed documentation is available.
5. Check `isCallable('functionName)` or `fboundp('functionName)` when availability may vary.
6. Add a fallback that preserves correctness or clearly narrows the checked scope.
7. Log the enabled or degraded behavior once, not once per database object.

Documentation presence does not guarantee that every license tier exports the function.
`isCallable` returning `nil` also does not prove an API is unavailable: a case error such as `axlBackDrillGet` instead of `axlBackdrillGet` produces the same result.

## Diagnosing failures

### Undefined function repeated many times

Cause: a missing optional API is called inside a Via/Net loop, often under `errset(... t)`, which prints every error.

Fix: guard the call outside or inside the helper with `isCallable`; use a documented fallback.

### Some Vias never appear

Check complete branch traversal, XNet expansion, object-type filters, and deduplication. Print diagnostic counts by DiffPair, member, Net, branch, and Via before changing geometry logic.

### Missing Keepout is not reported

Check whether candidate intersection was mistaken for containment, whether another layer was accepted, whether a policy exclusion suppressed the Net, and whether the Net was ever collected.

### Valid Keepout is reported missing

Check shape type, layer, void handling, center-versus-full-clearance semantics, dynamic shape state, and database units.

### Allegro crashes or creates a minidump

Reduce to load-only, then one API family at a time. Avoid running UI APIs from unsupported batch contexts. Preserve the minidump and journal, but do not infer a source cause solely from their presence.

## Handoff statement

State validation precisely, for example:

```text
Standalone SKILL load passed. Allegro runtime validation was not run because no license was available. Verify on a board copy using command MyCommand and compare the generated report against the listed controlled cases.
```
