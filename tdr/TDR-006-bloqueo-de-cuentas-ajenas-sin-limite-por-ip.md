---
status: Open
date: 2026-11-03
related-adrs: [ADR-002]
affected-components: ["Servidor de Identidad Northwind"]
tags: [T3-D, stride, denegacion-de-servicio, fuerza-bruta]
driver: Architecture
---

# TDR-006: El bloqueo por cuenta del Servidor de Identidad Northwind permite bloquear cuentas ajenas

## Status

`Open`

**Initiative**: Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión (architecture v1.10.5)
**Driver**: Architecture — control de fuerza bruta solo por cuenta

## Description

Keycloak 25 bloquea una cuenta 15 minutos tras 5 intentos fallidos ([Sección 9.3](../docs/07-security-architecture.md)). No hay límite de peticiones por IP documentado en el inicio de sesión (I-01). Lo registra STRIDE T3-D; se aceptó en el PR #134.

## Impact

Disponibilidad. Alguien sin cuenta que conozca correos puede bloquear a miembros y recepcionistas de forma repetida. Un bloqueo masivo en recepción deja a una sede sin poder cancelar reservas.

## Possible Solutions

- Option A: límite de peticiones por IP en el inicio de sesión de Keycloak o en el ingress.
- Option B: CAPTCHA tras varios fallos y bloqueo progresivo en lugar de fijo.

## Owner

- **Technical**: Plataforma Northwind
- **Business (P&L)**: Dirección de Operaciones

---

## History

- 2026-11-03: Created. Status: `Open`. STRIDE T3-D, aceptado en https://github.com/shadowX4fox/northwind-reservas/pull/134.
