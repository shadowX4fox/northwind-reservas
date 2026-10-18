# Servicio de Reservas — Obligaciones de Seguridad

<!-- managed by sa-skills:architecture-dev-handoff — rendered by security-obligations.js from the architecture docs and the security analyses; fix a value there and re-run, never here -->

**Regla**: denegar por defecto. Solo los llamadores de Entrada alcanzan este componente; una interfaz cuya autenticación no está documentada falla cerrada —rechaza toda llamada— hasta que la arquitectura la declare. Ningún control de abajo se relaja para simplificar el código.

## Entrada — quién puede llamar <!-- SECTION: Inbound -->

| Integration | Caller | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-02 | Portal de Reservas | HTTPS/JSON [Query] | [NOT DOCUMENTED — authentication of I-02: state it in docs/07-security-architecture.md] — falla cerrada hasta que se declare | docs/05 |

Cualquier otro llamador se rechaza.

## Salida — credenciales que presenta <!-- SECTION: Outbound -->

| Integration | Target | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-03 | Proveedor de Identidad Northwind | HTTPS/JSON [Auth] | [NOT DOCUMENTED — authentication of I-03: state it in docs/07-security-architecture.md] | docs/05 |
| I-04 | Base de Datos de Reservas | JDBC/SQL [Data] | [NOT DOCUMENTED — authentication of I-04: state it in docs/07-security-architecture.md] | docs/05 |

## Decisiones vigentes <!-- SECTION: Decisions in Force -->

### Principio: 4. Seguridad por Diseño

**Descripción:**
Se rechaza por defecto toda solicitud sin un token válido del Proveedor de Identidad Northwind, en cada llamada al Servicio de Reservas.

**Implementación:**
- Portal de Reservas: OIDC con PKCE; tokens en memoria, nunca en `localStorage` ni `sessionStorage` ([ADR-002](../../../adr/ADR-002-oidc-keycloak-identity.md)).
- Servicio de Reservas valida cada JWT RS256 con JWKS y responde 401 sin token válido ([ADR-002](../../../adr/ADR-002-oidc-keycloak-identity.md)).
- Autorización por el rol `recepcion` y el atributo `sede` del token (PO Spec §7).
- Credenciales de la Base de Datos de Reservas inyectadas desde el gestor de secretos del clúster ([ADR-005](../../../adr/ADR-005-kubernetes-container-runtime.md)).
- TLS 1.2 o superior en el Ingress del clúster ([ADR-005](../../../adr/ADR-005-kubernetes-container-runtime.md)).

**Compensaciones:**
- Una recarga de página pierde los tokens en memoria y repite el flujo OIDC contra Keycloak 25.
- La validación local del JWT retrasa la baja de un rol `recepcion` hasta el vencimiento del token, hasta 5 min ([ADR-002](../../../adr/ADR-002-oidc-keycloak-identity.md)).
- La verificación RS256 en cada solicitud agrega cómputo a cada llamada al Servicio de Reservas.

_docs/02-architecture-principles.md:64_

### ADR institucionales que cita la arquitectura de seguridad

- [ADR-001](../../../adr/ADR-001-rest-openapi-apis.md) — APIs síncronas REST con contrato OpenAPI
- [ADR-002](../../../adr/ADR-002-oidc-keycloak-identity.md) — Autenticación con OpenID Connect en Keycloak
- [ADR-003](../../../adr/ADR-003-postgresql-relational-store.md) — PostgreSQL como base de datos relacional institucional
- [ADR-004](../../../adr/ADR-004-opentelemetry-observability.md) — Observabilidad con OpenTelemetry
- [ADR-005](../../../adr/ADR-005-kubernetes-container-runtime.md) — Despliegue de servicios en el clúster Kubernetes de Plataforma Northwind

## Amenazas (STRIDE) <!-- SECTION: Threats -->

[NOT DOCUMENTED — analysis/STRIDE-*.md — run /sa-analysis:architecture-analysis stride]

## Datos que maneja <!-- SECTION: Data -->

[NOT DOCUMENTED — analysis/DATA-SENSITIVITY-*.md — run /sa-analysis:architecture-analysis data-sensitivity]

## Pruebas que la construcción debe pasar <!-- SECTION: Security Tests -->

- [ ] I-02 rechaza toda llamada hasta que su autenticación esté documentada.
