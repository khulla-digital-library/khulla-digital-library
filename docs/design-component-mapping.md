# RestroX → Flutter Component Mapping

Companion to [`design-system.md`](./design-system.md) and [`design-tokens.json`](./design-tokens.json).
This file says **what to build, at what level of the Flutter app, and what must never be rebuilt
per-screen.** It assumes the reader is implementing the Flutter app and has not seen the Next.js code.

---

## 0. How to read this

* **Global token** — belongs in `AppTheme` / `AppColors` / `AppTypography` / `AppSpacing`. One
  definition, referenced everywhere. Never inlined at a call site.
* **Reusable component** — a widget in `lib/design_system/`. Screens compose it; screens do not
  restyle it.
* **Screen-specific** — legitimately lives in a feature folder. Usually a one-off composition of
  reusable components, not new styling.
* **Do not recreate** — a visual pattern that already has an owner. If you find yourself writing
  these styles inside a screen file, stop and use the component.

---

## 1. Primary component map

| SaaS component (source) | Flutter component | Notes |
|---|---|---|
| `ui/button/new-button.tsx` | **`AppButton`** | 8 variants × 10 sizes, ripple, tap-scale, loading, shortcut chip. Default = `sm` (36px). |
| `ui/input/input.tsx` | **`AppTextField`** | 40/44px, no focus ring, 2px focus padding nudge. |
| `ui/input/textarea.tsx` | `AppTextField.multiline` | autosize 5–10 rows, not resizable. |
| `ui/input/input-with-icon.tsx` | `AppTextField(prefixIcon:, suffixIcon:)` | Not a separate widget. |
| `ui/input/form-input.tsx` | **`AppFormField`** | label + required marker + control + description + error, with the 8/12px label gap. |
| `ui/label.tsx` | `AppFieldLabel` | 12/14px, w500, `ink200`. |
| `ui/form.tsx` (`FormMessage`) | `AppFieldError` | 10/12px, w500, `primary`. |
| `ui/select.tsx` | **`AppSelect<T>`** | trigger + menu; menu width matches trigger. |
| `ui/input/select-input.tsx` | `AppFilterSelect` | the dashed-outline filter chip variant. |
| `ui/multi-select.tsx`, `input/combobox-input.tsx`, `input/async-select.tsx` | `AppMultiSelect`, `AppCombobox`, `AppAsyncSelect` | same trigger/menu skin. |
| `ui/checkbox.tsx` | **`AppCheckbox`** | 16px, 1.5px border, tick-only (no fill). |
| `ui/radio.tsx` | **`AppRadio`** / `AppRadioGroup` | spring indicator, hover/tap scale. |
| `ui/switch.tsx` | **`AppSwitch`** | 2 sizes × 3 colours; pale track + saturated thumb. |
| `ui/table/table.tsx` + `data-table.tsx` + `row.tsx` | **`AppTable` / `AppDataTable<T>`** | zebra, hover, selection, sticky header, sort chevrons, empty spacer. |
| `ui/table/data-table-pagination.tsx` + `pagination.tsx` | **`AppPagination`** | outline = active, ghost = inactive, ends hidden. |
| `ui/table/empty-ui.tsx` | **`AppEmptyState`** | illustration + title + description + CTA. |
| `ui/table/action-buttons.tsx` | **`AppRowActionsMenu`** | 192px menu, View/Edit/Delete, `primary` delete. |
| `ui/table/filters.tsx` | `AppFilterBar` | wrap, 12px gap, "Clear" ghost button in `primary`. |
| `ui/card.tsx` | **`AppCard`** | default = the product pattern (1px border, 6px radius, 16px pad, no shadow); `AppCard.filled` = the shadcn primitive. |
| `pages/analytics/detail-card.tsx` | `AppStatCard` | title + delta chip + value. |
| `ui/badge.tsx` | **`AppBadge`** + **`AppStatusChip`** | `AppBadge` for the pill variants; `AppStatusChip(status)` for the tinted table statuses. |
| `ui/tabs.tsx` | **`AppSegmentedTabs`** | red active pill on `#F2F4F7`. |
| `re-useables/tabs-link.tsx` | `AppRouteTabs` | same control, route-driven, hosts a trailing slot. |
| `ui/animated-tabs.tsx` + `motion-highlight.tsx` | `AppAnimatedTabs` | `underline` and `transparent` variants. |
| `ui/dropdown-menu.tsx` / `context-menu.tsx` | **`AppMenu`** (+ `AppMenuItem`, `AppMenuLabel`, `AppMenuSeparator`) | one widget; long-press = context menu on touch. |
| `ui/popover.tsx` | **`AppPopover`** | 288px, 16px pad, `shadow-md`. |
| `ui/tooltip.tsx` | **`AppTooltip`** | light surface, hairline border. |
| `ui/dialog.tsx` + `modal/modal.tsx` | **`AppDialog`** | wrapper semantics, not the raw primitive (see §3). |
| `ui/sheet.tsx` + `sheet/sheet.tsx` | **`AppSideSheet`** | right/left panel with the outside close chip. |
| `ui/drawer.tsx` (vaul) | **`AppBottomSheet`** | 10px top radius, 100×8 handle, 80% scrim. |
| `layout/sidebar/*` | **`AppSidebar`** + `AppSidebarItem` + `AppSidebarSubItem` | 240/64, hover-expand, 4px left indicator. |
| `apps/connect/components/mobile-nav.tsx` | **`AppBottomNav`** | floating rounded bar, 8px bottom inset. |
| `layout/table-page-header.tsx` | **`AppPageHeader`** | title + optional back button + trailing actions slot. |
| `layout/fetch-wrapper.tsx`, `table-fetch-wrapper.tsx`, `loaders/*` | **`AppSkeleton`** + `AppTableSkeleton`, `AppFilterSkeleton`, `AppPaginationSkeleton`, `AppCardGridSkeleton` | |
| `ui/sonner.tsx` | **`AppToast`** | light toast, `shadow-lg`. |
| `ui/avatar.tsx` | **`AppAvatar`** | 40px, initials fallback on `#E1E6FF`. |
| `ui/progress.tsx` | `AppProgressBar` | 8px, `primary` on `primary@20%`. |
| `ui/separator.tsx` | `AppDivider` | 1px `#EBE9F1`. |
| `ui/accordion.tsx` | `AppAccordion` | 200ms ease-out height. |
| `ui/command.tsx` | `AppCommandPalette` | if the Flutter app needs global search. |
| `ui/calendar.tsx`, `date-range-picker/`, `input/time-picker.tsx` | `AppDatePicker`, `AppDateRangePicker`, `AppTimePicker` | skin with `AppSelect`/`AppPopover` tokens. |
| `ui/image.tsx`, `re-useables/image-drop-zone.tsx` | `AppImage`, `AppDropZone` | drop zone uses the dashed-border painter. |
| `ui/charts.tsx` (recharts) | `AppChart*` | axis/grid/tooltip must use `border`, `muted-foreground` and `shadow-md` from tokens. |

