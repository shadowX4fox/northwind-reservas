# ADR-104: Tokens OIDC solo en memoria en la SPA

**Status**: Proposed
**Scope**: User
**Date**: 2026-10-18
**Authors**: Architecture Team
**Related**: ADR-002

---

## Context

### Problem Statement

Los tokens OIDC del Portal de Reservas expuestos en el almacenamiento del navegador permiten su robo y el acceso a reservas de miembros.

### Requirements

| Tipo | Requisito |
|---|---|
| Functional | Autenticar con código de autorización OIDC y PKCE contra el `Proveedor de Identidad Northwind` |
| Functional | Mantener la sesión con renovación silenciosa por token de refresco |
| Security | Mitigar el robo de token desde el navegador |
| Security | Token de acceso de 5 minutos |
| Constraint | El `Proveedor de Identidad Northwind` (Keycloak 25) es la única fuente de autenticación |

### Business Drivers

- Proteger nombre, correo y reservas del miembro, y los tokens de acceso.
- Cumplir [ADR-002](ADR-002-oidc-keycloak-identity.md), que fija los tokens en memoria para aplicaciones de una página.

---

## Decision

### Summary

Los tokens OIDC viven solo en la memoria del `Portal de Reservas`. Nunca se guardan en `localStorage` ni en `sessionStorage`. El token de acceso dura 5 minutos y se renueva en silencio.

### Detailed Decision

- Flujo de código de autorización OIDC con PKCE contra el `Proveedor de Identidad Northwind`.
- Almacenamiento de tokens solo en memoria del `Portal de Reservas`.
- Token de acceso de 5 minutos con renovación silenciosa por token de refresco.
- El `Servicio de Reservas` valida el JWT en cada solicitud con JWKS (RS256) y responde 401 sin token válido.

### Scope

| Incluye | No incluye |
|---|---|
| Tokens del `Portal de Reservas` en el navegador | Gestión de secretos: Not documented |
| Duración y renovación del token de acceso | Roles y atributo `sede` (ADR Candidate 5) |

---

## Rationale

### Primary Drivers

- **Mitigación del robo de token** — el modelo de amenazas (Sección 9.2) lo cubre con tokens en memoria y vida de 5 minutos.
- **Coherencia institucional** — aplica [ADR-002](ADR-002-oidc-keycloak-identity.md): en una SPA los tokens viven en memoria.
- **Ventana de exposición corta** — el token de acceso expira en 5 minutos.

### Comparison Summary

| Criteria | Solo en memoria | localStorage / sessionStorage |
|----------|----------------|---------------|
| **Robo de token desde el navegador** | ✅ | ❌ |
| **Alineación con ADR-002** | ✅ | ❌ |

---

## Consequences

### Positive Consequences

- **Menor superficie de robo de token** — miembros y recepción; los tokens no persisten en el almacenamiento del navegador.
- **Exposición acotada** — un token robado sirve como máximo 5 minutos.

### Negative Consequences

- **Sesión perdida al recargar la página** — miembros y recepción. **Severity**: Low. **Mitigation**: Not documented.
- **Dependencia de la renovación silenciosa** — usuarios del portal. **Severity**: Medium. **Mitigation**: Not documented.

### Trade-offs

- **Seguridad vs continuidad de sesión**: se cede la persistencia entre recargas a cambio de menor riesgo de robo.

---

## Alternatives Considered

| Alternative | Why rejected | When it would have been the better choice |
|---|---|---|
| Tokens en `localStorage` o `sessionStorage` | Exponen el token al robo desde el navegador | Not documented |

---

## Implementation Plan

Not documented

---

## Success Metrics

Not documented

---

## References

### Documentation
- docs/07-security-architecture.md, secciones 9.1, 9.2 y 9.3
- PRODUCT_OWNER_SPEC.md, Restricciones de Integración (§7)

### Related ADRs
- [ADR-002](ADR-002-oidc-keycloak-identity.md) - Autenticación con OpenID Connect en Keycloak

---

## Review History

| Date | Reviewer | Action | Notes |
|------|----------|--------|-------|
| 2026-10-18 | Architecture Team | Created | Initial draft |

---

## Notes

- Los secretos no están documentados en la Sección 9.3.
- Mitigaciones de las consecuencias negativas: Not documented.
