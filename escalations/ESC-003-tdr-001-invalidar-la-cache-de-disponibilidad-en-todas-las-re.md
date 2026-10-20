---
id: ESC-003
status: Resolved
date: 2026-10-20
architecture: architecture-v1.4.0
route: tier-2
triggers: [low-confidence]
components: [Servicio de Reservas, Base de Datos de Reservas]
integrations: [I-04]
adrs: [ADR-108]
tdrs: [TDR-001]
requested_by: Equipo del Servicio de Reservas
issue: https://github.com/shadowX4fox/northwind-reservas/issues/42
resolution: architecture-v1.5.0
closed: 2026-10-20
---
# ESC-003 — TDR-001: invalidar la caché de disponibilidad en todas las réplicas con LISTEN/NOTIFY de PostgreSQL

## Request

```text
Cerremos el TDR-001
```

## Why it needs an architect

| Trigger | Evidence |
|---|---|
| low-confidence | build pack 1.4.0, adr:ADR-108, líneas 45 y 56 — "Las otras réplicas no se enteran: su entrada vive hasta expirar." y, fuera de alcance, "Caché distribuida o compartida entre réplicas." La propuesta cambia una decisión Accepted. |
| low-confidence | build pack 1.4.0, tdr:TDR-001, línea 30 — "Opción B: invalidar la entrada de la sede y fecha en todas las réplicas al crear o cancelar una reserva." |
| low-confidence | northwind-servicio-reservas@9348dbe src/main/java/northwind/reservas/dominio/ServicioReservas.java:293 y CacheDisponibilidad.java:55 — Hoy solo la réplica que crea o cancela invalida su entrada, tal como decide ADR-108. |

**Route**: Tier 2 — design authority (CHANGE work).

## What the AI would propose (not applied)

- Al confirmar la creación o la cancelación de una reserva, el Servicio de Reservas emite NOTIFY con la sede y la fecha en la misma transacción, sobre la Base de Datos de Reservas (I-04).
- Cada réplica del Servicio de Reservas mantiene una conexión con LISTEN y, al recibir la notificación, invalida su entrada Caffeine de esa sede y fecha.
- La expiración de 5 minutos de ADR-108 se conserva como red de seguridad si una réplica pierde notificaciones (por ejemplo, al reconectar).
- Sin tecnología ni componente nuevo: PostgreSQL 16 (ADR-003) y Caffeine 3.2 (ADR-108) ya están en la arquitectura.
- ADR-108 se modifica (o se sustituye) para incluir la invalidación entre réplicas; con el código en main, TDR-001 pasa Open → In Progress → Resolved por Tier 0.

## Open questions for the architect

- ADR-108 dice que "las otras réplicas no se enteran" y deja fuera la caché compartida entre réplicas. ¿Se acepta invalidar la entrada en todas las réplicas con LISTEN/NOTIFY de PostgreSQL (opción B de TDR-001) y se modifica ADR-108 en consecuencia?
- Si se acepta: ¿la notificación se emite dentro de la transacción de creación o cancelación (PostgreSQL solo la entrega al confirmar), y la expiración de 5 minutos se conserva como red de seguridad?
- La conexión de LISTEN es una conexión más por réplica hacia la Base de Datos de Reservas, fuera del pool. ¿Hay que reflejarlo en el Interface Contract Servicio de Reservas → Base de Datos de Reservas?

## Resolution

- Resolved 2026-10-20 by architecture-v1.5.0.
