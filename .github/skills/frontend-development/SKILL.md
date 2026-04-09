---
name: frontend-development
description: "**WORKFLOW SKILL** — Design and implement frontend applications and UI components. USE FOR: HTML5, CSS3, TypeScript, React, Vue, Angular, Svelte, Vite, responsive design, accessibility (a11y), state management, routing, SSR/SSG, component libraries, design systems, performance optimization. USE WHEN: building web UIs, single-page applications, component libraries, or frontend integration with backend APIs."
argument-hint: "Describe the frontend task (e.g., 'React dashboard with TypeScript and Tailwind CSS')"
---

# Frontend Development

Design and implement frontend applications, UI components, and client-side logic.

## When to Use

- Building new web applications or SPAs
- Creating reusable UI components or design systems
- Implementing responsive layouts and accessibility
- Integrating frontend with REST, GraphQL, or WebSocket backends
- Optimizing frontend performance (bundle size, rendering, caching)

## Framework Reference

### React

| Stack | Use Case |
| ----- | -------- |
| React + Vite | SPA, fast dev iteration |
| Next.js | SSR/SSG, full-stack React, SEO |
| Remix | Nested routing, progressive enhancement |
| React Native | Mobile (iOS/Android) |

**Patterns**: Hooks, Context, React Query / TanStack Query, Zustand / Jotai state management, React Router, React Hook Form + Zod.

### Vue

| Stack | Use Case |
| ----- | -------- |
| Vue 3 + Vite | SPA, Composition API |
| Nuxt 3 | SSR/SSG, file-based routing |

**Patterns**: Composition API, Pinia state management, Vue Router, VueUse composables, Vuetify / PrimeVue UI.

### Angular

| Stack | Use Case |
| ----- | -------- |
| Angular 17+ | Enterprise SPAs, strong typing |
| Angular Universal | SSR |

**Patterns**: Signals, standalone components, RxJS, NgRx/SignalStore, Angular Material, reactive forms.

### Svelte

| Stack | Use Case |
| ----- | -------- |
| SvelteKit | Full-stack Svelte, SSR/SSG |
| Svelte 5 | Lightweight SPA, runes reactivity |

**Patterns**: Runes (`$state`, `$derived`, `$effect`), load functions, form actions, Skeleton UI.

## Styling

| Approach | When |
| -------- | ---- |
| Tailwind CSS | Utility-first, rapid prototyping, design systems |
| CSS Modules | Scoped styles, co-located with components |
| Vanilla CSS / PostCSS | Standard projects, CSS-first approach |
| Styled Components / Emotion | CSS-in-JS, dynamic theming (React) |
| Sass/SCSS | Legacy projects, complex selector hierarchies |

## Build Tools

| Tool | Purpose |
| ---- | ------- |
| Vite | Dev server, HMR, production bundling (recommended default) |
| esbuild | Ultra-fast bundling, library builds |
| Webpack | Legacy, complex plugin ecosystem |
| Turbopack | Next.js optimized bundler |
| tsup | Library bundling with TypeScript |

## Accessibility (a11y)

- Semantic HTML first (`<nav>`, `<main>`, `<article>`, `<button>`)
- ARIA attributes only when native semantics are insufficient
- Keyboard navigation: focus management, tab order, skip links
- Color contrast: WCAG 2.1 AA minimum (4.5:1 text, 3:1 large text)
- Screen reader testing: axe-core, Lighthouse, VoiceOver/NVDA
- Reduced motion: `prefers-reduced-motion` media query

## Performance

| Area | Technique |
| ---- | --------- |
| Bundle size | Tree-shaking, code splitting, dynamic imports |
| Images | WebP/AVIF, responsive `<picture>`, lazy loading |
| Rendering | Virtual scrolling, memoization, suspense boundaries |
| Caching | Service workers, CDN, `Cache-Control` headers |
| Metrics | Core Web Vitals (LCP, FID/INP, CLS) |

## Procedure

1. **Define** UI requirements, wireframes, and component hierarchy
2. **Choose** framework, styling approach, and build tooling
3. **Scaffold** project with proper TypeScript configuration
4. **Implement** components with accessibility built in
5. **Integrate** with backend APIs (REST, GraphQL, WebSocket)
6. **Style** with responsive design and mobile-first approach
7. **Test** components (unit with Vitest, e2e with Playwright/Cypress)
8. **Optimize** bundle size, load performance, and Core Web Vitals
9. **Document** component API and usage patterns

## Code Standards

- TypeScript strict mode (`strict: true`)
- Components: small, single-responsibility, composable
- No inline styles except truly dynamic values
- Semantic HTML over `<div>` soup
- Error boundaries for graceful failure
- Environment variables for API URLs and config (never hardcode)