---

## 2. What becomes a **global Flutter token**

Everything in `design-tokens.json`. Concretely, these must exist as named constants and must never
be typed as literals in a screen:

**Color** — the full `primary` ramp; the `ink` ramp (inverting) and the `neutral` (`white`) ramp
(non-inverting); every semantic (`background`, `foreground`, `card`, `popover`, `secondary`,
`muted`, `mutedForeground`, `accent`, `destructive`, `border`, `ring`); `success`/`warn`/`role`/
`premium`; the hard-coded status-chip triples; **and the `tints` table** — the alpha composites
(`accent@20`, `accent@10`, `ink700@10`, `ink500@5`, `muted@50`, `primary@10`, `primary@5`, the
`black@40`/`@80` scrims). The tint table is a token set in its own right; screens must not invent
new alphas.

**Typography** — `Poppins` as the app-wide family; the four weights (400/500/600/700); the seven
**paired** text styles (`micro`, `body`, `bodyLarge`, `title`, `pageHeader`, `formTitle`,
`sheetTitle`) each resolving base/wide from a single density flag.

**Density** — `AppDensity { compact, comfortable }` derived from `MediaQuery.width >= 1600`
(always `compact` on phone/tablet). This is the *only* place the `3xl` breakpoint is read.
Every paired token resolves through it.

