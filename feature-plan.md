|---|---------|------------|
| 1 | **Staff auth** | Already live. Nothing to do. |
| 2 | **Library profile** | Read/write `library_settings` on the settings screen (name + currency exist; branch/address/hours only if you want them). |
| 3 | **Loan rules** | Add rule columns to `library_settings` — loan period, borrowing limit, renewals, fine per day, grace days, max fine. Wire `LoanRulesPage`. |

---

## 2. Catalogue

| # | Feature | What to do |
|---|---------|------------|
| 4 | **Titles** | `titles` table. List, detail, add/edit. Author as plain text for now. |
| 5 | **Copies** | `copies` table (barcode, shelf, condition, status, → title). List + add from title detail. |
| 6 | **Catalog overview** | Point dashboard stats at real title/copy counts (replace placeholders). |
| 7 | **Authors** | `authors` table + link from titles. Author list/detail. *Optional until you need proper author records.* |
| 8 | **Label print** | No new table — print from `copies`. |

---

## 3. Members

| # | Feature | What to do |
|---|---------|------------|
| 9 | **Members** | `members` table. List, detail, add/edit. Card number, category, status, contact. |

---

## 4. Circulation (desk is usable after this block)

| # | Feature | What to do |
|---|---------|------------|
| 10 | **Loans** | `loans` table — copy, member, issued, due, returned, renewals. |
| 11 | **Check-out** | Scan member + barcode → create loan, mark copy on loan. |
| 12 | **Return** | Scan barcode → close loan, copy back on shelf. |
| 13 | **Circulation list** | Open loans — due / overdue filters. |

**Stop here and use the app for real.** Add title → copy → member → check out → return.

---

## 5. Circulation extras

| # | Feature | What to do |
|---|---------|------------|
| 14 | **Fines** | `fines` table — amount, reason, status, member, optional loan. Fine list + pay/waive. |
| 15 | **Reservations** | `reservations` table — member, title, queue, hold shelf expiry. |

---

## 6. Staff & settings

| # | Feature | What to do |
|---|---------|------------|
| 16 | **Staff accounts** | Wire user list to `staff` — add/disable accounts (table already exists). |
| 17 | **Roles** | No new table — `UserRole` on staff. Roles screen is reference/editing the enum labels. |
| 18 | **Appearance** | Theme only — no database. |
| 19 | **Backup** | Export/import the `.sqlite` file — no new tables. |
| 20 | **Sync** | Skip for now — local-first; no server in scope. |

---

## 7. Read-only / aggregate screens

Wire these **after** the tables they read exist. No new schema.

| # | Feature | Needs |
|---|---------|--------|
| 21 | **Dashboard** | Loans, copies, members, fines — counts + recent activity. |
| 22 | **OPAC** | Titles + copy availability — public search, same data as catalogue. |
| 23 | **Reports** | Loans (+ fines) — aggregates, top titles/members, exports later. |

---

## Quick reference — shell order vs build order

Shell nav (shift order): Dashboard → Catalog → Circulation → Members → OPAC → Reports → Staff → Settings.

**Build order** (dependency order): Settings (rules) → Catalog (titles, copies) → Members → Circulation (loans, checkout, return) → Fines & reservations → Staff UI → Dashboard / OPAC / Reports.

---

## Ignore until you need it

- **Sync** — not in v1
- **Authors** — can wait until titles with a text author feel tight
- **Label print** — nice-to-have after copies work
- **Reports PDFs** — after reports read real data
