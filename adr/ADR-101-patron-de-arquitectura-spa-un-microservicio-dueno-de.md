# ADR-101: SPA y un microservicio dueño de su base de datos

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005

---

## Context

### Problem Statement

Los tres casos de uso (consultar, reservar, cancelar) necesitan un patrón de arquitectura. Un equipo de 4 personas debe entregarlos sin infraestructura que ningún caso exige.

### Requirements

| Tipo | Requisito |
|---|---|
| Funcional | Consulta de disponibilidad, creación y cancelación de reservas, todas síncronas |
| Rendimiento | Consulta ≤ 1 s; reserva y cancelación ≤ 2 s (p95, flujo completo) |
| Tecnología | SPA React 18 estática; Java 21 con Spring Boot 3.3 en el clúster Kubernetes de Plataforma Northwind; PostgreSQL 16 gestionado |
| Seguridad | Prohibido guardar tokens en `localStorage` |
| Equipo | 4 personas, 2 desarrolladores backend |

### Business Drivers

- Entregar los tres casos de uso con la menor superficie operativa posible.
- Reutilizar la infraestructura de Plataforma Northwind sin infraestructura propia.
- Diferir componentes (gateway, malla, bus) hasta que un caso de uso los exija.

---

## Decision

### Summary

La arquitectura se compone de la SPA Portal de Reservas y un único microservicio, Servicio de Reservas. Este es dueño exclusivo de la Base de Datos de Reservas. No hay API Gateway, service mesh ni event bus. Los tres casos de uso son síncronos y un solo servicio basta.

### Detailed Decision

- Tres contenedores en tres capas: Portal de Reservas (L1), Servicio de Reservas (L2), Base de Datos de Reservas (L3).
- El Portal de Reservas llama al Servicio de Reservas directamente por HTTPS/JSON.
- Solo el Servicio de Reservas lee y escribe la Base de Datos de Reservas (database-per-service, ADR-003).
- Un bounded context: disponibilidad, creación y cancelación en un microservicio.
- Única llamada servicio a servicio: Servicio de Reservas hacia el Proveedor de Identidad Northwind.
- Sin procesamiento asíncrono: todos los flujos son síncronos.

### Scope

**What IS included:**

| Elemento | Estado |
|---|---|
| Portal de Reservas, Servicio de Reservas, Base de Datos de Reservas | Incluidos |
| Comunicación REST síncrona | Incluida |

**What is NOT included:**

| Elemento | Estado |
|---|---|
| API Gateway, Service Mesh, Event Bus | Excluidos |
| Otros microservicios o almacenes de datos | Excluidos |

---

## Rationale

### Primary Drivers

- **Simplicidad** — un servicio síncrono cubre los tres casos de uso; ver principio 7 de la Sección 2.
- **Separación de responsabilidades** — el portal presenta y autentica; las reglas viven en el servicio (ADR-003).
- **Reutilización de plataforma** — CDN, clúster y PostgreSQL 16 de Plataforma Northwind (ADR-005).
- **Escalado sin estado** — réplicas validan el JWT con JWKS (ADR-002); no se comparte estado.

### Comparison Summary

| Criteria | Selected Option | Alternative 1 | Alternative 2 |
|----------|----------------|---------------|---------------|
| **Superficie operativa** | ✅ | ⚠️ | ❌ |
| **Ajuste a casos síncronos** | ✅ | ✅ | ❌ |
| **Autonomía de despliegue** | ⚠️ | ✅ | ✅ |

Alternative 1: varios microservicios. Alternative 2: arquitectura con event bus.

---

## Consequences

### Positive Consequences

- **Menos componentes que operar** — el equipo de 4 personas mantiene tres contenedores.
- **Integridad centralizada** — la superposición se declara en PostgreSQL 16, sin código de coordinación.
- **Réplicas sin estado compartido** — añadir réplicas no requiere coordinación.

### Negative Consequences

- **Un reporte de ocupación exige una operación nueva en la API** — equipo backend. **Severity**: Medium. **Mitigation**: Not documented.
- **Todo cambio despliega el servicio completo** — los 2 desarrolladores backend. **Severity**: Low. **Mitigation**: Not documented.
- **Un recordatorio asíncrono no tiene event bus** — agregarlo exige infraestructura nueva. **Severity**: Low. **Mitigation**: Not documented.

### Trade-offs

- **Simplicidad vs. autonomía**: disponibilidad, creación y cancelación comparten imagen y versión.
- **Simplicidad vs. extensibilidad**: un dominio nuevo exige separar el servicio y agregar enrutamiento, costo de migración diferido.
- **Aislamiento vs. acceso a datos**: un ajuste de esquema exige una migración Flyway versionada.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Varios microservicios con API Gateway | Not documented | Not documented |
| Arquitectura orientada a eventos con event bus | Los tres casos de uso son síncronos | Un caso de uso asíncrono, como notificaciones |
| Base de datos compartida entre servicios | Rechazado por separación de responsabilidades (ADR-003) | Not documented |

---

## Implementation Plan

### Phases

Not documented

### Dependencies

- Plataforma Northwind: clúster Kubernetes (ADR-005), PostgreSQL 16 (ADR-003), colector OpenTelemetry (ADR-004).
- Proveedor de Identidad Northwind: autenticación (ADR-002).

### Risks

Not documented

---

## Success Metrics

### Quantitative Metrics

- **Consulta de disponibilidad (p95)**: Not documented → ≤ 1 s
- **Reserva (p95)**: Not documented → ≤ 2 s
- **Cancelación (p95)**: Not documented → ≤ 2 s

### Qualitative Metrics

Not documented

### Review Timeline

Not documented

---

## References

### Documentation
- docs/03-architecture-layers.md (Secciones 4, 4.1, 4.2)
- docs/04-data-flow-patterns.md (Fases 3 y 5)
- docs/08-scalability-and-performance.md (10.1, 10.3, 10.4)
- docs/02-architecture-principles.md (principios 1, 5, 7)
- PRODUCT_OWNER_SPEC.md (§7 Restricciones Tecnológicas)

### Related ADRs
- `[ADR-001](ADR-001-rest-openapi-apis.md)` - APIs síncronas REST con contrato OpenAPI
- `[ADR-002](ADR-002-oidc-keycloak-identity.md)` - Autenticación con OpenID Connect en Keycloak
- `[ADR-003](ADR-003-postgresql-relational-store.md)` - PostgreSQL como base de datos relacional institucional
- `[ADR-004](ADR-004-opentelemetry-observability.md)` - Observabilidad con OpenTelemetry
- `[ADR-005](ADR-005-kubernetes-container-runtime.md)` - Despliegue en el clúster Kubernetes de Plataforma Northwind

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

Se revisa la decisión cuando un caso de uso exija asincronía o un segundo dominio. Latencia por salto y tamaño de pool: Not documented.
