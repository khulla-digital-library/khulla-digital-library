# Khulla Digital Library
## User Manual

**Version 1.0.0** · Applies to Khulla Digital Library 1.0.0 and later 1.0.x releases

---

> **How to use this manual**
>
> Sections 1–4 are for the person setting the library up for the first time. Sections 5–10 are for everyone who works the desk — read section 9 (Circulation) if you read nothing else. Sections 11–13 are for the administrator. Section 14 onward is reference material to look things up in, not to read straight through.

---

## Table of contents

1. [About Khulla](#1-about-khulla)
2. [Before you begin](#2-before-you-begin)
3. [First-run setup](#3-first-run-setup)
4. [Signing in](#4-signing-in)
5. [Getting around](#5-getting-around)
6. [Setting up the library](#6-setting-up-the-library)
7. [Building the catalogue](#7-building-the-catalogue)
8. [Members](#8-members)
9. [The circulation desk](#9-the-circulation-desk)
10. [Dashboard and reports](#10-dashboard-and-reports)
11. [Backup, restore and erase](#11-backup-restore-and-erase)
12. [Appearance and About](#12-appearance-and-about)
13. [Working routines](#13-working-routines)
14. [Reference tables](#14-reference-tables)
15. [Troubleshooting](#15-troubleshooting)
16. [Frequently asked questions](#16-frequently-asked-questions)
17. [Glossary](#17-glossary)
18. [Appendices](#18-appendices)

---

# 1. About Khulla

## 1.1 What Khulla is

Khulla Digital Library is a library management system for schools, colleges and community libraries. It handles the whole working cycle of a lending library:

- a **catalogue** of the works the library holds and the physical copies of each;
- a **register** of the members who borrow them;
- a **circulation desk** that checks copies out, takes them back, renews loans, queues holds and prices overdue fines;
- **reports** on what the library did over a period and what it holds today;
- **staff accounts** with roles, so the record says who did what.

It is open source and free to use.

## 1.2 Local-first: what that means for you

**Khulla runs entirely on the computer it is installed on.** There is no server to rent, no account to create with anyone, and no internet connection required. The whole catalogue — every title, copy, member, loan and fine — lives in a single database file on that machine.

This has three consequences you need to understand before you start.

| | |
| --- | --- |
| **The library keeps working when the internet does not.** | A power cut at the exchange, a cable cut in the street, an unpaid bill — none of it stops the desk. |
| **Nothing you type leaves the machine.** | Member names, addresses and borrowing histories are not uploaded anywhere. Nobody but the people with accounts on this computer can read them. |
| **The backup is your responsibility, and it is not optional.** | Nobody else holds a copy of your catalogue. If this computer is stolen, dropped or its disk fails, the library's records are gone unless you exported a backup. **See [section 11](#11-backup-restore-and-erase).** |

> ⚠️ **Read this twice.** A local-first system trades a monthly fee for a weekly habit. The habit is the export. A library that has never exported a backup is one hardware fault away from losing every record it has.

## 1.3 One installation, one library

Each installation of Khulla manages one library's catalogue. Two branches that want separate catalogues run two installations. There is no built-in merging of one catalogue into another.

## 1.4 Who this manual is for

| You are | Read |
| --- | --- |
| Setting the system up for the first time | Sections 2, 3, 6, then 11 |
| Working the counter — checking books in and out | Sections 4, 5, 9, 15 |
| Cataloguing new stock | Sections 5, 7 |
| Running the library, answering to a committee | Sections 6, 10, 11, 13, 14 |

---

# 2. Before you begin

## 2.1 What you need

**A computer.** Khulla runs on:

| Platform | Notes |
| --- | --- |
| **Windows** | The primary target. Recommended for a desk machine. |
| **Web browser** | Runs in a recent Chrome, Edge or Firefox. The catalogue is stored inside the browser's own storage on that device — see the warning below. |
| **Linux** | Builds and runs from the same source. |
| **macOS, Android, iOS** | Build from the same source; not the primary targets. |

> ⚠️ **A note on the web version.** In a browser, the catalogue lives in that browser's storage on that device. Clearing site data, browsing in a private window, or using a different browser means a different (or empty) catalogue. For a real library's live records, install the desktop version. Use the web version for demonstration, evaluation or a read-only terminal.

**Hardware that helps but is not required:**

| Item | What it is for |
| --- | --- |
| **Handheld barcode scanner** (USB, keyboard-emulation type) | Scanning copies at the desk instead of typing barcodes. Any scanner that behaves like a keyboard and sends Enter after the code works — Khulla needs no driver and no configuration. |
| **Label printer or a sheet printer** | Printing spine labels and barcode stickers for new copies. |
| **An external drive or USB stick** | Holding your backup files somewhere other than this computer. |

## 2.2 Two ways the app is built

Khulla ships in two flavours:

- **Production** — what you install and run the library on. It opens the real catalogue.
- **Development** — used by people working on Khulla itself. It opens a **separate** database, so experiments never touch real records.

If you installed Khulla normally, you are running production and can ignore this. If you were given a development build, be aware that anything you catalogue in it is in a different file and will not appear in the production app.

## 2.3 Language

Khulla ships in **English** and **Nepali**. It follows your operating system's language automatically — there is no language setting inside the app in this version. To use Nepali, set the computer's display language to Nepali.

---

<!-- SCREENSHOT: The Khulla desktop icon / installer welcome screen. Caption: "Installing Khulla on Windows." -->

# 3. First-run setup

The very first time Khulla opens on a computer, there is no library yet, so it goes straight to setup instead of a sign-in screen. Setup is three steps and takes about five minutes.

> **Who should do this?** Whoever will be the library's administrator. The account created here is the first administrator account and it cannot be created twice.

<!-- SCREENSHOT: Onboarding step 1 — "Set up your library". Caption: "Step 1 of 3: naming the library and choosing its currency." -->

## 3.1 Step 1 — Name the library

| Field | What to enter |
| --- | --- |
| **Library name** | What the library calls itself, e.g. *Kathmandu Community Library*. This appears in the app and on printed material. |
| **Currency** | The currency every fine, fee and deposit will be shown in. |

> **About the currency.** The currency setting changes how amounts are **displayed** — the symbol, its position, the digit grouping. It never converts amounts already recorded. Choosing the right one now saves confusion later; changing it in a year will not rewrite last year's fines into a new currency.

Press **Continue**.

## 3.2 Step 2 — Create your administrator account

<!-- SCREENSHOT: Onboarding step 2 — "Your administrator account". Caption: "Step 2 of 3: the first administrator account." -->

| Field | What to enter |
| --- | --- |
| **Full name** | Your name. It is shown against every action you take at the desk. |
| **Email** | Your sign-in identifier. It does not need to be a working mailbox — Khulla never sends email — but it must be unique and you must remember it. |
| **Password** | Choose something you will remember. The minimum length is shown on screen. |
| **Confirm password** | Type it again. |

Email addresses are not case-sensitive: `Ram@Lib.np` and `ram@lib.np` are the same account.

Press **Continue**.

## 3.3 Step 3 — Save your recovery codes

<!-- SCREENSHOT: Onboarding step 3 — the recovery codes list with the confirmation checkbox. Caption: "Step 3 of 3: recovery codes are shown once and never again." -->

Khulla now shows a list of one-time **recovery codes**, formatted like `7K2M-9QWP-4XNH-B6RT`.

> 🔴 **This is the only time these codes are ever shown.** There is no "show them again" button anywhere in the app. They are the only way back into the library if the administrator password is forgotten.

Each code can reset the administrator password **once**, and is then used up.

Save them now, by any of these means:

- **Copy codes** — copies them to the clipboard, to paste into a password manager.
- **Download** — saves them as a file. Move that file somewhere safe; do not leave it in Downloads on the same computer.
- **Print the page** or write the codes on paper and lock it in the library's cash box or safe.

> ⚠️ **Where not to keep them:** a text file on the library desktop, an unlocked drawer beside the machine, or a sticky note on the monitor. Anyone holding a code can set a new administrator password and take over the system.

Tick **"I have saved these codes somewhere I can find them"**, then press **Create library**.

## 3.4 The alternative: restoring instead of setting up

If you are reinstalling Khulla, or moving the library to a new computer, do **not** work through setup. On the first setup screen, choose **"Restore from a backup instead."**

Khulla asks you to confirm, then takes a backup file and rebuilds the whole library from it — catalogue, members, loans, staff accounts and all. Anything typed into the setup screen is discarded, and the app restarts when it finishes.

See [section 11.2](#112-restoring-from-a-backup).

---

# 4. Signing in

<!-- SCREENSHOT: The sign-in screen. Caption: "Staff sign in with their own account, so the record says who did what." -->

After setup, Khulla opens on the sign-in screen. Enter your email address and password, and press sign in.

## 4.1 Every person gets their own account

> ⚠️ **Do not share one login between the staff on a shift.** Every checkout, return, waived fine and deleted record is stamped with the account that did it. A shared login makes a waived fine impossible to trace back to a person, and that is exactly the record an auditor or a committee will ask for. Creating extra accounts is free and takes thirty seconds — see [section 6.4](#64-staff-accounts).

## 4.2 Signing out

Use the account control at the bottom of the navigation rail (or in the **More** sheet on a phone) and choose **Sign out**. Sign out at the end of a shift if the machine is in a public area.

## 4.3 Forgotten password

**If you are not the first administrator:** ask an administrator to reset it for you. They do this from **Staff → the account → Reset password**. No recovery code is involved.

**If you are the first administrator and nobody else can help,** use a recovery code from setup:

1. On the sign-in screen, choose the password-reset link.
2. Enter your **email address** and one **unused recovery code**.
3. Choose a **new password** and confirm it.

That code is now used up and cannot be used again. The reset only works for an **active** account.

> **If you have lost both the password and the recovery codes,** there is no way in. This is deliberate — a back door into a library's member records is a security hole, not a feature. Your remaining option is to restore a backup onto a fresh installation and set the library up again from there.

---

# 5. Getting around

Khulla adapts to the size of the window it is in. The layout differs, but every screen is reachable on every device.

<!-- SCREENSHOT: The app on a desktop window, rail extended, dashboard showing. Annotate: (1) navigation rail, (2) top bar with title and breadcrumbs, (3) section actions, (4) rail footer with search/notifications/theme/account. Caption: "The shell on a desktop window." -->

## 5.1 The navigation rail

On a desktop or tablet window, the sections run down the left-hand side. From about 1200 pixels wide, the rail widens to show labels beside the icons.

The eight sections, in order:

| Section | What lives there |
| --- | --- |
| **Dashboard** | The shift's starting point: counts, recent activity, quick actions. |
| **Catalogue** | Titles, copies, labels and barcodes. |
| **Circulation** | Loans, check out, return, reservations, fines. |
| **Members** | Borrower records and their standing. |
| **OPAC** | The public catalogue. |
| **Reports** | Statistics and CSV exports. |
| **Staff** | Staff accounts and roles. |
| **Settings** | Library profile, loan rules, appearance, backup. |

> **You may not see all eight.** The rail only shows sections your role can open. A desk assistant sees fewer than an administrator. See [section 14.1](#141-roles-and-permissions).

## 5.2 On a phone

<!-- SCREENSHOT: The app at phone width, bottom nav bar visible, and the "All sections" sheet open. Caption: "At phone width the four main sections sit in a bottom bar; the rest live behind More." -->

Below roughly 600 pixels wide, the rail is replaced by a bar across the bottom holding the four main destinations. Everything else lives behind **More**, which opens an **All sections** sheet.

## 5.3 The top bar

Across the top of every screen sits the title, the breadcrumb trail showing where you are, and the actions that belong to the current section (for example **Add a title** on the titles list). The top bar stays put while the page scrolls underneath it.

## 5.4 The rail footer

At the foot of the rail — or in the **More** sheet on a phone — are the controls that belong to the whole app rather than to one section: search, notifications, the light/dark switch, and your account.

## 5.5 Searching

Most list screens have their own search box, and each searches the fields that matter to it:

| Screen | Searches |
| --- | --- |
| Titles | Title, author, ISBN |
| Copies | Barcode, title, shelf |
| Members | Name, card number, phone |
| Loans | Member, title, barcode |
| Reservations, Fines | Member or title |
| Staff | Name or email |

Search matches **partial words anywhere in the field**, so typing `sapiens`, `harari` or part of an ISBN all find the same book. It is designed to stay fast on a catalogue of tens of thousands of titles.

## 5.6 Filters, empty states and errors

Lists carry filter chips — *With loans*, *Owes fines*, *Suspended*, *On loan* and so on. When a filter or search hides everything, the screen says **No matches** and offers **Clear filters**. When a list is genuinely empty, it says so and tells you what to do first — *"Catalogue the first work and its copies, and the library can start lending."*

If something goes wrong, Khulla shows a plain message and a **Try again** button rather than a crash. The messages are listed in [section 15](#15-troubleshooting).

## 5.7 Forms open as panels, not pages

Creating or editing a record — a title, a member, a copy, a staff account — opens a panel over the current screen rather than navigating away. On a desktop it is a centred panel; on a phone it fills the screen. Press **Cancel** or **Close** to discard, or the save button to keep your changes.

---

# 6. Setting up the library

Do these four things once, in this order, before cataloguing anything. Loan rules and member categories decide how every future loan behaves, and getting them right first saves correcting records later.

## 6.1 Library profile

**Settings → Library profile**

<!-- SCREENSHOT: Settings → Library profile, filled in. Caption: "The library's own record." -->

| Field | Notes |
| --- | --- |
| **Library name** | Shown in the app and on printed slips and labels. |
| **Currency** | Symbol and formatting for every amount. Changes display only — it never converts amounts already recorded. |
| **Email**, **Phone**, **Address** | The library's contact details. |
| **Opening hours** | Free text, e.g. *Sun–Fri 10:00–17:00, Sat closed*. Not a structured schedule. |
| **Logo** | Upload the library's mark. You are offered a crop step. |
| **Barcode prefix** | The letters that begin an auto-generated copy barcode. Default `KH-`. |
| **Next barcode number** | The counter that follows the prefix. Increments itself each time a barcode is generated. |

**How auto-generated barcodes look.** Prefix plus the counter padded to six digits: with the defaults, the first is `KH-000001`, then `KH-000002`, and so on.

> **Changing the prefix later is allowed** and does not rewrite existing barcodes. If you switch from `KH-` to `LIB-`, older copies keep their `KH-` codes and new ones get `LIB-`. Both remain valid and scannable.

## 6.2 Loan rules

**Settings → Loan rules** · *Administrators only*

<!-- SCREENSHOT: Settings → Loan rules showing the three groups. Caption: "The library-wide lending policy. Member categories can override most of it." -->

These are the library-wide defaults. A member category can override most of them ([section 6.3](#63-member-categories)).

### Loan periods

| Setting | Default | What it does |
| --- | --- | --- |
| **Loan period (days)** | 14 | How long a new loan runs. The due date is this many calendar days after checkout. |
| **Renewals allowed** | 2 | How many times one loan may be renewed. |
| **Renewal period (days)** | *(blank)* | How far a renewal pushes the due date. Blank means use the loan period. |
| **Copies per member** | 5 | How many copies one member may hold open at once. |

### Fines

| Setting | Default | What it does |
| --- | --- | --- |
| **Fine per day** | 5 | Charged for each chargeable late day. |
| **Grace days** | 1 | Late days forgiven before charging starts. |
| **Maximum fine per copy** | 500 | The ceiling on one copy's overdue fine, however late it is. |
| **Maximum fine before blocked** | *(blank)* | Owe more than this and the member cannot borrow. Blank means no limit. |

### Holds and membership

| Setting | Default | What it does |
| --- | --- | --- |
| **Hold shelf days** | 7 | How long a copy waits on the hold shelf for the member it was set aside for. |
| **Membership length (months)** | 12 | How far ahead a new or renewed membership expires. |
| **Holds per member** | 3 | How many open holds one member may have. |

### Switches

| Switch | Default | What it does |
| --- | --- | --- |
| **Block members with overdue copies** | On | The desk cannot check out to a member who is already late. |
| **Renew automatically when nobody is waiting** | Off | ⚠️ **Not active in version 1.0.0.** The switch saves its setting, but no automatic renewal runs. Renew loans by hand. |

Press **Save rules**.

> **Changing the rules does not change existing loans.** Every loan records the loan period, fine rate, grace days and maximum fine *that applied on the day it was issued*, and its overdue fine is priced from that record. Raising the fine rate today does not retroactively make last month's late book more expensive. This is deliberate and is what makes the fine ledger defensible.

## 6.3 Member categories

**Members → Manage categories**

<!-- SCREENSHOT: The Manage categories sheet, with a category open for editing showing blank override fields. Caption: "Leave a rule blank to inherit the library default." -->

A category — *Student*, *Teacher*, *Public*, *Life member* — decides the loan period, borrowing limit and fine rate a card runs under. Every member must have one.

For each category set a **Name** and a **sort order**, then optionally override any of these:

- Loan period (days) · Copies per member · Renewals allowed · Renewal period (days)
- Fine per day · Grace days · Maximum fine per copy · Maximum fine before blocked
- Membership length (months) · Holds per member

> 🔑 **The one rule to remember: blank means inherit.** A blank field on a category is not zero — it means "use the library default from Loan rules". Set only the fields where this category genuinely differs. A Teacher category that needs 30-day loans and nothing else sets **one** field.

**Three settings cannot be overridden per category**, because they describe how the library runs rather than what a card is worth: *hold shelf days*, *block members with overdue copies*, and *renew automatically*.

**Archiving a category.** A category in use cannot be deleted, only archived. It leaves the picker on new and edited members; members already on it keep their card and keep running under its rules. Archived categories can be restored.

### Worked example

Library defaults: 14-day loan, 5 copies, fine 5/day, grace 1 day.

| Category | Overrides set | Effect |
| --- | --- | --- |
| **Student** | *(none)* | 14 days, 5 copies, fine 5/day, grace 1 |
| **Teacher** | Loan period 30, Copies 10 | 30 days, 10 copies, fine 5/day, grace 1 |
| **Public** | Copies 3, Max outstanding 200 | 14 days, 3 copies, fine 5/day, grace 1, blocked above 200 owed |

## 6.4 Staff accounts

**Staff → Add staff** · *Administrators only*

<!-- SCREENSHOT: Staff → Add staff account form, with the role picker open. Caption: "Each role carries a fixed set of permissions." -->

| Field | Notes |
| --- | --- |
| **Name** | Shown against everything this person does. |
| **Email** | Their sign-in identifier. Must be unique. |
| **Password** | Give it to them and ask them to tell you if they want it changed. |
| **Role** | What they may do. See below. |

### The four roles

| Role | In one line |
| --- | --- |
| **Administrator** | Everything, including staff accounts, backups and library settings. |
| **Librarian** | The whole catalogue and circulation desk, plus fines and reports. Can read settings but not change them. |
| **Desk assistant** | The circulation desk: check out, return, and look up a member. |
| **Read only** | Look at the catalogue and reports. Change nothing. |

The exact permission matrix is in [section 14.1](#141-roles-and-permissions). Roles are a fixed set; custom roles do not exist in this version.

### Managing accounts

- **Edit account** — change name, email or role.
- **Reset password** — set a new password for someone who has forgotten theirs.
- **Disable account** — the person can no longer sign in, but everything they did stays attributed to them.

> **Disable rather than delete** when someone leaves. Their name stays attached to the loans they issued and the fines they waived, which is what keeps the ledger readable a year later.

Two things Khulla will not let you do:

- **Disable your own account.** *"You cannot disable your own account."*
- **Disable the last active administrator.** *"The library must always have at least one active administrator."* Promote someone else first.

---

# 7. Building the catalogue

## 7.1 The idea: titles and copies

This is the single most important concept in the system, and the one most often got wrong.

> 🔑 **A title is the work. A copy is the physical object on the shelf.**
>
> *Sapiens* by Yuval Noah Harari is **one title**. The four battered paperbacks of it on your shelf are **four copies**, each with its own barcode.
>
> Members borrow **copies**, not titles. This is what lets four people borrow *Sapiens* at the same time while a fifth waits in the queue. It is also why availability is counted from copies: a title can be simultaneously available, on loan and lost.

Cataloguing is therefore always two moves: create the title once, then add a copy for each physical item.

## 7.2 Title formats

**Catalogue → Titles → Manage title formats**

Formats classify a work — Book, Journal, Magazine, Audiobook, Video, E-book, Other. They appear on the title form and as filters on the titles list.

Keep at least one format so new titles can pick one. Deleting a format removes it from the picker; titles already using it keep it.

## 7.3 Adding a title

**Catalogue → Titles → Add a title**

<!-- SCREENSHOT: The Create title panel, both sections visible. Caption: "Creating a title, with its first copies." -->

### Bibliographic details

| Field | Required | Notes |
| --- | --- | --- |
| **Title** | Yes | Up to 300 characters. |
| **Author** | Yes | Plain text. Type it consistently — *Harari, Yuval Noah* or *Yuval Noah Harari*, but pick one and stick to it, because search matches the text you typed. |
| **ISBN** | No | Up to 20 characters. |
| **Publisher** | No | |
| **Year published** | No | Between 1000 and 2200. |
| **Edition** | No | e.g. *3rd edition*, *Revised*. |
| **Pages** | No | Must be greater than zero. |
| **Language** | No | Defaults to English. |
| **Format** | Yes | From the formats you configured. |
| **Description** | No | Free text — a blurb, a note on contents. |

### Shelving and value

| Field | Notes |
| --- | --- |
| **Shelf location** | Where copies of this work live, e.g. *A-3*, *305.8 HAR*. Copies inherit this unless given their own. |
| **Replacement cost** | What one copy costs to replace if lost. Used when charging a lost-copy fine. |
| **Lendable** | On by default. **Turn it off for reference works that never leave the building** — a dictionary, an atlas, a bound periodical run. A non-lendable title cannot be checked out or held. |
| **Initial copies** | How many copies to create along with the title. At least one. Each gets an auto-generated barcode. |

Press **Save title**.

> 💡 **The fastest way to catalogue a shelf** is to set *Initial copies* to the number of physical items you are holding. Khulla creates them all with sequential barcodes in one go, and you print the labels for all of them together.

## 7.4 The title record

**Catalogue → Titles → (any row)**

<!-- SCREENSHOT: A title detail page showing overview, copies table and loan history. Caption: "One title's record: what it is, what copies exist, and who has borrowed it." -->

The title record has three parts:

- **Overview** — the bibliographic details, whether it may be lent, and the description.
- **Copies** — every physical item of this work, with barcode, shelf and status. A copy that is out shows *Out to [borrower] · due [date]*.
- **Loan history** — who has borrowed this work, most recent first.

Actions here: **Edit**, **Add copies**, **Delete title**.

> ⚠️ **Deleting a title removes the title and every copy under it.** The loan history is kept, so past borrowing records stay intact. Prefer turning *Lendable* off, or withdrawing the individual copies, if the work might come back.

## 7.5 Copies

**Catalogue → Copies** lists every physical item across every title.

<!-- SCREENSHOT: Catalogue → Copies list with status chips visible. Caption: "Every physical item in the library, and where it is right now." -->

### Adding a copy

| Field | Notes |
| --- | --- |
| **Title** | Which work this item belongs to. |
| **Barcode** | **Leave blank to assign the next number** from the library profile's prefix and counter. Type one only if the item already carries a barcode you want to keep. Barcodes must be unique across the whole library. |
| **Shelf** | Leave blank to inherit the title's shelf location. |
| **Acquired** | When the library got it. |
| **Notes** | Anything about this particular item — *ex-library, water damage to cover*. |

### Copy status

Every copy is in exactly one of these states:

| Status | Meaning |
| --- | --- |
| **Available** | On the shelf, free to borrow. |
| **On loan** | Currently checked out. |
| **Reserved** | Set aside on the hold shelf for a specific member. |
| **Lost** | Reported lost. Not lendable. |
| **Damaged** | Flagged as damaged. Stays on the shelf but marked. |

Status moves by itself as the desk works — checking out sets *On loan*, returning sets *Available* or *Reserved* depending on the hold queue. You only set it by hand in the three cases below.

### Copy actions

| Action | What it does |
| --- | --- |
| **Mark as lost** | The copy is marked lost and removed from the lendable shelf. |
| **Mark as damaged** | The copy stays on the shelf but is flagged as damaged. |
| **Withdraw from stock** | The copy is withdrawn and hidden from the catalogue. Use for a book discarded, sold or permanently removed. Loan history is kept. |

## 7.6 Labels and barcodes

**Catalogue → Labels and barcodes**

<!-- SCREENSHOT: The labels screen — scan box, queue table, layout options and the sticker preview. Caption: "Building a print queue of labels." -->

This is where spine labels and barcode stickers are printed for new copies, so a handheld scanner can read them at the desk instead of someone typing a call number.

### Getting copies into the queue

| Method | How |
| --- | --- |
| **Scan** | Put the cursor in the barcode box and scan, or type a barcode and press **Enter**. It joins the queue. |
| **Paste a list** | **Paste a list** takes one barcode per line — from a spreadsheet or an accession list — and queues them all. Khulla reports how many were queued and how many were not found. |
| **From the copies list** | Add a whole shelf of copies at once from the copies screen. |

### Layout

| Option | Choices |
| --- | --- |
| **Sticker size** | Small (38 × 21 mm), Medium (63 × 38 mm), Large (99 × 57 mm) |
| **What to print** | Title · Author · Shelf mark · Library name — each on or off |

The **Preview** panel shows one sticker at the chosen size. Use it to check that a long title still fits before committing a sheet of stock.

Press **Print sheet**. Remove individual rows with **Remove from the queue**, or empty it with **Clear the queue**.

> 💡 **Print a test page on plain paper first** and hold it against a sheet of label stock before printing on the real thing. Label stock is expensive and alignment is worth thirty seconds of checking.

---

# 8. Members

**Members** holds every borrower — student, teacher or public.

> **Members are not staff.** A member borrows books; a staff member operates the system. They are separate registers with different fields, and only staff accounts can sign in. Someone who is both a librarian and a borrower needs one of each.

## 8.1 Registering a member

**Members → Add a member**

<!-- SCREENSHOT: The New member panel. Caption: "Registering a borrower. The category decides the rules their card runs under." -->

### Identity

| Field | Required | Notes |
| --- | --- | --- |
| **Full name** | Yes | Up to 160 characters. |
| **Card number** | Yes | Must be unique across the library. Type it yourself — card numbers are not auto-generated in this version. Pick a scheme and keep to it (see the tip below). |
| **Date of birth** | No | |
| **Guardian** | No | For a child member — the parent or guardian responsible. |

### Membership

| Field | Notes |
| --- | --- |
| **Category** | Decides the loan period, the borrowing limit and the fine rate. See [section 6.3](#63-member-categories). |
| **Member since** | When they joined. |
| **Expires** | **Set automatically from the category when the member is saved** — joined date plus the category's membership length. |

### Contact

**Email**, **Phone**, **Address**, and **Notes** — all optional.

**Send overdue notices** is on by default. Turn it off for a member who has asked not to be contacted.

Press **Save member**.

> 💡 **Choose a card-number scheme before you register the first member.** Something like `2026-0001` (year plus sequence) or `S-0042` for students and `P-0042` for public reads well in a list and sorts sensibly. Changing scheme halfway leaves you with two incompatible sets of cards.

## 8.2 The members list

<!-- SCREENSHOT: The members list with filter chips and status badges. Caption: "The register, filtered to members who owe fines." -->

Columns: **Name**, **Card**, **Category**, **On loan**, **Fines**, **Expires**.

Filters: **With loans** · **Owes fines** · **Suspended** · **Expiring**

Each member carries a standing:

| Standing | Meaning |
| --- | --- |
| **Active** | Membership valid, may borrow. |
| **Expiring soon** | The expiry date is approaching. Renew at the next visit. |
| **Expired** | Past the expiry date. **Cannot borrow or place holds** until renewed. |
| **Suspended** | Suspended by staff. Cannot borrow or place holds. |

## 8.3 The member record

<!-- SCREENSHOT: A member detail page — membership, contact, current loans, fines and history. Caption: "One borrower's record." -->

At the top: **On loan**, **Overdue**, **Fines owed** and **Borrowed all time**.

Below: **Membership** and **Contact** details, **On loan now**, **Fines**, and **Loan history**.

### Actions

| Action | What it does |
| --- | --- |
| **Check out to this member** | Opens the checkout desk with this member already looked up. |
| **Edit member** | Change any detail. |
| **Renew membership** | Pushes the expiry date out by the category's membership length. |
| **Suspend membership** | A suspended member cannot borrow or place holds. Record a reason. |
| **Reinstate membership** | Lifts a suspension. |
| **Archive member** | The member leaves the register. Loans and fines already recorded are kept. |
| **Delete member** | The borrower record is removed. Loans and fines already recorded are kept against the copies. |

> **Archive, don't delete.** Archiving takes someone off the active register while keeping their record whole and reversible. Deleting is for a record created in error — a duplicate, a test entry — not for a member who has simply left.

---

# 9. The circulation desk

This is the section the counter lives in. It has five screens: **Loans**, **Check out**, **Return**, **Reservations** and **Fines**.

## 9.1 Checking out

**Circulation → Check out**

<!-- SCREENSHOT: The check out screen with a member selected and three copies scanned, summary panel showing due date. Caption: "Checking out: member first, then every copy going home with them." -->

### Step 1 — Find the member

Search by **name, card number or phone**, and select them.

> **Always start with the member.** The loan period and the borrowing limit come from the member's category, so Khulla cannot price the loan until it knows whose card it is on.

### Step 2 — Add the copies

Put the cursor in the barcode box and scan each copy, or type the barcode and press Enter. Each one joins the list. Remove a mistake with **Remove copy**.

### Step 3 — Check the summary, then confirm

The summary panel shows:

| | |
| --- | --- |
| **Copies** | How many are in this checkout |
| **Loan period** | The days this member's category allows |
| **Due back** | The date every copy in this basket is due |
| **Borrowing limit** | How many copies this member may hold |
| **Outstanding fines** | What they currently owe |

Press **Confirm checkout**. Every copy goes out in **one transaction** — either the whole basket checks out or none of it does, so you never end a scan with a half-recorded loan.

### The due date

Due date = **today + the loan period in calendar days**. With the default 14-day period, a book borrowed on the 3rd is due on the 17th. Calendar days, not working days — closure days are not skipped.

### What blocks a checkout

Khulla refuses the checkout and says why. Every message and its fix is in [section 15.2](#152-messages-at-the-checkout-desk). In summary, it refuses when:

- the member is **archived, suspended or expired**;
- the member is at their **borrowing limit**;
- the member has **overdue copies** (when *Block members with overdue copies* is on);
- the member **owes more than the maximum outstanding fine**;
- the copy is **not available** — already out, lost, damaged or withdrawn;
- the copy is **reserved for someone else**;
- **another member has an earlier hold** on that title;
- the title is **not lendable** (reference) or has been **archived**.

## 9.2 Returning

**Circulation → Return**

<!-- SCREENSHOT: The return screen, two copies scanned, one showing days late and a fine. Caption: "Anything late is priced as it is scanned." -->

Scan each copy coming back. Khulla identifies it, closes its loan, and prices anything late as it is added — the list shows **Days late** and **Fine** per copy before you confirm anything.

### Condition

Set the **Condition** for the copies in this return: **As new**, **Good**, **Fair** or **Poor**. It is recorded against every copy in the return and builds a history of how the stock is wearing.

### Waiving fines on a return

**Waive the fines on this return** cancels the overdue charges for everything in this batch.

> Use it for a copy the library was at fault for — an unexpected closure day, a hold that was never collected. The waiver is recorded against your account, which is exactly why staff sign in individually.

### Confirm

The summary shows **Copies returning**, **Late copies** and **Fines due**. Press **Confirm return**.

Then, per copy:

1. The loan closes and the return condition is recorded.
2. If the copy is late and fines are not waived, **an overdue fine is raised** on the member's ledger.
3. If someone is waiting for that title, **the copy is set aside for the next person in the queue** and its status becomes *Reserved*. Otherwise it goes back to *Available*.

> 🔑 **An overdue fine is only created at the moment of return.** While a book is merely late, nothing is written to the ledger — the amount shown against an overdue loan is what *would* be charged if it came back today. This is why the fines list and an overdue list never agree, and why they should not.

## 9.3 Renewing a loan

**Circulation → Loans → (the loan) → Renew loan**

A renewal extends the loan. Two things to know:

> 🔑 **A renewal extends from the existing due date, not from today.** Renewing a 14-day loan three days after it was due moves the due date to 14 days after the *original* due date — which may still be in the past. The renewal does not wipe out the lateness that has already accrued.

Khulla refuses a renewal when:

- the loan has already reached its **renewal limit** (*"That loan has reached its renewal limit."*);
- **a hold is waiting** on that title (*"A hold is waiting on this title and the loan cannot be renewed."*) — the person in the queue comes first;
- the loan has already been returned.

The renewal length is the category's **renewal period** if set, otherwise its **loan period**.

## 9.4 The loans screen

**Circulation → Loans** is the desk's landing page: every open loan, with headline counts above it.

<!-- SCREENSHOT: The loans list with an overdue row highlighted and the row menu open. Caption: "Open loans, with the actions available on each." -->

Columns: **Title**, **Member**, **Barcode**, **Issued**, **Due**, **Status**, **Fine**.

Status reads **On loan**, **Due today** or **Overdue**. The **Fine** column on an overdue row is the amount that would be charged if the copy came back today — it is not yet money owed.

Row actions: **Renew loan**, **Return copy**, **Open member**.

> ⚠️ **"Mark copy lost" on a loan row is not wired up in version 1.0.0.** Selecting it shows a notice and does nothing. To record a copy lost while it is out: go to **Catalogue → Copies**, find it, and **Mark as lost**; then charge the member for it from **Circulation → Fines → Charge a fine**, reason *Lost copy*.

## 9.5 Reservations (holds)

**Circulation → Reservations**

<!-- SCREENSHOT: The reservations list showing queue positions and a "Ready for pickup" row. Caption: "Members waiting for a copy, in the order they asked." -->

A **hold** is a place in the queue for a title that is currently out. It is placed on the **title**, not a specific copy — whichever copy comes back first satisfies it.

### Placing a hold

**Place a hold**, then pick the member and the title. Khulla refuses when:

- the member is **archived, suspended or expired**;
- the member is at their **hold limit** (*"That member has reached their hold limit."*);
- the title is **archived** or **not lendable**;
- the member already has an open hold on that title — one active hold per member per title.

### How the queue works

1. Holds are served in the order they were placed — position is shown as **#1**, **#2** and so on.
2. When a copy of that title is returned, the first waiting hold is promoted to **Ready for pickup**, that copy is assigned to it, and the copy's status becomes *Reserved*.
3. The member has **Hold shelf days** (default 7) to collect it. The expiry date shows in the **Expires** column.
4. If they do not collect it in time, the hold **expires** automatically and the copy passes to the next person waiting, or returns to the shelf.

Khulla expires stale holds on its own — no daily job to remember.

### Hold statuses

| Status | Meaning |
| --- | --- |
| **Waiting** | In the queue; no copy set aside yet. |
| **Ready for pickup** | A copy is on the hold shelf with their name on it. |
| **Collected** | They came and borrowed it. Closed. |
| **Expired** | Not collected within the hold shelf period. Closed. |
| **Cancelled** | Cancelled by staff or at the member's request. Closed. |

### Hold actions

- **Mark ready for pickup** — assigns the next available copy by hand, for when a copy is found on the shelf rather than returned at the desk.
- **Cancel hold** — the member leaves the queue.

> **A hold blocks renewal, not the current loan.** Placing a hold does not recall a book that is already out. It stops that loan from being renewed and claims the copy the moment it comes back.

## 9.6 Fines

**Circulation → Fines**

<!-- SCREENSHOT: The fines ledger with the four stat tiles and a row menu open. Caption: "What members owe, what has been collected, and what was written off." -->

Above the list: **Outstanding**, **Collected this month**, **Waived this month**, **Members owing**.

Columns: **Member**, **Reason**, **Title**, **Raised**, **Amount**, **Status**.

### Why a fine exists

| Reason | Raised |
| --- | --- |
| **Overdue copy** | Automatically, when a late copy is returned. |
| **Damaged copy** | By hand. |
| **Lost copy** | By hand. |
| **Membership fee** | By hand. |

### How an overdue fine is calculated

```
chargeable days = (days between due date and return date) − grace days

if chargeable days ≤ 0        → no fine
otherwise                     → fine per day × chargeable days
                                capped at the maximum fine per copy
```

Every figure comes from the **snapshot stored on that loan** when it was issued — not from today's settings.

**Worked examples**, at fine 5/day, grace 1 day, maximum 500 per copy:

| Due | Returned | Days late | Chargeable | Fine |
| --- | --- | --- | --- | --- |
| 10 Mar | 10 Mar | 0 | 0 | **0** |
| 10 Mar | 11 Mar | 1 | 0 *(grace)* | **0** |
| 10 Mar | 12 Mar | 2 | 1 | **5** |
| 10 Mar | 20 Mar | 10 | 9 | **45** |
| 10 Mar | 10 Jun | 92 | 91 | **455** |
| 10 Mar | 20 Jun | 102 | 101 | **500** *(capped — 101 × 5 = 505, above the 500 ceiling)* |

### Settling a fine

| Action | What it does |
| --- | --- |
| **Collect payment** | Records the amount as paid by that member. A receipt line is kept against them. |
| **Waive fine** | The member stops owing it, and the waiver is recorded against your account. |

### Charging a fine by hand

**Charge a fine** — for a lost or damaged copy, or a membership fee. Pick the **member**, the **reason**, the **amount** (greater than zero) and an optional **note**.

> Do not use this for overdue charges. Those are raised automatically on return, and adding one by hand double-charges the member.

---

# 10. Dashboard and reports

## 10.1 Dashboard

**Dashboard** is where a shift starts.

<!-- SCREENSHOT: The dashboard with stat tiles, activity feed and the attention panel. Caption: "The day at a glance." -->

| Panel | Shows |
| --- | --- |
| **Stat tiles** | Copies borrowed · Overdue · Copies returned · Fines outstanding |
| **Quick actions** | **Check out a copy** · **Return a copy** |
| **Recent activity** | Checkouts and returns from the last seven days |
| **Needs attention** | Overdue loans, holds waiting to be filled, copies reported lost |
| **Library usage** | Checkouts and returns, day by day |
| **Fines accrued** | What overdue copies have cost members |
| **Collection at a glance** | Where every copy is right now |
| **Most borrowed** / **Most active members** | Ranked lists |

> 💡 **Work "Needs attention" top to bottom once a day** and the desk never accumulates a backlog. It is the only panel that asks you to do something.

## 10.2 Reports

**Reports**

<!-- SCREENSHOT: The reports page with a period selector and the charts. Caption: "What the library did over a period." -->

Choose a period — **Today**, **This week**, **This month**, **This quarter**, **This year** — and everything recalculates.

| Report | Shows |
| --- | --- |
| **Headline figures** | Loans issued · Copies returned · New members · Fines collected |
| **Circulation over time** | Loans issued against copies returned |
| **Collection mix** | Every catalogued copy by format |
| **Membership growth** | Members joining, month by month |
| **Fines** | Raised, collected and waived over the period |
| **Most borrowed titles** | Ranked, with each title's share |
| **Most active members** | Ranked by copies borrowed |

## 10.3 Saved reports and CSV export

**Saved reports** are the ones a committee or a council asks for. Selecting one exports it as a **CSV file** you can open in Excel, LibreOffice or Google Sheets.

| Report | Contents |
| --- | --- |
| **Monthly circulation summary** | Loans, returns, renewals and overdue counts for one month. |
| **Collection inventory** | Every title and copy, with shelf location. |
| **Membership register** | Active, expiring and suspended members with their borrowing history. |
| **Fine ledger** | Every fine raised, collected or waived, with the member and the reason. |
| **Overdue notices** | Members with copies past due, ready to print or email. |
| **Acquisitions** | Titles added over a period, with cost and supplier. |

Individual tables elsewhere in the app also carry **Export CSV**.

> 💡 **The annual report to your committee** is usually: set the period to *This year*, screenshot the circulation chart, then export the **Monthly circulation summary** and the **Fine ledger** for the numbers behind it.

> ⚠️ **A CSV export is not a backup.** It is a readable extract for a spreadsheet — it cannot be loaded back into Khulla. The only thing that restores a library is a backup file from [section 11](#11-backup-restore-and-erase).

---

# 11. Backup, restore and erase

**Settings → Backup and restore** · *Administrators only*

<!-- SCREENSHOT: Settings → Backup and data, showing last backup date and database size. Caption: "The most important screen in the application." -->

> 🔴 **This is the most important screen in Khulla.** Everything else can be corrected. A lost catalogue cannot.

The screen shows **Last backup** (or *Never*) and the **Database size**.

## 11.1 Exporting a backup

Press **Export**. Khulla writes the whole catalogue — titles, copies, members, loans, fines, staff accounts, settings — to **one file**, named like `khulla-backup-2026-09-12-1430.sqlite`. Choose where to save it.

### Where to keep backups

> ⚠️ **A backup on the same computer protects you from almost nothing.** The realistic disasters — theft, fire, a failed disk, a ransomware infection — take the backup with the machine.

Keep copies in at least two places:

1. **An external drive or USB stick** kept somewhere other than beside the computer.
2. **A second location** — a cloud drive, a laptop in another room, the school office.

### How often

| Library activity | Export at least |
| --- | --- |
| Busy — daily circulation | **Every day**, at close |
| Moderate — a few days a week | **Weekly** |
| Quiet | **Monthly**, and before any big change |

Always export **before** restoring a backup, erasing the library, or upgrading Khulla.

### A backup rotation that works

Keep the last **7 daily** files, the last **4 weekly** files, and **12 monthly** files. Old files are small; deleting them saves nothing worth the risk.

> 💡 **Make it somebody's job, written on the closing checklist.** "Export the backup and take the stick home" is a habit, not a feature. Khulla will not remind you.

## 11.2 Restoring from a backup

Press **Choose a file** and select a backup.

> 🔴 **Restoring replaces everything.** Every title, copy, member, loan and fine currently in this library is discarded and replaced with the contents of the file. The app restarts when it finishes. **Export a backup of the current state first**, even if you believe it is worthless — it costs one click and it is the only undo.

Khulla asks you to confirm before proceeding.

Restore is used for exactly three things:

1. **Recovering from a disaster** — the computer died, and a replacement is being set up.
2. **Moving the library to a new computer.** Install Khulla on the new machine; on the first setup screen choose **Restore from a backup instead**; give it the file.
3. **Undoing a catastrophe** — a mass deletion, a bad import.

## 11.3 Erasing the library

**Erase this library** deletes every title, copy, member and loan from this device.

> 🔴 **There is no undo. A backup file is the only way back.** Khulla requires your account password to confirm.

Use it only when handing the computer on, or deliberately starting the catalogue again from nothing.

## 11.4 Online sync

**Settings → Sync** shows an interface for writing an encrypted snapshot to a synced folder, a WebDAV server or an S3 bucket.

> ⚠️ **Sync is not functional in version 1.0.0.** The screen is the interface only — the controls do not write anything anywhere. **Do not rely on it.** Manual export from [section 11.1](#111-exporting-a-backup) is the only working backup in this version.

When it does arrive, the principle on that screen still holds: *sync is an extra copy, never the source of truth.*

---

# 12. Appearance and About

## 12.1 Appearance

**Settings → Appearance** — choose **System**, **Light** or **Dark**.

This applies to **this device only**. It is stored locally and is not part of the catalogue, so it does not travel in a backup and each machine is set separately.

## 12.2 About

**Settings → About**, or **About** in the account menu. Shows the version number, the licence, where the catalogue is stored on this machine, and links to the website, the source code and the issue tracker.

> **Quote the version number** whenever you report a problem — it is the first thing anyone will ask for.

## 12.3 The in-app guide

**Guide** in the account menu opens a short walkthrough of the same ground this manual covers, available offline at the desk. This manual is the fuller reference.

---

# 13. Working routines

Checklists to print and pin beside the desk.

## 13.1 Opening

1. Sign in with **your own** account.
2. Open the **Dashboard** and read **Needs attention**.
3. Check **Reservations** for holds marked **Ready for pickup**, and confirm those copies are physically on the hold shelf.
4. Shelve anything returned after closing yesterday.

## 13.2 During the day

| Situation | Do this |
| --- | --- |
| Member wants to borrow | **Circulation → Check out** — member first, then scan each copy |
| Member returns books | **Circulation → Return** — scan each copy, set condition, confirm |
| Member wants longer | **Circulation → Loans** → find it → **Renew loan** |
| Wanted book is out | **Circulation → Reservations → Place a hold** |
| Member pays a fine | **Circulation → Fines** → find it → **Collect payment** |
| New member joins | **Members → Add a member** |
| New stock arrives | **Catalogue → Add a title** (with its copies) → **Labels** → print and stick |
| Book found damaged | **Catalogue → Copies** → **Mark as damaged**; charge a fine if the borrower is at fault |
| Book declared lost | **Catalogue → Copies** → **Mark as lost**; **Fines → Charge a fine**, reason *Lost copy* |

## 13.3 Closing

1. Complete any unfinished checkout or return — never leave a basket unconfirmed.
2. **Export a backup** and take the copy off-site.
3. Sign out.

## 13.4 Weekly

- Work through **Members → Expiring** and renew memberships at the next visit.
- Review **Overdue** on the dashboard; contact the members concerned.
- Check **Reservations** for holds that have expired uncollected.
- Confirm the backups actually exist on the external drive — open the folder and look.

## 13.5 Monthly

- Export the **Monthly circulation summary** and the **Fine ledger**.
- Review **Reports → Collection mix** and **Most borrowed** for acquisition decisions.
- Review **Staff** accounts: disable anyone who has left.
- Move one monthly backup into long-term storage.

## 13.6 Annually

- Export the **Membership register** and the **Collection inventory** before the new academic year.
- Review **Loan rules** and **Member categories** against how the library actually works now.
- Run a stock check against the **Collection inventory** export.

---

# 14. Reference tables

## 14.1 Roles and permissions

**✔ Can change · 👁 Can view · — No access**

| Permission | Administrator | Librarian | Desk assistant | Read only |
| --- | :---: | :---: | :---: | :---: |
| Manage the catalogue | ✔ | ✔ | 👁 | 👁 |
| Work the circulation desk | ✔ | ✔ | ✔ | 👁 |
| Manage members | ✔ | ✔ | ✔ | 👁 |
| Collect and waive fines | ✔ | ✔ | 👁 | 👁 |
| View reports | ✔ | ✔ | — | 👁 |
| Library settings | ✔ | 👁 | — | — |
| Manage staff accounts | ✔ | — | — | — |
| Run backups and restores | ✔ | — | — | — |

Notes on the design:

- A section a role cannot view is **hidden from the navigation entirely**, not merely disabled.
- At *Can view*, every control that would change something is **gone**, not greyed out.
- A **librarian can read** the loan rules — so they can answer "how long is a loan?" without finding an administrator — but cannot change them.
- A **desk assistant** can look a book up but not edit its record, and can see what a member owes (it decides whether they may borrow) but cannot waive it.
- Roles are fixed. Custom roles do not exist in version 1.0.0.

## 14.2 Loan rule defaults

| Rule | Default | Overridable per category |
| --- | --- | :---: |
| Loan period (days) | 14 | Yes |
| Copies per member | 5 | Yes |
| Renewals allowed | 2 | Yes |
| Renewal period (days) | *(uses loan period)* | Yes |
| Fine per day | 5 | Yes |
| Grace days | 1 | Yes |
| Maximum fine per copy | 500 | Yes |
| Maximum fine before blocked | *(no limit)* | Yes |
| Membership length (months) | 12 | Yes |
| Holds per member | 3 | Yes |
| Hold shelf days | 7 | **No** |
| Block members with overdue copies | On | **No** |
| Renew automatically when nobody is waiting | Off *(not active)* | **No** |

Amounts are shown in the currency chosen in the library profile.

## 14.3 Statuses at a glance

**Copy** — Available · On loan · Reserved · Lost · Damaged

**Loan** — On loan · Due today · Overdue · Returned

**Member** — Active · Expiring soon · Expired · Suspended

**Hold** — Waiting · Ready for pickup · Collected · Expired · Cancelled

**Fine** — Unpaid · Paid · Waived · *(reasons:* Overdue copy · Damaged copy · Lost copy · Membership fee*)*

**Copy condition** — As new · Good · Fair · Poor

**Staff account** — Active · Disabled

## 14.4 What a rule change does and does not affect

| Change | Existing loans | New loans |
| --- | --- | --- |
| Loan period | Unaffected — due dates stay put | Use the new period |
| Fine per day, grace days, maximum fine | **Unaffected** — priced from the loan's own snapshot | Use the new figures |
| Borrowing limit, hold limit | Applied at the next checkout or hold | Applied |
| Membership length | Applied at the next renewal | Applied |
| Currency | Display only — no amount is converted | Display only |
| Member's category changed | Their **open** loans keep their original terms | New loans use the new category |

## 14.5 Where the data lives

| | |
| --- | --- |
| **Desktop** | One database file in the application support folder for your user account. The exact path is shown at **Settings → About → Catalogue stored at**. |
| **Web** | Inside the browser's own storage for that site, on that device. |
| **Backup file** | Wherever you chose to save it, named `khulla-backup-<date>.sqlite`. |
| **Theme setting** | Local to the device; not part of the catalogue or the backup. |

> ⚠️ **Do not open, move, rename or "clean up" the database file** while Khulla is running, and do not edit it with another tool. Use **Export** to make a copy.

---

# 15. Troubleshooting

## 15.1 Starting up

| Symptom | Cause | What to do |
| --- | --- | --- |
| **"The library database could not be opened."** | The file is locked, the disk is full, or the file is damaged. | Close any other copy of Khulla that is running. Check free disk space. Then **Try again**. If it persists, restore your latest backup. |
| Khulla opens straight into setup, but this library already existed | It is looking at a different database — a development build, a different user account on the computer, or a different browser. | Check you are running the normal (production) app, signed in as the usual Windows/Linux user. On web, check you are using the same browser and have not cleared site data. |
| The app refuses to open after an upgrade was rolled back | The catalogue was opened by a **newer** version of Khulla; older versions refuse to open it rather than risk damaging it. | Reinstall the newer version. Khulla deliberately never downgrades a catalogue in place — it holds the library's only copy of its records. |
| A white or blank window on launch | Graphics driver or window sizing issue. | Close and reopen. If it persists, report it with your version number from **About**. |

## 15.2 Messages at the checkout desk

| Message | What it means | What to do |
| --- | --- | --- |
| **"No copy matches that barcode."** | The barcode is not in the catalogue. | Check for a typo; try scanning again. The copy may never have been catalogued — add it under its title. |
| **"That copy is not available to borrow."** | It is already on loan, or marked lost, damaged or withdrawn. | Open the copy in the catalogue and read its status. If it is wrongly marked, correct it there. |
| **"That copy is reserved for another member."** | It is on the hold shelf for a specific person. | Find another copy. Do not override — the person waiting has already been told it is ready. |
| **"Another member has an earlier hold on this title."** | Someone is ahead in the queue. | Check **Reservations** for that title. Either serve the queue, or cancel the earlier hold if the member no longer wants it. |
| **"That member has reached their borrowing limit."** | They already hold the maximum for their category. | Take a return first, or raise the limit for that category if the policy is genuinely wrong. |
| **"That member has overdue loans and cannot borrow."** | *Block members with overdue copies* is on. | Take the overdue copies back first. An administrator can turn the switch off in **Loan rules** if that is not your policy. |
| **"That member owes more than the allowed outstanding fine."** | Their unpaid fines exceed the limit. | Collect or waive the fines, or raise the limit for that category. |
| **"That member was not found."** | The member record has been deleted or archived. | Search again; check the archived members. |
| **"That title is not lendable."** | It is marked reference-only. | If wrongly marked, turn **Lendable** on in the title record. |
| **"That title has been archived."** / **"That copy has been archived."** | The record has been withdrawn from the catalogue. | Restore it from the catalogue if it should still circulate. |
| **Member is suspended or expired** | Their membership is not current. | **Renew membership** or **Reinstate membership** from their record, then retry. |

## 15.3 Messages at the returns desk

| Message | What it means | What to do |
| --- | --- | --- |
| **"No copy matches that barcode."** | The barcode is not in the catalogue. | Retry the scan. The sticker may be damaged — type the number by hand. |
| **"That copy is not on loan."** | There is no open loan for it. | It may already have been returned by a colleague, or never checked out. Check the title's loan history. Shelve it. |

## 15.4 Messages when renewing or holding

| Message | What to do |
| --- | --- |
| **"That loan has reached its renewal limit."** | Take the copy back and check it out again if policy allows, or raise the category's renewal limit. |
| **"A hold is waiting on this title and the loan cannot be renewed."** | Someone is waiting. Ask for the copy back. |
| **"That loan has already been returned."** | Refresh the screen; someone else took the return. |
| **"That member has reached their hold limit."** | Cancel a hold they no longer want, or raise the category's hold limit. |

## 15.5 Other common problems

| Symptom | Cause | What to do |
| --- | --- | --- |
| **The scanner types nothing** | Wrong focus, or the scanner is not in keyboard mode. | Click into the barcode box first. Test the scanner in a text editor: it should type the digits and press Enter. |
| **The scanner types the code but nothing happens** | It is not sending Enter. | Configure the scanner to add a carriage return after each scan (see its own manual), or press Enter yourself. |
| **A barcode scans as a slightly wrong number** | The sticker is damaged, or two copies got the same sticker. | Reprint the label. Barcodes must be unique — Khulla will not accept a duplicate. |
| **A book is on the shelf but shows "On loan"** | It was returned without being scanned. | Scan it through **Return**. It will close the loan and price any lateness — waive the fine if the library was at fault. |
| **A member says they returned a book they still hold** | Same cause, opposite direction. | Check the title's loan history for who has it and when it went out. |
| **The same title appears twice** | It was catalogued twice instead of copies being added to one record. | Move the copies onto one title, then delete the empty duplicate. |
| **Fines look wrong after a rule change** | Fines are priced from the rules stored on the loan when it was issued. | This is correct behaviour — see [section 14.4](#144-what-a-rule-change-does-and-does-not-affect). Waive and re-charge by hand if the library decides to apply new rules retroactively. |
| **A member's expiry date did not update** | Expiry is set from the category at save, and on **Renew membership**. | Open the member and press **Renew membership**. |
| **The rail is missing a section** | Your role cannot open it. | Check your role against [section 14.1](#141-roles-and-permissions); ask an administrator. |
| **"This build is the interface only — that action is not wired up yet."** | That control is not implemented in 1.0.0. | See [section 15.6](#156-known-limitations-in-version-100) for the working alternative. |

## 15.6 Known limitations in version 1.0.0

Stated plainly so nobody builds a routine on something that does not run:

| Limitation | Work around it by |
| --- | --- |
| **Online sync does not function.** The screen is the interface only. | Exporting backups by hand — [section 11.1](#111-exporting-a-backup). |
| **"Renew automatically when nobody is waiting" does nothing.** The setting saves but no automatic renewal runs. | Renewing loans at the desk. |
| **"Mark copy lost" on a loan row is not wired.** | **Catalogue → Copies → Mark as lost**, then charge the fine from the fines screen. |
| **Card numbers are not auto-generated.** | Choosing a numbering scheme and typing them — [section 8.1](#81-registering-a-member). |
| **No in-app language switch.** | Setting the operating system's display language. |
| **No overdue emails or SMS.** Khulla never sends anything. | Exporting **Overdue notices** from saved reports and contacting members yourself. |
| **No merging of two catalogues.** | Keeping one installation per library. |

## 15.7 Getting help

Check the version at **Settings → About**, then use the links on that screen to open the repository's issue tracker. When reporting a problem, include:

1. The **version number**;
2. Your **platform** (Windows / web / Linux);
3. **Exactly what you did**, step by step;
4. The **exact message** shown, word for word;
5. What you expected instead.

Feature requests are welcome on the same tracker.

---

# 16. Frequently asked questions

**Does Khulla need an internet connection?**
No. It runs entirely on the computer it is installed on and works with the network unplugged.

**Does my members' data go anywhere?**
No. Nothing you type leaves the machine. There is no account with anyone and no telemetry.

**Can two computers share one catalogue?**
Not in version 1.0.0. Each installation holds its own catalogue. Two desks need either one shared computer or two separate catalogues.

**What happens if the computer dies?**
You restore your most recent backup onto a new machine. Whatever happened since that backup is lost — which is why the export habit matters.

**Is a CSV export a backup?**
No. CSV is a readable extract for a spreadsheet and cannot be loaded back. Only a backup file restores a library.

**Why can't I check this book out? It is right here on the desk.**
Read the message — [section 15.2](#152-messages-at-the-checkout-desk) explains every one. The commonest causes are a hold for another member, the member's borrowing limit, and an expired membership.

**Why is the fine different from what I calculated?**
Grace days come off first, the total is capped at the maximum per copy, and the rates used are the ones stored on that loan when it was issued — not today's. See [section 9.6](#96-fines).

**A member paid part of a fine. Can I record that?**
The **Collect payment** action records payment against a fine. To handle a partial settlement cleanly, discuss it with your administrator and record it consistently — Khulla tracks assessed, paid and waived amounts against each fine.

**Can I delete a member who has left?**
You can, but **archive** them instead. Archiving keeps the record whole and reversible. Either way, loans and fines already recorded are kept.

**What if I catalogue the same book twice?**
Move all the copies onto one title and delete the empty duplicate. Deleting a title keeps its loan history.

**Can I change the currency later?**
Yes, and it changes only how amounts are *shown*. It never converts amounts already recorded.

**Who can see what I did?**
Every action is attributed to the signed-in account, which is why shared logins are a bad idea. Administrators can see the staff list and the fine ledger with its waivers.

**How many books can Khulla handle?**
The lists and searches are built to stay responsive on catalogues in the tens of thousands of titles.

**Is it really free?**
Yes — open source, free to use, and the source code is linked from the About screen.

---

# 17. Glossary

| Term | Meaning |
| --- | --- |
| **Archive** | Remove a record from active lists while keeping it and its history. Reversible. Preferred to deleting. |
| **Barcode** | The unique code identifying one physical copy. Auto-generated as prefix plus a six-digit number unless you supply one. |
| **Card number** | The unique number identifying one member. You assign it. |
| **Category** *(member type)* | The class of membership — Student, Teacher, Public — that decides the loan period, borrowing limit and fine rate a card runs under. |
| **Check out** | Issue a copy to a member, opening a loan. |
| **Condition** | How worn a copy is: As new, Good, Fair, Poor. Recorded at accession and at every return. |
| **Copy** | One physical item on the shelf, with its own barcode. Members borrow copies. |
| **CSV** | A plain-text table format that opens in any spreadsheet program. An extract, not a backup. |
| **Due date** | When a loan must be back: checkout date plus the loan period in calendar days. |
| **Fine** | Money a member owes — raised automatically for an overdue return, or by hand for a lost or damaged copy or a membership fee. |
| **Format** | What kind of work a title is: Book, Journal, Magazine, Audiobook, Video, E-book, Other. |
| **Grace days** | Late days forgiven before a fine starts accruing. |
| **Hold** *(reservation)* | A place in the queue for a title that is currently out. Placed on the title; any copy satisfies it. |
| **Hold shelf** | Where a copy waits for the member it has been set aside for, for the hold-shelf period. |
| **Lendable** | Whether a title may leave the building. Off for reference works. |
| **Loan** | One copy issued to one member. Open until returned. |
| **Local-first** | The whole catalogue lives on this computer. No server, no internet needed, no data sent anywhere — and the backup is yours to make. |
| **Member** | A borrower on the register. Not the same as a staff account. |
| **OPAC** | Online Public Access Catalogue — the catalogue as readers see it. |
| **Recovery code** | A one-time code from setup that can reset the first administrator's password. Shown once, never again. |
| **Renewal** | Extending a loan. Counts against the renewal limit, extends from the existing due date, and is blocked when a hold is waiting. |
| **Replacement cost** | What one copy costs to replace. Used when charging for a lost copy. |
| **Restore** | Rebuild the whole library from a backup file, replacing everything currently in it. |
| **Role** | What a staff account may do: Administrator, Librarian, Desk assistant, Read only. |
| **Shelf location** | Where a work lives — a shelf mark or call number. Copies inherit the title's unless given their own. |
| **Staff account** | A person who signs in and operates the system. |
| **Suspend** | Stop a member borrowing or placing holds, without removing them from the register. |
| **Title** | The work itself. One title, many copies. |
| **Waive** | Cancel a fine so the member no longer owes it. Recorded against the staff account that did it. |
| **Withdraw** | Permanently remove a copy from stock — discarded, sold or lost for good. Loan history is kept. |

---

# 18. Appendices

## Appendix A — Using a barcode scanner

Khulla needs no driver and no configuration. Any USB scanner that behaves as a keyboard works.

1. Plug it in and let the computer recognise it.
2. Test it in a text editor: scanning should type the digits and then move to a new line.
3. If it does not send Enter, set it to add a carriage return after each scan, following the scanner's own manual (usually by scanning a configuration barcode printed there).
4. In Khulla, **click into the barcode box first**, then scan. Every barcode box in the app — check out, return, labels — accepts a scan the same way.

You can always type a barcode by hand and press Enter instead.

## Appendix B — Printing labels

1. **Catalogue → Labels and barcodes**.
2. Queue the copies: scan them, paste a list of barcodes, or add them from the copies list.
3. Choose the **sticker size** to match your label stock — Small 38 × 21 mm, Medium 63 × 38 mm, Large 99 × 57 mm.
4. Choose what prints on the sticker: title, author, shelf mark, library name.
5. Check the **Preview** — particularly that a long title is not cut off.
6. **Print a test on plain paper**, hold it against a label sheet, and only then print on stock.
7. **Print sheet**.

## Appendix C — Moving to a new computer

1. On the old machine: **Settings → Backup and restore → Export**. Save the file to a USB stick.
2. Verify the file exists on the stick and is not zero bytes.
3. Install Khulla on the new machine.
4. Launch it. On the first setup screen, choose **"Restore from a backup instead."**
5. Select the backup file and confirm. The app restarts when it finishes.
6. Sign in with the same staff account and password as before — accounts travel in the backup.
7. Check **Settings → Appearance**: the theme is per-device and will need setting again.
8. Spot-check a few members, a few titles, and the loan rules before going live.
9. Keep the old machine untouched until step 8 passes.

## Appendix D — Setting up a new library: the short version

1. Install Khulla. **[Section 2](#2-before-you-begin)**
2. First-run setup — name, currency, administrator account, **save the recovery codes**. **[Section 3](#3-first-run-setup)**
3. **Settings → Library profile** — contact details, logo, barcode prefix. **[6.1](#61-library-profile)**
4. **Settings → Loan rules** — periods, limits, fines, holds. **[6.2](#62-loan-rules)**
5. **Members → Manage categories** — Student, Teacher, Public, with only the overrides that differ. **[6.3](#63-member-categories)**
6. **Staff** — an account each for everyone who works the desk. **[6.4](#64-staff-accounts)**
7. **Catalogue → Manage title formats** — the formats you actually hold. **[7.2](#72-title-formats)**
8. **Catalogue** — titles and their copies. **[7.3](#73-adding-a-title)**
9. **Catalogue → Labels** — print and stick. **[7.6](#76-labels-and-barcodes)**
10. **Members** — register borrowers. **[8.1](#81-registering-a-member)**
11. **Settings → Backup** — export one now, and write the backup into the closing checklist. **[11](#11-backup-restore-and-erase)**
12. Open the desk.

## Appendix E — Print-and-pin quick reference

```
┌──────────────────────────────────────────────────────────┐
│  KHULLA — DESK QUICK REFERENCE                           │
├──────────────────────────────────────────────────────────┤
│  BORROW    Circulation → Check out                       │
│            1. Find the member    2. Scan every copy      │
│            3. Check due date     4. Confirm checkout     │
│                                                          │
│  RETURN    Circulation → Return                          │
│            1. Scan every copy    2. Set the condition    │
│            3. Check the fines    4. Confirm return       │
│                                                          │
│  RENEW     Circulation → Loans → Renew loan              │
│            Blocked if someone is waiting for the title.  │
│                                                          │
│  HOLD      Circulation → Reservations → Place a hold     │
│            Collect within 7 days or it passes on.        │
│                                                          │
│  FINE      Circulation → Fines → Collect payment         │
│            Overdue fines are raised automatically.       │
│                                                          │
│  BLOCKED?  Read the message. Usual causes:               │
│            · someone else has a hold on the title        │
│            · member is at their borrowing limit          │
│            · membership expired or suspended             │
│            · member has overdue copies                   │
├──────────────────────────────────────────────────────────┤
│  ⚠  BEFORE CLOSING: Settings → Backup → Export           │
│     and take the copy off-site. Every day.               │
└──────────────────────────────────────────────────────────┘
```

---

## Document information

| | |
| --- | --- |
| **Document** | Khulla Digital Library — User Manual |
| **Applies to** | Version 1.0.0 |
| **Audience** | Library staff and administrators |

Khulla Digital Library is open-source software, released under the MIT licence. The source code, issue tracker and website are linked from **Settings → About** inside the application.

*End of manual.*
