# Stack Tecnológico

<!-- EXPLORER_HEADER
key_concepts: stack tecnológico, SPA, microservicio, migraciones de esquema, contrato OpenAPI, OIDC PKCE, validación JWT, observabilidad, despliegue en contenedores, CDN de archivos estáticos
technologies: React 18, TypeScript, Java 21, Spring Boot 3.3, Caffeine 3.2, Flyway, OpenAPI 3.1, PostgreSQL 16, Keycloak 25, OpenTelemetry, Kubernetes, Helm
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas, proveedor-de-identidad-northwind
scope: Tecnologías por capa con el ADR que las exige; no cubre la configuración ni el dimensionamiento
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-102, ADR-107
-->

> Tecnologías de Reservas de Salas Northwind por categoría, cada una con su fuente: la PO Spec §7 o un ADR institucional. No describe la configuración de cada componente; esa está en `docs/components/`.

## 8. Stack Tecnológico <!-- SECTION: Technology Stack -->

**Fuentes**: PO Spec §7 Restricciones Tecnológicas; ADR-001 a ADR-005; descriptores de `docs/components/`.

### 8.1 Lenguajes <!-- SECTION: Languages -->

| Language | Version | Use Case | Justification |
|---|---|---|---|
| TypeScript | Not documented <!-- TODO: Add source reference --> | [Portal de Reservas](components/reservas-de-salas-northwind/01-portal-de-reservas.md) | Norma de Plataforma Northwind (PO Spec §7) |
| Java | 21 | [Servicio de Reservas](components/reservas-de-salas-northwind/02-servicio-de-reservas.md) | Exigido por la PO Spec §7 |
| SQL (PostgreSQL) | 16 | Migraciones y restricción de exclusión de la [Base de Datos de Reservas](components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md) | ADR-003; [ADR-102](../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md) |

### 8.2 Frameworks y Librerías <!-- SECTION: Frameworks & Libraries -->

| Framework | Version | Component | Purpose |
|---|---|---|---|
| React | 18 | Portal de Reservas | SPA de consulta, reserva y cancelación (PO Spec §7) |
| Spring Boot | 3.3 | Servicio de Reservas | API REST de disponibilidad, reserva y cancelación (PO Spec §7) |
| Caffeine | 3.2 | Servicio de Reservas | Caché en proceso de la disponibilidad por sede y fecha ([ADR-108](../adr/ADR-108-cache-en-proceso-con-caffeine-para-disponibilidad.md)) |
| Flyway | Not documented <!-- TODO: Add source reference --> | Servicio de Reservas | Migraciones de esquema versionadas en el repositorio del servicio (ADR-003) |
| JDBC | — | Servicio de Reservas | Acceso a la Base de Datos de Reservas (descriptor del Servicio de Reservas; ADR-003) |
| OpenAPI | 3.1 | Servicio de Reservas | Contrato de la API, escrito antes que el código (ADR-001) |
| SDK de OpenTelemetry | Not documented <!-- TODO: Add source reference --> | Portal de Reservas, Servicio de Reservas | Trazas, métricas y logs (ADR-004) |
| Cliente OIDC del navegador | Not documented <!-- TODO: Add source reference --> | Portal de Reservas | Código de autorización con PKCE, tokens en memoria (ADR-002) |

### 8.3 Bases de Datos <!-- SECTION: Databases -->

| Database | Version | Use Case | Data Type |
|---|---|---|---|
| PostgreSQL | 16 | Base de Datos de Reservas, gestionada por Plataforma Northwind (ADR-003) | Transaccional: salas y reservas |

**Respaldo**: diario, retención de 30 días, recuperación a un punto en el tiempo (PITR) de 7 días (ADR-003).

### 8.4 Infraestructura <!-- SECTION: Infrastructure -->

| Service | Version | Purpose |
|---|---|---|
| Kubernetes de Plataforma Northwind | Not documented <!-- TODO: Add source reference --> | Ejecución del Servicio de Reservas, al menos 2 réplicas en zonas distintas, escalado horizontal por CPU con HPA (ADR-005) |
| Helm | Not documented <!-- TODO: Add source reference --> | Chart de despliegue que entrega cada servicio (ADR-005) |
| Imagen de contenedor firmada | — | Artefacto de despliegue del Servicio de Reservas (ADR-005) |
| Ingress del clúster | — | Entrada del tráfico externo con TLS 1.2 o superior (ADR-005) |
| CDN de Plataforma Northwind | — | Publicación del Portal de Reservas como archivos estáticos, fuera del clúster (ADR-005; [ADR-107](../adr/ADR-107-publicacion-del-portal-de-reservas-como-archivos-estaticos.md)) |

### 8.5 Observabilidad <!-- SECTION: Observability -->

| Tool | Purpose |
|---|---|
| OpenTelemetry | Trazas, métricas y logs del Portal de Reservas y del Servicio de Reservas (ADR-004) |
| Colector de Plataforma Northwind | Destino de la telemetría OpenTelemetry (ADR-004) |
| W3C Trace Context | Propagación de `traceparent` del navegador a la base de datos (ADR-004) |
| Logs JSON estructurados | `trace_id`, `span_id`, `service.name` y nivel; sin tokens ni datos personales completos (ADR-004) |
| Métricas RED | Tasa, errores y duración por operación del Servicio de Reservas (ADR-004) |

### 8.6 Seguridad <!-- SECTION: Security -->

| Tool | Purpose |
|---|---|
| Keycloak 25 | Proveedor de Identidad Northwind: autenticación de miembros y recepcionistas (ADR-002) |
| OpenID Connect con PKCE | Inicio de sesión del Portal de Reservas; tokens en memoria, nunca en `localStorage` ni `sessionStorage` (ADR-002) |
| JWT RS256 con JWKS | Validación del token de acceso en cada solicitud al Servicio de Reservas (ADR-002) |
| Gestor de secretos del clúster | Inyección de las credenciales de la Base de Datos de Reservas (ADR-005) |
| TLS 1.2+ | Cifrado del tráfico externo en el ingress (ADR-005) |
| RFC 9457 | Formato `application/problem+json` de los errores de la API (ADR-001) |

### 8.7 CI/CD <!-- SECTION: CI/CD -->

| Tool | Purpose |
|---|---|
| Validación del contrato OpenAPI | Paso de CI de cada servicio (ADR-001) |
| Firma de imágenes | Imagen firmada del Servicio de Reservas (ADR-005) |
| Herramienta de CI/CD | Not documented <!-- TODO: Add source reference --> |
