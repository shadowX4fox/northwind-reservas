[Architecture](../../ARCHITECTURE.md) > [Components](README.md) > Reservas de Salas Northwind

# Reservas de Salas Northwind

<!-- EXPLORER_HEADER
key_concepts: sistema de reservas de salas, autoservicio, disponibilidad, reservas dobles, cancelación por sede, C4 L1
technologies: React 18, Spring Boot 3.3, Java 21, PostgreSQL 16
component_self: reservas-de-salas-northwind
scope: Descriptor C4 L1 del sistema interno y sus tres contenedores; no detalla cada contenedor
related_adrs: ADR-001, ADR-002, ADR-003, ADR-005
-->

> Sistema interno que permite a los miembros de Northwind Cowork consultar, reservar y cancelar las 42 salas de las 3 sedes. Agrupa un portal web, un microservicio y su base de datos.

**C4 Level:** System (L1)
**Type:** Internal System
**Owner:** Not documented <!-- TODO: Add source reference -->
**Containers:** 3 (2 Apps, 1 Store)

## Descripción <!-- LABEL: Description -->

Reservas de Salas Northwind reemplaza el registro manual de reservas por correo y hoja de cálculo. Muestra la disponibilidad en tiempo real, confirma la reserva en pantalla e impide dos reservas confirmadas superpuestas de la misma sala.

## Contenedores <!-- LABEL: Containers -->

| Component | Type | Technology | Internal Name |
|-----------|------|------------|---------------|
| [Portal de Reservas](reservas-de-salas-northwind/01-portal-de-reservas.md) | Web Application | [React 18, TypeScript] | |
| [Servicio de Reservas](reservas-de-salas-northwind/02-servicio-de-reservas.md) | API Service | [Java 21, Spring Boot 3.3] | |
| [Base de Datos de Reservas](reservas-de-salas-northwind/03-base-de-datos-de-reservas.md) | Database | [PostgreSQL 16] | |

## Límites del Sistema <!-- LABEL: System Boundaries -->

**Owns:** salas de las 3 sedes, con capacidad y equipamiento; reservas y cancelaciones.
**Depends on:** [Proveedor de Identidad Northwind](proveedor-de-identidad-northwind.md), para autenticación y validación de tokens.
**Consumed by:** miembros del cowork y recepcionistas de sede, por navegador.

## Comunicación <!-- LABEL: Communication -->

| From | To | Protocol | Description |
|------|----|----------|-------------|
| Portal de Reservas | Proveedor de Identidad Northwind | OIDC (PKCE) | Autenticación del miembro o recepcionista |
| Portal de Reservas | Servicio de Reservas | HTTPS/JSON | Consulta, reserva y cancela |
| Servicio de Reservas | Proveedor de Identidad Northwind | HTTPS (JWKS) | Validación de tokens |
| Servicio de Reservas | Base de Datos de Reservas | JDBC | Lee y escribe salas y reservas |
