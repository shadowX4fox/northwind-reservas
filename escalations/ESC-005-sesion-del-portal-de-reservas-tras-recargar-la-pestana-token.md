---
id: ESC-005
status: Rejected
date: 2026-10-21
architecture: architecture-v1.8.0
route: tier-1
triggers: [security-iam]
components: [Portal de Reservas]
integrations: [I-01]
adrs: [ADR-104, ADR-002]
tdrs: []
requested_by: el equipo del Portal de Reservas
issue: https://github.com/shadowX4fox/northwind-reservas/issues/82
resolution:
closed: 2026-10-21
---
# ESC-005 — Sesión del Portal de Reservas tras recargar la pestaña: tokens en sessionStorage frente a ADR-104

## Request

```text
Que la sesión del Portal de Reservas sobreviva a una recarga de la pestaña, sin volver a iniciar sesión.
```

## Why it needs an architect

| Trigger | Evidence |
|---|---|
| security-iam | src/auth/auth.ts:26 — El userStore pasa de InMemoryWebStorage a window.sessionStorage: los tokens OIDC quedarían en el almacenamiento del navegador, que ADR-104 e INV-06 prohíben (pack: adr:ADR-104:38, security:26). |

**Route**: Tier 1 — SA office hours.

## What the AI would propose (not applied)

- Guardar el userStore de oidc-client-ts en sessionStorage para recuperar la sesión tras una recarga
- Retirar la prueba de INV-06 (tokens solo en memoria) y sustituirla por una que exige la recuperación tras la recarga

## Open questions for the architect

- ¿Acepta la arquitectura tokens en sessionStorage para el Portal de Reservas, o la pérdida de sesión al recargar sigue siendo la compensación aceptada de ADR-104?
- Si no se aceptan, ¿hay otra vía documentada (renovación silenciosa al cargar, un BFF) para no pedir el inicio de sesión tras recargar?

## Resolution

- Rejected 2026-10-21: ADR-104 se mantiene: los tokens del Portal de Reservas viven solo en memoria, nunca en localStorage ni sessionStorage; perder la sesión al recargar la pestaña es la compensación que la parte de seguridad acepta.
