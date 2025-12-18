# MySched Documentation

This directory contains all project documentation organized by category.

## Structure

```
docs/
├── index.md                 # This file - documentation home
├── reference/               # Design and technical reference docs
│   ├── DESIGN_SYSTEM.md     # UI/UX design system specification
│   ├── ARCHITECTURE.md      # System architecture
│   ├── API.md               # Database schema and data access
│   ├── SECURITY.md          # Security guidelines
│   ├── ONBOARDING.md        # Developer setup guide
│   ├── DEPLOYMENT.md        # Build and release procedures
│   ├── PERFORMANCE.md       # Performance optimization
│   ├── ERROR_HANDLING.md    # Error handling patterns
│   └── PRIVACY.md           # Privacy policy
│
├── audit/                   # Screen and component specifications
│   ├── index.md             # Audit documentation index
│   ├── screens/             # Screen-level specs
│   ├── kit/                 # Component kit specs
│   ├── forms/               # Form and account specs
│   └── sheets/              # Bottom sheet specs
│
└── reports/                 # Code reviews and analysis
    └── CODE_REVIEW_REPORT.md
```

## Quick Links

### Reference Documentation

| Document | Description |
|----------|-------------|
| [Design System](reference/DESIGN_SYSTEM.md) | Visual tokens, components, motion, accessibility |
| [Architecture](reference/ARCHITECTURE.md) | System overview, services, data flow |
| [API](reference/API.md) | Database schema, RLS, query patterns |
| [Security](reference/SECURITY.md) | Auth, authorization, data protection |
| [Onboarding](reference/ONBOARDING.md) | Developer setup and workflow |
| [Deployment](reference/DEPLOYMENT.md) | Build, release, OTA updates |
| [Performance](reference/PERFORMANCE.md) | Optimization guidelines |
| [Error Handling](reference/ERROR_HANDLING.md) | Error patterns and messaging |
| [Privacy](reference/PRIVACY.md) | Privacy policy |

### Audit Specifications
- [Audit Index](audit/index.md) - All screen and component specs

### Reports
- [Code Review Report](reports/CODE_REVIEW_REPORT.md) - Latest code review findings

## Root-Level Documentation

These files remain at the project root per convention:

| File | Purpose |
|------|---------|
| `README.md` | Project overview and quick start |
| `CHANGELOG.md` | Version history and release notes |
| `AGENTS.md` | AI assistant configuration |
| `CLAUDE.md` | Claude-specific context |
