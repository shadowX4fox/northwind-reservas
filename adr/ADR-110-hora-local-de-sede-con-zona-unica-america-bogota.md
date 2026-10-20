# ADR-110: Hora local de sede con zona única America/Bogota

**Status**: Accepted
**Scope**: User
**Date**: 2026-10-20
**Authors**: Architecture Team
**Related**: ADR-102, ADR-105, TDR-004

---

## Context

### Problem Statement

INV-01, INV-04 y ADR-105 dependen de la hora actual en la sede, y la arquitectura no fija su zona horaria; cada despliegue elige una (TDR-004).

### Requirements

| Type | Requirement |
|---|---|
| Functional | Rechazar franjas en el pasado (PO Spec CU1, INV-01) |
| Functional | Contar las reservas futuras del miembro en un mismo día, máximo 3 (PO Spec CU2, INV-04) |
| Functional | Rechazar la cancelación de una reserva ya iniciada con "reserva en curso" ([ADR-105](ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md)) |
| Constraint | El contrato expresa la franja como `date` + `start`/`end` en `HH:mm`, sin desfase |
| Constraint | Ninguna reserva doble ([ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)) |

### Business Drivers

- El miembro piensa en "la sala de las 10:00 en Centro", no en UTC.
- Cerrar TDR-004: una variable de despliegue mal fijada acepta o rechaza mal las reservas.

---

## Decision

### Summary

Las franjas de reserva se expresan en hora local de la sede, sin desfase. Las sedes Centro, Norte y Puerto comparten la zona `America/Bogota`, y "ahora" se calcula en esa zona.

### Detailed Decision

- `date` + `start`/`end` (`HH:mm`) son hora local de la sede, sin desfase. Así se leen en el contrato del Servicio de Reservas y en la Base de Datos de Reservas.
- Zona única para las 3 sedes: `America/Bogota` (UTC−5, sin horario de verano).
- El Servicio de Reservas calcula la hora actual en esa zona. La usan INV-01 (franja en el pasado), INV-04 (reservas futuras del día) y ADR-105 (reserva ya iniciada).
- El Portal de Reservas no deja elegir una franja anterior a la hora actual de la sede, no la del navegador. Quien decide sigue siendo el Servicio de Reservas (`VALIDATION_FAILED`).
- La zona deja de ser una elección del despliegue.

### Scope

**What IS included:**
- La zona horaria de las 3 sedes y la interpretación de las horas del contrato y del esquema.
- El reloj de negocio del Servicio de Reservas y del Portal de Reservas.

**What is NOT included:**
- Una zona distinta por sede. Con una sede en otra zona, la zona pasa a la Base de Datos de Reservas como atributo de la sede (opción B de TDR-004).
- Las marcas de tiempo técnicas, como `cancelledAt`, que siguen en ISO 8601.

---

## Rationale

### Primary Drivers

- **Una sola zona** — las 3 sedes son de un mismo cowork; una zona por sede es un costo sin necesidad hoy.
- **Sin horas ambiguas** — `America/Bogota` no tiene horario de verano: ninguna franja `HH:mm` se repite ni deja de existir.
- **Contrato sin cambios** — el contrato y el esquema ya usan hora local. La restricción de exclusión de [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md) sigue siendo correcta: todas las salas comparten zona.

### Comparison Summary

| Criteria | Hora local, zona única (seleccionada) | Zona por sede | UTC con desfase en el contrato |
|----------|---------------------------------------|---------------|--------------------------------|
| **Cambio en contrato y esquema** | ✅ ninguno | ⚠️ atributo nuevo en la sede | ❌ formato de `start`/`end` y columnas |
| **Riesgo de mala configuración** | ✅ la zona está en la arquitectura | ✅ la zona está en los datos | ✅ ninguna zona que configurar en el servicio |
| **Sedes en zonas distintas** | ❌ no las soporta | ✅ las soporta | ✅ las soporta |

---

## Consequences

### Positive Consequences

- **TDR-004 se puede cerrar** — el servicio deja de exigir `RESERVAS_ZONA_HORARIA` sin valor por defecto.
- **Las tres reglas de hora usan la misma referencia** — servicio y portal comparan contra la misma hora de la sede.

### Negative Consequences

- **Una sede en otra zona exige un cambio de modelo** — la zona pasa a la sede. **Severity**: Low. **Mitigation**: la opción B de TDR-004.

### Trade-offs

- **Simplicidad vs generalidad**: se renuncia a sedes en zonas distintas a cambio de no tocar contrato ni esquema.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Zona por sede | Costo sin necesidad con las 3 sedes en una zona | Con una sede en otra zona horaria |
| UTC con desfase en el contrato | Complica contrato y esquema sin beneficio con una sola zona | Con usuarios que reservan desde varias zonas |

---

## Implementation Plan

### Phases

Not documented.

### Dependencies

- El Servicio de Reservas fija `America/Bogota` y retira la variable obligatoria `RESERVAS_ZONA_HORARIA` (TDR-004).

### Risks

Not documented.

---

## Success Metrics

### Quantitative Metrics

Not documented.

### Qualitative Metrics

Not documented.

### Review Timeline

Not documented.

---

## References

### Documentation
- docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md
- docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md
- docs/components/reservas-de-salas-northwind/01-portal-de-reservas.md
- tdr/TDR-004-zona-horaria-de-las-sedes-leida-de-una-variable-de-despliegu.md
- escalations/ESC-004-zona-horaria-de-las-sedes-no-documentada-inv-01-inv-04-adr-1.md

### Related ADRs
- [ADR-102](ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md) - Restricción de exclusión contra reservas dobles
- [ADR-105](ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md) - Autorización por rol recepcion y atributo sede

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-20 | Architecture Team | Created | Decisión del arquitecto en ESC-004; Accepted |

---

## Notes

Not documented.
