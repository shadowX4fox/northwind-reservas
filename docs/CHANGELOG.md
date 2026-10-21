# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Servicio de Reservas: operación `getBooking` (`GET /v1/bookings/{code}`) para el paso 1 de CU3; contrato 1.1.0.

## [1.7.0] - 2026-10-20

### Added
- ADR: ADR-110 — Hora local de sede con zona única America/Bogota (Accepted)
- TDR: TDR-004 — Zona horaria de las sedes leída de una variable de despliegue (In Progress)

### Changed
- Contenedor: Portal de Reservas — no deja elegir franjas anteriores a la hora actual de la sede (ADR-110)
- Contenedor: Servicio de Reservas — `start`/`end` en hora local de la sede y reloj de negocio en America/Bogota (ADR-110)
- Contenedor: Base de Datos de Reservas — horas de las reservas en hora local de la sede (ADR-110)
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-004 pasa a In Progress
- ESC-004 resolved by this release: Zona horaria de las sedes no documentada (INV-01, INV-04, ADR-105)

## [1.6.0] - 2026-10-20

### Added
- TDR: TDR-003 — Los avisos de disponibilidad perdidos al reconectar LISTEN dejan la caché desactualizada hasta 5 minutos (Resolved)

### Changed
- ADR: ADR-102 — enlaza TDR-003 en Notes
- ADR: ADR-109 — cita TDR-003 en References

## [1.5.1] - 2026-10-20

### Changed
- Contenedor: Servicio de Reservas — deja de nombrar TDR-001, resuelta
- TDR: TDR-001 — estado: In Progress → Resolved (ADR-109 implementado en northwind-servicio-reservas@3238407)
- Sección: Escalabilidad y Rendimiento (`docs/08-scalability-and-performance.md`) — la ventana de TDR-001 ya no aplica
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-001 sale de 13.2 Deuda Técnica

## [1.5.0] - 2026-10-20

### Added
- ADR: ADR-109 — Invalidación de la caché con LISTEN/NOTIFY (Accepted)

### Changed
- Contenedor: Servicio de Reservas — la caché se invalida en todas las réplicas con LISTEN/NOTIFY (ADR-109)
- Contenedor: Base de Datos de Reservas — I-04 incluye el canal `disponibilidad`
- ADR: ADR-108 — estado: Accepted → Superseded by ADR-109
- TDR: TDR-001 — estado: Open → In Progress
- Sección: Patrones de Flujo de Datos (`docs/04-data-flow-patterns.md`) — crear y cancelar emiten NOTIFY en el canal `disponibilidad`
- Sección: Puntos de Integración (`docs/05-integration-points.md`) — I-04 añade NOTIFY y una conexión LISTEN por réplica
- Sección: Stack Tecnológico (`docs/06-technology-stack.md`) — la fila de Caffeine cita ADR-109
- Sección: Escalabilidad y Rendimiento (`docs/08-scalability-and-performance.md`) — invalidación en todas las réplicas; 5 minutos como red de seguridad
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-001 en In Progress
- ESC-003 resolved by this release: TDR-001: invalidar la caché de disponibilidad en todas las réplicas con LISTEN/NOTIFY de PostgreSQL

## [1.4.0] - 2026-10-20

### Added
- ADR: ADR-108 — Caché en proceso con Caffeine para disponibilidad (Accepted)

### Changed
- Contenedor: Servicio de Reservas — tecnología: Java 21, Spring Boot 3.3 → Java 21, Spring Boot 3.3, Caffeine 3.2
- ADR: ADR-101 — estado: Proposed → Accepted
- ADR: ADR-102 — estado: Proposed → Accepted
- ADR: ADR-103 — estado: Proposed → Accepted
- ADR: ADR-104 — estado: Proposed → Accepted
- ADR: ADR-105 — estado: Proposed → Accepted
- ADR: ADR-106 — estado: Proposed → Accepted
- ADR: ADR-107 — estado: Proposed → Accepted
- Sección: Patrones de Flujo de Datos (`docs/04-data-flow-patterns.md`) — la consulta de disponibilidad pasa por la caché Caffeine; crear y cancelar invalidan la entrada local
- Sección: Stack Tecnológico (`docs/06-technology-stack.md`) — Caffeine 3.2 en el Servicio de Reservas
- Sección: Escalabilidad y Rendimiento (`docs/08-scalability-and-performance.md`) — caché de aplicación en cada réplica, sin caché distribuida
- TDR: TDR-001 — sigue Open; nombra la caché Caffeine de ADR-108
- ESC-002 resolved by this release: TDR-001 registra una caché de disponibilidad que el Servicio de Reservas no tiene

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
