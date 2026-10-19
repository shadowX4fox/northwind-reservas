---
status: Open
date: 2026-10-19
related-adrs: []
affected-components: ["Servicio de Reservas"]
tags: [disponibilidad, cache, CU1]
driver: Architecture
---

# TDR-001: La consulta de disponibilidad se sirve de una caché de 5 minutos

## Status

`Open`

**Initiative**: Reservas de Salas Northwind (architecture v1.1.1)
**Driver**: Architecture — caché en memoria en lugar de un índice por sala y franja

## Description

El Servicio de Reservas sirve la consulta de disponibilidad (CU1) desde una caché en memoria de 5 minutos por sede y fecha, para cumplir el p95 de 1 s sin un índice por sala y franja en la Base de Datos de Reservas.

## Impact

Una sala recién reservada puede verse libre hasta 5 minutos. La reserva doble la impide igualmente la verificación de solapamiento al crear, pero el miembro ve un error tras elegir la sala.

## Possible Solutions

- Opción A: índice por sala y franja en la Base de Datos de Reservas y retirar la caché.
- Opción B: invalidar la caché de la sede y fecha al crear o cancelar una reserva.

## Owner

- **Technical**: Equipo del Servicio de Reservas
- **Business (P&L)**: Gerencia de Producto Digital

---

## History

- 2026-10-19: Creado. Status: `Open`. Evidencia: caché de 5 minutos en northwind-servicio-reservas (prueba de CI de la etapa 9); solicitud https://github.com/shadowX4fox/northwind-reservas/issues/19.
