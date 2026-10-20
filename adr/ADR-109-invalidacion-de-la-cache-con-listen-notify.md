# ADR-109: Invalidación de la caché con LISTEN/NOTIFY

**Status**: Accepted
**Scope**: User
**Date**: 2026-10-20
**Authors**: Architecture Team
**Related**: Supersedes [ADR-108](ADR-108-cache-en-proceso-con-caffeine-para-disponibilidad.md); ADR-003, ADR-102, TDR-001

---

## Context

### Problem Statement

Con ADR-108, una sala reservada en otra réplica puede verse libre hasta 5 minutos (TDR-001). Las réplicas no se avisan entre sí.

### Requirements

| Type | Requirement |
|---|---|
| Functional | Consultar la disponibilidad de salas por sede, fecha y franja (PO Spec CU1) |
| Performance | Consulta de disponibilidad ≤ 1 s p95 (PO Spec §8) |
| Reliability | Ninguna reserva doble ([ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)) |
| Constraint | La Base de Datos de Reservas, en PostgreSQL 16, es la única fuente de salas y reservas ([ADR-003](ADR-003-postgresql-relational-store.md)) |
| Constraint | El Servicio de Reservas corre con al menos 2 réplicas ([ADR-005](ADR-005-kubernetes-container-runtime.md)) |

### Business Drivers

- Que el miembro no elija una sala ya ocupada y reciba "sala ocupada" al reservar.
- Cerrar TDR-001 sin tecnología nueva que operar.

---

## Decision

### Summary

El Servicio de Reservas mantiene la caché Caffeine de ADR-108. Al crear o cancelar una reserva, avisa a todas las réplicas con NOTIFY de PostgreSQL para que borren su entrada.

### Detailed Decision

- Caché: Caffeine 3.2 en cada réplica, disponibilidad por sede y fecha, entradas de 5 minutos (como ADR-108).
- Al crear o cancelar, el Servicio de Reservas emite `NOTIFY` en el canal `disponibilidad` con la sede y la fecha.
- El `NOTIFY` va en la misma transacción: PostgreSQL solo lo entrega si la transacción confirma.
- Cada réplica mantiene una conexión `LISTEN` a la Base de Datos de Reservas, fuera del pool, y borra su entrada al recibir el aviso.
- La expiración de 5 minutos queda como red de seguridad si una réplica pierde avisos, por ejemplo al reconectar.
- Tamaño máximo de la caché: Not documented.

### Scope

**What IS included:**
- La invalidación de la caché de disponibilidad en todas las réplicas del Servicio de Reservas.

**What is NOT included:**
- Caché distribuida o compartida entre réplicas.
- La detección de reservas superpuestas, que sigue en [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md).

---

## Rationale

### Primary Drivers

- **Frescura** — la entrada vieja se borra al confirmar la transacción, no a los 5 minutos.
- **Sin tecnología nueva** — PostgreSQL 16 ([ADR-003](ADR-003-postgresql-relational-store.md)) y Caffeine 3.2 ya están en la arquitectura.
- **Consistencia con la escritura** — el aviso no sale si la transacción se revierte.

### Comparison Summary

| Criteria | LISTEN/NOTIFY (seleccionada) | Solo expiración (ADR-108) | Caché distribuida |
|----------|------------------------------|---------------------------|-------------------|
| **Disponibilidad desactualizada** | ✅ solo si se pierde un aviso, hasta 5 min | ❌ hasta 5 min en otra réplica | ✅ ninguna |
| **Componente nuevo que operar** | ✅ ninguno | ✅ ninguno | ❌ un almacén compartido |
| **Conexiones a la Base de Datos de Reservas** | ⚠️ una más por réplica | ✅ ninguna extra | ✅ ninguna extra |

---

## Consequences

### Positive Consequences

- **TDR-001 se puede cerrar** — la ventana de 5 minutos queda solo para avisos perdidos.
- **Sin dependencia nueva** — el canal vive en la Base de Datos de Reservas.

### Negative Consequences

- **Una conexión más por réplica** — la conexión `LISTEN` queda fuera del pool. **Severity**: Low. **Mitigation**: Not documented.
- **Avisos perdidos al reconectar** — PostgreSQL no guarda los avisos. **Severity**: Low. **Mitigation**: la expiración de 5 minutos.

### Trade-offs

- **Frescura vs conexiones**: se paga una conexión por réplica a cambio de no mostrar salas ocupadas como libres.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Solo expiración de 5 minutos (ADR-108) | Deja la ventana de TDR-001 | Si 5 minutos de disponibilidad vieja fueran aceptables |
| Caché distribuida | Tecnología nueva que operar para un equipo de 4 | Con muchas réplicas o avisos perdidos frecuentes |

---

## Implementation Plan

### Phases

Not documented.

### Dependencies

- Conexión `LISTEN` de cada réplica a la Base de Datos de Reservas.

### Risks

Not documented.

---

## Success Metrics

### Quantitative Metrics

- **Consulta de disponibilidad**: baseline Not documented → ≤ 1 s p95.

### Qualitative Metrics

Not documented.

### Review Timeline

Not documented.

---

## References

### Documentation
- docs/04-data-flow-patterns.md (Fases 3, 4 y 5)
- docs/05-integration-points.md (I-04)
- docs/08-scalability-and-performance.md (sección 10.4)
- tdr/TDR-001-la-consulta-de-disponibilidad-se-sirve-de-una-cache-de-5-min.md
- tdr/TDR-003-los-avisos-de-disponibilidad-perdidos-al-reconectar-listen-d.md
- escalations/ESC-003-tdr-001-invalidar-la-cache-de-disponibilidad-en-todas-las-re.md

### Related ADRs
- [ADR-108](ADR-108-cache-en-proceso-con-caffeine-para-disponibilidad.md) - Caché en proceso con Caffeine para disponibilidad (sustituido)
- [ADR-003](ADR-003-postgresql-relational-store.md) - PostgreSQL como base de datos relacional institucional
- [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md) - Restricción de exclusión contra reservas dobles

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-20 | Architecture Team | Created | Decisión del arquitecto en ESC-003; Accepted |

---

## Notes

Not documented.
