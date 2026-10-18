# ADR-105: Autorización por rol recepcion y atributo sede

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-002, ADR-003

---

## Context

### Problem Statement

La cancelación de reservas ajenas necesita una regla de autorización. Sin ella, cualquier usuario autenticado podría cancelar reservas de otros miembros.

### Requirements

| Tipo | Requisito |
|---|---|
| Funcional | El dueño de la reserva la cancela (PO Spec CU3). |
| Funcional | Recepción cancela reservas de su sede, con motivo de hasta 120 caracteres. |
| Seguridad | Deny by default: en cualquier otro caso, "no autorizado". |
| Seguridad | Mínimo privilegio: solo `recepcion` con `sede` coincidente cancela reservas ajenas. |
| Restricción | El rol `recepcion` y el atributo `sede` vienen en el token del Proveedor de Identidad Northwind (PO Spec §7). |

### Business Drivers

- Impedir el acceso no autorizado a una reserva ajena (modelo de amenazas, sección 9.2).
- Permitir que recepción atienda cancelaciones de su sede.
- Dejar el estado "Cancelada" con autor, hora y motivo.

---

## Decision

### Summary

El Servicio de Reservas autoriza la cancelación al dueño de la reserva. También la autoriza a un token con rol `recepcion` cuyo atributo `sede` coincide con la sede de la sala. En cualquier otro caso responde "no autorizado" y la reserva sigue "Confirmada".

### Detailed Decision

- El Servicio de Reservas lee de la Base de Datos de Reservas el dueño, la sede, el estado y el inicio de la reserva.
- Verifica que el solicitante sea el dueño o tenga el rol `recepcion` con `sede` igual a la sede de la sala.
- Si no se cumple, rechaza con "no autorizado"; si la reserva ya inició, rechaza con "reserva en curso".
- Si se cumple, cambia el estado a "Cancelada" con autor, hora y, para recepción, motivo.
- El rol y la sede se leen del JWT validado en cada solicitud con JWKS.

### Scope

**What IS included:**
- Autorización de la cancelación de reservas (fase 5).
- Roles miembro y `recepcion`, acotado por `sede`.

**What is NOT included:**
- Autenticación y almacenamiento de tokens ([ADR-002](ADR-002-oidc-keycloak-identity.md)).
- Roles y operaciones distintos de la cancelación: Not documented.

---

## Rationale

### Primary Drivers

- **Mínimo privilegio** — solo `recepcion` con `sede` coincidente cancela reservas ajenas (sección 9.1).
- **Fuente única de identidad** — rol y sede viajan en el token del Proveedor de Identidad Northwind (PO Spec §7).
- **Deny by default** — cualquier caso no previsto produce "no autorizado".

### Comparison Summary

| Criteria | Selected Option |
|----------|----------------|
| **Alcance por sede** | ✅ |
| **Sin consulta adicional al proveedor** | ✅ |
| **Rechazo por defecto** | ✅ |

---

## Consequences

### Positive Consequences

- **Reservas ajenas protegidas** — solo el dueño o recepción de la sede las cancela.
- **Sin dependencia extra** — la decisión usa claims del token ya validado.

### Negative Consequences

- **Dependencia de claims correctos** — un `sede` mal emitido amplía el acceso de recepción. **Severity**: Medium. **Mitigation**: Not documented.

### Trade-offs

- **Simplicidad vs granularidad**: solo dos roles; no hay permisos más finos.

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
- docs/04-data-flow-patterns.md (fase 5, clasificación de fallas)
- docs/07-security-architecture.md (secciones 9.1, 9.2, 9.3)
- PRODUCT_OWNER_SPEC.md §4 CU3, §7 Restricciones de Integración

### Related ADRs
- [ADR-002](ADR-002-oidc-keycloak-identity.md) - Autenticación con OpenID Connect en Keycloak
- [ADR-003](ADR-003-postgresql-relational-store.md) - PostgreSQL como base de datos relacional institucional

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

Latencia p95 de la fase 5: Not documented; el flujo completo cumple ≤ 2 s.
