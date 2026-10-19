# Arquitectura de Seguridad

<!-- EXPLORER_HEADER
key_concepts: OIDC PKCE, tokens en memoria, deny by default, autorización por rol y sede, JWKS, datos personales, retención de 24 meses, purga, auditoría de cancelaciones, TLS 1.2
technologies: Keycloak 25, OIDC, PKCE, JWT, JWKS, PostgreSQL 16, TLS 1.2, Kubernetes
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas, proveedor-de-identidad-northwind
scope: Autenticación, autorización, protección de datos y cumplimiento; no cubre operación ni respuesta a incidentes
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-104, ADR-105, ADR-106
-->

> Seguridad de Reservas de Salas Northwind: autenticación delegada al Proveedor de Identidad Northwind, tokens solo en memoria del navegador, autorización por rol y sede en el Servicio de Reservas, y retención de 24 meses con purga y auditoría de cancelaciones.

## 9. Arquitectura de Seguridad <!-- SECTION: Security Architecture -->

### 9.1 Principios de Seguridad <!-- SECTION: Security Principles -->

| Principio | Aplicación |
|---|---|
| Deny by default | El `Servicio de Reservas` responde 401 sin token válido y no procesa nada ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)) |
| Mínimo privilegio | Solo el rol `recepcion` con atributo `sede` coincidente cancela reservas ajenas |
| Un solo dueño de datos | Solo el `Servicio de Reservas` accede a las tablas de la `Base de Datos de Reservas` ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)) |
| Cifrado en tránsito | TLS 1.2 o superior en el ingress del clúster ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)) |

### 9.2 Modelo de Amenazas <!-- SECTION: Threat Model -->

**Activos**: nombre y correo del miembro, reservas, tokens de acceso, registro de auditoría de cancelaciones.

| Amenaza | Mitigación |
|---|---|
| Robo de token desde el navegador | Tokens en memoria, nunca en `localStorage` ni `sessionStorage`; token de acceso de 5 minutos ([ADR-104](../adr/ADR-104-manejo-de-tokens-oidc-en-la-spa-sin.md)) |
| Acceso no autorizado a una reserva ajena | Cancelación solo para el dueño o `recepcion` de la misma `sede` ([ADR-105](../adr/ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md)) |
| Token falsificado o expirado | Validación RS256 con las llaves JWKS del Proveedor de Identidad Northwind en cada solicitud |
| Intercepción del tráfico | TLS 1.2 o superior en el ingress |
| Conservación de datos personales más allá del plazo | Purga a los 24 meses ([ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md)) |
| Cancelación sin rastro | Registro de auditoría por cancelación ([ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md)) |

### 9.3 Controles de Seguridad <!-- SECTION: Security Controls -->

**Autenticación**
- Método: código de autorización OIDC con PKCE contra el `Proveedor de Identidad Northwind` ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)); integración [I-01](05-integration-points.md).
- Sesión: token de acceso de 5 minutos con renovación silenciosa por token de refresco.
- Almacenamiento: tokens solo en memoria del `Portal de Reservas`. ([ADR-104](../adr/ADR-104-manejo-de-tokens-oidc-en-la-spa-sin.md)).
- Membresía vigente: cuenta de miembro activa en el `Proveedor de Identidad Northwind`; al darse de baja, Recepción la desactiva y el miembro ya no obtiene token. El `Servicio de Reservas` no hace una verificación de membresía aparte (PO Spec CU1 y CU2).

**Autorización**
- Validación del JWT en cada solicitud con JWKS; integración [I-03](05-integration-points.md).
- Roles: miembro (dueño de sus reservas) y `recepcion`, acotado por el atributo `sede` del token ([ADR-105](../adr/ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md)).
- Respuesta "no autorizado" en cualquier otro caso.

**Autenticación por integración**

| Integración | Mecanismo |
|---|---|
| [I-01](05-integration-points.md) | Código de autorización OIDC con PKCE en el `Proveedor de Identidad Northwind` ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)) |
| [I-02](05-integration-points.md) | JWT RS256 en `Authorization: Bearer`, validado en cada solicitud con JWKS; sin token válido, 401 ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)) |
| [I-03](05-integration-points.md) | Sin credencial de cliente: endpoint JWKS público por HTTPS con verificación del certificado del proveedor; claves en caché local |
| [I-04](05-integration-points.md) | Usuario PostgreSQL propio del `Servicio de Reservas`, con credenciales del gestor de secretos del clúster ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)); JDBC con TLS |

**Datos**
- En tránsito: TLS 1.2 o superior hacia el ingress; TLS en la conexión JDBC de I-04.
- En reposo: PostgreSQL 16 gestionado por Plataforma Northwind; respaldo diario con retención de 30 días ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).
- Datos personales: nombre, correo y reservas del miembro.

**Aplicación**
- Contrato OpenAPI 3.1 como fuente de la validación de entradas ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Acceso a la base de datos solo por el `Servicio de Reservas`; integración [I-04](05-integration-points.md).

**Secretos**: credenciales de la Base de Datos de Reservas inyectadas desde el gestor de secretos del clúster; nunca en la imagen ni en el repositorio ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).

### 9.4 Cumplimiento <!-- SECTION: Compliance -->

| Requisito | Control |
|---|---|
| Ley de protección de datos personales aplicable | Datos de reservas conservados 24 meses y eliminados por una purga programada |
| Auditoría de cada cancelación (quién, cuándo y, en las de recepción, el motivo) | El `Servicio de Reservas` escribe un registro de auditoría en la misma transacción de la cancelación; se conserva 24 meses |

**Decisión ([ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md))**: retención de 24 meses para reservas y registro de auditoría, con purga programada en la `Base de Datos de Reservas`.

**Costo**: los respaldos diarios conservan datos ya purgados hasta 30 días ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).

### 9.5 Monitoreo de Seguridad <!-- SECTION: Security Monitoring -->

- Trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Plan de respuesta a incidentes: Not documented. <!-- TODO: Add source reference -->
