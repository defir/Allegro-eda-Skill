# Allegro database and API patterns

Read only the sections relevant to the current task. Confirm exact signatures against the installed Cadence documentation because product tiers and releases differ.

## Contents

- Database traversal
- Geometry and keepout checks
- Units
- Selection and visibility
- Properties and Backdrill
- Reports and highlighting
- Forms and command structure

## Database traversal

### DiffPair, XNet, Net, Branch

`axlDBGetDesign()->diffpair` returns DiffPair group DBIDs. A DiffPair member can be a Net or an XNet-like group. Resolve members before accessing Net fields:

```lisp
if(memberObj->objType == "net" then
    nets = list(memberObj)
else
    if(memberObj->objType == "group" && memberObj->type == "XNET" then
        nets = memberObj->groupMembers
    else
        nets = nil
    )
)
```

Collect routed figures from every branch:

```lisp
foreach(netObj nets
    foreach(branch netObj->branches
        foreach(child branch->children
            when(child->objType == "via"
                unless(member(child vias)
                    vias = cons(child vias)
                )
            )
        )
    )
)
```

`net->nBranches` can exceed one for incomplete connectivity, stubs, multiple endpoints, or island shapes. Never use only `car(net->branches)` unless the requirement explicitly targets the first branch.

## Geometry and keepout checks

Choose an API based on the real invariant:

| Requirement | Appropriate approach |
|---|---|
| Find candidate shapes on a class/layer | `axlDBGetShapes("ROUTE KEEPOUT")` |
| Does a shape contain a Via center? | `axlGeoPointInShape(via->xy shape t)` |
| Does any object intersect a window? | `axlAddSelectBox` with saved/restored UI state |
| Does a full clearance disk fit? | Polygon construction/expansion and Boolean containment, or a documented sampling approximation |

`axlAddSelectBox` selects every qualified object intersecting its box. A Route Keepout touching the box edge can therefore produce a false “protected” result if the intended invariant is containment.

With `axlGeoPointInShape(point shape t)`, a point inside a shape void is treated as outside. Select the void behavior deliberately.

Use exact layer equality when policy requires `ROUTE KEEPOUT/ALL`; use the class query only when any Route Keepout subclass is valid.

## Units

Coordinates and numeric geometry values use active design units. Convert explicit engineering dimensions:

```lisp
radius = axlMKS2UU("30 mils")
```

Avoid hard-coded `30` when the requirement says 30 mil because an mm design would interpret it differently.

Use `axlMKSConvert` when converting between named systems or converting from design units to another unit.

## Selection and visibility

Prefer database APIs for noninteractive audits. If selection is unavoidable:

1. Save `axlVisibleGet()`.
2. Save both Find Filter lists using `axlGetFindFilter(nil)` and `axlGetFindFilter(t)`.
3. Save the current selection set when the workflow must preserve it.
4. Perform the selection.
5. Restore selection, filters, and visibility even on empty results.

Do not let correctness depend on zoom-dependent trap size from point-selection APIs.

## Properties and Backdrill

Read attached properties with:

```lisp
props = axlDBGetProperties(dbObj)
entry = assoc("BACKDRILL_MAX_PTH_STUB" props)
value = if(entry then cadr(entry) else nil)
```

Check the logical levels where the design may carry the property: DiffPair, XNet/member group, and Net. Determine whether the requirement concerns an attached property or an effective inherited constraint.

The API name is case-sensitive. Allegro 25.1 exports `axlBackdrillGet` (lowercase `d` in `drill`); `axlBackDrillGet` is a different, nonexistent symbol. Guard the exact documented name:

```lisp
if(isCallable('axlBackdrillGet) then
    axlMsgPut("Via backdrill API: enabled (axlBackdrillGet)")
    result = axlBackdrillGet(via)
else
    axlMsgPut("Via backdrill API: skipped; axlBackdrillGet is unavailable")
)
```

`axlBackdrillGet(via)` returns `nil` when the Via is not backdrilled or an error occurs. Otherwise it returns a disembodied property list. Documented fields include `electricalStub`, `holeSize`, `backdrillSize`, and `mfgStub`, so this access is valid after a non-nil result:

```lisp
backdrillData = axlBackdrillGet(via)
when(backdrillData
    stubValue = backdrillData->electricalStub
)
```

`electricalStub` is derived from the Net's `BACKDRILL_MAX_PTH_STUB` property. Do not confuse "the Net has a backdrill requirement" with "this Via has already been backdrilled": check attached properties for the former and API results for the latter.

If the API is absent, report once that only attached properties were checked. Always emit one enabled/skipped diagnostic during verification; otherwise a spelling error inside `isCallable` is indistinguishable from an unavailable API. Do not call a missing API repeatedly inside a loop under a printing `errset`, which floods the console.

## Reports and highlighting

Use `outfile`, `fprintf`, and `close` for stable text reports. Open them with `axlUIViewFileCreate` when Allegro-native coordinate review is desired.

Structure reports by action priority:

1. Highest-risk/action-required records.
2. Medium-risk/manual review.
3. Low-risk/informational.
4. Suppressed-rule summary.

Print group-level statistics once per group. Print child-specific coordinates and reasons only when they differ.

Highlight only the actionable subset when a large result set would hide important items. Avoid `axlDehighlightObject('all)` unless the user explicitly accepts clearing existing highlights.

## Forms and command structure

Register commands explicitly:

```lisp
axlCmdRegister("MyCommand" 'MyCommand)
```

Keep top-level evaluation minimal. Put work inside procedures so standalone load checks do not require an open design.

Use `let` for procedure-local state. Prefix helper procedures consistently to reduce collisions with other loaded SKILL packages.

For `.form` files, inspect the existing form declaration and callback contract before changing field names. Treat form field identifiers as an interface: changing them requires updating both the form and callbacks.
