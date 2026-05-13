# Service Boundaries

Frontend domains are grouped by the four backend service boundaries from the
project architecture wiki.

| Boundary | Backend service | Frontend domains |
|---|---|---|
| platform | synapse-platform-svc | auth, billing, notifications, settings, admin |
| engagement | synapse-engagement-svc | community, gamification |
| knowledge | synapse-knowledge-svc | notes, graph, search |
| learning | synapse-learning-svc | cards |

`shared/features/dashboard` stays outside a single service boundary because it
aggregates multiple service domains.
