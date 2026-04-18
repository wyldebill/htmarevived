# Work Routing

How to decide who handles what for the Buffalo business tracker app.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Product scope, architecture, trade-offs | Cobb | MVP definition, feature sequencing, app architecture, review gates |
| Flutter UI, navigation, screen composition | Ariadne | Home screen, business detail page, add/edit flows, theming |
| Firebase, repositories, app services | Arthur | Firebase setup, Firestore models, repository layer, sync behavior |
| Business catalog structure and visit tracking UX | Saito | Business fields, categories, filters, stats, Buffalo-specific discovery flows |
| Code review | Cobb | Review implementation direction, reject weak architecture, enforce decisions |
| Testing | Eames | Widget tests, repository tests, edge cases, regression checks |
| Session logging | Scribe | Automatic — never needs routing |
| Work monitoring | Ralph | Backlog checks, follow-up loops, idle/watch behavior |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Cobb |
| `squad:cobb` | Pick up issue and complete the work | Cobb |
| `squad:ariadne` | Pick up issue and complete the work | Ariadne |
| `squad:arthur` | Pick up issue and complete the work | Arthur |
| `squad:saito` | Pick up issue and complete the work | Saito |
| `squad:eames` | Pick up issue and complete the work | Eames |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, **Cobb** triages it and assigns the right `squad:{member}` label.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the inbox for untriaged work.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`.
3. **Quick facts → coordinator answers directly.**
4. **Primary concern wins** when more than one agent could handle a task.
5. **"Team, ..." → fan-out.** Use Cobb for coordination, plus Ariadne, Arthur, Saito, or Eames as needed.
6. **Testing starts early.** Eames should be brought in while features are being designed or built.
