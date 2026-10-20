---
status: In Progress
date: 2026-10-19
related-adrs: [ADR-108, ADR-109]
affected-components: ["Servicio de Reservas"]
tags: [disponibilidad, cache, CU1]
driver: Architecture
---

# TDR-001: La consulta de disponibilidad se sirve de una caché de 5 minutos

## Status

`In Progress`

**Initiative**: Reservas de Salas Northwind (architecture v1.1.1)
**Driver**: Architecture — caché en memoria en lugar de un índice por sala y franja

## Description

El Servicio de Reservas sirve la consulta de disponibilidad (CU1) desde una caché en proceso Caffeine 3.2 de 5 minutos por sede y fecha ([ADR-108](../adr/ADR-108-cache-en-proceso-con-caffeine-para-disponibilidad.md)). Así cumple el p95 de 1 s sin un índice por sala y franja en la Base de Datos de Reservas. Solo la réplica que crea o cancela una reserva invalida su entrada.

## Impact

Una sala recién reservada en otra réplica puede verse libre hasta 5 minutos. La reserva doble la impide igualmente la verificación de solapamiento al crear, pero el miembro ve un error tras elegir la sala.

## Possible Solutions

- Opción A: índice por sala y franja en la Base de Datos de Reservas y retirar la caché.
- Opción B: invalidar la entrada de la sede y fecha en todas las réplicas al crear o cancelar una reserva.

## Owner

- **Technical**: Equipo del Servicio de Reservas
- **Business (P&L)**: Gerencia de Producto Digital

---

## History

- 2026-10-19: Creado. Status: `Open`. Evidencia: caché de 5 minutos en northwind-servicio-reservas (prueba de CI de la etapa 9); solicitud https://github.com/shadowX4fox/northwind-reservas/issues/19.
- 2026-10-20: La caché no existía en el código (ESC-002, https://github.com/shadowX4fox/northwind-reservas/issues/38); el arquitecto decide implementarla con Caffeine (ADR-108). Status: `Open`.
- 2026-10-20: ESC-003 (https://github.com/shadowX4fox/northwind-reservas/issues/42) acepta invalidar en todas las réplicas con LISTEN/NOTIFY (ADR-109). Status: `In Progress`.
