# RestroX Design System — Reverse-Engineered Visual Specification

> **Purpose.** This document is a faithful reconstruction of the *existing* visual language of the
> RestroX Next.js monorepo, written so a Flutter application can reproduce it exactly. Nothing here
> is a redesign or a proposal. Every value is traced to a source file. Where the codebase is
> internally inconsistent, the inconsistency is documented **as an inconsistency** with a
> recommendation for which value to canonicalise in Flutter — but the SaaS remains the source of truth.

**Source of truth files**

| Concern | File |
|---|---|
| Tokens (CSS variables) | `packages/ui/src/globals.css` |
| Token → utility mapping | `packages/ui/tailwind.config.ts` |
| Primitives (shadcn/ui-derived) | `packages/ui/src/components/ui/**` |
| App shell / sidebar | `apps/web/src/components/layouts/**`, `apps/web/src/app/[locale]/(with-auth)/(with-layout)/layout.tsx` |
| Modal & sheet registries | `apps/web/src/components/modals/data.ts`, `apps/web/src/components/sheets/data.ts` |
| Data table | `packages/ui/src/components/ui/table/**` |

Three apps consume the same package: `apps/web` (operator console, 907 `.tsx`), `apps/backoffice`
(admin, 294) and `apps/connect` (customer-facing mobile web, 51). All three re-export the *same*
Tailwind config (`export * from "@repo/ui/tailwind.config"`), so there is exactly **one** design system.

---

## 1. Design philosophy

Five properties define the look. Reproduce these before reproducing any single component.

1. **Dense, desktop-first operator UI.** This is a restaurant back-office, not a marketing site.
   Default body text is **12px** (`text-xs`), the default button is **36px** tall, table cells use
   `py-1.5` (6px). The design assumes many rows on screen at once.
2. **Density scales up, not down.** The dominant responsive axis is `3xl:` (**≥1600px**), used
   **1495 times** across `packages/ui` + `apps/web`. By comparison `md:` appears 25 times, `sm:` 58,
   `lg:` 9, `xl:` 4. There is essentially no mobile breakpoint work in the operator app — instead,
   on very large monitors *everything grows by one step* (12→14px text, 40→44px inputs, 16→20px icons,
   gap-3→gap-4). **This is the single most distinctive rule of the system.**
3. **One saturated brand red on a near-white ground.** `#D90819`. It is used sparingly — for the
   primary button, active navigation, destructive intent, focus rings and selected states. Everything
   else is a neutral grey. There is no secondary brand hue.
4. **Hairline borders, almost no shadow.** Structure comes from 1px `#EBE9F1` borders and very light
   tinted fills (`bg-accent/20`, `bg-dark-500/5`, `even:bg-dark-700/10`), not from elevation. Only
   overlays (dialog/sheet/popover/toast) carry visible shadow.
5. **Motion is small, fast and physical.** Ripple on button press, `scale: 0.95` while tapping, a
   3.5px left-padding nudge on input focus, a 90° close-icon rotation, spring radio indicators.
   Nothing slides more than ~8px; nothing takes longer than 500ms.

---

## 2. Color system

Colors are declared as **HSL channel triplets** in CSS variables and consumed via
`hsl(var(--x))`, which is what enables the `bg-primary/10` opacity-modifier idiom that this codebase
relies on very heavily. In Flutter, that idiom becomes `Color.withValues(alpha: …)`.

### 2.1 Brand ramp — `primary`

`--primary-100` is the brand; the ramp gets *lighter* as the number grows (opposite of Material).

| Token | HSL | Hex | Where used |
|---|---|---|---|
| `primary` / `primary-100` | `355 93% 44%` | **#D90819** | Primary button fill, active nav text/bar, focus ring, destructive text, required-field asterisk, `dashed-border-active` stroke |
| `primary-200` | `5 76% 54%` | #E33F31 | rarely |
| `primary-300` | `7 80% 60%` | #EB5A47 | rarely |
| `primary-400` | `9 85% 66%` | #F2755F | rarely |
| `primary-500` | `10 90% 72%` | #F88D77 | rarely |
| `primary-600` | `11 95% 78%` | #FCA592 | = `accent` |
| `primary-650` | `5 92% 95%` | #FEE8E7 | tint backgrounds |
| `primary-700` | `0 100% 99%` | #FFFAFA | faintest tint |
| `primary-foreground` | `0 0% 100%` | #FFFFFF | text on primary |

