# Architecture

The design pattern this project follows and how files are organized for it.

<!-- FILL INSTRUCTIONS (delete this block when done)
- A human sets the Pattern table. The AI never chooses or changes the pattern.
- Existing project: name the pattern the code already follows and verify every path against the repository.
- Name one established pattern (MVC, MVVM, layered, hexagonal, clean, feature-sliced, etc.). Do not blend or invent one.
- Use the pattern's standard terms for parts. The {e.g.} values below show MVC; replace them.
- State rules, not descriptions. Unknown value: write `TODO({owner}): {question}`. Do not guess.
- Delete sections that do not apply. Add no sections. Max 80 lines.
-->

## Pattern

Set by a human. If blank, stop and ask. Do not choose one.

| Setting | Value |
|---|---|
| Pattern | {e.g. MVC} |
| Organized by | {layer or feature} |

All code follows this pattern. Do not introduce a second one.

## Parts

Every source file belongs to exactly one part.

| Part | Does | Must not |
|---|---|---|
| {e.g. Model} | {e.g. Holds data, business rules, and persistence} | {e.g. Know about requests, responses, or views} |
| {e.g. View} | {e.g. Renders data it is given} | {e.g. Contain business rules or query data} |
| {e.g. Controller} | {e.g. Reads the request, calls models, selects a view} | {e.g. Contain business rules or query the database directly} |
| {part} | {responsibility} | {prohibition} |

## Structure

Do not add, move, or rename directories.

```
{root}/
  {e.g. models/}        {part: Model}
  {e.g. views/}         {part: View}
  {e.g. controllers/}   {part: Controller}
  {e.g. routes/}        {maps URLs to controllers}
  {e.g. config/}        {settings, no logic}
  {e.g. tests/}         {mirrors the source tree}
```

## Where things go

| To add | Part | Put it in | Name it |
|---|---|---|---|
| {e.g. Business rule} | {Model} | `{models/}` | `{user.model.ts}` |
| {e.g. Database query} | {Model} | `{models/}` | `{user.model.ts}` |
| {e.g. Request handler} | {Controller} | `{controllers/}` | `{user.controller.ts}` |
| {e.g. Page or template} | {View} | `{views/users/}` | `{show.html}` |
| {e.g. URL mapping} | {Routing} | `{routes/}` | `{user.routes.ts}` |
| {e.g. Input validation} | {part} | `{path}` | `{pattern}` |
| {e.g. Call to an external service} | {part} | `{path}` | `{pattern}` |
| {e.g. Shared helper} | {part} | `{path}` | `{pattern}` |
| {e.g. Test} | {same as source} | `{path}` | `{pattern}` |

If nothing fits, stop and ask. Do not create a new location or a new part.

## Dependencies

| Part | May use | Must not use |
|---|---|---|
| {e.g. Controller} | {Model, View} | {Database driver} |
| {e.g. View} | {Data passed by the controller} | {Model, Controller} |
| {e.g. Model} | {Other models, database} | {Controller, View} |

- No circular imports.
- {e.g. Import a part only through its public exports.}

## Request flow

Every request follows this path. Do not skip a step.

```
{e.g. Route -> Controller -> Model -> Controller -> View -> Response}
```

## Adding a feature

Create or change files in this order.

1. {e.g. Model: data and rules}
2. {e.g. Controller: handler that calls the model}
3. {e.g. View: output for the handler}
4. {e.g. Route: URL to the handler}
5. {e.g. Tests: one per file above}