[Architecture](../../../ARCHITECTURE.md) > [Components](../README.md) > [Reservas de Salas Northwind](.) > Servicio de Reservas

# Servicio de Reservas

<!-- EXPLORER_HEADER
key_concepts: microservicio de reservas, disponibilidad, creación de reserva, cancelación, validación JWT, JWKS, rol recepcion, atributo sede, contrato OpenAPI
technologies: Java 21, Spring Boot 3.3
component_self: servicio-de-reservas
component_type: api-service
scope: API REST de disponibilidad, reserva y cancelación de salas; no cubre la autenticación ni la interfaz
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-102
-->

> Servicio de Reservas es el único microservicio del sistema: expone la API REST de disponibilidad, reserva y cancelación, valida los tokens y es dueño de la Base de Datos de Reservas.

**Type:** API Service
**Technology:** [Java 21, Spring Boot 3.3]
**C4 Level:** Container (L2)
**Deploys as:** Docker container
**Communicates via:** HTTPS
**Description:** Servicio de Reservas expone la API REST de disponibilidad, reserva y cancelación de salas y aplica sus reglas.

**Component Version:** 1.0.0
**Architecture Version:** 1.0.0
**Last Updated:** 2026-10-18

**Bounded Context**: Reservas de salas — disponibilidad, creación y cancelación.
**Team Owner**: Not documented <!-- TODO: Add source reference -->

## Propósito <!-- LABEL: Purpose -->

Concentra las reglas de reserva de las 42 salas de las 3 sedes y es la única puerta a sus datos (ADR-003).

## Responsabilidades <!-- LABEL: Responsibilities -->

- Calcular la disponibilidad de salas por sede, fecha y franja.
- Crear reservas confirmadas sin superposición para la misma sala.
- Cancelar reservas: las propias del miembro, o cualquiera de su sede para el rol `recepcion`.
- Validar los tokens del Proveedor de Identidad Northwind con sus claves JWKS.

## Especificación de API <!-- LABEL: API Specification -->

**API Type**: REST sobre HTTPS con cuerpos JSON (ADR-001).
**Contrato**: OpenAPI 3.1 versionado en el repositorio del servicio, escrito antes que el código (ADR-001).
**Autenticación**: token JWT del Proveedor de Identidad Northwind (ADR-002).

| Operación | Caso de uso | Endpoint |
|---|---|---|
| Consultar disponibilidad | CU1 | Not documented <!-- TODO: Add source reference --> |
| Crear reserva | CU2 | Not documented <!-- TODO: Add source reference --> |
| Cancelar reserva | CU3 | Not documented <!-- TODO: Add source reference --> |

## Gestión de Datos <!-- LABEL: Data Management -->

- **Almacén**: [Base de Datos de Reservas](03-base-de-datos-de-reservas.md), de su propiedad exclusiva (ADR-003).
- **Acceso**: JDBC; ningún otro servicio lee ni escribe sus tablas (ADR-003).
- **Consistencia**: fuerte; la superposición la rechaza la base de datos ([ADR-102](../../../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).

## Dependencias <!-- LABEL: Dependencies -->

| Dependencia | Protocolo | Uso |
|---|---|---|
| [Base de Datos de Reservas](03-base-de-datos-de-reservas.md) | JDBC | Lee y escribe salas y reservas |
| [Proveedor de Identidad Northwind](../proveedor-de-identidad-northwind.md) | HTTPS (JWKS) | Claves para validar tokens |

**Consumido por**: [Portal de Reservas](01-portal-de-reservas.md).

## Despliegue <!-- LABEL: Deployment -->

- Contenedor en el clúster Kubernetes de Plataforma Northwind, con al menos 2 réplicas en zonas distintas (ADR-005).
- Solicitudes y límites de CPU y memoria, sondas de vida y de disponibilidad declaradas (ADR-005).

## Observabilidad <!-- LABEL: Observability -->

- Trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind (ADR-004).
- Contexto W3C Trace Context recibido del Portal de Reservas (ADR-004).
- Métrica de negocio: tiempo de confirmación de reservas, meta p95 ≤ 2 s (PO Spec §8).

## Capacidad <!-- LABEL: Capacity -->

| Metric | Value | Unit | Source |
|---|---|---|---|
| capacity_per_replica | Not documented | rps | |
| replicas | 2 | count | Mínimo de ADR-005 |
| max_replicas | Not documented | count | |
| requests_per_transaction | Not documented | ratio | |
| documented_demand | Not documented | rps | PO Spec §1: 310 solicitudes por semana con el proceso por correo |
