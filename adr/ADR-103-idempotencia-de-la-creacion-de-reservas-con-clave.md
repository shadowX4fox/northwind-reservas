# ADR-103: Idempotencia de la creación de reservas con clave

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-001, ADR-003

---

## Context

### Problem Statement

Un doble clic o un reintento por pérdida de red puede crear dos reservas para la misma confirmación. La creación debe ejecutarse una sola vez por clave.

### Requirements

| Tipo | Requisito |
|---|---|
| Functional | Un reintento devuelve la reserva ya creada, sin crear una segunda (PO Spec §4 CU2) |
| Functional | La creación envía `Idempotency-Key` en la cabecera (I-02) |
| Reliability | Clave y respuesta se guardan 24 horas |
| Constraint | Contrato REST/OpenAPI según ADR-001 |
| Constraint | Persistencia en la Base de Datos de Reservas según ADR-003 |

### Business Drivers

- Evitar reservas duplicadas del miembro por reintentos del navegador o de la red.
- Mantener el flujo completo de creación dentro de 2 s.

---

## Decision

### Summary

El Portal de Reservas genera en el navegador una clave por cada confirmación y la envía en `Idempotency-Key`. El Servicio de Reservas busca la clave antes de insertar y guarda clave y respuesta 24 horas en la Base de Datos de Reservas.

### Detailed Decision

- El Portal de Reservas genera una clave nueva por cada confirmación de reserva.
- La clave viaja en la cabecera `Idempotency-Key` de la llamada I-02.
- Fase 4, paso 1: el Servicio de Reservas busca la clave antes de insertar.
- Clave ya registrada: devuelve la respuesta guardada, sin insertar.
- Clave nueva: inserta la reserva confirmada y la clave con su respuesta.
- TTL de clave y respuesta: 24 horas, según ADR-001.

### Scope

| Incluido | No incluido |
|---|---|
| Creación de reservas (Fase 4) | Consulta de disponibilidad y cancelación |
| Clave generada en el navegador | Nombre de la tabla de claves: Not documented |
| Almacén en la Base de Datos de Reservas | Rechazo por superposición (decisión aparte) |

---

## Rationale

### Primary Drivers

- **Caso borde de CU2** — el doble clic y el reintento por red devuelven la reserva existente.
- **Clave por confirmación** — el cliente identifica la intención; el servidor no la infiere.
- **Almacén existente** — la Base de Datos de Reservas ya guarda la reserva; no se añade componente (ADR-003).
- **Contrato REST** — una cabecera estándar encaja en la API de ADR-001.

### Comparison Summary

Not documented

---

## Consequences

### Positive Consequences

- **Sin duplicados** — el miembro recibe el mismo código de reserva ante un reintento.
- **Sin componente nuevo** — la clave vive en la base existente.

### Negative Consequences

- **Búsqueda previa en cada creación** — afecta al Servicio de Reservas. **Severity**: Low. **Mitigation**: Not documented.
- **Almacenamiento de claves y respuestas** — afecta a la Base de Datos de Reservas. **Severity**: Low. **Mitigation**: expiración a 24 horas.

### Trade-offs

- **Simplicidad vs. ventana de protección**: un reintento posterior a 24 horas se trata como clave nueva.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Not documented | Not documented | Not documented |

---

## Implementation Plan

Not documented

---

## Success Metrics

Not documented

---

## References

### Documentation
- docs/04-data-flow-patterns.md (Fase 4, Idempotencia)
- docs/05-integration-points.md (I-02)

### Related ADRs
- [ADR-001](ADR-001-rest-openapi-apis.md) - Contrato REST/OpenAPI y TTL de 24 horas
- [ADR-003](ADR-003-postgresql-relational-store.md) - Almacén relacional de la Base de Datos de Reservas

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

- Nombre de la tabla de claves y presupuesto de latencia p95 de la Fase 4: Not documented.
