# ADR-107: Portal de Reservas como archivos estáticos en CDN

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-005, ADR-002, ADR-004

---

## Context

### Problem Statement

El Portal de Reservas es una SPA y necesita una forma de publicación. La norma de Plataforma Northwind la exige como archivos estáticos, separada del clúster del backend.

### Requirements

| Type | Requirement |
|---|---|
| Functional | SPA React 18 con TypeScript para consultar, reservar y cancelar (PO Spec §7) |
| Constraint | Servida como archivos estáticos, norma de Plataforma Northwind (PO Spec §7) |
| Performance | Primera carga (LCP, 4G) ≤ 2,5 s en el percentil 75 (PO Spec §8) |
| Reliability | Disponibilidad mensual de 99,5 % (PO Spec §7) |
| Security | Prohibido guardar tokens en `localStorage` (PO Spec §7) |

### Business Drivers

- Cumplir la norma de Plataforma Northwind sin infraestructura propia para el frontend.
- Mantener el clúster Kubernetes dedicado al Servicio de Reservas ([ADR-005](ADR-005-kubernetes-container-runtime.md)).
- Equipo de 4 personas y 14 semanas: menos componentes que operar.

---

## Decision

### Summary

El Portal de Reservas se publica como archivos estáticos desde el CDN de Plataforma Northwind, fuera del clúster Kubernetes. El portal no tiene réplicas propias. El tráfico de la API sigue por el Ingress del clúster ([ADR-005](ADR-005-kubernetes-container-runtime.md)).

### Detailed Decision

- El artefacto del Portal de Reservas es el paquete estático de la SPA (React 18, TypeScript).
- El CDN de Plataforma Northwind lo sirve; el clúster no ejecuta ningún contenedor del portal.
- La escala del portal la absorbe el CDN; límites: Not documented.
- La autenticación usa el cliente OIDC del navegador con PKCE y tokens en memoria ([ADR-002](ADR-002-oidc-keycloak-identity.md)).
- El portal envía telemetría OpenTelemetry al colector de Plataforma Northwind ([ADR-004](ADR-004-opentelemetry-observability.md)).

### Scope

**What IS included:**
- Publicación del paquete estático del Portal de Reservas en el CDN.
- Caché de los archivos estáticos fuera del clúster.

**What is NOT included:**
- Despliegue del Servicio de Reservas en Kubernetes ([ADR-005](ADR-005-kubernetes-container-runtime.md)).
- Método de despliegue, reversión y frecuencia del portal: Not documented.

---

## Rationale

### Primary Drivers

- **Norma de plataforma** — la PO Spec §7 exige archivos estáticos para la SPA.
- **Disponibilidad** — el portal queda fuera del clúster, sin depender de las 2 réplicas del backend (meta 99,5 % mensual).
- **Rendimiento** — el CDN sirve la primera carga; meta LCP ≤ 2,5 s (percentil 75).
- **Delegación** — Plataforma Northwind opera la publicación (principio Nativo en la Nube).

### Comparison Summary

| Criteria | CDN (seleccionada) | Servir desde el clúster |
|----------|--------------------|-------------------------|
| **Cumple la norma de plataforma** | ✅ | Not documented |
| **Réplicas propias del portal** | ✅ ninguna | Not documented |

---

## Consequences

### Positive Consequences

- **Sin cómputo propio para el portal** — el equipo no opera réplicas del frontend.
- **Caché fuera del clúster** — la carga de archivos no llega al Ingress del backend.

### Negative Consequences

- **Dependencia de Plataforma Northwind** — salir reescribe la publicación. **Severity**: Medium. **Mitigation**: Not documented.
- **Peso del paquete** — el SDK de OpenTelemetry aumenta lo que descarga cada navegador. **Severity**: Low. **Mitigation**: Not documented.

### Trade-offs

- **Autonomía vs delegación**: se cede el control del CDN a cambio de no operar infraestructura de frontend.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Not documented | Not documented | Not documented |

---

## Implementation Plan

### Phases

Not documented.

### Dependencies

- CDN de Plataforma Northwind: publicación de los archivos estáticos; owner Plataforma Northwind.

### Risks

Not documented.

---

## Success Metrics

### Quantitative Metrics

- **Primera carga del portal (LCP, 4G)**: baseline Not documented → ≤ 2,5 s en el percentil 75.
- **Disponibilidad mensual**: baseline Not documented → 99,5 %.

### Qualitative Metrics

Not documented.

### Review Timeline

Not documented.

---

## References

### Documentation
- docs/06-technology-stack.md (secciones 8.1, 8.2, 8.4)
- docs/08-scalability-and-performance.md (secciones 10.1, 10.3, 10.4)
- docs/02-architecture-principles.md (principios 2, 5 y 8)
- docs/09-operational-considerations.md (sección 11.1)
- PRODUCT_OWNER_SPEC.md, Restricciones Tecnológicas (§7)

### Related ADRs
- [ADR-005](ADR-005-kubernetes-container-runtime.md) - Despliegue de servicios en el clúster Kubernetes de Plataforma Northwind
- [ADR-002](ADR-002-oidc-keycloak-identity.md) - Autenticación con OpenID Connect en Keycloak
- [ADR-004](ADR-004-opentelemetry-observability.md) - Observabilidad con OpenTelemetry

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

Not documented.
