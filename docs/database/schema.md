# Database schema

> DO NOT HAND-EDIT. Generated from `drift_schemas/app_database/drift_schema_v2.json` by `tools/db_diagram.dart`. Regenerate with `make db-diagram`.

## ER diagram — schema v2

Renders on GitHub and in VS Code Markdown preview.

```mermaid
erDiagram
  library_settings {
    INTEGER id PK "required"
    TEXT name "required, max 160"
    TEXT currency "required, AppCurrency"
    DATETIME created_at "required"
  }
  staff {
    TEXT id PK "required"
    TEXT name "required, max 120"
    TEXT email UK "required, max 254"
    TEXT password_hash "required"
    TEXT role "required, UserRole"
    TEXT status "required, UserStatus"
    DATETIME created_at "required"
  }
```

## Tables

### `library_settings`

- Source: `lib/features/settings/data/tables/library_settings.dart`
- Enforces `CHECK (id = 1)`.
- No outgoing foreign keys.

### `staff`

- Source: `lib/features/users/data/tables/staff.dart`
- No outgoing foreign keys.

