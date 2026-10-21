# Estándares Transversales — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión

<!-- managed by sa-skills:architecture-dev-handoff — do not edit manually -->
<!-- TEMPLATE_VERSION: 4.3.1 -->
| Field | Value |
|-------|-------|
| Versión | 4.3.1 |
| Aplica a | Todos los servicios dentro del alcance de Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión |
| Versión de la arquitectura | 1.8.0 |
| Generado | 2026-10-20 |

### Índice rápido por rol <!-- SECTION: Role Quick Index -->

| Audience | Read first in this document |
|----------|-----------------------------|
| **Arquitecto** | Todas las secciones + tabla de Desviaciones |
| **Dev** | Semántica de errores · Versionado · Idempotencia · Valores de resiliencia por defecto |
| **QA** | Idempotencia · Convenciones de observabilidad · Datos |
| **Ops / SRE** | Convenciones de observabilidad · Valores de resiliencia por defecto · Datos |

El orden de lectura de los cuatro documentos de entrega está en `handoffs/README.md`.

Reglas globales que aplican a todo servicio. Cada Component Specification las **referencia**; ninguna las repite. Repetir causa deriva; la deriva causa incoherencia.

Cada regla es normativa (MUST / SHOULD / MAY) y enlaza a su fuente: un ADR institucional (por ejemplo `ADR-001`). Las reglas sin cita se marcan `[NOT DOCUMENTED]` y no son exigibles.

---

## Semántica de errores <!-- SECTION: Error semantics -->

- **MUST** Los errores siguen RFC 9457 (`application/problem+json`) con un campo `code` estable.
  → per [ADR-001](../adr/ADR-001-rest-openapi-apis.md)

---

## Versionado <!-- SECTION: Versioning -->

- **MUST** Cada API se describe con un contrato OpenAPI 3.1 versionado en el repositorio del servicio; el contrato se escribe antes que el código.
  → per [ADR-001](../adr/ADR-001-rest-openapi-apis.md)
- **MUST** La versión mayor va en la ruta (`/v1/…`); un cambio incompatible publica `/v2` y mantiene `/v1` al menos 90 días.
  → per [ADR-001](../adr/ADR-001-rest-openapi-apis.md)
- **MUST** El esquema se versiona con migraciones en el repositorio del servicio (Flyway en Java).
  → per [ADR-003](../adr/ADR-003-postgresql-relational-store.md)

---

## Identidad y autorización <!-- SECTION: Identity and authorisation -->

- **MUST** El Proveedor de Identidad Northwind (Keycloak 25) es la única fuente de autenticación de miembros, empleados y servicios.
  → per [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)
- **MUST** Una aplicación de una página usa el flujo de código de autorización con PKCE; los tokens viven en memoria, nunca en `localStorage` ni `sessionStorage`.
  → per [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)
- **MUST** Un servicio valida el token de acceso (JWT, RS256) con las llaves públicas del endpoint JWKS del proveedor, en cada solicitud, y autoriza por roles y atributos del token.
  → per [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)
- **MUST** La vida del token de acceso es de 5 minutos; la renovación es silenciosa con el token de refresco.
  → per [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)

---

## Idempotencia <!-- SECTION: Idempotency -->

- **MUST** Toda operación que crea un recurso acepta la cabecera `Idempotency-Key`; la misma clave en 24 horas devuelve el mismo resultado.
  → per [ADR-001](../adr/ADR-001-rest-openapi-apis.md)

---

## Convenciones de observabilidad <!-- SECTION: Observability conventions -->

- **MUST** Todo servicio y aplicación web emite trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind.
  → per [ADR-004](../adr/ADR-004-opentelemetry-observability.md)
- **MUST** La propagación de contexto usa W3C Trace Context (`traceparent`) en cada llamada HTTP, desde el navegador hasta la base de datos.
  → per [ADR-004](../adr/ADR-004-opentelemetry-observability.md)
- **MUST** Los logs son JSON estructurado con `trace_id`, `span_id`, `service.name` y nivel; nunca incluyen tokens ni datos personales completos.
  → per [ADR-004](../adr/ADR-004-opentelemetry-observability.md)
- **MUST** Cada servicio publica las métricas RED (tasa, errores, duración) por operación.
  → per [ADR-004](../adr/ADR-004-opentelemetry-observability.md)

---

## Datos <!-- SECTION: Data -->

- **MUST** PostgreSQL 16, gestionado por Plataforma Northwind, es el motor relacional institucional.
  → per [ADR-003](../adr/ADR-003-postgresql-relational-store.md)
- **MUST** Cada servicio es dueño de su esquema; ningún otro servicio lee ni escribe sus tablas directamente.
  → per [ADR-003](../adr/ADR-003-postgresql-relational-store.md)
- **MUST** Las restricciones de integridad que el negocio exige (unicidad, no superposición) se declaran en la base, no solo en el código.
  → per [ADR-003](../adr/ADR-003-postgresql-relational-store.md)
- **MUST** Respaldo diario con retención de 30 días y recuperación a un punto en el tiempo de 7 días.
  → per [ADR-003](../adr/ADR-003-postgresql-relational-store.md)
- **MUST** Los secretos (credenciales de base de datos) se inyectan desde el gestor de secretos del clúster; nunca en la imagen ni en el repositorio.
  → per [ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)
- **MUST** El tráfico externo entra por el ingress del clúster con TLS 1.2 o superior.
  → per [ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)

---

## Valores de resiliencia por defecto <!-- SECTION: Resilience defaults -->

- **MUST** Todo servicio backend se despliega como contenedor en el clúster Kubernetes de Plataforma Northwind, con al menos 2 réplicas en zonas distintas.
  → per [ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)
- **MUST** Cada servicio declara solicitudes y límites de CPU y memoria, sondas de vida y de disponibilidad, y un escalado horizontal por CPU.
  → per [ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)

---

## Desviaciones <!-- SECTION: Deviations -->

Un servicio PUEDE desviarse solo mediante una excepción registrada, fechada y con vencimiento. Nunca una salida local silenciosa.

| Service | Rule | Deviation | Rationale | Expiry | Record |
|---------|------|-----------|-----------|-------:|--------|
| — | — | Sin desviaciones registradas. | — | — | — |

<!--
Row template:
| [component-slug] | [rule reference e.g. ADR-018] | [what the service does differently] | [why the exception is necessary] | [YYYY-MM-DD] | [link to ADR or ticket] |

Deviations without an expiry date are treated as expired on next audit.
-->

---

## Ruta de retorno <!-- SECTION: Return Path -->

Proceso para cuestionar reglas: ver [`SYSTEM_RUNTIME_VIEW.md § Return Path`](SYSTEM_RUNTIME_VIEW.md#return-path).
Este documento solo se modifica mediante un nuevo ADR institucional que reemplace la regla anterior; la modificación dispara la regeneración de este archivo en la siguiente ejecución de `architecture-dev-handoff`.

---

*Generado por `sa-skills:architecture-dev-handoff` el 2026-10-20*
*Fuentes: ADR institucionales 001–100*
