# Servicio de Reservas — Obligaciones de Seguridad

<!-- managed by sa-skills:architecture-dev-handoff — rendered by security-obligations.js from the architecture docs and the security analyses; fix a value there and re-run, never here -->

**Regla**: denegar por defecto. Solo los llamadores de Entrada alcanzan este componente; una interfaz cuya autenticación no está documentada falla cerrada —rechaza toda llamada— hasta que la arquitectura la declare. Ningún control de abajo se relaja para simplificar el código.

## Entrada — quién puede llamar <!-- SECTION: Inbound -->

| Integration | Caller | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-02 | Portal de Reservas | HTTPS/JSON [Query] | JWT RS256 en Authorization: Bearer, validado con JWKS en cada solicitud | STRIDE TB-01 |

Cualquier otro llamador se rechaza.

## Salida — credenciales que presenta <!-- SECTION: Outbound -->

| Integration | Target | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-03 | Proveedor de Identidad Northwind | HTTPS/JSON [Auth] | Sin credencial de cliente; HTTPS con verificación del certificado del proveedor | STRIDE TB-03 |
| I-04 | Base de Datos de Reservas | JDBC/SQL [Data] | Usuario PostgreSQL propio con credenciales del gestor de secretos del clúster; JDBC con TLS | STRIDE TB-04 |

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

| # | Boundary | Threat | Category | Severity | Status | Mitigation |
|---|---|---|---|---|---|---|
| T1-R | TB-01 | Un miembro niega haber creado una reserva | R — Repudio | Medium | ⚠️ Finding | Solo la cancelación escribe auditoría; la creación de reservas por I-02 no tiene registro con usuario, hora y recurso documentado (docs/07 § 9.4) |
| T2-D | TB-01 | Inundación de solicitudes sin autenticar contra la API pública | D — Denegación de servicio | High | ⚠️ Finding | Límite de tasa por IP y por cliente en el ingress (anotaciones de rate limit del Ingress Controller) y límite por usuario en el servicio; HPA con máximo de réplicas documentado. |
| T3-E | TB-01 | Escalada desde un contenedor comprometido del Servicio de Reservas | E — Elevación de privilegios | Medium | ⚠️ Finding | Autorización por rol recepcion y sede (ADR-105, Proposed) e imagen firmada; ejecución sin root y NetworkPolicy no documentadas (docs/07 § 9.3; docs/09 § 11.1) |
| T7-D | TB-03 | Indisponibilidad del endpoint JWKS bloquea todas las solicitudes | D — Denegación de servicio | Low | ⚠️ Finding | Caché local de claves y deny by default; TTL y refresco de la caché no documentados (docs/05 § 7, I-03) |
| T8-T | TB-04 | Alteración de datos en reposo o en respaldos | T — Manipulación | Medium | ⚠️ Finding | TLS en JDBC; cifrado en reposo de la Base de Datos de Reservas y de sus respaldos no documentado (docs/07 § 9.3) |
| T9-R | TB-04 | Cambio directo en la base sin rastro (acceso administrativo) | R — Repudio | Low | ⚠️ Finding | Auditoría de cancelaciones en la misma transacción (ADR-106); auditoría de acceso administrativo a PostgreSQL 16 no documentada |
| T10-I | TB-04 | Divulgación de datos personales desde almacenamiento o respaldos | I — Divulgación de información | Medium | ⚠️ Finding | Cifrado en reposo no documentado; respaldos conservan datos purgados 30 días en una ubicación no documentada (docs/07 § 9.4; docs/09 § 11.3) |
| T11-D | TB-04 | Agotamiento de conexiones JDBC | D — Denegación de servicio | Low | ⚠️ Finding | Falla de conexión responde error de servicio; tamaño del pool y límite de conexiones no documentados (docs/05 § 7, I-04) |
| T12-E | TB-04 | Inyección que ejecuta DDL con el usuario del servicio | E — Elevación de privilegios | Medium | ⚠️ Finding | Privilegios del usuario PostgreSQL (DML frente a DDL de migraciones) no documentados; las migraciones viven en el repositorio del servicio (docs/09 § 11.1) |

_analysis/STRIDE-2026-10-18.md_

## Datos que maneja <!-- SECTION: Data -->

[NOT DOCUMENTED — analysis/DATA-SENSITIVITY-*.md — run /sa-analysis:architecture-analysis data-sensitivity]

## Pruebas que la construcción debe pasar <!-- SECTION: Security Tests -->

- [ ] Una llamada a I-02 sin credenciales se rechaza.
- [ ] Una llamada a I-02 desde un llamador que no figura en Entrada se rechaza.
- [ ] T1-R — Un miembro niega haber creado una reserva: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T2-D — Inundación de solicitudes sin autenticar contra la API pública: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T3-E — Escalada desde un contenedor comprometido del Servicio de Reservas: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T7-D — Indisponibilidad del endpoint JWKS bloquea todas las solicitudes: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T8-T — Alteración de datos en reposo o en respaldos: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T9-R — Cambio directo en la base sin rastro (acceso administrativo): la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T10-I — Divulgación de datos personales desde almacenamiento o respaldos: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T11-D — Agotamiento de conexiones JDBC: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T12-E — Inyección que ejecuta DDL con el usuario del servicio: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
