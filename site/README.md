# site/

The public website for Khulla: one static page, with no framework, no build step and no dependencies.

| File | What it is |
| --- | --- |
| `index.html` | The page. The icon sprite at the top is generated, so don't edit it by hand |
| `styles.css` | Every token, copied from `packages/khulla_ui` (palette, spacing, radius, shadows, motion, type) |
| `app.js` | Logo scroll-to-top, the interactive app preview, brand swatches, the download table and the help form |
| `assets/` | Poppins (the app's bundled weights), the logos, the favicon |
| `scripts/icons.sh` | Rebuilds the icon sprite |

## Preview

Open `index.html` in a browser, or serve the folder:

```sh
python3 -m http.server -d site 8080
```

or 

```sh
npx serve
```

## Keeping it in step with the app

- **Tokens.** The page doesn't import the design system. It copies it. When `app_palette.dart`,
  `app_radius.dart`, `app_spacing.dart`, `app_shadows.dart` or `app_motion.dart` change, update
  the matching custom properties at the top of `styles.css`. The brand derivation in `app.js`
  (`fromSeed`) mirrors `AppBrand.fromSeed`.
- **Icons.** The page draws Solar's *outline* weight from `solar_iconkit`, the same set
  `AppIcons` uses. Reference a glyph as `<use href="#i-<solar-name>"/>`, then run
  `site/scripts/icons.sh` to rebuild the sprite (it needs `make bootstrap` to have filled the
  pub cache). The sprite holds exactly the icons the page references.
- **Facts.** Feature copy is written from the ARB strings and the README. If a feature changes,
  change the sentence. The page promises nothing the current release doesn't do.
- **Version.** Nothing on the page hard-codes a version. `app.js` reads the latest release from
  the GitHub API to fill in file names, sizes and the tag. If that request fails, every download
  link still goes to `/releases/latest`.

## Deploying

Any static host works. GitHub Pages already serves the web demo from the root of this repository's
Pages site, so publish this folder somewhere else: a separate Pages repository, a sub-path, or a
host such as Netlify or Cloudflare Pages pointed at `site/`.