**Spacing** — the 4px scale plus the named semantic values (`pageHorizontal` 24, `pageVertical` 20,
`sectionStackGap` 12, `formRowGap` 12/16, `labelToControlGap` 8/12, `buttonIconGap` 8,
`menuItemIconGap` 10, `sidebarIconGap` 16, `dialogPadding` 32, `emptyStatePaddingY` 96).

**Radius** — 4 / 6 / 8 / 10 / 12 / 16 / full, plus the written hierarchy rule
(controls 8 > containers 6 > items 4).

**Borders** — 1px hairline `#EBE9F1` as the single default; 1.5px for checkbox; the dashed
6-on/6-off 2px painter.

**Shadows** — exactly three `List<BoxShadow>` constants (`sm`, `md`, `lg`) built from the CSS
values. Ban `Material(elevation:)` for design-system surfaces.

**Icons** — 12 / 14 / 16 / 20 / 24 with the two responsive pairs; default stroke 2.

**Motion** — durations (150 / 200 / 300 / 500 / 600 / 2000), the four curves, the radio spring
(`stiffness 200, damping 16`), tap scale 0.95, the ripple spec, and the overlay-enter recipe
(fade + 0.95→1.0 scale + 8px directional slide).

---

## 3. What becomes a **reusable Flutter component**

Build these once. In priority order — the first six carry ~80% of the app's screens.

1. **`AppButton`** — all eight variants and ten sizes from the tokens. Must include: ripple from the
   tap position (20px → scale 10, 600ms), `scale: 0.95` while pressed, the loading state that
   *replaces* the label with a 19px arc spinner without changing the button's size, `disabled` as
   50% whole-widget opacity, the 3px focus ring, and the padding reduction when an icon is present.
2. **`AppTextField` / `AppFormField`** — the 2px left-padding focus nudge over 300ms **and no focus
   ring**. Label above (12/14, w500, `ink200`) with the red space-asterisk for required; error below
   (10/12, w500, `primary`); the label turns red on error but **the border does not**.
3. **`AppDataTable<T>`** — column defs, zebra (`even` rows at `ink700@10`), hover `muted@50`,
   selection `accent@10`, sticky header, sort chevrons that fade in on hover, single-line ellipsised
   cells, the hover-revealed row checkbox, the 410px empty spacer, and the built-in header/filter/
   pagination slots. This is the largest single component and the most valuable to get right.
4. **`AppDialog`** — model it on the **`Modal` wrapper**, not the raw primitive: content padding 0
   with an internal scroll region capped at 90% of viewport height and padded 32px for the `form`
   variant; centred 20/24px w500 title in `ink200`; centred 12/14px grey description; the close chip
   **floating outside the top-right corner** that shifts outward and rotates its X 90° on hover;
   footer that is column-reverse when narrow and a right-aligned row with 8px gaps when wide; the
   dirty-form confirmation guard. Default width 576px; expose the full `sm`…`7xl` ladder.
5. **`AppSideSheet` / `AppBottomSheet`** — side sheet: 75% width capped at 384px, 24px padding
   (32px for forms), **500ms open / 300ms close**, and the 45px close chip floating 64px outside
   the panel with a red X. Bottom sheet: 10px top corners, 100×8 handle 16px from the top, 80% scrim.
6. **`AppSidebar`** — 240/64px with hover-expand-as-overlay, 300ms ease-in-out; the **4px
   half-height left indicator with a rounded right edge**; `accent@20` for both hover and active;
   accordion sub-items with the bulleted connector line; 56px header; sticky footer.
7. **`AppSelect` / `AppFilterSelect`** — shared menu skin; the filter variant is a dashed-outline
   chip that turns `primary@5` + red text + red dashed stroke when a value is set.
