# Training Progress Dashboard

A Next.js 14+ App Router web application for tracking progress across all six learning tracks. Built with TypeScript, Tailwind CSS, and local JSON persistence.

This dashboard is both a tool (tracks your training) and a training project itself (demonstrates Next.js skills from the `software-engineer` track).

---

## Quick Start

```bash
cd dashboard
npm install
npm run dev
# → http://localhost:3000
```

---

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 14+ (App Router) | Industry standard, RSC + streaming, App Router is the future |
| Language | TypeScript (strict) | Type safety across the whole app |
| Styling | Tailwind CSS | Utility-first, no CSS files to maintain |
| Persistence | `data/progress.json` | Zero infrastructure to start; swappable for PostgreSQL |
| Data access | `src/lib/data.ts` | All reads/writes through one layer — enables DB migration |
| Convention | `src/app/` (not bare `app/`) | All Next.js projects in this repo follow the `src/` directory convention |

---

## Pages

| Route | Purpose |
|-------|---------|
| `/` | Overview: global progress, active tracks, streak counter, recent activity |
| `/tracks` | All tracks with per-track progress bars |
| `/tracks/[slug]` | Individual track: modules list, status toggles, hours logger |
| `/roadmap` | Visual roadmap timeline (Phase 1 → 4 with milestones) |
| `/log` | Daily log entry: what I worked on, hours, notes |

---

## Components

| Component | File | Used on |
|-----------|------|---------|
| `ProgressBar` | `src/components/ProgressBar.tsx` | Everywhere |
| `ModuleCard` | `src/components/ModuleCard.tsx` | `/tracks/[slug]` |
| `TrackCard` | `src/components/TrackCard.tsx` | `/tracks` |
| `RoadmapTimeline` | `src/components/RoadmapTimeline.tsx` | `/roadmap` |
| `Sidebar` | `src/components/Sidebar.tsx` | All pages (desktop) |
| `BottomNav` | `src/components/BottomNav.tsx` | All pages (mobile) |
| `StreakCounter` | `src/components/StreakCounter.tsx` | `/` overview |

---

## Data Schema

Data lives in `data/progress.json`. See the full schema in [the data file itself](data/progress.json).

Key structure:
```
tracks[] → modules[] → { status, hoursLogged, lastUpdated, notes }
dailyLog[] → { date, trackId, moduleId, hours, notes }
streak → { current, longest, lastStudyDate }
```

---

## PostgreSQL Migration Path

The data access layer in `lib/data.ts` is the **only** place that reads/writes `progress.json`. To migrate to PostgreSQL:

1. Create a PostgreSQL schema matching the JSON structure (migration script: `scripts/migrate-to-postgres.sql`)
2. Replace the `readProgress()` and `writeProgress()` functions in `lib/data.ts` with Prisma or raw `pg` queries
3. Update `docker-compose.yml` to add the database service (already there — it's `training_postgres`)
4. Update environment variables: add `DATABASE_URL`
5. Remove `data/progress.json` (back it up first)

No component files need to change — they consume typed data through `lib/data.ts`.

**Why this matters:** This is the strangler fig pattern applied to a data layer. It demonstrates architecture thinking: designing for extensibility without over-engineering upfront.

---

## Scripts

```bash
npm run dev      # Development server with hot reload
npm run build    # Production build
npm run start    # Start production server
npm run lint     # ESLint
npm run type-check  # TypeScript check (no emit)
```

---

## Deployment

The CI workflow in `.github/workflows/dashboard-deploy.yml` builds the dashboard on every push to `main` that touches `dashboard/`.

**Recommended deployment:** Vercel (zero config for Next.js).

See the workflow file for the full deployment configuration. Two commented options are provided: Vercel and GitHub Pages.
