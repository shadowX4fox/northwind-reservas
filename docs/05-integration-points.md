# Puntos de Integración

<!-- EXPLORER_HEADER
key_concepts: integración, OIDC PKCE, validación JWKS, REST sobre HTTPS, JDBC, límite de confianza, sistema externo, contrato OpenAPI
technologies: HTTPS, JSON, OIDC, PKCE, JWKS, JDBC, PostgreSQL 16, Keycloak 25, OpenAPI 3.1
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas, proveedor-de-identidad-northwind
scope: Cuatro integraciones entre contenedores y el Proveedor de Identidad Northwind; no cubre credenciales, SLA ni costos
related_adrs: ADR-001, ADR-002, ADR-003, ADR-102, ADR-103
-->

> Cuatro integraciones síncronas: dos con el Proveedor de Identidad Northwind (externo), una REST entre el Portal de Reservas y el Servicio de Reservas, y una JDBC hacia la Base de Datos de Reservas. No hay integraciones asíncronas.

## 7. Puntos de Integración <!-- SECTION: Integration Points -->

| # | From | To | Protocol | Pattern | Boundary |
|---|---|---|---|---|---|
| I-01 | `Portal de Reservas` | `Proveedor de Identidad Northwind` | HTTPS/JSON [Auth] | request-response | external |
| I-02 | `Portal de Reservas` | `Servicio de Reservas` | HTTPS/JSON [Query] | request-response | internal |
| I-03 | `Servicio de Reservas` | `Proveedor de Identidad Northwind` | HTTPS/JSON [Auth] | request-response | external |
| I-04 | `Servicio de Reservas` | `Base de Datos de Reservas` | JDBC/SQL [Data] | request-response | internal |

**Actores**: las aristas "Usa" del HLD (Miembro del cowork y Recepcionista de sede hacia el Portal de Reservas) son uso por personas desde el navegador, no integraciones entre sistemas; no llevan fila `I-nn`.

**I-01 — Autenticación del usuario**
El Portal de Reservas autentica a miembros y recepcionistas con el flujo de código de autorización OIDC con PKCE. El token de acceso, con el rol `recepcion` y el atributo `sede`, vive en memoria del navegador. Falla de autenticación: el portal redirige al inicio de sesión. Gobierna [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md).

**I-02 — Consulta, reserva y cancelación**
El Portal de Reservas llama a la API REST del Servicio de Reservas con el token de acceso en `Authorization`. La creación de reservas envía `Idempotency-Key` ([ADR-103](../adr/ADR-103-idempotencia-de-la-creacion-de-reservas-con-clave.md)). El contrato OpenAPI 3.1 es la fuente de la interfaz. Sin token válido, respuesta 401. Gobierna [ADR-001](../adr/ADR-001-rest-openapi-apis.md).

**I-03 — Validación de tokens**
El Servicio de Reservas valida la firma y los claims de cada token con las claves públicas JWKS del Proveedor de Identidad Northwind, con caché local de las claves. Sin claves disponibles, rechaza la solicitud (deny by default). Gobierna [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md).

**I-04 — Persistencia de reservas**
El Servicio de Reservas lee y escribe la Base de Datos de Reservas por JDBC; ningún otro componente accede a sus tablas. La restricción de exclusión rechaza reservas superpuestas ([ADR-102](../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)). Falla de conexión: la solicitud responde error de servicio. Gobierna [ADR-003](../adr/ADR-003-postgresql-relational-store.md).
