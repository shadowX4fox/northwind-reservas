# ADR-106: Retención de 24 meses, purga y auditoría

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-003, ADR-005

---

## Context

### Problem Statement

El portal guarda datos personales y cancelaciones. La ley aplicable exige un plazo de conservación y trazabilidad de cada cancelación; sin esta decisión no hay plazo ni rastro.

### Requirements

| Tipo | Requisito |
|---|---|
| Funcional | Conservar reservas 24 meses y eliminarlas luego |
| Funcional | Registrar quién, cuándo y por qué se cancela cada reserva |
| Funcional | Conservar el registro de auditoría 24 meses |
| Cumplimiento | Ley de protección de datos personales aplicable (PO Spec §7) |
| Seguridad | Mitigar conservación de datos más allá del plazo y cancelación sin rastro |

### Business Drivers

- Cumplir la ley de protección de datos personales sobre nombre, correo y reservas del miembro.
- Dar evidencia auditable de cada cancelación.

---

## Decision

### Summary

Las reservas y el registro de auditoría de cancelaciones se conservan 24 meses en la `Base de Datos de Reservas`. Una purga programada los elimina. El `Servicio de Reservas` escribe la auditoría en la misma transacción de la cancelación.

### Detailed Decision

- Retención de reservas: 24 meses, luego eliminación por purga programada.
- Retención del registro de auditoría de cancelaciones (quién, cuándo, motivo): 24 meses.
- El `Servicio de Reservas` escribe el registro en la misma transacción que la cancelación.
- Ambos datos residen en la `Base de Datos de Reservas`, responsable de la purga.
- Calendario de la purga: Not documented.

### Scope

**What IS included:**
- Reservas y registro de auditoría de cancelaciones.
- Purga programada en la `Base de Datos de Reservas`.

**What is NOT included:**
- Calendario de la purga: Not documented.
- Respaldos: siguen su propia retención de 30 días ([ADR-003](ADR-003-postgresql-relational-store.md)).

---

## Rationale

### Primary Drivers

- **Cumplimiento legal** — la PO Spec §7 fija 24 meses para reservas y auditoría.
- **Atomicidad** — la auditoría en la transacción de cancelación impide cancelaciones sin rastro.
- **Almacén único** — la `Base de Datos de Reservas` ya es el almacén del servicio ([ADR-003](ADR-003-postgresql-relational-store.md)).

### Comparison Summary

| Criteria | Selected Option | Alternative 1 | Alternative 2 |
|----------|----------------|---------------|---------------|
| **Cumple plazo legal** | ✅ | ⚠️ | ❌ |
| **Auditoría sin pérdida** | ✅ | ❌ | ⚠️ |
| **Simplicidad** | ✅ | ✅ | ❌ |

Not documented: las alternativas no figuran en las fuentes; las columnas son genéricas.

---

## Consequences

### Positive Consequences

- **Cumplimiento** — los datos personales no superan el plazo de 24 meses.
- **Trazabilidad** — cada cancelación deja un registro confiable.

### Negative Consequences

- **Respaldos con datos purgados** — los respaldos diarios conservan hasta 30 días datos ya purgados. **Severity**: Low. **Mitigation**: Not documented.

### Trade-offs

- **Retención vs. privacidad**: la auditoría conserva datos 24 meses.
- **Atomicidad vs. latencia**: la escritura de auditoría se suma a la transacción de cancelación.

---

## Alternatives Considered

Not documented: las fuentes no muestran alternativas evaluadas.

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Not documented | Not documented | Not documented |

---

## Implementation Plan

Not documented.

---

## Success Metrics

Not documented.

---

## References

### Documentation
- docs/07-security-architecture.md (9.2, 9.3, 9.4)
- docs/09-operational-considerations.md (11.1, 11.3, 11.4)
- PRODUCT_OWNER_SPEC.md (§7 Requisitos Regulatorios y de Cumplimiento)

### Related ADRs
- [ADR-003](ADR-003-postgresql-relational-store.md) - PostgreSQL como base de datos relacional institucional
- [ADR-005](ADR-005-kubernetes-container-runtime.md) - Despliegue en el clúster Kubernetes de Plataforma Northwind

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

- Calendario de la purga, RTO y RPO: Not documented.
- Los respaldos conservan datos hasta 30 días después de la purga.
