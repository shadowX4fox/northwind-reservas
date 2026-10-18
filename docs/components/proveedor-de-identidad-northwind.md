[Architecture](../../ARCHITECTURE.md) > [Components](README.md) > Proveedor de Identidad Northwind

# Proveedor de Identidad Northwind

<!-- EXPLORER_HEADER
key_concepts: proveedor de identidad, OpenID Connect, PKCE, JWKS, rol recepcion, atributo sede, sistema externo, C4 L1
technologies: Keycloak 25
component_self: proveedor-de-identidad-northwind
scope: Descriptor C4 L1 del sistema externo de identidad; no documenta su configuración interna
related_adrs: ADR-002
-->

> Sistema externo, propiedad de Northwind, que autentica a miembros y recepcionistas con OpenID Connect. Emite los tokens con el rol `recepcion` y el atributo `sede` que usa Reservas de Salas Northwind.

**C4 Level:** System (L1)
**Type:** External System
**Owner:** Not documented <!-- TODO: Add source reference -->
**Containers:** 1 (1 App, 0 Stores)

## Descripción <!-- LABEL: Description -->

Proveedor de Identidad Northwind (Keycloak 25) es la única fuente de autenticación de miembros, empleados y servicios (ADR-002). Ya tiene las cuentas de los 1.850 miembros y de los 6 recepcionistas (PO Spec, Supuestos).

## Contenedores <!-- LABEL: Containers -->

| Component | Type | Technology | Internal Name |
|-----------|------|------------|---------------|
| Proveedor de Identidad Northwind | Identity Provider | [Keycloak 25] | |

## Límites del Sistema <!-- LABEL: System Boundaries -->

**Owns:** cuentas, credenciales, roles y atributos de miembros y empleados.
**Depends on:** —
**Consumed by:** [Reservas de Salas Northwind](reservas-de-salas-northwind.md).

## Comunicación <!-- LABEL: Communication -->

| From | To | Protocol | Description |
|------|----|----------|-------------|
| Portal de Reservas | Proveedor de Identidad Northwind | OIDC (PKCE) | Flujo de código de autorización con PKCE |
| Servicio de Reservas | Proveedor de Identidad Northwind | HTTPS (JWKS) | Obtención de claves para validar tokens |
