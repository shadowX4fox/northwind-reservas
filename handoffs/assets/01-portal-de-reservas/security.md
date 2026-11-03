# Portal de Reservas — Obligaciones de Seguridad

<!-- managed by sa-skills:architecture-dev-handoff — rendered by security-obligations.js from the architecture docs and the security analyses; fix a value there and re-run, never here -->

**Regla**: denegar por defecto. Solo los llamadores de Entrada alcanzan este componente; una interfaz cuya autenticación no está documentada falla cerrada —rechaza toda llamada— hasta que la arquitectura la declare. Ningún control de abajo se relaja para simplificar el código.

## Entrada — quién puede llamar <!-- SECTION: Inbound -->

Ningún llamador documentado: toda llamada entrante se rechaza.

## Salida — credenciales que presenta <!-- SECTION: Outbound -->

| Integration | Target | Protocol | Authentication | Source |
|---|---|---|---|---|
| I-01 | Servidor de Identidad Northwind | HTTPS/JSON [Auth] | Código de autorización OIDC con PKCE, TOTP obligatorio, bloqueo de 15 minutos tras 5 intentos (ADR-002) | STRIDE TB-01 |
| I-02 | Servicio de Reservas | HTTPS/JSON [Query] | JWT RS256 en Authorization: Bearer, validado con JWKS en cada solicitud; 401 sin token válido (ADR-002) | STRIDE TB-02 |

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
| T4-D | TB-02 | Saturación del Servicio de Reservas por volumen de solicitudes públicas en I-02 | DoS | Medium | ⚠️ Finding | Límite de tasa en el ingress o en el servicio: Not documented; solo HPA de Kubernetes (docs/07 § 9.3, docs/02 § 3) |
| T5-E | TB-02 | Escalada desde un pod comprometido del Servicio de Reservas por ejecución como root | Elevation of Privilege | Low | ⚠️ Finding | Imagen firmada (ADR-005); usuario no root y network policies: Not documented |

_analysis/STRIDE-2026-11-03.md_

## Datos que maneja <!-- SECTION: Data -->

| Flow | Step | From | To | Carries Sensitive Data? | Encryption in Transit | Gap |
|---|---|---|---|---|---|---|
| Flujo 1 — Consultar disponibilidad | 1 | Portal de Reservas | Servidor de Identidad Northwind | Sí: credenciales, TOTP, token de acceso | Documented (HTTPS; versión TLS Not documented) | None |
| Flujo 1 — Consultar disponibilidad | 2 | Portal de Reservas | Servicio de Reservas | Sí: token de acceso con rol y sede | Documented | None |
| Flujo 2 — Reservar una sala | 1 | Portal de Reservas | Servicio de Reservas | Sí: token de acceso y datos de la reserva | Documented | None |
| Flujo 3 — Cancelar una reserva | 1 | Portal de Reservas | Servicio de Reservas | Sí: token con rol recepcion y sede, motivo de cancelación | Documented | None |

_analysis/DATA-SENSITIVITY-2026-11-03.md_

## Pruebas que la construcción debe pasar <!-- SECTION: Security Tests -->

- [ ] T4-D — Saturación del Servicio de Reservas por volumen de solicitudes públicas en I-02: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
- [ ] T5-E — Escalada desde un pod comprometido del Servicio de Reservas por ejecución como root: la mitigación se cumple, o un `TODO(architecture)` cita este hallazgo.
