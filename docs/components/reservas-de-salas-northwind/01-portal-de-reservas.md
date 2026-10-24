[Architecture](../../../ARCHITECTURE.md) > [Components](../README.md) > [Reservas de Salas Northwind](.) > Portal de Reservas

# Portal de Reservas

<!-- EXPLORER_HEADER
key_concepts: SPA, consulta de disponibilidad, reserva de sala, cancelación, OIDC PKCE, tokens en memoria, archivos estáticos, portal responsivo
technologies: React 18, TypeScript
component_self: portal-de-reservas
component_type: web-application
scope: SPA de consulta, reserva y cancelación de salas; no contiene reglas de negocio ni datos persistentes
related_adrs: ADR-001, ADR-002, ADR-004, ADR-101, ADR-104, ADR-107, ADR-110
-->

> Portal de Reservas es la aplicación web por la que miembros y recepcionistas consultan, reservan y cancelan salas. Autentica con el Proveedor de Identidad Northwind y llama al Servicio de Reservas.

**Type:** Web Application
**Technology:** [React 18, TypeScript]
**C4 Level:** Container (L2)
**Deploys as:** Archivos estáticos
**Communicates via:** HTTPS
**Description:** Portal de Reservas es la SPA donde miembros y recepción consultan disponibilidad, reservan y cancelan salas.

**Component Version:** 1.0.2
**Architecture Version:** 1.9.0
**Last Updated:** 2026-10-20

**Team Owner**: Not documented <!-- TODO: Add source reference -->

## Propósito <!-- LABEL: Purpose -->

Interfaz de autoservicio de reservas, responsiva para navegador y teléfono. Sustituye la solicitud por correo a recepción.

## Responsabilidades <!-- LABEL: Responsibilities -->

- Mostrar la disponibilidad de salas por sede, fecha y franja, con capacidad y equipamiento.
- No dejar elegir una franja anterior a la hora actual de la sede (America/Bogota), no la del navegador ([ADR-110](../../../adr/ADR-110-hora-local-de-sede-con-zona-unica-america-bogota.md)).
- Enviar la reserva de una sala libre y mostrar la confirmación con el código de reserva.
- Listar las reservas futuras del miembro y permitir su cancelación.
- Permitir al recepcionista cancelar cualquier reserva de su sede.
- Autenticar al usuario con el Proveedor de Identidad Northwind.

## Interfaces <!-- LABEL: Interfaces -->

| Dirección | Contraparte | Protocolo | Uso |
|---|---|---|---|
| Saliente | [Servicio de Reservas](02-servicio-de-reservas.md) | HTTPS/JSON (REST, ADR-001) | Consulta, reserva y cancela |
| Saliente | [Proveedor de Identidad Northwind](../proveedor-de-identidad-northwind.md) | OIDC, código de autorización con PKCE (ADR-002) | Inicio de sesión |
| Entrante | Miembro del cowork, Recepcionista de sede | HTTPS (navegador) | Uso del portal |

## Propiedad de datos <!-- LABEL: Data Ownership -->

- **Dueño de**: ningún dato persistente; los tokens viven solo en memoria del navegador ([ADR-104](../../../adr/ADR-104-manejo-de-tokens-oidc-en-la-spa-sin.md)).
- **Solo lectura**: disponibilidad y reservas del Servicio de Reservas (I-02).

## Seguridad <!-- LABEL: Security -->

- **Autenticación**: flujo de código de autorización con PKCE (ADR-002).
- **Tokens**: prohibido guardarlos en `localStorage` (PO Spec §7, política de Seguridad de la Información).

## Observabilidad <!-- LABEL: Observability -->

- Trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind (ADR-004).
- Propagación W3C Trace Context (`traceparent`) en cada llamada al Servicio de Reservas (ADR-004).
- Métrica de experiencia: tiempo desde "Confirmar" hasta ver el código de reserva, meta p95 ≤ 2 s (PO Spec §8).

## Capacidad <!-- LABEL: Capacity -->

| Metric | Value | Unit | Source |
|---|---|---|---|
| capacity_per_replica | Not documented | rps | Servido como archivos estáticos |
| replicas | Not documented | count | |
| max_replicas | Not documented | count | |
| requests_per_transaction | Not documented | ratio | |
| documented_demand | Not documented | rps | |
