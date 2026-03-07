# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

START v1 is a full-stack financial data platform built with Rails 8 + Inertia.js + React 19. The application tracks market data for stocks (tickers) and options contracts with historical pricing at daily and minute intervals.

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

### Authentication

Session-based authentication using signed cookies (httponly, same_site: lax):

- **Authentication concern**: `app/controllers/concerns/authentication.rb` provides `require_authentication`, `Current.session`, `Current.user`
- **User model**: Uses bcrypt via `has_secure_password`
- **Session model**: Tracks IP address and user agent
- **Rate limiting**: 10 login attempts per 3 minutes
- **Controllers**: All inherit authentication requirement by default; use `allow_unauthenticated_access` to skip

### Database Schema

**Core domain models:**

- `User` - has_many sessions
- `Session` - belongs_to user, tracks IP/user agent
- `Ticker` - Stock symbols with metadata (symbol, name, exchange)
- `OptionContract` - belongs_to ticker (option_type, strike_price, expires_on)
- `TickerDailyPrice` / `TickerMinutePrice` - OHLCV data for tickers
- `OptionDailyPrice` / `OptionMinutePrice` - OHLCV data for options

All price models include: `price_open`, `price_high`, `price_low`, `price_close`, `volume`, `vwap`, `num_trades`

Unique indexes on `(ticker_id, date)` and `(ticker_id, start_at)` prevent duplicate price records.

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

### Dual Asset Pipeline

1. **Vite** (modern frontend): Handles React/TypeScript in `app/frontend/`
2. **Propshaft** (Rails default): Handles other assets in `app/assets/`

Entry points defined in `app/frontend/entrypoints/`. Vite dev server runs on port 3036 with hot module reloading.

## Key Configuration Files

- `components.json` - shadcn/ui setup (style: base-lyra, iconLibrary: lucide)
- `.rubocop.yml` - Inherits Rails Omakase style guide
- `vite.json` - Vite dev server port 3036, sourceCodeDir: app/frontend
- `config/initializers/inertia_rails.rb` - Inertia configuration and shared data
- `Procfile.dev` - Foreman process file for concurrent dev servers