**Critical:** the *tint* used for hover/active/selected surfaces is **not** `primary-650`. It is
`accent` (#FCA592) at low alpha — `bg-accent/20` for sidebar hover/active, `bg-accent/10` for
selected table rows, `bg-accent/30` for the switch track. Reproduce it as `#FCA592` with alpha,
because compositing a 78%-light salmon at 20% over white gives a warmer result than tinting the red.

### 2.2 Ink ramp — `dark`

`dark-*` is a **text/ink ramp that inverts in dark mode**, not a fixed grey palette. In Flutter this
should be named `ink`, not `dark`, or you will invert it wrongly.

| Token | Light | Dark | Role |
|---|---|---|---|
| `dark` / `dark-100` | `0 0% 7%` #121212 | #FFFFFF | primary ink |
| `dark-200` | `0 0% 16%` #292929 | #F5F5F5 | **label text**, dialog titles |
| `dark-300` | `0 0% 25%` #404040 | #DEDEDE | sub-nav link text |
| `dark-400` | `0 0% 34%` #575757 | #C9C9C9 | **sidebar link text (rest state)**, filter labels |
| `dark-500` | `0 0% 44%` #707070 | #B5B5B5 | secondary/meta text, outline-button text, char counters |
| `dark-600` | `0 0% 55%` #8C8C8C | #9E9E9E | tertiary, unchecked radio dot fill |
| `dark-700` | `210 14% 83%` #CED4DA | #CED4DA (**not inverted**) | checkbox border, zebra-stripe base, hairline connectors |

`dark-700` is the only rung that does not invert — it is a *line* colour, not an ink colour.

### 2.3 Fixed neutral ramp — `white`

`white-*` does **not** invert in dark mode. Use it only where a literally-light surface is intended.

`white`/`white-100` #FFFFFF · `white-200` #F5F5F5 · `white-300` #DEDEDE · `white-400` #C9C9C9 ·
`white-500` #B5B5B5 · `white-600` #9E9E9E (input leading-icon colour, unchecked switch track at 50%).

### 2.4 Semantic tokens

| Token | Light | Dark | Notes |
|---|---|---|---|
| `background` | #FFFFFF | #121212 | |
| `foreground` | #121212 | #FFFFFF | |
| `card` | **#F5F5F5** | #292929 | note: card is *greyer* than the page |
| `card-foreground` | #121212 | #FFFFFF | |
| `popover` | #FFFFFF | #292929 | |
| `popover-foreground` | #121212 | #FFFFFF | |
| `secondary` | `216 24% 96%` **#F2F4F7** | — | secondary button, ghost hover, tab strip |
| `secondary-foreground` | ⚠ `0 0 0%` — **malformed** (missing `%` on saturation) | — | see §2.6 |
| `muted` | `0 0% 87%` #DEDEDE | #404040 | separators, table-row hover at 50% |
| `muted-foreground` | `0 0% 60%` #999999 | #DEDEDE | placeholders, table head text, captions |
| `accent` | `11 95% 78%` #FCA592 | #C9C9C9 | tint source (see §2.1) |
| `accent-foreground` | #FFFFFF | #121212 | |
| `destructive` | #D90819 | #D90819 | identical to primary |
| `destructive-foreground` | ⚠ #121212 | #FFFFFF | see §2.6 |
| `border` | `255 22% 93%` **#EBE9F1** | `0 0% 20%` #333333 | faint lavender-grey hairline |
| `input` | ⚠ #D90819 | #292929 | see §2.6 |
| `ring` | #D90819 | #292929 | focus ring |
| `role` | `194 100% 50%` #00C4FF | | role chips |
| `success-500` | `143 83% 39%` #11B650 | | |
| `success-600` | `140 82% 33%` #0F993D | | |
| `warn-500` | `37 100% 44%` #E08A00 | | |
| `warn-600` | `29 77% 57%` #E68F3D | | |
| `premium` | `39 98% 56%` #FDB021 | | subscription/premium accents |

### 2.5 Hard-coded status colors (intentional, in `badge.tsx`)

These bypass the token system deliberately and must be carried over verbatim:

* active / success chip — bg `#e0f9ec15`, text `#32d583`, border `#e0f9ec`
* inactive / error chip — bg `#f7001915`, text `#da0819`, border `#f7001950`
* pending chip — bg `#FDB02215`, text `#FDB022`, border `#FDB02215`
* open / info chip — bg `#00C2FF15`, text `#00C2FF`, border `#00C2FF15`
* violet chip — bg `#efe3ff15`, text `#ad6eff`
* role chip — bg `#28C76F1F`, text `#28C76F`
* payment-out chip — bg `#fff0f2`, text `#da0819`, border `#cd1d2c1b`
* sticky-column row backgrounds — `#fafafb` (odd), `#fef6f4` (selected), `#ededee` (hover),
  `#252526` (dark) — `table/row.tsx`
* gradient text (`subscription-gradient-text`) — `linear-gradient(90deg, #423a8f 0%, #d50a1d 100%)`
* default avatar fallback background — `#E1E6FF`

Note the `15`/`1F`/`50`/`1b` suffixes: these are **8-digit hex with an alpha byte** (`15` ≈ 8%,
`1F` ≈ 12%, `50` ≈ 31%). Flutter must apply the alpha, not treat them as opaque.

### 2.6 Known token defects (do NOT faithfully reproduce)

Three tokens are, on the evidence, mistakes rather than intent:

1. **`--input: 355 93% 44%`** — the brand red. `border-input` is used by `SelectTrigger` and
   `RadioGroupItem`, so an un-overridden select trigger renders with a **red 1px border** while a
   text `Input` (which uses `border-border`) renders with the lavender-grey hairline. In practice
   nearly every select in the app overrides it (`border-none dashed-border`, `border-muted`, …), which
   is why it survives. **Flutter: use `border` (#EBE9F1) for all resting field borders.**
2. **`--secondary-foreground: 0 0 0%`** — missing the `%` on saturation, so the declaration is invalid
   and the colour falls through to inherited text. **Flutter: use `foreground` (#121212).**
3. **`--destructive-foreground: 0 0% 7%`** in light mode — near-black on a red fill would fail
   contrast. It is never actually exercised, because the `destructive` button variant is an *outline*
   (red text on transparent), not a red fill. **Flutter: destructive text = #D90819; if a filled
   destructive is ever needed, put #FFFFFF on it.**

### 2.7 Theme mode

`ThemeProvider` (next-themes) is wired up and `DEFAULT_SYSTEM_THEME = "light"`
(`packages/ui/src/config/constants.ts`), and a `.dark` block exists. **But `apps/web` and
`apps/connect` hard-code `<html className="light" style={{colorScheme:"light"}}>`.** Dark mode is
authored but effectively dormant in the shipped operator and customer apps.

**Flutter guidance:** implement the light theme as the shipped product. Carry the dark values into
the token file (they are recorded in `design-tokens.json`) so a dark theme is a data change, not a
rewrite — but do not ship dark as a supported mode unless asked.

---

## 3. Surface / background hierarchy

Flat, four levels, distinguished by hairlines more than by fill:

| Level | Fill | Border | Shadow | Example |
|---|---|---|---|---|
| 0 — page | `background` #FFFFFF | — | — | scroll container |
| 1 — sidebar | `background` #FFFFFF | `border-r` 1px #EBE9F1 | — | `aside` |
| 1 — bordered block | transparent | 1px #EBE9F1, `rounded-md` | — | table wrapper, filter chips, stat cards, sidebar profile box |
| 2 — Card component | `card` #F5F5F5 | 1px #EBE9F1, `rounded-lg` | `shadow-sm` | `Card` |
| 3 — popover/dropdown/tooltip | `popover` #FFFFFF | 1px, `rounded-md` | `shadow-md` | menus |
| 4 — dialog / sheet / toast | `background` #FFFFFF | 1px | `shadow-lg` | modals |

Overlay scrim: **`bg-black/40`** for both Dialog and Sheet; **`bg-black/80`** for the vaul Drawer.

Tinted surfaces (the workhorse of this design — all are alpha over the page, never solid):
`bg-accent/20` (nav hover + nav active), `bg-accent/10` (selected row), `bg-accent/[3%]` (default
`TableHeader`), `bg-dark-500/5` (data-table header as actually used), `bg-dark-700/10` (zebra row +
tab strip track), `bg-dark-500/10` (table footer), `bg-muted/50` (row hover), `bg-secondary/50`
(menu-item focus), `bg-primary/10` (highlighted row), `bg-primary/5` (active filter select),
`bg-success-500/10`, `bg-destructive/10`.

---

## 4. Typography

### 4.1 Families

* **Primary — Poppins**, `next/font/google`, weights 100–900, `display: swap`, exposed as
  `--custom-primary-font` → `font-primary`. Applied globally: `* { @apply border-border font-primary }`.
  **Every element in the app is Poppins.**
* **Printer — Merchant Copy** (`Merchant-Copy.ttf`) → `font-printer`. Receipt/KOT preview only.
* **Roboto** — declared in the Tailwind config and defined only in `apps/backoffice`; unused in `web`.
* **PDF export** — DejaVu Sans / Poppins-Bold / Poppins-Regular `@font-face` for Kendo PDF output only.

### 4.2 Scale as actually used

Measured frequency across `packages/ui/src` + `apps/web/src`:

| Class | px | uses | Role |
|---|---|---|---|
| `text-[10px]` | 10 | — | badge text, form error message |
| `text-xs` | **12** | 1016 | **default body / table cells / inputs / labels / menu items** |
| `text-sm` | **14** | 1026 | secondary body; base size of `<table>`; tooltips; dropdown labels |
| `text-base` | 16 | 353 | sidebar top-level link at ≥1600px |
| `text-lg` | 18 | 185 | dialog title, sheet title, empty-state title, page header |
| `text-xl` | 20 | 115 | form-modal title, stat value |
| `text-[22px]` | 22 | 28 (3xl only) | page header at ≥1600px |
| `text-2xl` | 24 | 64 | `CardTitle`, form-modal title at ≥1600px |
| `text-3xl` | 30 | 7 | sheet form title |
| `text-4xl` | 36 | 1 | editor h1 only |

### 4.3 The paired-size rule (essential)

Sizes are almost never written alone. The canonical pairs, in frequency order:

* `text-xs 3xl:text-sm` — 12 → 14. Body, inputs, selects, table cells, labels, menu items.
* `text-sm 3xl:text-base` — 14 → 16. Sidebar links, section text.
* `text-[10px] 3xl:text-xs` — 10 → 12. Badges, form error messages.
* `text-lg 3xl:text-xl` — 18 → 20. Empty-state title.
* `text-xl 3xl:text-2xl` — 20 → 24. Form-modal title.
* `text-lg 3xl:text-[22px]` — 18 → 22. Page header.

**Flutter:** define text styles as *pairs* resolved from a single `isWide = width >= 1600` (or, on a
phone, always the base rung). Do not invent intermediate sizes.

### 4.4 Weights

Poppins is loaded at every weight, but only four are used in the UI:

* **400 regular** — body copy, table cell values, sidebar links (`font-normal` is set explicitly on
  the sidebar accordion trigger to defeat the primitive's `font-medium`).
* **500 medium** — the default for interactive text: buttons, labels, tabs, dialog descriptions,
  page headers, form error text, dropdown content, pagination size selector.
* **600 semibold** — table column headers, dropdown section labels, `CardTitle`, badges,
  search-panel section headings, stat-card titles.
* **700 bold** — empty-state heading, editor `h1`. Rare.

`DialogTitle` and `SheetTitle` are `font-semibold` in the primitive but the `Modal`/`Sheet` wrapper
downgrades the form variant to `font-medium`. Form modals — 98 of 141 — are therefore **medium**.

### 4.5 Line height / tracking

`leading-none` on `CardTitle`, `DialogTitle` and `Label`; `tracking-tight` on `CardTitle`/`DialogTitle`;
`tracking-widest` on keyboard-shortcut hints. Otherwise Tailwind defaults (≈1.5 for body,
`line-clamp-1` + ellipsis on every table cell).

---

## 5. Spacing scale

Standard Tailwind 4px base. Measured usage:

`gap-1` 4 (109×) · `gap-2` 8 (422×) · `gap-2.5` 10 · `gap-3` 12 (374×) · `gap-3.5` 14 ·
**`gap-4` 16 (490×)** · `gap-5` 20 · `gap-6` 24 · `gap-8` 32

`space-y-1` 4 · `space-y-1.5` 6 · `space-y-2` 8 (146×) · `space-y-3` 12 (146×) ·
**`space-y-4` 16 (256×)** · `space-y-5` 20 · `space-y-6` 24 · `space-y-8` 32

Horizontal padding: `px-2` 8 (281×) · `px-3` 12 (131×) · `px-4` 16 (171×) · `px-2.5` 10 · `px-6` 24

### 5.1 Spacing rhythm rules

1. **Page shell:** `px-6 py-5` (24/20) on the main scroll container.
2. **Form rows:** `space-y-3 3xl:space-y-4` between rows; `gap-3 3xl:gap-4` between side-by-side
   fields. Two fields per row is the standard layout.
3. **Field internals:** `3xl:space-y-3 space-y-2` between label and control (`FormInput`, vertical),
   `space-y-2` in the raw `FormItem`.
4. **Table stack:** `grid gap-y-3` between header row / filter row / table / pagination.
5. **Sidebar:** `px-2` on the list, `space-y-1.5` between groups, `p-2.5 px-3` inside a link,
   `gap-4` icon→label, sub-links `px-5 py-2.5` with `gap-2`.
6. **Dialog:** `p-6` on the primitive, but `Modal` overrides to `p-0` and the inner scroll region
   uses `p-8` for the `form` variant. `gap-4` between stacked children.
7. **Empty state:** `py-24` (`py-9` for the small variant), `space-y-6`, inner `space-y-2`.

---

## 6. Border system

* **Width:** 1px everywhere. Exceptions: checkbox `border-[1.5px]`, switch `border-2 border-transparent`
  (a track inset, not a visible line), shortcut `kbd` `border-[0.5px]`, dashed drop-zone stroke 2px.
* **Color:** `border` = **#EBE9F1** (light) / #333333 (dark). Global default via
  `* { @apply border-border }`, so any `border` utility inherits it without restating the colour.
* **Opacity variants in use:** `border-red-700/70` (default button), `border-green-600/70` (success
  button), `border-white/30` (kbd on primary), `border-transparent` (filled badges, ghost button).
* **Ghost button carries `border border-transparent`** so that hover/focus does not shift layout —
  reproduce this as a transparent 1px border in Flutter, not as zero border.
* **Dashed borders** are SVG background images, not CSS borders (`.dashed-border` stroke `#ebe9f1`,
  `.dashed-border-active` stroke `#d90819`, both `6,6` dash, `rx=6`). Used for filter selects and
  file drop zones. In Flutter: a dashed painter with 6-on/6-off, 2px stroke, 6px corner radius.

---

## 7. Border radius scale

`--radius: 0.5rem` (8px) drives three Tailwind rungs:

| Rung | Value | Applied to |
|---|---|---|
| `rounded-sm` | `calc(8px - 4px)` = **4px** | menu items, select items, tab triggers, dialog close button, tab-link strip |
| `rounded-md` | `calc(8px - 2px)` = **6px** | **inputs, selects, textareas, table wrapper, dropdown/popover/tooltip content, most containers (573 uses — the dominant radius)** |
| `rounded-lg` | **8px** | `Button`, `Card`, `Dialog` (`sm:rounded-lg`), search results panel, sidebar nav row |
| `rounded-full` | pill | badges, avatars, switch, radio, progress bar, active-nav vertical bar (`rounded-e-full`) |
| `rounded-xl` / `rounded-2xl` | 12 / 16 | rare, marketing-ish surfaces |
| `rounded-t-[10px]` | 10 | vaul Drawer top corners only |

**Radius hierarchy rule:** *controls that sit inside a container are more rounded than the container's
inner elements, and the container is 6px.* Buttons (8) > containers (6) > menu items (4). Getting this
inverted is the most common visual error — do not make everything 8px.

---

## 8. Shadow / elevation

Tailwind defaults, used at only three levels. Shadows here are **soft and shallow** — the largest is
a 10px blur at 10% black.

| Level | Class | Value | Used by |
|---|---|---|---|
| 1 | `shadow-sm` | `0 1px 2px 0 rgb(0 0 0 / .05)` | **every Button**, `Card`, sticky table header |
| 2 | `shadow-md` | `0 4px 6px -1px rgb(0 0 0 / .1), 0 2px 4px -2px rgb(0 0 0 / .1)` | dropdown, popover, tooltip, select content, google-places container |
| 3 | `shadow-lg` | `0 10px 15px -3px rgb(0 0 0 / .1), 0 4px 6px -4px rgb(0 0 0 / .1)` | dialog, sheet, toast, dropdown *sub*-menu, dialog close button, switch thumb |

`shadow-none` is explicitly set on `link`, `ghost` and `table-header` button variants.

**Flutter:** `shadow-sm` ≈ `BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 2,
offset: Offset(0,1))`. Do not substitute Material `elevation:` — Material's default elevation shadows
are far darker and will make the UI look nothing like this.

---

## 9. Icon sizing

Icons are **lucide-react** (`lucide-react@0.395`) with `react-icons` as a secondary source.

| Size | px | Where |
|---|---|---|
| `size-3` | 12 | dense chevrons, sidebar bullet circles, row action icon at base width |
| `size-3.5` | **14** | **default icon size inside every Button** (`[&_svg:not([class*='size-'])]:size-3.5`) |
| `size-4` | **16** | **the everyday icon size — 273 uses.** Menu-item icons (`size={16} mr-2.5`), select chevron, table sort chevrons, checkbox tick container, dialog close X |
| `size-5` | 20 | sidebar icons at ≥1600px, page-header chevrons, sidebar collapse chevron (`size={20}`), connect bottom-nav |
| `size-6` / `size-7` | 24 / 28 | occasional, sheet close X at ≥1600px |
| `size-8`–`size-10` | 32–40 | avatars, sheet close X (`size-10`) |

Common pattern `size-3 3xl:size-4` and `size-4 3xl:size-5` — icons step up with the `3xl` rung too.

**Stroke widths:** lucide default 2, except checkbox tick `strokeWidth={4}` and the sidebar bullet
`LucideCircle strokeWidth={5}` (which renders as a filled dot with a background-coloured ring).

Icon-to-label gap: `gap-2` (8) in buttons; `mr-2.5` (10) in dropdown items; `gap-4` (16) in sidebar links.

---

## 10. Component density

The numbers that define "how tight this app feels". Get these wrong and nothing else matters.

| Element | Base | ≥1600px |
|---|---|---|
| Default button height | **36px** (`size: "sm"` is the CVA default) | 36 |
| `size="default"` button | 40px | 40 |
| `size="lg"` button | 44px | 44 |
| Icon buttons | `xs`/`icon-xs` 32 · `icon-sm` 36 · `icon` 40 · `icon-lg` 44 | same |
| Text input / textarea | **40px** (`h-10`) | **44px** (`3xl:h-11`) |
| Select trigger | 40px | 40 (no 3xl bump — an inconsistency vs Input) |
| Table header cell | **40px** (`h-10`) | **48px** (`3xl:h-12`) |
| Table body cell padding | `px-4 py-1.5` → row ≈ **36–38px** | `py-2.5` → row ≈ **44px** |
| Dropdown / context menu item | `px-2 py-2.5` → **~38px** | ~40px |
| Select item | `py-1.5 px-2`; `SelectInput` forces `h-10 3xl:h-11 pl-3` | 44 |
| Command item | `min-h-10` | `min-h-11` |
| Checkbox | **16px** with 1.5px border, 10px tick | 16 |
| Radio | 16px with 10px indicator dot | 16 |
| Switch | 32×16, thumb 12 | 36×20, thumb 16 |
| Switch (`size="small"`) | 28×12, thumb 8 | 32×16, thumb 12 |
| Badge | `px-2.5 py-0.5`, 10px text | 12px text |
| Avatar | 40px default (prop-driven) | 40 |
| Top nav / logo row | `min-h-14` (56px, `.nav-height`) | 56 |
| Sidebar expanded | **240px** (`max-w-[240px]`) | 240 |
| Sidebar collapsed | **64px** (`max-w-16`) | 64 |
| Sidebar nav row | `h-9.5` = **38px** | `3xl:h-[42px]` |
| Pagination button | forced `!h-9.5` = 38px | 38 |
| Page-size select | `h-8` | `3xl:h-9.5` (38) |

`h-9.5` (`2.375rem` = 38px) and `w-24.75` (`6.188rem`) are **custom Tailwind extensions** in
`packages/ui/tailwind.config.ts` — real intentional tokens, not typos.

---

## 11. Buttons

`packages/ui/src/components/ui/button/new-button.tsx`. `Button` and `NewButton` are the same
component; the legacy alias is kept for compatibility. Built on `motion/react` — it is a
`motion.button`, not a plain button.

### 11.1 Base (all variants)

```
relative overflow-hidden inline-flex items-center justify-center gap-2 whitespace-nowrap
rounded-lg text-sm font-medium shadow-sm cursor-pointer shrink-0 transition-all outline-none
disabled:pointer-events-none disabled:opacity-50
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-3.5
focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]
```

8px radius · 14px text · weight 500 · 8px icon gap · 14px icons · `shadow-sm` ·
**focus = a 3px ring at 50% alpha of the variant's ring colour** (not a 2px offset ring).
Disabled = **50% opacity of the whole button** plus pointer-events off. There is no separate
disabled colour.

### 11.2 Variants

| Variant | Rest | Hover | Notes |
|---|---|---|---|
| `default` | fill `primary` #D90819, text #FFF, **1px `red-700/70`** border | `bg-primary/90` | The border is a real, darker red hairline on the fill |
| `destructive` | transparent, text #D90819, 1px #D90819 | `bg-destructive/10` | **outline, not filled** |
| `outline` | `bg-background`, text `dark-500` #707070, 1px `border` | (none declared — ripple only) | focus ring `secondary`, focus border `border` |
| `secondary` | `bg-secondary` #F2F4F7, text `secondary-foreground` | `bg-secondary/80` | |
| `ghost` | transparent, `border border-transparent`, `shadow-none` | `bg-secondary` #F2F4F7 | focus border `gray-300` |
| `success` | `bg-green-500`, text #FFF, 1px `green-600/70` | `bg-success/90` | uses Tailwind `green-500` (#22C55E), **not** the `success-500` token (#11B650) — a local exception |
| `link` | text `blue-700`, no bg, `shadow-none` | underline | Tailwind blue-700 #1D4ED8, not a token |
| `table-header` | no bg, no shadow, `text-dark`, **font-semibold** | — | column-header sort trigger |

### 11.3 Sizes

`default` h-10 px-4 py-2 (`has-[>svg]:px-3`) · **`sm` (DEFAULT) h-9 rounded-md gap-1.5 px-3
(`has-[>svg]:px-2.5`)** · `lg` h-11 px-8 (`has-[>svg]:px-6`) · `icon` 40² · `xs`/`icon-xs` 32² ·
`icon-sm` 36² · `icon-lg` 44² · `link` `h-fit px-0 py-0` · `table-header` `h-fit px-0 py-0`.

Two things AI reliably gets wrong here:
1. **The default size is `sm` (36px), and `sm` also drops the radius to `rounded-md` (6px) and the
   gap to 6px.** So the *typical* button in this app is 36px tall with a 6px radius — not 40/8.
2. **Horizontal padding shrinks when the button contains an icon** (`has-[>svg]:px-*`), by 4px at
   `default`/`sm` and 8px at `lg`.

### 11.4 States and motion

* **Pressed:** `whileTap={{ scale: 0.95 }}` with the shared transition
  (`{ duration: 0.6, ease: "easeOut" }`).
* **Ripple:** on click, a `size-5` (20px) circle is spawned at the pointer, positioned
  `top: y-10, left: x-10`, animated `scale 0 → 10`, `opacity 0.5 → 0` over **600ms easeOut**, then
  removed. Ripple colour per variant: `default` → `bg-secondary`; `destructive` → `destructive/20`;
  `outline`/`secondary` → `gray-300/80`; `ghost` → `gray-300/70`; `success` → `secondary/80`.
* **Loading:** children are *replaced* by a masked SVG spinner (`.loading-spinner .loading-spin
  .loading-md`, width `1.2rem` ≈ 19px, `bg-current` behind a rotating-arc mask, 1.5–2s loop). Colour
  per variant: white on `default`/`destructive`/`success`, black on `ghost`/`outline`/`secondary`.
  The button stays the same size; clicks are swallowed while loading.
* **Shortcut chip:** optional `<kbd>` rendered inside the button —
  `bg-white/20 h-[17px] rounded border-[0.5px] border-white/30 px-1 text-[0.625rem] font-medium
  aspect-square ms-1 -me-1`, offset `-top-[0.5px]`. Per-variant recolour (see `shortcutVariants`).
  A global `keydown` listener fires the button when the key matches and focus is not in an input.

---

## 12. Inputs

`packages/ui/src/components/ui/input/input.tsx`

```
h-10 3xl:h-11 w-full rounded-md border border-border bg-background px-3 py-2
text-xs 3xl:text-sm placeholder:text-muted-foreground
disabled:cursor-not-allowed disabled:opacity-50
focus:pl-3.5 transition-all ease-in-out duration-300
```

* 40 → 44px tall, 6px radius, 1px #EBE9F1 border, 12px horizontal padding, 12 → 14px text.
* Placeholder colour `muted-foreground` #999999.
* **Signature detail:** `preventFocusStyles` defaults to **true**, so there is *no focus ring on
  inputs*. Focus is signalled purely by `focus:pl-3.5` — the text nudges **2px to the right over
  300ms ease-in-out**. Reproduce this; it is the most recognisable micro-interaction in the app.
  When `preventFocusStyles={false}`, a 1px `ring` with 1px offset appears instead.
* Number inputs: spinners removed globally (`::-webkit-*-spin-button { appearance: none }`,
  `-moz-appearance: textfield`), wheel-scroll blurs the field, keydown is filtered for step/max/negative.
* `textarea { @apply resize-none }` globally. `Textarea` uses `react-textarea-autosize`,
  `minRows={5} maxRows={10}`, same skin minus the fixed height.
* **`InputWithIcon`** — icon absolutely positioned `left-4 top-1/2 -translate-y-1/2`, colour
  `white-600` #9E9E9E, search icon 18px / plus 22px; input gets `pl-12` and `focus:pl-[51px]`
  (the same 3px nudge). `reverse` moves the icon to `right-4`.
* Error text: `text-[10px] 3xl:text-xs font-medium text-destructive`, no icon, sits below the field.
* Label: `text-xs 3xl:text-sm font-medium leading-none text-dark-200`, turns `text-destructive` on
  error; required marker is a **red space-asterisk** `<span className="text-primary"> *</span>`.
* Character counter (when `charLimit`): `text-xs text-dark-500`, right-aligned on the label row.

---

## 13. Selects

`select.tsx` (Radix). Trigger: `h-10 w-full rounded-md border border-input bg-background px-3 py-2
text-xs 3xl:text-sm [&>span]:line-clamp-1`, chevron `size-4 opacity-50`.
**Focus ring is explicitly disabled** (`focus:ring-0 focus:ring-offset-0`) — consistent with Input.
See §2.6 on `border-input` rendering red.

Content: `max-h-96 min-w-[8rem] rounded-md border bg-popover shadow-md`, viewport padding
`p-1.5 3xl:p-2.5`, popper-positioned with a 4px directional offset and min-width locked to the
trigger width (`min-w-[var(--radix-select-trigger-width)]`).

Item: `rounded-sm py-1.5 px-2 text-xs 3xl:text-sm`, focus `bg-secondary/50`,
**checked → `text-primary` + `bg-accent/20`**, disabled 50%. The check icon is opt-in
(`isCheckIcon`); most selects show the selection by colour alone.

`SelectInput` (the app-level wrapper) is what most screens use: it strips the border
(`border-none dashed-border`) and, when a value is set, switches to
`bg-primary/5 text-primary dashed-border-active` — i.e. **filter selects are dashed-outline chips
that turn red-tinted when active**, not conventional dropdowns.

Related: `MultiSelect`, `ComboboxInput`, `AsyncSelect`, `ToggleableSelect`, `CustomTextSelect`
all build on the same trigger/content skin.

---

## 14. Checkboxes, radios, switches

**Checkbox** — 16×16, `rounded-sm` (4px), **1.5px** `dark-700` #CED4DA border. Checked: border →
`primary`, tick → `primary` (`Check size-2.5 strokeWidth={4}`), background stays transparent
(`data-[state=checked]:bg-primary-background`, an undefined class → no fill). **So a checked
checkbox is a red tick in a red 1.5px box on white, not a filled red box.** `colorVariant="green"`
swaps to `green-500`. Indeterminate renders the indicator at `opacity-0`. Focus: 1px ring, 2px offset.

**Radio** — 16×16 circle, 1px `border-input`, `text-primary`; indicator is a `Circle size-2.5
fill-current` animated in with a **spring (`stiffness: 200, damping: 16`)**; the whole item has
`whileHover={{ scale: 1.05 }}` and `whileTap={{ scale: 0.95 }}`. Group layout `grid gap-2.5` (10px).

Some screens (e.g. `add-customer.tsx`) hand-roll a radio as a ghost button containing a 16px
`rounded-full border p-0.5` box with an inner filled span — a **screen-specific pattern**, see the
mapping doc.

**Switch** — track `rounded-full border-2 border-transparent`; **32×16 base, 36×20 at ≥1600px**
(`small`: 28×12 / 32×16). Off: track `bg-white-600/50`, thumb `bg-background` (white) with
`shadow-lg`. On: track `bg-accent/30`, or per `color` prop `bg-accent/10` (primary) /
`bg-success-500/10` / `bg-blue-500/10`; thumb `bg-primary` / `success-500` / `blue-500`, translated
`translate-x-4` (16px). Transition `transition-colors` on the track, `transition-all ease-in-out`
on the thumb.

**Note the unusual off-state:** the track is a translucent grey and the thumb is *white with a
shadow*; on-state is a **very pale tinted track with a saturated thumb** — the track never becomes
solid brand colour. This is the opposite of Material's switch and must be copied deliberately.

---

## 15. Tables

The data table (`table/data-table.tsx`, ~850 lines) is the centrepiece of the operator app —
TanStack Table + dnd-kit + a filter/function slot system.

### 15.1 Structure

```
grid gap-y-3
├─ header row      flex justify-between gap-4 flex-wrap-reverse
│  ├─ title        text-lg 3xl:text-[22px] font-medium, h-10 (+ back button icon-sm outline)
│  └─ functions    ml-auto grid  (export, column toggle, filter toggle, bulk actions)
├─ filters row     flex flex-wrap items-center gap-3   (conditional)
├─ {children}
├─ table wrapper   rounded-md border overflow-hidden
└─ pagination row  flex md:flex-row flex-col items-center py-1
   ├─ selection count  flex-1 text-xs 3xl:text-sm text-muted-foreground
   └─ paginator        flex justify-end
```

### 15.2 Metrics

* **Header:** `bg-dark-500/5` (the primitive's own default is `bg-accent/[3%]`); `h-10 3xl:h-12`;
  `px-4`; `text-xs 3xl:text-sm`; `font-semibold`; `text-muted-foreground` from the primitive but
  overridden to `text-dark` in the data table. Sortable headers are `table-header` buttons
  (`text-sm font-semibold py-0.5 px-0 h-fit`) whose chevron is `size-4`, **hidden at `opacity-0`
  and revealed on hover** (`group-hover:opacity-100 transition-opacity duration-150`) when unsorted.
* **Body row:** `even:bg-dark-700/10` zebra · `hover:bg-muted/50` · selected
  `data-[state=selected]:bg-accent/10` · highlighted `!bg-primary/10` · `transition-colors`.
* **Cell:** `px-4 py-1.5 3xl:py-2.5 align-middle` → **~36–38px rows, ~44px at ≥1600px**. Content is
  wrapped in `line-clamp-1 whitespace-nowrap max-w-sm overflow-ellipsis [&_*]:break-all`.
* **Selector / serial columns** are pinned to `width: 10` and get `!px-2` / `!px-1`.
* **Row-select checkbox is `invisible group-hover:visible`** — it only appears on row hover, and
  stays visible once the row is selected. Distinctive and easy to miss.
* **Footer:** `bg-dark-500/10`, `border-t`, `font-medium`.
* **Sticky columns:** when enabled, the wrapper scrolls (`custom-scrollbar-thin`), the header goes
  `sticky top-0 z-40 shadow-sm bg-background`, and cells take explicit backgrounds
  (`#fafafb` odd / `bg-background` even / `#fef6f4` selected / `#ededee` hover).
* **Empty body:** an `invisible` spacer `TableRow` of `h-[410px]` keeps the frame, with the empty
  state absolutely positioned over it — so the table never collapses.
* **Drag handle** column (`SORTABLE_THUMB_COLUMN`) appears only when reordering is toggled on.

---

## 16. Cards

Two distinct things are called "card":

1. **The `Card` primitive** (`card.tsx`) — `rounded-lg border bg-card text-card-foreground shadow-sm`;
   `CardHeader` `flex flex-col space-y-1.5 p-6`; `CardTitle` `text-2xl font-semibold leading-none
   tracking-tight`; `CardDescription` `text-sm text-muted-foreground`; `CardContent` `p-6 pt-0`;
   `CardFooter` `flex items-center p-6 pt-0`. Note `bg-card` is **#F5F5F5**, slightly darker than
   the page. This is stock shadcn and is used comparatively rarely.
2. **The ad-hoc bordered block** — `border rounded-md p-4` with `space-y-3` — which is what the
   product actually uses for stat cards, list cards and panels
   (e.g. `pages/analytics/detail-card.tsx`). White background, 6px radius, no shadow.

**Flutter:** build `AppCard` around pattern 2 (the real one) and expose pattern 1 as a `filled`
variant. Do not default to the `p-6` / 24px-text shadcn card — nothing in the product looks like that.

Stat card anatomy (`detail-card.tsx`): title row `flex items-center gap-3 font-semibold` plus a
delta chip `flex items-center text-sm` in `text-green-500` / `text-red-500` with an
`ArrowUp`/`ArrowDown` at 18px; value `text-xl font-semibold` with the `currency` class
(a `::before` that injects the restaurant's currency symbol from a CSS variable).

---

## 17. Badges / status indicators

`inline-flex items-center rounded-full border px-2.5 py-0.5 text-[10px] 3xl:text-xs font-semibold
transition-colors` — **10px semibold pill, 10px horizontal padding, 2px vertical**. Tiny.

Variants: `default` (primary fill, white text) · `secondary` · `destructive` · `outline` (text only) ·
`outline-secondary` (`bg-secondary/70 px-1.5 py-0 font-medium`) · `success` · `info` ·
`role` · `table-status-active|inactive|pending|open|violet` · `status-blue` · `status-payment-out`
(the last two override to `rounded-lg px-2 py-0.5 font-normal`). Exact colours in §2.5.

Optional `size` (`md` = `px-4 py-2`, `sm` = `px-2.5 py-1`) and `shape`
(`pill-md` → `rounded-md`, `pill-sm` → `rounded-sm`) override the pill.

**The dominant pattern is the tinted status chip:** a ~8% alpha fill of the status hue, the same hue
at full strength for the text, and a border in the hue at ~8–30%. All three come from one colour.

---

## 18. Tabs

Three separate tab systems coexist — Flutter needs all three, and they must not be conflated.

1. **`Tabs` primitive** (Radix) — list: `inline-flex rounded-md border bg-secondary p-1`;
   trigger: `rounded-sm px-3 py-1.5 text-sm font-medium transition-all`, inactive `bg-transparent
   text-background`, **active `bg-primary text-white shadow-sm`**. A red segmented control on a
   #F2F4F7 track.
2. **`TabsLinks`** (`re-useables/tabs-link.tsx`) — route-driven segmented control:
   container `flex items-center border rounded-sm bg-dark-700/10 py-1 px-1 gap-2`; item
   `text-sm font-medium py-1.5 rounded-sm`, active `text-white bg-primary`; link padding `py-1.5 px-4`.
   Visually the same idea, on a `#CED4DA @10%` track, and it hosts the filter/function slot on its right.
3. **`AnimatedTabs`** (`animated-tabs.tsx` + `motion-highlight.tsx`) — motion-highlighted tabs with
   two variants: `underline` (a 2px `bg-primary` bar rendered via `after:` at `-bottom-8`, active
   text `text-primary`) and `transparent` (`bg-primary/10` pill, active text `text-primary`).
   The highlight animates between triggers via a shared layout element.

---

## 19. Dropdowns and popovers

**DropdownMenu** — content `z-50 min-w-[8rem] rounded-md border bg-popover p-1 shadow-md`;
sub-content identical but `shadow-lg`; `sideOffset={4}`.
Item: `rounded-sm px-2 py-2.5 text-xs 3xl:text-sm transition-colors`, focus `bg-secondary/50`,
disabled 50%. Checkbox/radio items reserve `pl-8` with the indicator absolutely at `left-2`
in a `size-3.5` box (tick `size-3 3xl:size-4`; radio dot `size-2 fill-current`).
Label `px-2 py-2.5 text-sm font-semibold`. Separator `-mx-1 my-1 h-px bg-muted`.
Shortcut `ml-auto text-xs tracking-widest opacity-60`.

Row action menus (`table/action-buttons.tsx`) are `w-48 font-medium`, `align="end"`, trigger is a
`ghost`/`icon` button with `MoreHorizontal size-3 3xl:size-4`. Items are View (`Eye`), Edit (`Edit3`),
Delete — all icons at `size={16} mr-2.5`, delete styled `text-primary font-medium`. The same menu is
rendered as a `ContextMenu` on right-click via a component swap.

**Popover** — `z-50 w-72 rounded-md border bg-popover p-4 shadow-md`, `align="center"`,
`sideOffset={4}`; in dark mode nested inputs get `bg-background/30`.

**Entry/exit animation (shared by dropdown, popover, select, tooltip, context menu):**
`fade-in-0 zoom-in-95` on open, `fade-out-0 zoom-out-95` on close, plus a directional
`slide-in-from-{side}-2` (8px) — i.e. **fade + 95%→100% scale + an 8px slide from the trigger side**.

---

## 20. Dialogs

Primitive `DialogContent`: `fixed left-1/2 top-1/2 -translate-1/2 z-50 grid w-full max-w-lg gap-4
border bg-background p-6 shadow-lg sm:rounded-lg duration-200`, over a `bg-black/40` overlay.
Enter: `fade-in-0 zoom-in-95 slide-in-from-left-1/2 slide-in-from-top-[48%]` — a **200ms fade +
95% zoom from 2% above centre**.

**Close button (signature detail).** It sits *outside* the top-right corner:
`absolute -right-2.5 -top-2` (`3xl:-right-3 3xl:-top-3`), `rounded-sm bg-background p-1 3xl:p-1.5
shadow-lg border`, and on hover it **moves 2–4px further out** (`hover:-right-2 hover:-top-1`,
300ms ease-in-out) while the `X` (`size-4 3xl:size-5`) **rotates 90°**.

**The `Modal` wrapper** (`components/modal/modal.tsx`) is what screens actually use, and it changes
the proportions materially:

* forces `p-0 flex flex-col items-center` on the content;
* wraps children in `#content` — `max-h-[90vh] overflow-y-auto scroll-smooth custom-scrollbar-thin
  flex flex-col gap-4`;
* `variant="form"` → inner `p-8` (32px), title `text-xl 3xl:text-2xl font-medium text-dark-200
  text-center`, description `text-xs 3xl:text-sm text-gray-500 text-center py-2`;
* `variant="no-exit"` → hides the close button and allows `max-h-screen`;
* dirty-form guard: closing a dirty `form` modal opens a warning modal instead;
* Arrow/Page/Home keys scroll the dialog body by 50/150px.

**Sizes actually registered** (`modals/data.ts`, 141 modals):
`max-w-xl` 60× (576px) · `max-w-lg` 31× (512) · `max-w-3xl` 29× (768) · `max-w-md` 25× (448) ·
`max-w-2xl` 25× (672) · `max-w-sm` 10× (384) · `max-w-4xl` 8× (896) · `max-w-6xl` 7× (1152) ·
`max-w-5xl` 6× (1024) · `max-w-7xl` 3× (1280) · plus `max-w-[95vw] !h-[90vh]` for full-bleed editors.
Variants: `form` 98 · `default` 33 · `no-exit` 7 · `warning` 3.

**So the canonical dialog is: 576px wide, 32px padding, centred 20px medium title, body capped at
90vh and scrolling internally, close chip floating outside the corner.**

`DialogHeader` `flex flex-col space-y-1 3xl:space-y-1.5 text-center sm:text-left`;
`DialogFooter` `flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2` — **stacked and
reversed on narrow, right-aligned row with 8px gaps on wide**.

---

## 21. Sheets and bottom sheets

`sheetVariants` base: `fixed z-50 gap-4 bg-background p-6 shadow-lg transition ease-in-out`,
**open 500ms / close 300ms** (`data-[state=open]:duration-500 data-[state=closed]:duration-300`).
Sides: `right` (default) and `left` are `inset-y-0 h-full w-3/4 sm:max-w-sm` with a border on the
inner edge; `top`/`bottom` are `inset-x-0` with a border on the inner edge. All slide in from
their own edge.

**The `Sheet` wrapper** forces `p-0 flex flex-col items-center` and an inner `#sheet-content`
(`overflow-y-auto flex-1 flex flex-col custom-scrollbar-thin p-6`, `p-4 md:p-8` for `form`), title
`text-3xl font-medium text-gray-600 text-center` for the form variant, description
`text-sm text-gray-500 text-center py-3`, and passes **`btnOutside`**: the close button becomes a
**45×45 `bg-background border rounded-md p-2.5` chip floating at `-left-16`** (64px to the left of
the sheet) with a `text-primary` X. For `side="bottom"` it moves to `-top-12 left-1/2 -translate-x-1/2`.

Registered sheet widths: mostly `max-w-md 3xl:max-w-xl`, `max-w-lg sm:max-w-lg 3xl:max-w-xl`,
`max-w-sm 3xl:max-w-md`, up to `md:max-w-5xl` and `w-[100vw] md:max-w-[95vw]`; several add
`[&_#sheet-content]:p-4`.

**True bottom sheet** — `drawer.tsx` (vaul): overlay `bg-black/80`, content
`fixed inset-x-0 bottom-0 z-50 mt-24 flex h-auto flex-col rounded-t-[10px] border bg-background`,
with a **grab handle: `mx-auto mt-4 h-2 w-[100px] rounded-full bg-muted`** (100×8px, 16px from the
top). Header `grid gap-1.5 p-4 text-center sm:text-left`. Background scales down behind it
(`shouldScaleBackground`).

**Flutter:** the `right` Sheet is the desktop pattern; on phone form factors the vaul Drawer is the
correct analogue for `AppBottomSheet` — 10px top radius, 100×8 handle, 80% scrim.

---

## 22. Tooltips

`z-50 overflow-hidden rounded-md border bg-popover px-3 py-1.5 text-sm text-popover-foreground
shadow-md`, `sideOffset={4}`, same fade+zoom+8px-slide entry. **Light tooltip on white with a
hairline border — not a dark tooltip.** An animated variant exists in
`components/animate-ui/radix/tooltip.tsx`.

---

## 23. Pagination

`table/pagination.tsx` + `data-table-pagination.tsx`. The bar reads:

`Show [ 25 ▾ ] Entries   [‹ Previous] [1][2] … [n-1][n] [Next ›]`

* Page-size select: `h-8 3xl:h-9.5 w-20 border-muted`; options 25 / 50 / 100 / 150; labels
  `text-xs 3xl:text-sm font-medium`; group gap `space-x-2 md:space-x-3`.
* **The whole paginator is hidden when `count <= 25`.**
* Page buttons are `buttonVariants` with **`variant: "outline"` when active and `"ghost"` when
  not** — the current page is the *outlined* one, there is no filled state. All forced to `!h-9.5`
  (38px), `size="icon"` (so 38×40), `gap-1` between items.
* Previous/Next use `size="default"` with `md:px-6 px-3` and a `size-4` chevron, and are
  **`hidden` rather than disabled** at the ends.
* Ellipsis: a 36×36 box with `MoreHorizontal size-4`.
* Window logic: ≤6 pages → all; otherwise `1 2 … [current] … n-1 n`.
* Selection count sits on the left: `text-xs 3xl:text-sm text-muted-foreground`,
  "*x of y row(s) selected*".
* Layout: `flex md:flex-row flex-col items-center gap-2 md:gap-0 py-1`.

---

## 24. Navigation / sidebar

**Shell** (`(with-layout)/layout.tsx`):
`<Sidebar />` + `<div className="flex flex-1 flex-col overflow-y-auto custom-scrollbar-thin px-6 py-5">`,
inside a root `flex h-screen w-screen overflow-hidden`. `body` is `w-screen overflow-hidden` —
**the page never scrolls; only the content column does.**

**Sidebar** (`apps/web/src/components/layouts/sidebar/index.tsx`):

* `aside flex flex-col justify-between bg-background border-r transition-all ease-in-out
  duration-300 shrink-0 relative`.
* Width **240px expanded / 64px collapsed**, and **expands to 240px on hover while collapsed**;
  when collapsed it becomes `fixed top-0 left-0 h-full z-50` with a 64px spacer div holding the
  layout open — so hovering overlays rather than pushes.
* Header: `.nav-height` (`min-h-14`, 56px) `flex items-center justify-between px-2`; logo 128×40
  expanded / 36×40 collapsed (variant `light` vs `light-vertical`); collapse toggle is a
  `ghost`/`icon-sm` button with `LucideChevronsLeft size={20} text-primary`, rotated 180° when
  collapsed, and only rendered on hover/expanded.
* Body: `overflow-y-auto no-scrollbar flex-1` (+ `pb-48` when expanded).
* Footer: `p-2 sticky bottom-0 space-y-2` — premium CTA + a profile box
  (`p-2 border rounded-md flex items-center justify-center`, `p-1` when collapsed).

**Nav items** (`layout/sidebar/links-section.tsx`) — an Accordion, `space-y-1.5`, `px-2`:

* Row: `h-9.5 3xl:h-[42px] rounded-lg font-normal text-dark-400 hover:bg-accent/20`,
  `transition-all ease-in-out duration-150`, `[&_svg]:hover:text-primary`; inner link
  `p-2.5 px-3 flex w-full items-center` with `gap-4` between icon and label.
* Icon `size-4 3xl:size-5`; label `text-sm 3xl:text-base`, hidden when collapsed.
* **Active state** = `bg-accent/20` + icon, label and the vertical bar in `primary`.
* **Active indicator:** `#vertical-bar` — `w-1 h-1/2 absolute left-0 rounded-e-full`, 300ms
  transition, `bg-primary` when active. A **4px half-height red tab on the left edge**, not a full-
  height bar and not a background pill alone.
* Chevron only renders when there is a submenu *and* the rail is expanded; rotation is inverted
  (`[data-state=closed]>svg` = `-rotate-90`, open = `rotate-0`).
* Sub-items: `px-5 py-2.5 gap-2 rounded-md text-dark-300 text-xs 3xl:text-sm hover:bg-accent/20`,
  active `bg-accent/20 text-primary`; bullet is `LucideCircle size-3 strokeWidth={5}
  fill-dark-600 stroke-background`, filling `primary` when active/hovered, joined by a
  **1px × 12–16px `bg-dark-700` connector line** centred under each bullet except the last.
* "New" badge: `Badge variant="table-status-active" className="bg-green-50"`.

**Top search** (`navbar-search-input.tsx`): borderless `h-12` input with a leading search icon,
placeholder "Search ( Ctrl + L )"; focusing drops a full-screen `bg-black/20 backdrop-blur-[1px]`
scrim and reveals a results panel `absolute inset-x-2 top-[calc(100%+8px)] bg-background border
rounded-lg`, height animating `h-0 → h-[50vh]` with `opacity` over 300ms ease-in-out. Result rows
`flex items-center gap-4 p-4 hover:bg-muted/50`, section labels `text-sm font-semibold px-4`.

**Mobile bottom nav** (`apps/connect/src/components/mobile-nav.tsx`) — the pattern a Flutter phone
app should mirror: `w-[95%] max-w-4xl mx-auto fixed bottom-2 left-0 right-0 bg-white border
rounded-md py-3 px-12`, four items `flex flex-col gap-1 items-center`, icon `size-5`, label
`text-xs 3xl:text-sm font-medium`, colour `text-dark-400` → `text-primary` when active.
A **floating rounded bar inset 8px from the bottom**, not an edge-to-edge Material bottom bar.

---

## 25. Empty states

`table/empty-ui.tsx`:

```
flex flex-col items-center py-24 space-y-6      (variant "small" → py-9)
├─ illustration   size-[120px] 3xl:size-[175px]   (assets/states/empty-table.svg|png)
└─ space-y-6 flex flex-col items-center
   ├─ space-y-2
   │  ├─ h3   text-lg 3xl:text-xl font-bold text-center   "No {name} found"
   │  └─ p    text-xs 3xl:text-base text-center           description
   └─ Button (default variant) with a leading <Plus/>     optional CTA
```

96px vertical padding, a 120px illustration, an 18px bold heading, a 12px description, one red
primary CTA. Inside a table it is absolutely positioned over a 410px invisible spacer row so the
frame never collapses.

Other empties: `assets/states/no-notification.png`, `assets/images/coming-soon.png` +
`layout/comming-soon.tsx`.

---

## 26. Loading / skeleton states

There is **one skeleton token**, the `.loading` utility class:

```css
.loading { @apply animate-pulse bg-slate-100 dark:bg-white/10 rounded-md; }
```

`bg-slate-100` = **#F1F5F9**, 6px radius, Tailwind's `animate-pulse`
(`opacity 1 → .5 → 1`, **2s cubic-bezier(.4,0,.6,1) infinite**). Every skeleton in the app is a
`<div className="loading h-… w-…" />`. No shimmer, no gradient sweep.

Composed skeletons:
* `TableFetchWrapper` / `TableLoading` — `space-y-6 flex flex-col flex-1 pt-4`: title `h-10 w-56`,
  filter bar `h-11`, body `loading flex-1`, pagination `h-11`.
* `FilterLoading` / `PaginationLoading` — a single `h-11` bar (or three `h-10 w-[100px]` chips in
  `table/filters.tsx`).
* `InfiniteTableFetchWrapper` — **25** placeholder rows: `h-5 w-8` index, `size-8 rounded-full`
  avatar + `h-4 w-32` label, trailing `h-4 w-12`/`w-44`.
* `FetchWrapper` — `loader="cards"` renders N `aspect-square bg-secondary animate-pulse rounded-md`
  tiles (default 20); otherwise a centred `Loader2 size={32} animate-spin` in a `py-16` block.
* Button loading — the masked SVG arc spinner at 1.2rem (§11.4), *not* `Loader2`.

**Two spinners exist and they are visually different**: lucide `Loader2` (a 3/4 ring, linear spin)
for page/section loads, and the CSS-masked arc (`.loading-spin`, dash-array animated, 1.5s) inside
buttons. Reproduce both.

---

## 27. Error states

* **Field errors** — `FormMessage`: `text-[10px] 3xl:text-xs font-medium text-destructive`, rendered
  under the control; the `Label` simultaneously turns `text-destructive`. **The input border does
  not change** (`aria-invalid` styling exists on Button but not on Input). Messages equal to
  `HIDDEN_BACKEND_VALIDATION_ERROR` render nothing.
* **Toasts** — `sonner`, themed to the app: `bg-background text-foreground border-border shadow-lg`,
  description `text-muted-foreground`, action button `bg-primary text-primary-foreground`, cancel
  `bg-muted text-muted-foreground`. In dark mode the close button is forced to `rgb(26,26,26)`.
  Dialogs and sheets explicitly **ignore outside-clicks that land on a toast**.
* **Destructive confirmation** — a `warning`-variant modal; the confirm control is the `destructive`
  button (red text/border on transparent, `hover:bg-destructive/10`), never a filled red button.
* **Unsaved-changes guard** — closing a dirty `form` modal/sheet routes through a warning modal
  rather than closing.

---

## 28. Responsive behaviour

Breakpoints (`packages/ui/tailwind.config.ts`): `xs` 375 · `sm` 640 · `md` 768 · `lg` 1024 ·
`xl` 1280 · `2xl` 1536 · **`3xl` 1600**. Container: centred, `padding: 2rem`, `2xl` max 1400px.

Usage counts tell the whole story: **`3xl:` 1495 · `sm:` 58 · `md:` 25 · `lg:` 9 · `xl:` 4 ·
`2xl:` 3 · `xs:` 9.**

* **`3xl` (≥1600px) is a density/comfort tier, not a layout tier.** It changes type size, control
  height, icon size and gaps by exactly one step. It almost never changes layout.
* `md:` appears only where a row must stack on small screens — pagination
  (`flex md:flex-row flex-col`), the data-table header (`flex-wrap-reverse`), a few sheet widths.
* `sm:` is mostly inherited from shadcn primitives (`sm:rounded-lg`, `sm:max-w-sm`,
  `sm:flex-row sm:justify-end`, `sm:text-left`).
* Sheets are `w-3/4` capped at `sm:max-w-sm` (384px) unless a registry entry widens them.
* The operator shell (`apps/web`) is **not** designed for phones: `body` is `w-screen
  overflow-hidden`, the sidebar has no mobile drawer, and tables scroll horizontally. `apps/connect`
  is the phone-shaped surface.

**Flutter mapping:** treat `3xl` as `MediaQuery.width >= 1600` and drive a single `AppDensity`
(`compact` | `comfortable`) from it. On phone/tablet, always use `compact`.

---

## 29. Animation and transition behaviour

| Motion | Spec | Source |
|---|---|---|
| Generic hover/colour | `transition-colors` / `transition-all` — Tailwind default **150ms cubic-bezier(.4,0,.2,1)** | everywhere |
| Sidebar width, nav rows, input focus | `transition-all ease-in-out duration-300` (nav rows `duration-150`) | sidebar, input |
| Button press | `whileTap scale 0.95` | `new-button.tsx` |
| Button ripple | 20px circle, `scale 0→10`, `opacity .5→0`, **600ms easeOut**, removed after 600ms | `new-button.tsx` |
| Button loading arc | masked SVG, rotate 2s linear + dash 1.5s, infinite | `globals.css` |
| Overlay open/close | `fade` + `zoom 95%↔100%` + `slide 8px` from the trigger side | Radix `animate-in/out` |
| Dialog | `duration-200`, slides from `top-[48%]`/`left-1/2` | `dialog.tsx` |
| Sheet | **open 500ms / close 300ms**, `ease-in-out`, edge slide | `sheet.tsx` |
| Dialog close chip | position shift + `rotate-90` on the X, 300ms ease-in-out | `dialog.tsx` |
| Accordion | `accordion-down/up 0.2s ease-out` on `--radix-accordion-content-height` | tailwind config |
| Accordion chevron | `rotate-180` (sidebar: `-rotate-90 → 0`) `duration-200` | `accordion.tsx` |
| Radio indicator | spring `stiffness 200, damping 16`; item `whileHover 1.05` / `whileTap .95` | `radio.tsx` |
| Skeleton | `animate-pulse` — 2s `cubic-bezier(.4,0,.6,1)`, opacity 1→.5→1 | `.loading` |
| Search panel | height `0 → 50vh` + opacity, 300ms ease-in-out | navbar |
| Collapsible details | `transition-[max-height] duration-300 ease-in-out` | form modals |
| OTP caret | `caret-blink 1.25s ease-out infinite` | tailwind config |
| Decorative | `animate-spin-60s` (60s linear) | `globals.css` |
| Sort chevron reveal | `opacity 0→1`, `duration-150` | `data-table.tsx` |

**Rule of thumb:** 150ms for colour, 300ms for size/position, 500ms only for the sheet opening,
600ms only for the ripple. Easing is `ease-in-out` for layout and `ease-out` for entrances.

---

## 30. General composition and layout rules

1. **Fixed viewport, inner scroll.** `body { w-screen overflow-hidden }`; the app is
   `flex h-screen w-screen overflow-hidden`; only the content column
   (`flex-1 overflow-y-auto custom-scrollbar-thin px-6 py-5`) and modal bodies scroll.
   Scrollbars are `scrollbar-width: thin` (`.custom-scrollbar-thin`) or hidden (`.no-scrollbar`).
2. **Page = header row → filter row → content → pagination**, stacked with `gap-y-3` (12px).
3. **Header row** = `flex items-center justify-between`; title left
   (`text-xl 3xl:text-[22px] font-medium h-10 flex items-center`, optional `icon-sm outline`
   back button with a `text-primary` chevron), actions right via a **slot context**
   (`useDataTableSlotContext` supplies `filters` and `functions`) with skeleton fallbacks.
4. **Forms are two-column**: `flex gap-3 3xl:gap-4` with `className="w-full"` on each `FormInput`,
   rows separated by `space-y-3 3xl:space-y-4`. Secondary fields hide behind a
   `link`-variant "Additional details" toggle with a rotating chevron and a `max-height` transition.
5. **Actions sit bottom-right**, in a `DialogFooter` (`flex-col-reverse` → `sm:flex-row
   sm:justify-end sm:space-x-2`): cancel/secondary left of confirm/primary.
6. **Alpha over solid.** Every hover, active, selected and zebra surface is an alpha tint of an
   existing token. There is no separate "hover grey" palette.
7. **Text truncates, never wraps, in tables**; `whitespace-nowrap` on chips, labels and pagination text.
8. **`content-layout`** utility exists for centred document pages:
   `mx-auto w-full max-w-5xl space-y-12 py-12`.
9. **Permission-driven visibility** is a Tailwind *variant* (`permission-<resource>-<action>:`)
   scoped by `#PERMISSION_ROOT[data-permission-…="true"]` — an architectural pattern, not visual,
   but it means some controls are conditionally rendered rather than disabled.
10. **CSS-variable content injection**: `.currency`, `.user-full-name`, `.user-username`,
    `.user-subscription`, `.user-active-restaurant` render values via `::before { content: var(…) }`.
    In Flutter these are simply data bindings — do not attempt to replicate the mechanism.
