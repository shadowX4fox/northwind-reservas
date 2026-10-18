# ADR-102: Restricción de exclusión contra reservas dobles

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: [ADR-001](ADR-001-rest-openapi-apis.md), [ADR-003](ADR-003-postgresql-relational-store.md)

---

## Context

### Problem Statement

Dos solicitudes concurrentes pueden confirmar la misma sala en franjas superpuestas. Los miembros y recepción pierden la confianza en la disponibilidad.

### Requirements

| Tipo | Requisito |
|---|---|
| Functional | Rechazar toda reserva confirmada superpuesta para la misma sala (PO Spec §4 CU2) |
| Non-Functional | Integridad con réplicas concurrentes del Servicio de Reservas |
| Non-Functional | Consistencia fuerte en la Base de Datos de Reservas |
| Constraint | PostgreSQL 16 como motor relacional institucional ([ADR-003](ADR-003-postgresql-relational-store.md)) |

### Business Drivers

- PO Spec §3 Objetivo 1: evitar reservas dobles.
- Sin la garantía, hay conflictos de sala que recepción resuelve a mano.

---

## Decision

### Summary

La Base de Datos de Reservas rechaza con una restricción de exclusión de PostgreSQL toda reserva confirmada superpuesta para la misma sala. El motor garantiza la integridad; el Servicio de Reservas no la coordina.

### Detailed Decision

- La restricción de exclusión de PostgreSQL 16 vive en el esquema de la Base de Datos de Reservas, versionado con migraciones.
- El Servicio de Reservas inserta la reserva "Confirmada" y acepta o rechaza según la respuesta del motor (Fase 4).
- La superposición se devuelve como rechazo de negocio con error RFC 9457 y `code` estable ([ADR-001](ADR-001-rest-openapi-apis.md)).
- No hay bloqueos en la aplicación.
- El rechazo ocurre al confirmar: el miembro elige otra franja y repite la reserva.

### Scope

**What IS included:**
- Reservas en estado "Confirmada" de la misma sala.
- Restricción y migración en la Base de Datos de Reservas.

**What is NOT included:**
- Límite diario por miembro (se cuenta en el Servicio de Reservas).
- Idempotencia de la creación (otra decisión).

---

## Rationale

### Primary Drivers

- **Integridad en el motor** — la restricción se cumple aun con réplicas concurrentes (Escalabilidad Primero, Resiliencia).
- **Sin coordinación de bloqueos** — el principio de Resiliencia prefiere rechazo del motor y reintento idempotente.
- **Servicio sin estado** — las réplicas escalan sin compartir bloqueos.

### Comparison Summary

| Criteria | Restricción de exclusión | Bloqueos en la aplicación |
|----------|----------------|---------------|
| **Integridad con réplicas concurrentes** | ✅ | ⚠️ |
| **Servicio sin estado** | ✅ | ❌ |
| **Lógica en el Servicio de Reservas** | ✅ | ⚠️ |

---

## Consequences

### Positive Consequences

- **Sin reservas dobles** — miembros y recepción; la garantía no depende del código del servicio.
- **Escala horizontal** — réplicas sin bloqueos compartidos.

### Negative Consequences

- **Conflicto visible al confirmar** — el miembro. **Severity**: Low. **Mitigation**: el Portal de Reservas distingue sala ocupada por `code` y ofrece otra franja.
- **Lógica en el esquema** — quien mantiene la base. **Severity**: Low. **Mitigation**: migración Flyway versionada ([ADR-003](ADR-003-postgresql-relational-store.md)).

### Trade-offs

- **Portabilidad vs integridad**: la regla depende de una capacidad propia de PostgreSQL.
- **Detección tardía vs sin bloqueos**: el conflicto aparece al insertar, no antes.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Bloqueos en la aplicación | El principio de Resiliencia los descarta; exigen coordinar réplicas | Not documented |

---

## Implementation Plan

Not documented

---

## Success Metrics

Not documented

---

## References

### Documentation
- docs/04-data-flow-patterns.md (Fases 4 y 5)
- docs/05-integration-points.md (I-04)
- docs/06-technology-stack.md (8.1)
- docs/02-architecture-principles.md (principios 1, 3 y 6)
- docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md

### Related ADRs
- [ADR-001](ADR-001-rest-openapi-apis.md) - Contrato de errores RFC 9457 e idempotencia
- [ADR-003](ADR-003-postgresql-relational-store.md) - PostgreSQL como motor relacional

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

Latencia p95 de la creación: Not documented; el flujo completo apunta a ≤ 2 s.
