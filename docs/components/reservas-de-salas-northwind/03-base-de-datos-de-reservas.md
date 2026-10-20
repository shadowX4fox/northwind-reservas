[Architecture](../../../ARCHITECTURE.md) > [Components](../README.md) > [Reservas de Salas Northwind](.) > Base de Datos de Reservas

# Base de Datos de Reservas

<!-- EXPLORER_HEADER
key_concepts: base de datos por servicio, salas, reservas, restricción de exclusión, superposición de horarios, migraciones de esquema, integridad
technologies: PostgreSQL 16
component_self: base-de-datos-de-reservas
component_type: database
scope: Almacén de salas y reservas del Servicio de Reservas; no cubre la retención ni la purga de datos
related_adrs: ADR-003, ADR-102
-->

> Base de Datos de Reservas guarda las salas y las reservas. Es propiedad exclusiva del Servicio de Reservas y rechaza por construcción dos reservas confirmadas superpuestas de la misma sala.

**Type:** Database
**Technology:** [PostgreSQL 16]
**C4 Level:** Container (L2)
**Deploys as:** managed service
**Communicates via:** TCP
**Description:** Base de Datos de Reservas guarda salas y reservas e impide dos reservas confirmadas superpuestas de una sala.

**Component Version:** 1.0.1
**Architecture Version:** 1.6.0
**Last Updated:** 2026-10-20

## Propósito <!-- LABEL: Purpose -->

Fuente de verdad de salas y reservas. PostgreSQL 16 gestionado por Plataforma Northwind (ADR-003).

## Responsabilidades <!-- LABEL: Responsibilities -->

- Guardar las 42 salas de las 3 sedes, con capacidad y equipamiento.
- Guardar las reservas y su estado, incluidas las cancelaciones.
- Rechazar una reserva confirmada que se superponga con otra de la misma sala, con una restricción de exclusión ([ADR-102](../../../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).

## Gestión de Datos <!-- LABEL: Data Management -->

- **Propietario**: [Servicio de Reservas](02-servicio-de-reservas.md); ningún otro servicio lee ni escribe sus tablas (ADR-003).
- **Esquema**: versionado con migraciones (ADR-003).
- **Carga inicial**: las 42 salas se cargan una vez desde la hoja de cálculo de recepción antes del piloto (PO Spec, Supuestos).
- **Consistencia**: fuerte; la integridad ante superposición la garantiza el motor, no la aplicación.

## Patrones de Comunicación <!-- LABEL: Communication Patterns -->

**Entrante:**

| Integración | Contraparte | Protocolo | Uso |
|---|---|---|---|
| I-04 | [Servicio de Reservas](02-servicio-de-reservas.md) | JDBC con TLS | Única lectura y escritura de sus tablas; canal `disponibilidad` |

**Saliente:** ninguna.

## Propiedad de datos <!-- LABEL: Data Ownership -->

- **Guarda**: salas, reservas, registro de auditoría de cancelaciones y claves de idempotencia; su dueño es el Servicio de Reservas (ADR-003).
- **Garantiza**: la restricción de exclusión que rechaza dos reservas confirmadas superpuestas de una sala ([ADR-102](../../../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).

## Capacidad <!-- LABEL: Capacity -->

| Metric | Value | Unit | Source |
|---|---|---|---|
| capacity_per_replica | Not documented | rps | |
| replicas | Not documented | count | Gestionado por Plataforma Northwind |
| max_replicas | Not documented | count | |
| requests_per_transaction | Not documented | ratio | |
| documented_demand | Not documented | rps | |
