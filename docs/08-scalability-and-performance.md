# Escalabilidad y Rendimiento

<!-- EXPLORER_HEADER
key_concepts: escalado horizontal, HPA por CPU, servicio sin estado, réplicas mínimas, metas de latencia p95, LCP, demanda por caso de uso, CDN, capacidad
technologies: Kubernetes, HPA, PostgreSQL 16, CDN de Plataforma Northwind, React 18, Spring Boot 3.3
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas
scope: Modelo de escalado, demanda, metas de rendimiento y optimización; no cubre despliegue ni respaldo
related_adrs: ADR-002, ADR-003, ADR-005, ADR-101, ADR-107
-->

> Escalado horizontal del Servicio de Reservas por CPU con un mínimo de 2 réplicas, Portal de Reservas estático en CDN y metas de latencia p95 de la PO Spec. La carga medida (TPS) y los límites máximos no están documentados.

## 10. Escalabilidad y Rendimiento <!-- SECTION: Scalability & Performance -->

### 10.1 Modelo de Escalabilidad <!-- SECTION: Scalability Model -->

**Escalado horizontal**

| Component | Scaling Strategy | Limits |
|---|---|---|
| `Portal de Reservas` | Archivos estáticos servidos por el CDN; sin réplicas propias | Not documented <!-- TODO: Add source reference --> |
| `Servicio de Reservas` | HPA por CPU sobre réplicas sin estado, mínimo 2 en zonas distintas ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)) | Máximo de réplicas: Not documented <!-- TODO: Add source reference --> |
| `Base de Datos de Reservas` | Capacidad dimensionada por Plataforma Northwind ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)) | Not documented <!-- TODO: Add source reference --> |

**Escalado vertical**: cada servicio declara solicitudes y límites de CPU y memoria ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)); valores: Not documented. <!-- TODO: Add source reference -->

**Particionamiento de datos**: Not documented. <!-- TODO: Add source reference -->

**Sin sesión de servidor**: cada réplica valida el JWT con las llaves JWKS ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)), por lo que añadir réplicas no requiere estado compartido.

### 10.2 Demanda por Caso de Uso <!-- LABEL: Demand by Use Case -->

| Use Case | Value | Unit | Peak factor | Source |
|---|---|---|---|---|
| FLOW-1 | Not documented | rps | | Sin medición; [Sección 1](01-system-overview.md#1-resumen-ejecutivo) TPS: Not documented |
| FLOW-2 | Not documented | rps | | Sin medición; [Sección 1](01-system-overview.md#1-resumen-ejecutivo) TPS: Not documented |
| FLOW-3 | Not documented | rps | | Sin medición; [Sección 1](01-system-overview.md#1-resumen-ejecutivo) TPS: Not documented |

**Base de usuarios**: 1.850 miembros con membresía vigente al 2026-09-30 y 6 recepcionistas, en 42 salas de 3 sedes.

### 10.3 Metas de Rendimiento <!-- SECTION: Performance Targets -->

| Operation | p50 | p95 | p99 |
|---|---|---|---|
| Primera carga del portal (LCP, 4G) | Not documented | ≤ 2,5 s (percentil 75) | Not documented |
| Consulta de disponibilidad | Not documented | ≤ 1 s | Not documented |
| Reserva | Not documented | ≤ 2 s | Not documented |
| Cancelación | Not documented | ≤ 2 s | Not documented |

**Fuente**: PO Spec §8 Expectativas de Rendimiento; el desglose por salto está en [Presupuesto de latencia](04-data-flow-patterns.md).

**Rendimiento (TPS)**: Not documented; los valores se registran en [Sección 1](01-system-overview.md#1-resumen-ejecutivo) cuando exista medición. <!-- TODO: Add source reference -->

**Planificación de capacidad**: Not documented. <!-- TODO: Add source reference -->

### 10.4 Optimización de Rendimiento <!-- SECTION: Performance Optimization -->

**Caché**
- CDN: archivos estáticos del `Portal de Reservas` fuera del clúster ([ADR-107](../adr/ADR-107-publicacion-del-portal-de-reservas-como-archivos-estaticos.md)).
- Caché de aplicación y distribuida: Not documented. <!-- TODO: Add source reference -->

**Base de datos**
- Índices y consultas: Not documented. <!-- TODO: Add source reference -->
- Conexiones: cada réplica abre sus propias conexiones JDBC; el tamaño del pool es Not documented. <!-- TODO: Add source reference -->

**Procesamiento asíncrono**: ninguno; todos los flujos son síncronos ([ADR-101](../adr/ADR-101-patron-de-arquitectura-spa-un-microservicio-dueno-de.md)).
