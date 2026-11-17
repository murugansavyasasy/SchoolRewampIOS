# App Blueprint — School Chimes

This is documentation only; no source files were changed. It has everything needed to recreate this app under a different name, either as a new white-label flavour or as a new build against the same backend contract.

| File | What it covers |
|---|---|
| `APP_WORKFLOW.md` | Users, roles (p1–p5, parent), launch/login/role selection, home, menu-ID router, every module's flow, push, errors |
| `BACKEND_ARCHITECTURE.md` | Hosts, service modules, token and tenancy model, targeting data pattern, uploads, push, integrations, minimum backend |
| `BACKEND_API_REFERENCE.md` | Every endpoint (234): path, method, host, request fields, response model and the screens that use it |
| `DATA_MODELS.md` | All 474 response/request models with JSON field names and types |
| `REBRAND_GUIDE.md` | Step-by-step new-name app (flavour or rebuild), secrets to replace, test checklist |

**Read in this order:**

1. `APP_WORKFLOW.md`
2. `BACKEND_ARCHITECTURE.md`
3. `REBRAND_GUIDE.md`
4. Use the API reference and the data models as lookups.

**How these were made:**

- The endpoints and models were extracted from the Swift source.
- Anything not visible in the app, such as server internals, is marked as inferred (🔶).
- No credentials or keys are included.

The related UI/UX specs are in `docs/ui-ux-redesign/`.
