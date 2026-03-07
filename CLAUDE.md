# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

START v1 is a full-stack financial data platform built with Rails 8 + Inertia.js + React 19. The application tracks market data for stocks (tickers) and options contracts.

**Tech Stack:**
- Backend: Rails 8.1.2 (Ruby 4.0.1) + PostgreSQL 13+
- Frontend: React 19 + Inertia.js 2.3 + TypeScript 5.9
- Styling: Tailwind CSS 4.2 + shadcn/ui (base-lyra style)
- Build: Vite 7.3
- Deployment: Kamal

## Development Commands

### Running the Application
```bash
bin/dev
```

### Testing
```bash
bin/rails test                          # Run all tests
bin/rails test test/models              # Run model tests
bin/rails test test/controllers         # Run controller tests
bin/rails test test/integration         # Run integration tests
bin/rails test <path/to/test_file.rb>  # Run a single test file
```

### Database
```bash
bin/rails db:migrate        # Run pending migrations
bin/rails db:migrate:reset  # Reset DB
bin/rails db:rollback       # Rollback last migration
bin/rails db:seed           # Load seed data
```

### Setup
```bash
bin/setup                # Initial project setup
```

## Architecture

### Inertia.js Server-Driven SPA

This project uses **Inertia.js** to build a server-driven React SPA. Key concepts:

- **Controllers render Inertia responses** instead of JSON or HTML templates
- **Page components** live in `app/frontend/pages/` and are auto-resolved
- **Shared data** (like current user) is configured in `config/initializers/inertia_rails.rb`
- **No REST API needed** - controllers pass props directly to React components
- **TypeScript path aliases**: `@/*` maps to `app/frontend/*`, `~/*` maps to `app/javascript/*`

Example controller action:
```ruby
def show
  render inertia: 'Tickers/Show', props: {
    ticker: ticker.as_json
  }
end
```

Corresponding React component at `app/frontend/pages/Tickers/Show.tsx`:
```tsx
export default function Show({ ticker }: { ticker: Ticker }) {
  // Component code
}
```

### Frontend Structure

```
app/frontend/
├── components/
│   └── ui/              # shadcn/ui components (button, input, sheet, etc.)
├── pages/               # Inertia page components
├── lib/
│   └── utils.ts         # Utility functions (cn for className merging)
├── types/               # TypeScript type definitions
└── entrypoints/
    ├── application.ts   # Vite entry point
    └── inertia.tsx      # Inertia app setup with React 19
```

**Component library:**
- shadcn/ui with base-lyra style preset
- Icons: Lucide React + Phosphor Icons
- Tailwind CSS v4 with CSS variables for theming

## Conventions

- **Always use UUID, not integer ID, as the record identifier** in API responses, frontend types, query keys, and URLs. Never expose or use `id` for records that have a `uuid`.
- **ALWAYS** optimize for best practices and high quality and readable code.
- Use OpenAPI standards for API endpoints.
- Use Sorbet for type signatures.