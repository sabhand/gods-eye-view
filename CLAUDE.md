# God's Eye View

Browser-based 3D globe of live public data. Vanilla JS (ES modules, no framework) + CesiumJS + Vite. Full contributor guide: [CONTRIBUTING.md](CONTRIBUTING.md). Authoritative runtime reference: [docs/CURRENT-STATE.md](docs/CURRENT-STATE.md) — read it before changing a feature.

## Setup

- Node `>=24.14 <25` or `26.x` (enforced by `package.json`). In Claude Code cloud sessions, `.claude/hooks/session-start.sh` installs Node 24 and dependencies and points puppeteer at the preinstalled Chromium.
- `npm run doctor` checks the toolchain and lists which optional provider keys are configured. No key is needed to boot.
- `npm run dev` serves http://localhost:4173. Never bind it to the LAN (`--host`): it exposes configured API keys (see [SECURITY.md](SECURITY.md)). Never commit `.env` or keys.

## Checks

- `npm test` — unit suite (node:test, `*.test.mjs` next to sources). Run one file with `node --test path/to/file.test.mjs`.
- `npm run build` — production build.
- `npm run test:track` — tracking regression; needs the dev server running.
- `npm run format:check` and `npm run check:boundaries` — CI runs both. Use `npm run format` to fix; keep formatting in its own commit.
- Feature gates: `scripts/qa-*.mjs` drive the real app headlessly. Run the gate for whatever you touched; each file's header says how. CI does not run `test:track` or any `qa-*` gate.
- Cloud sessions can't reach most map tile hosts, so the globe renders blank there; UI and logic still work.

## Conventions

- 2-space indent, single quotes, semicolons, JSDoc on exported functions. Match surrounding code.
- Ownership: assembly in `src/app/`, UI in `src/ui/`, layers in `src/layers/<family>/`, portable sources in `src/sources/`, voice in `src/voice/`, server proxies in `server/providers/`. See [docs/CODE-BOUNDARIES.md](docs/CODE-BOUNDARIES.md).
- Secrets stay server-side behind `server/providers/`; the browser only sees the restricted Google Maps key and ephemeral tokens.
- World text labels use the world-overlay host, never Cesium text labels.
- Share-link layer tokens are immutable: follow the "Share-link layer tokens" section of CONTRIBUTING.md.
- Runtime behavior changes update `docs/CURRENT-STATE.md` and `CHANGELOG.md`; new data sources update `DATA_SOURCES.md`.