8. **`AppMenu`** — dropdown and context menu from one implementation; 192px row-action preset.
9. **`AppBadge` / `AppStatusChip`** — the tinted-triple pattern must be derivable from a single hue.
10. **`AppEmptyState`**, **`AppSkeleton`** (+ the five composed presets), **`AppPagination`**,
    **`AppSegmentedTabs`**, **`AppPageHeader`**, **`AppToast`**, **`AppTooltip`**, **`AppPopover`**,
    **`AppCard`**, **`AppAvatar`**, **`AppSwitch`**, **`AppCheckbox`**, **`AppRadio`**.

---

## 4. What stays **screen-specific**

* **Form field composition** — which fields, in what order, two-per-row vs full width. Each screen
  assembles `AppFormField`s; it does not restyle them.
* **Table column definitions** — headers, cell builders, widths, which columns pin or export.
* **Copy** — titles, descriptions, empty-state names, badge labels, validation messages.
* **The "Additional details" progressive-disclosure block** (a `link` button with a rotating chevron
  over a max-height transition) — the *pattern* is screen-level, but the button and the chevron
  rotation come from `AppButton`.
* **Domain visuals** — receipt/KOT preview (Merchant Copy font), POS layouts, QR designs, menu
  cards, dish tiles, the subscription/premium marketing surfaces, seat/table maps, chart compositions.
* **One-off layouts** — onboarding steps, login/OTP screens, the checkout flow.
* **The hand-rolled radio-as-ghost-button** in `add-customer.tsx` (the toCollect/toPay toggle):
  a genuine local exception. Keep it screen-local, or promote it to `AppChoiceCard` **once** if a
  second screen needs it — do not copy-paste it.

---

## 5. Existing Flutter conventions to preserve

These are the points where Flutter's defaults actively fight this design system. Decide once, globally.

1. **Disable Material's ink splash and replace it with this ripple.** Set
   `splashFactory: NoSplash.splashFactory` (and `highlightColor: Colors.transparent`) in the theme,
   then implement the button ripple explicitly. Material's splash colour, timing and clipping are all
   wrong for this design.
2. **Do not use `Material(elevation:)`, `Card`'s default elevation, or `Theme.shadowColor`.** Use the
   three explicit `BoxShadow` lists. Material's elevation shadows are several times darker.
3. **Do not use `InputDecoration`'s default focus behaviour.** No `focusedBorder` colour change, no
   floating label, no filled background. The focus signal is the 2px content-padding shift.
   `AppTextField` should own an `AnimatedPadding`/`AnimatedContainer`, not lean on `InputDecorator`.
