# ADR-108: Caché en proceso con Caffeine para disponibilidad

**Status**: Accepted
**Scope**: User
**Date**: 2026-10-20
**Authors**: Architecture Team
**Related**: ADR-003, ADR-005, ADR-102, TDR-001

---

## Context

### Problem Statement

CU1 debe responder en ≤ 1 s p95. El Servicio de Reservas lee la Base de Datos de Reservas en cada consulta, sin índice por sala y franja.

### Requirements

| Type | Requirement |
|---|---|
| Functional | Consultar la disponibilidad de salas por sede, fecha y franja (PO Spec CU1) |
| Performance | Consulta de disponibilidad ≤ 1 s p95 (PO Spec §8) |
| Reliability | Ninguna reserva doble, aunque la disponibilidad mostrada esté desactualizada ([ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)) |
| Constraint | La Base de Datos de Reservas es la única fuente de salas y reservas ([ADR-003](ADR-003-postgresql-relational-store.md)) |
| Constraint | El Servicio de Reservas corre con al menos 2 réplicas ([ADR-005](ADR-005-kubernetes-container-runtime.md)) |

### Business Drivers

- Respuesta inmediata al elegir sala, la meta de CU1.
- Equipo de 4 personas: ningún componente nuevo que operar.

---

## Decision

### Summary

El Servicio de Reservas guarda la disponibilidad por sede y fecha en una caché Caffeine 3.2 dentro de cada réplica. Cada entrada expira a los 5 minutos.

### Detailed Decision

- Clave: sede y fecha; valor: las salas de la sede con sus reservas confirmadas de ese día.
- Una entrada expira 5 minutos después de escribirse.
- La réplica que crea o cancela una reserva invalida su entrada de esa sede y fecha.
- Las otras réplicas no se enteran: su entrada vive hasta expirar.
- Sin entrada vigente, la consulta lee la Base de Datos de Reservas y guarda la entrada.
- Tamaño máximo de la caché: Not documented.

### Scope

**What IS included:**
- La consulta de disponibilidad (CU1) del Servicio de Reservas.

**What is NOT included:**
- Creación y cancelación: siempre escriben en la Base de Datos de Reservas; la superposición la rechaza [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md).
- Caché distribuida o compartida entre réplicas.

---

## Rationale

### Primary Drivers

- **Latencia** — una entrada vigente responde sin ir a la Base de Datos de Reservas; meta ≤ 1 s p95.
- **Sin infraestructura nueva** — Caffeine es una biblioteca dentro del proceso Java 21.
- **Corrección** — la reserva doble la impide la base de datos, no la caché.

### Comparison Summary

| Criteria | Caffeine en proceso (seleccionada) | Índice por sala y franja | Caché distribuida |
|----------|------------------------------------|--------------------------|-------------------|
| **Componente nuevo que operar** | ✅ ninguno | ✅ ninguno | ❌ un almacén compartido |
| **Disponibilidad desactualizada** | ⚠️ hasta 5 min en otra réplica | ✅ ninguna | ✅ ninguna con invalidación |
| **Lecturas a la Base de Datos de Reservas en CU1** | ✅ solo sin entrada vigente | ❌ en cada consulta | ✅ solo sin entrada vigente |

---

## Consequences

### Positive Consequences

- **Menos carga en la Base de Datos de Reservas** — la consulta más frecuente casi nunca llega a ella.
- **Sin dependencia nueva de Plataforma Northwind** — la caché vive y muere con la réplica.

### Negative Consequences

- **Disponibilidad desactualizada** — una sala reservada en otra réplica puede verse libre hasta 5 minutos; el miembro recibe "sala ocupada" al reservar. **Severity**: Medium. **Mitigation**: deuda registrada en TDR-001.
- **Memoria por réplica** — sin tamaño máximo documentado. **Severity**: Low. **Mitigation**: Not documented.

### Trade-offs

- **Frescura vs latencia**: se acepta hasta 5 minutos de disponibilidad vieja a cambio de no leer la base en cada consulta.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Índice por sala y franja en la Base de Datos de Reservas | Cada consulta sigue leyendo la base; su latencia no está medida | Si la base cumple el p95 de 1 s sola (opción A de TDR-001) |
| Caché distribuida | Tecnología nueva que operar para un equipo de 4 | Con más réplicas o si 5 minutos de disponibilidad vieja no se aceptan |

---

## Implementation Plan

### Phases

Not documented.

### Dependencies

- Caffeine 3.2 en el Servicio de Reservas.

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
- docs/04-data-flow-patterns.md (Fase 3 — Consulta de disponibilidad)
- docs/06-technology-stack.md (sección 8)
- docs/08-scalability-and-performance.md (sección 10.4)
- tdr/TDR-001-la-consulta-de-disponibilidad-se-sirve-de-una-cache-de-5-min.md
- escalations/ESC-002-tdr-001-registra-una-cache-de-disponibilidad-que-el-servicio.md

### Related ADRs
- [ADR-003](ADR-003-postgresql-relational-store.md) - PostgreSQL como base de datos relacional institucional
- [ADR-005](ADR-005-kubernetes-container-runtime.md) - Despliegue de servicios en el clúster Kubernetes de Plataforma Northwind
- [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md) - Restricción de exclusión contra reservas dobles

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-20 | Architecture Team | Created | Decisión del arquitecto en ESC-002 |
| 2026-10-20 | Architecture Team | Accepted | Aceptado por el arquitecto |

---

## Notes

Not documented.
