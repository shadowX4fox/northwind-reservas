# Base de Datos de Reservas — Obligaciones de Seguridad

<!-- managed by sa-skills:architecture-dev-handoff — rendered by security-obligations.js from the architecture docs and the security analyses; fix a value there and re-run, never here -->

**Regla**: denegar por defecto. Solo los llamadores de Entrada alcanzan este componente; una interfaz cuya autenticación no está documentada falla cerrada —rechaza toda llamada— hasta que la arquitectura la declare. Ningún control de abajo se relaja para simplificar el código.

## Entrada — quién puede llamar <!-- SECTION: Inbound -->

| Integration | Caller | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-04 | Servicio de Reservas | JDBC/SQL [Data] | Usuario PostgreSQL propio del Servicio de Reservas, credenciales del gestor de secretos del clúster; JDBC con TLS (ADR-005) | STRIDE TB-04 |

Cualquier otro llamador se rechaza.

## Salida — credenciales que presenta <!-- SECTION: Outbound -->

Nada documentado.

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
| T7-T | TB-04 | Alteración de datos en reposo o en respaldos de la Base de Datos de Reservas | Tampering | Medium | ⚠️ Finding | TLS en JDBC (I-04); cifrado en reposo y ubicación de respaldos: Not documented (docs/07 § 9.3, docs/09 § 11.3) |
| T8-I | TB-04 | Divulgación de datos personales desde el almacenamiento o los respaldos de la Base de Datos de Reservas | Information Disclosure | Medium | ⚠️ Finding | Cifrado en reposo: Not documented; respaldos conservan datos purgados hasta 30 días (docs/07 § 9.4, docs/09 § 11.3) |

_analysis/STRIDE-2026-11-03.md_

## Datos que maneja <!-- SECTION: Data -->

| Flow | Step | From | To | Carries Sensitive Data? | Encryption in Transit | Gap |
|---|---|---|---|---|---|---|
| Flujo 1 — Consultar disponibilidad | 4 | Servicio de Reservas | Base de Datos de Reservas | Sí: lectura de reservas por sede y fecha | Documented | None |
| Flujo 2 — Reservar una sala | 3 | Servicio de Reservas | Base de Datos de Reservas | Sí: reserva ligada al miembro | Documented | G2 (destino sin cifrado en reposo documentado, G2-01) |
| Flujo 3 — Cancelar una reserva | 3 | Servicio de Reservas | Base de Datos de Reservas | Sí: cancelación y registro de auditoría (quién, cuándo, motivo) | Documented | G2 (destino sin cifrado en reposo documentado, G2-01) |

_analysis/DATA-SENSITIVITY-2026-11-03.md_

## Pruebas que la construcción debe pasar <!-- SECTION: Security Tests -->

- [ ] Una llamada a I-04 sin credenciales se rechaza.
- [ ] Una llamada a I-04 desde un llamador que no figura en Entrada se rechaza.
- [ ] T7-T — Alteración de datos en reposo o en respaldos de la Base de Datos de Reservas: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T8-I — Divulgación de datos personales desde el almacenamiento o los respaldos de la Base de Datos de Reservas: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
