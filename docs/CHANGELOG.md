# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

## [1.3.2] - 2026-10-19

### Changed
- Contenedor: Servicio de Reservas — deja de nombrar TDR-002, resuelta
- Contenedor: Base de Datos de Reservas — deja de nombrar TDR-002, resuelta
- TDR: TDR-002 — estado: In Progress → Resolved (la purga de claves de idempotencia vencidas está en main del Servicio de Reservas)
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-002 sale de 13.2 Deuda Técnica

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
