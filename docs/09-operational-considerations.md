# Consideraciones Operacionales

<!-- EXPLORER_HEADER
key_concepts: despliegue en Kubernetes, ventana de mantenimiento, disponibilidad 99,5 %, soporte en horario hábil, observabilidad, respaldo y recuperación, purga de 24 meses, costo
technologies: Kubernetes, Helm, OpenTelemetry, PostgreSQL 16, CDN de Plataforma Northwind
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas
scope: Despliegue, monitoreo, respaldo, recuperación y costo; no cubre procedimientos de guardia detallados
related_adrs: ADR-003, ADR-004, ADR-005, ADR-106, ADR-107
-->

> Operación sobre la plataforma de Plataforma Northwind: despliegue con Helm en Kubernetes, portal estático en CDN, telemetría OpenTelemetry y respaldo diario de PostgreSQL. Disponibilidad objetivo de 99,5 % mensual en horario de soporte hábil.

## 11. Consideraciones Operacionales <!-- SECTION: Operational Considerations -->

### 11.1 Despliegue <!-- SECTION: Deployment -->

**Ambientes**: Not documented. <!-- TODO: Add source reference -->

**Estrategia de despliegue**

| Aspecto | Valor |
|---|---|
| Servicio de Reservas | Contenedor firmado desplegado con un chart de Helm en el clúster Kubernetes de Plataforma Northwind, al menos 2 réplicas en zonas distintas ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)) |
| Portal de Reservas | Archivos estáticos publicados en el CDN de Plataforma Northwind ([ADR-107](../adr/ADR-107-publicacion-del-portal-de-reservas-como-archivos-estaticos.md)) |
| Esquema de datos | Migraciones versionadas en el repositorio del servicio ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)) |
| Ventana de mantenimiento | Domingos 02:00–04:00 (PO Spec §7) |
| Método, reversión y frecuencia | Not documented <!-- TODO: Add source reference --> |

**Infraestructura como código**: chart de Helm por servicio; repositorio y gestión de estado: Not documented. <!-- TODO: Add source reference -->

### 11.2 Monitoreo y Observabilidad <!-- SECTION: Monitoring & Observability -->

**Telemetría**
- Trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Propagación W3C Trace Context desde el navegador hasta la base de datos.
- Métricas RED (tasa, errores, duración) por operación del `Servicio de Reservas`.
- Logs JSON estructurados con `trace_id`, `span_id`, `service.name` y nivel; sin tokens ni datos personales completos.

**Alertas**

| Alert | Threshold | Severity | On-call |
|---|---|---|---|
| Latencia de consulta de disponibilidad | p95 > 1 s | Not documented | Not documented |
| Latencia de reserva y cancelación | p95 > 2 s | Not documented | Not documented |
| Disponibilidad mensual | < 99,5 % | Not documented | Not documented |

Los umbrales vienen de las metas de [Escalabilidad y Rendimiento](08-scalability-and-performance.md); severidad y guardia: Not documented. <!-- TODO: Add source reference -->

**Paneles**: Not documented. <!-- TODO: Add source reference -->

**Soporte**: lunes a viernes, 08:00–19:00 (PO Spec §7).

### 11.3 Respaldo y Recuperación <!-- SECTION: Backup & Disaster Recovery -->

| Data Store | Frequency | Retention | Location |
|---|---|---|---|
| `Base de Datos de Reservas` | Diario | 30 días; PITR de 7 días | Not documented |

- RTO y RPO: Not documented. <!-- TODO: Add source reference -->
- Los respaldos conservan datos hasta 30 días después de la purga de 24 meses ([ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md); [Seguridad](07-security-architecture.md)).

### 11.4 Retención y Purga de Datos <!-- SECTION: Data Retention and Purge -->

| Dato | Retención | Responsable |
|---|---|---|
| Reservas | 24 meses, luego eliminación por purga programada | `Base de Datos de Reservas` |
| Registro de auditoría de cancelaciones | 24 meses | Escrito por el `Servicio de Reservas` en la `Base de Datos de Reservas` |

Decisión: [ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md). Calendario de la purga: Not documented. <!-- TODO: Add source reference -->

### 11.5 Gestión de Costos <!-- SECTION: Cost Management -->

**Presupuesto de desarrollo**: USD 95.000 (desarrollo USD 85.000, contingencia USD 10.000), aprobado el 2026-10-01 (PO Spec §7).

**Costo operativo mensual**: Not documented. <!-- TODO: Add source reference -->

**Costo fijo**: dos réplicas permanentes del `Servicio de Reservas` ([Principios](02-architecture-principles.md)).
