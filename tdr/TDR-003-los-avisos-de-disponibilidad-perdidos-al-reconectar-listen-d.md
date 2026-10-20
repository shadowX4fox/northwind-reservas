---
status: Open
date: 2026-10-20
related-adrs: ["ADR-109", "ADR-102"]
affected-components: ["Servicio de Reservas"]
tags: [disponibilidad, cache, listen-notify]
driver: Architecture
---

# TDR-003: Los avisos de disponibilidad perdidos al reconectar LISTEN dejan la caché desactualizada hasta 5 minutos

## Status

`Open`

**Initiative**: Reservas de Salas Northwind (architecture v1.5.1)
**Driver**: Architecture — la reconexión de LISTEN no vacía la caché de la réplica

## Description

Cuando se pierde la conexión LISTEN al canal disponibilidad, los avisos de ese intervalo se pierden: PostgreSQL no los guarda. La réplica del Servicio de Reservas registra el aviso, espera y reconecta, pero no vacía la caché; esa réplica sirve disponibilidad desactualizada hasta 5 minutos, la expiración de ADR-109.

## Impact

El Portal de Reservas puede mostrar libre una franja ya reservada. La reserva no se duplica, porque la Base de Datos de Reservas la rechaza (ADR-102), pero el usuario recibe un 409 inesperado (`ROOM_OCCUPIED`).

## Possible Solutions

- Opción A: al reconectar, vaciar la caché de disponibilidad de la réplica.
- Opción B: exponer la escucha en el health check de readiness, para que la réplica salga del balanceo mientras está desconectada.

## Owner

- **Technical**: Equipo del Servicio de Reservas
- **Business (P&L)**: Gerencia de Producto Digital

---

## History

- 2026-10-20: Creado. Status: `Open`. Evidencia: northwind-servicio-reservas@33fc2f0 `EscuchaDisponibilidad.java` líneas 82-88 y `ErrorDeNegocio.java` línea 31; solicitud https://github.com/shadowX4fox/northwind-reservas/issues/52.
