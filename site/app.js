/*
 * Khulla landing page behaviour. No dependencies, no build step.
 *
 * The brand derivation (fromSeed) and the money formatting mirror
 * packages/khulla_ui/lib/src/theme/app_brand.dart and
 * lib/core/money/money_format.dart, so the preview behaves like the app.
 */
(() => {
  "use strict";

  const REPO = "sawongam/khulla-digital-library";
  const GITHUB = `https://github.com/${REPO}`;

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
  const root = document.documentElement;

  function externalizeLink(a) {
    if (!/^https?:/i.test(a.href)) return;
    a.target = "_blank";
    const rel = new Set((a.rel || "").split(/\s+/).filter(Boolean));
    rel.add("noopener");
    a.rel = [...rel].join(" ");
  }

  // ── Toast ────────────────────────────────────────────────────────────────

  let toastTimer;
  function toast(message) {
    $(".toast")?.remove();
    const el = document.createElement("div");
    el.className = "toast";
    el.setAttribute("role", "status");
    el.innerHTML = '<svg class="icon" aria-hidden="true"><use href="#i-check-circle"/></svg>';
    el.append(message);
    document.body.append(el);
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.remove(), 2400);
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  const nav = $(".nav");
  const onScroll = () => nav.classList.toggle("is-pinned", window.scrollY > 4);
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  const menuBtn = $(".nav-menu-btn");
  const sheet = $("#nav-sheet");
  function setMenu(open) {
    sheet.hidden = !open;
    menuBtn.setAttribute("aria-expanded", String(open));
    menuBtn.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    $("use", menuBtn).setAttribute("href", open ? "#i-close-circle" : "#i-hamburger-menu");
  }
  menuBtn.addEventListener("click", () => setMenu(sheet.hidden));
  sheet.addEventListener("click", (e) => { if (e.target.closest("a")) setMenu(false); });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && !sheet.hidden) { setMenu(false); menuBtn.focus(); } });
  window.addEventListener("resize", () => { if (window.innerWidth > 960 && !sheet.hidden) setMenu(false); });

  // The header is sticky, so jumping to its own #top anchor would not move the
  // page. Scroll explicitly; CSS scroll-behavior handles smooth vs reduced motion.
  $$(".brand-mark").forEach((logo) => logo.addEventListener("click", (e) => {
    e.preventDefault();
    if (!sheet.hidden) setMenu(false);
    window.scrollTo({ top: 0 });
    if (location.hash) history.replaceState(null, "", location.pathname + location.search);
  }));

  // ── The app preview ──────────────────────────────────────────────────────

  const shell = $("#shell");
  const moreSheet = $("[data-more-sheet]", shell);
  const moreBtn = $("[data-more]", shell);

  function showView(name) {
    $$("[data-view]", shell).forEach((v) => {
      const show = v.dataset.view === name;
      if (show && v.hidden) {
        v.classList.add("is-entering");
        v.addEventListener("animationend", () => v.classList.remove("is-entering"), { once: true });
      }
      v.hidden = !show;
    });
    // Only navigation marks the current section; a worklist row that jumps
    // to one is a link, not a destination.
    $$(".rail-item[data-go], .navbar [data-go]", shell).forEach((b) => b.setAttribute("aria-current", String(b.dataset.go === name)));
    const inMore = ["reports", "staff", "settings"].includes(name);
    moreBtn.setAttribute("aria-current", String(inMore));
    setMore(false);
  }
  function setMore(open) {
    moreSheet.hidden = !open;
    moreBtn.setAttribute("aria-expanded", String(open));
  }
  $$("[data-go]", shell).forEach((b) => b.addEventListener("click", () => showView(b.dataset.go)));
  moreBtn.addEventListener("click", () => setMore(moreSheet.hidden));

  // ── Charts — AppBarChart, AppLineChart, AppDonutChart ───────────────────

  const SVG_NS = "http://www.w3.org/2000/svg";
  function node(tag, attrs, text) {
    const el = document.createElementNS(SVG_NS, tag);
    for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, v);
    if (text != null) el.textContent = text;
    return el;
  }

  // Drawn at the slot's real size rather than scaled from a fixed viewBox, so
  // the plot fills its card and the axis text stays at its type size.
  function sized(svg) {
    const box = svg.getBoundingClientRect();
    if (!box.width || !box.height) return null;
    svg.setAttribute("viewBox", `0 0 ${box.width} ${box.height}`);
    svg.replaceChildren();
    return { W: box.width, H: box.height };
  }

  // Grouped bars. With `highlight`, every other column is drawn in its
  // series' soft tone, as AppBarChart does, so today reads first.
  function drawBars(svg, { labels, series, step, axis = true, highlight = null }) {
    const size = sized(svg);
    if (!size) return;
    const { W, H } = size;
    const left = axis ? 26 : 0, bottom = 20, top = 8;
    const max = Math.max(step, ...series.flatMap((s) => s.values));
    const ceil = Math.ceil(max / step) * step;
    const plotH = H - top - bottom;

    for (let i = 0; i <= 4; i++) {
      const y = top + plotH - (plotH * i) / 4;
      svg.append(node("line", { class: "grid-line", x1: left, x2: W, y1: y, y2: y }));
      if (axis) svg.append(node("text", { x: 0, y: y + 3 }, String(Math.round((ceil * i) / 4))));
    }

    const slot = (W - left) / labels.length;
    const barW = Math.max(3, Math.min(axis ? 16 : 18, slot * (axis ? 0.3 : 0.26)));
    const every = slot < 22 ? 2 : 1;
    labels.forEach((label, i) => {
      const cx = left + slot * i + slot / 2;
      const dim = highlight != null && highlight !== i;
      const x0 = cx - (barW * series.length + series.length - 1) / 2;
      series.forEach((s, k) => {
        const h = (s.values[i] / ceil) * plotH;
        if (h > 0) svg.append(node("rect", { class: s.cls + (dim ? " dim" : ""), x: x0 + k * (barW + 1), y: top + plotH - h, width: barW, height: h, rx: 2 }));
      });
      if (series.every((s) => s.values[i] === 0) && slot >= 34 && labels[i] === "Sat") {
        svg.append(node("text", { x: cx, y: top + plotH - 6, "text-anchor": "middle" }, "closed"));
      }
      if (i % every === 0) svg.append(node("text", { x: cx, y: H - 4, "text-anchor": "middle", class: highlight === i ? "on" : "" }, label));
    });
  }

  function drawLine(svg, { labels, values }) {
    const size = sized(svg);
    if (!size) return;
    const { W, H } = size;
    const pad = 8, bottom = 20, top = 10;
    const plotH = H - top - bottom;
    const max = Math.max(...values) * 1.15;
    for (let i = 0; i <= 3; i++) {
      const y = top + plotH - (plotH * i) / 3;
      svg.append(node("line", { class: "grid-line", x1: 0, x2: W, y1: y, y2: y }));
    }
    const pts = values.map((v, i) => [pad + ((W - pad * 2) * i) / (values.length - 1), top + plotH - (v / max) * plotH]);
    const d = pts.map(([x, y], i) => `${i ? "L" : "M"}${x.toFixed(1)},${y.toFixed(1)}`).join("");
    svg.append(node("path", { class: "area", d: `${d}L${pts.at(-1)[0]},${top + plotH}L${pts[0][0]},${top + plotH}Z` }));
    svg.append(node("path", { class: "line", d }));
    pts.forEach(([x, y], i) => {
      const last = i === pts.length - 1;
      svg.append(node("circle", { class: last ? "pt on" : "pt", cx: x, cy: y, r: last ? 3.5 : 2.5 }));
      svg.append(node("text", { x, y: H - 4, "text-anchor": "middle", class: last ? "on" : "" }, labels[i]));
    });
  }

  // Slices separated by a hairline of surface, the way AppDonutChart paints
  // its `gap`.
  function drawDonut(svg, slices) {
    const r = 46, c = 2 * Math.PI * r, gap = 2;
    const total = slices.reduce((sum, s) => sum + s.value, 0);
    svg.setAttribute("viewBox", "0 0 108 108");
    svg.replaceChildren();
    let offset = 0;
    slices.forEach((s) => {
      // A sliver still gets a visible arc, or the legend lists a slice nobody can find.
      const len = Math.max(2.5, (s.value / total) * c - gap);
      svg.append(node("circle", { cx: 54, cy: 54, r, stroke: `var(--${s.tone})`, "stroke-dasharray": `${len} ${c - len}`, "stroke-dashoffset": -offset }));
      offset += len + gap;
    });
  }

  // The board's figures for each period. Weekday counts run Sun → Sat;
  // today is Thursday 17 September, and the library shuts on Saturdays.
  const PERIODS = {
    today: {
      caption: "vs yesterday",
      borrowed: [40, 41], returned: [27, 33], overdue: [14, 13], fines: [4500, 3000],
      checkouts: [0, 0, 0, 0, 40, 0, 0], returns: [0, 0, 0, 0, 27, 0, 0],
    },
    week: {
      caption: "vs last week",
      borrowed: [184, 164], returned: [149, 142], overdue: [14, 11], fines: [21500, 23500],
      checkouts: [31, 38, 34, 41, 40, 0, 0], returns: [24, 29, 36, 33, 27, 0, 0],
    },
    month: {
      caption: "vs last month",
      borrowed: [569, 612], returned: [529, 498], overdue: [14, 16], fines: [62000, 54500],
      checkouts: [78, 96, 101, 112, 118, 64, 0], returns: [70, 88, 97, 104, 99, 71, 0],
    },
  };
  // Overdue and fines rising is bad news, so their pills invert.
  const INVERTED = new Set(["overdue", "fines"]);
  let period = PERIODS.week;

  function renderTrend(el, [now, before], inverted) {
    const pct = before === 0 ? (now === 0 ? 0 : 100) : ((now - before) / before) * 100;
    const flat = Math.abs(pct) < 0.05;
    const good = inverted ? pct < 0 : pct > 0;
    el.className = "trend" + (flat ? " flat" : good ? "" : " down");
    el.replaceChildren();
    if (!flat) el.append(node("svg", { class: "icon", "aria-hidden": "true" }));
    if (!flat) el.firstChild.append(node("use", { href: pct > 0 ? "#i-arrow-up" : "#i-arrow-down" }));
    el.append(`${pct >= 0 ? "+" : ""}${pct.toFixed(1)}%`);
  }

  function renderPeriod() {
    for (const key of ["borrowed", "returned", "overdue"]) {
      const value = $(`[data-stat="${key}"]`, shell);
      if (value) value.textContent = period[key][0].toLocaleString("en-IN");
    }
    for (const key of ["borrowed", "returned", "overdue", "fines"]) {
      const el = $(`[data-trend="${key}"]`, shell);
      if (el) renderTrend(el, period[key], INVERTED.has(key));
    }
    $$("[data-caption]", shell).forEach((el) => { el.textContent = period.caption; });
    drawCharts();
  }

  const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const usage = $('[data-chart="usage"]');
  const fines = $('[data-chart="fines"]');
  const months = $('[data-chart="months"]');

  function drawCharts() {
    if (usage) {
      drawBars(usage, {
        labels: WEEKDAYS,
        series: [{ values: period.checkouts, cls: "bar-a" }, { values: period.returns, cls: "bar-ret" }],
        step: 10,
        axis: false,
        highlight: 4,
      });
    }
    // Fines accrued per month, in rupees — falling since the grace-day rule changed in July.
    if (fines) drawLine(fines, { labels: ["Apr", "May", "Jun", "Jul", "Aug", "Sep"], values: [980, 1120, 1460, 1720, 1520, 1240] });
    if (months) {
      drawBars(months, {
        labels: ["Apr", "May", "Jun", "Jul", "Aug", "Sep"],
        series: [{ values: [512, 604, 431, 389, 655, 298], cls: "bar-a" }, { values: [488, 590, 466, 402, 610, 271], cls: "bar-b" }],
        step: 100,
      });
    }
  }

  const donut = $("[data-donut]");
  if (donut) {
    drawDonut(donut, [
      { value: 4443, tone: "success" },
      { value: 312, tone: "brand" },
      { value: 38, tone: "info" },
      { value: 12, tone: "danger" },
      { value: 7, tone: "warning" },
    ]);
  }

  const periodGroup = $("[data-period]", shell);
  if (periodGroup) {
    const buttons = $$('[role="radio"]', periodGroup);
    const select = (i, focus) => {
      buttons.forEach((b, j) => { b.setAttribute("aria-checked", String(i === j)); b.tabIndex = i === j ? 0 : -1; });
      if (focus) buttons[i].focus();
      period = PERIODS[buttons[i].dataset.p];
      renderPeriod();
    };
    buttons.forEach((b, i) => {
      b.tabIndex = b.getAttribute("aria-checked") === "true" ? 0 : -1;
      b.addEventListener("click", () => select(i, false));
    });
    // radioKeys is a function declaration further down, so it is hoisted.
    radioKeys(periodGroup, (i) => select(i, true));
  }

  renderPeriod();
  if ("ResizeObserver" in window) {
    let frame;
    new ResizeObserver(() => {
      cancelAnimationFrame(frame);
      frame = requestAnimationFrame(drawCharts);
    }).observe(shell);
  }
  // A chart in a hidden view has no size until the view is shown.
  $$("[data-go]", shell).forEach((b) => b.addEventListener("click", () => requestAnimationFrame(drawCharts)));

  // ── Brand — AppBrand.fromSeed ────────────────────────────────────────────

  const BRANDS = [
    // Teal ships hand-tuned rather than derived — same as AppBrand.teal.
    { name: "Teal", seed: "#0a6a66", fixed: { brand: "#0a6a66", strong: "#07514e", deep: "#04403d", accent: "#4fb3ac", onBrand: "#ffffff" } },
    { name: "Indigo", seed: "#4338ca" },
    { name: "Blue", seed: "#1d4ed8" },
    { name: "Violet", seed: "#6d28d9" },
    { name: "Rose", seed: "#a61e4d" },
    { name: "Amber", seed: "#b45309" },
    { name: "Forest", seed: "#15803d" },
    { name: "Graphite", seed: "#334155" },
  ];

  const hexToRgb = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255);
  const rgbToHex = (rgb) => "#" + rgb.map((c) => Math.round(c * 255).toString(16).padStart(2, "0")).join("");

  function rgbToHsl([r, g, b]) {
    const max = Math.max(r, g, b), min = Math.min(r, g, b);
    const l = (max + min) / 2;
    if (max === min) return [0, 0, l];
    const d = max - min;
    const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    let h;
    if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    return [h * 60, s, l];
  }

  function hslToRgb([h, s, l]) {
    const c = (1 - Math.abs(2 * l - 1)) * s;
    const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
    const m = l - c / 2;
    const [r, g, b] = h < 60 ? [c, x, 0] : h < 120 ? [x, c, 0] : h < 180 ? [0, c, x]
      : h < 240 ? [0, x, c] : h < 300 ? [x, 0, c] : [c, 0, x];
    return [r + m, g + m, b + m];
  }

  const luminance = (rgb) => {
    const [r, g, b] = rgb.map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  };

  function fromSeed(seedHex) {
    const rgb = hexToRgb(seedHex);
    const [h, s, l] = rgbToHsl(rgb);
    return {
      brand: seedHex,
      onBrand: luminance(rgb) > 0.45 ? "#121212" : "#ffffff",
      accent: rgbToHex(hslToRgb([h, Math.min(0.7, Math.max(0.2, s * 0.75)), 0.55])),
      deep: rgbToHex(hslToRgb([h, s, l * 0.55])),
      strong: rgbToHex(hslToRgb([h, s, l * 0.78])),
    };
  }

  function applyBrand(entry) {
    const ramp = entry.fixed ?? fromSeed(entry.seed);
    const style = root.style;
    style.setProperty("--brand", ramp.brand);
    style.setProperty("--brand-strong", ramp.strong);
    style.setProperty("--brand-deep", ramp.deep);
    style.setProperty("--accent", ramp.accent);
    style.setProperty("--on-brand", ramp.onBrand);
  }

  const swatchHost = $("[data-swatches]");
  if (swatchHost) {
    BRANDS.forEach((entry, i) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "swatch";
      btn.setAttribute("role", "radio");
      btn.setAttribute("aria-checked", String(i === 0));
      btn.setAttribute("aria-label", entry.name);
      btn.title = entry.name;
      btn.tabIndex = i === 0 ? 0 : -1;
      btn.style.setProperty("--c", entry.seed);
      btn.addEventListener("click", () => selectSwatch(i, false));
      swatchHost.append(btn);
    });
    radioKeys(swatchHost, (i) => selectSwatch(i, true));
  }
  function selectSwatch(index, focus) {
    const buttons = $$(".swatch", swatchHost);
    buttons.forEach((b, i) => {
      b.setAttribute("aria-checked", String(i === index));
      b.tabIndex = i === index ? 0 : -1;
    });
    if (focus) buttons[index].focus();
    applyBrand(BRANDS[index]);
  }

  // Arrow keys move through a radio group, as a native one would.
  function radioKeys(group, select) {
    group.addEventListener("keydown", (e) => {
      const keys = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 };
      if (!(e.key in keys)) return;
      const items = $$('[role="radio"], [role="tab"]', group);
      const current = items.indexOf(document.activeElement);
      if (current < 0) return;
      e.preventDefault();
      select((current + keys[e.key] + items.length) % items.length);
    });
  }

  // ── Library name and logo ────────────────────────────────────────────────

  const nameInput = $("#lib-name");
  nameInput?.addEventListener("input", () => {
    const value = nameInput.value.trim() || "Your library";
    $$("[data-lib-name]").forEach((el) => { el.textContent = value; });
  });

  let logoUrl;
  $("[data-logo-input]")?.addEventListener("change", (e) => {
    const file = e.target.files?.[0];
    if (!file || !file.type.startsWith("image/")) return;
    if (logoUrl) URL.revokeObjectURL(logoUrl);
    logoUrl = URL.createObjectURL(file);
    $$("[data-lib-logo]").forEach((img) => { img.src = logoUrl; });
    toast("Logo updated in this browser only");
  });

  // ── Money — MoneyFormat ──────────────────────────────────────────────────

  const FORMATS = {
    npr: { symbol: "Rs", space: true, locale: "en-IN" },
    inr: { symbol: "₹", space: false, locale: "en-IN" },
    kes: { symbol: "KSh", space: true, locale: "en-US" },
    usd: { symbol: "$", space: false, locale: "en-US" },
  };

  // Amounts stay in minor units; only display divides by 100, and a whole
  // amount never shows its decimals.
  function display(minor, f) {
    const whole = minor % 100 === 0;
    const n = (minor / 100).toLocaleString(f.locale, {
      minimumFractionDigits: whole ? 0 : 2,
      maximumFractionDigits: whole ? 0 : 2,
    });
    return `${f.symbol}${f.space ? " " : ""}${n}`;
  }

  const currencyGroup = $("[data-currency]");
  if (currencyGroup) {
    const buttons = $$("[data-cur]", currencyGroup);
    const select = (i, focus) => {
      buttons.forEach((b, j) => { b.setAttribute("aria-checked", String(i === j)); b.tabIndex = i === j ? 0 : -1; });
      if (focus) buttons[i].focus();
      const f = FORMATS[buttons[i].dataset.cur];
      $$("[data-money]").forEach((el) => { el.textContent = display(Number(el.dataset.money), f); });
    };
    buttons.forEach((b, i) => { b.tabIndex = i === 0 ? 0 : -1; b.addEventListener("click", () => select(i, false)); });
    radioKeys(currencyGroup, (i) => select(i, true));
  }

  // ── Download tabs ────────────────────────────────────────────────────────

  const tabs = $("[data-tabs]");
  if (tabs) {
    const buttons = $$('[role="tab"]', tabs);
    const select = (i, focus) => {
      buttons.forEach((b, j) => {
        const on = i === j;
        b.setAttribute("aria-selected", String(on));
        b.tabIndex = on ? 0 : -1;
        $("#" + b.getAttribute("aria-controls")).hidden = !on;
      });
      if (focus) buttons[i].focus();
    };
    buttons.forEach((b, i) => b.addEventListener("click", () => select(i, false)));
    radioKeys(tabs, (i) => select(i, true));
  }

  // ── Platform detection ───────────────────────────────────────────────────

  const ua = navigator.userAgent;
  const platform = /Android/i.test(ua) ? "android"
    : /Windows/i.test(ua) ? "windows"
    : /iPhone|iPad|iPod/i.test(ua) ? "ios"
    : /Macintosh|Mac OS X/i.test(ua) ? "mac"
    : /Linux|X11/i.test(ua) ? "linux"
    : null;

  const PLATFORM_NAMES = { windows: "Windows", android: "Android", linux: "Linux" };
  const heroLabel = $("[data-hero-download-label]");
  const row = platform && $(`.dl-row[data-platform="${platform}"]`);
  if (row) {
    row.classList.add("is-you");
    $("[data-you]", row).hidden = false;
    const btn = $(".btn", row);
    btn.classList.replace("btn-outline", "btn-primary");
    heroLabel.textContent = `Download for ${PLATFORM_NAMES[platform]}`;
  } else if (platform === "mac" || platform === "ios") {
    // No published build: point at the demo instead of a download that isn't there.
    const hero = $("[data-hero-download]");
    hero.href = "https://sawongam.github.io/khulla-digital-library/";
    externalizeLink(hero);
    heroLabel.textContent = "Open the web version";
    $("use", hero).setAttribute("href", "#i-globe");
    const demo = $('.dl-row[data-platform="demo"]');
    demo.classList.add("is-you");
    $(".btn", demo).classList.replace("btn-secondary", "btn-primary");
  }

  // ── Latest release ───────────────────────────────────────────────────────
  // Progressive: every link already points at /releases/latest, so a failed or
  // rate-limited request leaves a working page.

  const ASSET_SUFFIX = {
    windows: "-windows-x64.zip",
    android: "-android.apk",
    linux: "-linux-x64.tar.gz",
    web: "-web.tar.gz",
    sums: "SHA256SUMS.txt",
  };

  const formatSize = (bytes) => bytes >= 1e6 ? `${(bytes / 1e6).toFixed(1)} MB` : `${Math.round(bytes / 1e3)} KB`;

  fetch(`https://api.github.com/repos/${REPO}/releases/latest`, { headers: { Accept: "application/vnd.github+json" } })
    .then((res) => (res.ok ? res.json() : Promise.reject(res.status)))
    .then((release) => {
      const assets = release.assets ?? [];
      for (const [key, suffix] of Object.entries(ASSET_SUFFIX)) {
        const asset = assets.find((a) => a.name.endsWith(suffix));
        if (!asset) continue;
        $$(`[data-asset="${key}"]`).forEach((a) => { a.href = asset.browser_download_url; });
        const file = $(`[data-file="${key}"]`);
        if (file) file.textContent = asset.name;
        const size = $(`[data-size="${key}"]`);
        if (size) size.textContent = formatSize(asset.size);
      }
      if (release.tag_name) {
        const date = release.published_at
          ? new Date(release.published_at).toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })
          : null;
        const meta = $("[data-release-meta]");
        if (meta) {
          meta.textContent = "";
          const link = document.createElement("a");
          link.className = "link";
          link.href = release.html_url;
          externalizeLink(link);
          link.textContent = `Khulla ${release.tag_name}`;
          meta.append(link, date ? `, released ${date}` : "");
        }
      }
    })
    .catch(() => { /* links already resolve to the latest release page */ });

  // ── Copy ─────────────────────────────────────────────────────────────────

  $$("[data-copy]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const pre = document.getElementById(btn.dataset.copy);
      const text = pre.innerText
        .split("\n")
        .map((line) => line.replace(/^\$ /, "").replace(/\s+#.*$/, ""))
        .join("\n")
        .trim();
      try {
        await navigator.clipboard.writeText(text);
        toast("Commands copied");
      } catch {
        const range = document.createRange();
        range.selectNodeContents(pre);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
      }
    });
  });

  // ── Help request → a prefilled GitHub issue ──────────────────────────────

  const composer = $("[data-composer]");
  if (composer) {
    const kind = $("[data-kind]", composer);
    const kinds = $$('[role="radio"]', kind);
    const selectKind = (i, focus) => {
      kinds.forEach((b, j) => { b.setAttribute("aria-checked", String(i === j)); b.tabIndex = i === j ? 0 : -1; });
      if (focus) kinds[i].focus();
    };
    kinds.forEach((b, i) => { b.tabIndex = i === 0 ? 0 : -1; b.addEventListener("click", () => selectKind(i, false)); });
    radioKeys(kind, (i) => selectKind(i, true));

    const body = $("#req-body");
    const error = $("#req-error");
    body.addEventListener("input", () => {
      if (body.value.trim()) { error.hidden = true; body.removeAttribute("aria-invalid"); }
    });

    composer.addEventListener("submit", (e) => {
      e.preventDefault();
      const text = body.value.trim();
      if (!text) {
        error.hidden = false;
        body.setAttribute("aria-invalid", "true");
        body.focus();
        return;
      }
      const type = kinds.find((b) => b.getAttribute("aria-checked") === "true").dataset.value;
      const library = $("#req-library").value.trim();
      const platformValue = $("#req-platform").value;
      const summary = text.split("\n")[0].slice(0, 72);
      const title = `[${type}] ${summary}${text.length > 72 ? "…" : ""}`;
      const lines = [
        `**Type:** ${type}`,
        library ? `**Library:** ${library}` : null,
        `**Platform:** ${platformValue}`,
        "",
        "### What do you need?",
        "",
        text,
        "",
        "<sub>Sent from the Khulla website.</sub>",
      ].filter((l) => l !== null);
      const url = `${GITHUB}/issues/new?title=${encodeURIComponent(title)}&body=${encodeURIComponent(lines.join("\n"))}`;
      window.open(url, "_blank", "noopener");
    });
  }
})();