4. **`Colors.grey` / `Colors.red` / any Material swatch is banned.** Every colour comes from
   `AppColors`. Where the SaaS itself used Tailwind literals (`green-500` #22C55E for the success
   button, `blue-700` #1D4ED8 for link text, `slate-100` #F1F5F9 for skeletons), those exact values
   are recorded in `design-tokens.json` under `colors.hardcoded` — use them from there.
5. **Keep the ink ramp semantic.** `ink100…ink700` are *roles*, not shades. Do not swap them for
   `Colors.black87`/`black54`, and remember `ink700` is a line colour that does not invert.
6. **Alpha, not pre-mixed colour.** Reproduce `bg-accent/20` as `AppColors.accent.withValues(alpha:
   0.2)`. Pre-mixing against white will drift as soon as the surface underneath changes.
7. **`Theme.of(context).textTheme` must be built from the paired styles**, resolved through
   `AppDensity`. Never call `TextStyle(fontSize: 12)` in a widget.
8. **Poppins for everything** — including numbers, table cells and buttons. There is no second UI
   font. `Merchant Copy` is receipt-only.
9. **Scroll ownership** — the shell does not scroll; the content column and modal bodies do. Mirror
   this with a fixed shell plus scrollable regions, thin scrollbars where a scrollbar is visible.
10. **`textScaler`** — the design is dense (10–12px text). Clamp text scaling (e.g. to ≤1.3) or the
    36px rows and 17px shortcut chips will break. Decide this once in the app-level `MediaQuery`.
11. **Light mode only, but token-complete.** Ship light (as `apps/web` does). Keep the dark values
    in the token file so enabling dark is a data change.

---

## 6. Visual patterns that must **NOT** be recreated per screen

If any of these appear inline in a feature file, it is a bug.

| Pattern | Owner | Why it goes wrong when copied |
|---|---|---|
| **Hover / active / selected tints** (`accent@20`, `accent@10`, `muted@50`, `ink700@10`) | `AppColors.tints` | Screens invent slightly different greys and the table stops looking like the sidebar. |
| **Button ripple + tap-scale + loading spinner** | `AppButton` | Hand-rolled buttons lose the ripple, or the button resizes when it starts loading. |
| **The input focus nudge (2px / 300ms) and the absence of a focus ring** | `AppTextField` | Any locally-built field will show a Material focus underline and read as a different app. |
| **The dialog close chip** (outside the corner, shifts on hover, X rotates 90°) | `AppDialog` | The single most recognisable detail; a plain in-corner X changes the product's character. |
| **The sheet's outside close chip** (45px, 64px to the left, red X) | `AppSideSheet` | Same. |
| **Table row rhythm** — `px-4 py-1.5` (→ ~37px), zebra on even rows, hover-revealed checkbox, single-line ellipsis | `AppDataTable` | Rebuilt tables come out 48–56px per row and the app stops feeling dense. |
| **The sidebar active indicator** (4px, half-height, rounded right edge) | `AppSidebar` | Reimplementations use a full-height bar or a plain filled pill. |
| **Status chip colours** | `AppStatusChip` | Screens hand-pick greens and ambers that do not match the eight canonical statuses. |
| **The dashed filter-chip border** (6/6 dash, 2px, 6px radius, idle grey → active red) | `AppFilterSelect` / `AppDropZone` | Flutter has no dashed border; each ad-hoc painter comes out with a different dash rhythm. |
| **Skeletons** — `#F1F5F9`, 6px radius, 2s pulse, no shimmer | `AppSkeleton` | Shimmer packages are the default reflex and are wrong here. |
| **Empty states** — 96px padding, 120px illustration, 18px bold title, 12px description, one red CTA | `AppEmptyState` | Ad-hoc empties end up with different spacing on every list. |
| **Pagination** — outline = current page, ghost = others, ends hidden not disabled, 38px | `AppPagination` | The "filled current page" instinct is wrong for this system. |
| **The two spinners** — lucide `Loader2` (32px, sections) vs the masked arc (19px, inside buttons) | `AppSpinner` / `AppButton` | Using one everywhere loses a real distinction. |
| **The `3xl` density step-up** | `AppDensity` + paired text/size tokens | If each widget reads `MediaQuery` itself, the steps desynchronise and large screens look scrambled. |
| **Radius hierarchy** (8 controls / 6 containers / 4 items) | `AppRadius` | Flattening everything to 8px is the most common single error. |
| **Dialog and sheet proportions** — 576px / 32px padding / 90vh internal scroll; 75%→384px / 24px / 500ms | `AppDialog`, `AppSideSheet` | Full-screen dialogs and 16px padding are Flutter's defaults and both are wrong. |

---

## 7. Build order (recommended)

1. Tokens + `AppDensity` + `ThemeData` (splash off, elevation off, text theme wired).
2. `AppButton`, `AppTextField`/`AppFormField`, `AppBadge`/`AppStatusChip`, `AppCard`.
3. `AppSelect`, `AppCheckbox`, `AppRadio`, `AppSwitch`, `AppMenu`, `AppTooltip`, `AppPopover`.
4. `AppDialog`, `AppSideSheet`, `AppBottomSheet`, `AppToast`.
5. `AppDataTable` + `AppPagination` + `AppEmptyState` + `AppSkeleton` + `AppFilterBar`.
6. `AppSidebar` / `AppBottomNav` / `AppPageHeader` / `AppSegmentedTabs`.
7. Screens.

**Acceptance check.** Put a form dialog, a data table page and the sidebar side by side with the
running SaaS at 1440px and again at 1600px. If the 1600px view is not visibly one step roomier —
14px body, 44px inputs, 48px table headers, 20px sidebar icons — the density system is not wired up,
and that is the failure that will make the Flutter app look like a different product no matter how
correct the colours are.
