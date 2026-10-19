---
status: Open
date: 2026-10-19
related-adrs: ["ADR-103", "ADR-106"]
affected-components: ["Servicio de Reservas", "Base de Datos de Reservas"]
tags: [idempotencia, purga, almacenamiento, retencion]
driver: Architecture
---

# TDR-002: Las claves de idempotencia vencidas nunca se purgan

## Status

`Open`

**Initiative**: Reservas de Salas Northwind (architecture v1.2.0)
**Driver**: Architecture — sin purga programada para la tabla de claves de idempotencia

## Description

El Servicio de Reservas guarda cada `Idempotency-Key` con su respuesta en la tabla `clave_idempotencia` de la Base de Datos de Reservas (ADR-103), pero ninguna purga elimina las claves de más de 24 horas. La búsqueda las ignora al vencer, así que la idempotencia funciona; las filas se quedan para siempre.

## Impact

La tabla crece sin límite, una fila por cada creación de reserva, y con ella el almacenamiento y los respaldos de la Base de Datos de Reservas. Cada fila guarda la respuesta de la creación (el `sub` del miembro y el asunto de la reserva), que permanece más allá de las 24 horas de ADR-103 y del plazo de 24 meses de ADR-106.

## Possible Solutions

- Opción A: una purga programada en la Base de Datos de Reservas que elimine las claves con `creada_en` de más de 24 horas, junto con la purga de 24 meses de ADR-106.
- Opción B: el Servicio de Reservas borra las claves vencidas de forma periódica, con un índice sobre `creada_en`.

## Owner

- **Technical**: Equipo del Servicio de Reservas
- **Business (P&L)**: Gerencia de Producto Digital

---

## History

- 2026-10-19: Creado. Status: `Open`. Evidencia: northwind-servicio-reservas@53bad3d `V1__esquema_inicial.sql` líneas 57 y 65 y `RepositorioReservas.java` línea 90; solicitud https://github.com/shadowX4fox/northwind-reservas/issues/24.
