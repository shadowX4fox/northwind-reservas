# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

## [1.3.1] - 2026-10-19

### Changed
- TDR: TDR-002 — estado: Open → In Progress
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-002 en curso en 13.2 Deuda Técnica

## [1.3.0] - 2026-10-19

### Added
- TDR: TDR-002 — Las claves de idempotencia vencidas nunca se purgan (Open)

### Changed
- Contenedor: Servicio de Reservas — nombra su deuda técnica TDR-002
- Contenedor: Base de Datos de Reservas — nombra su deuda técnica TDR-002
- ADR: ADR-103 — enlaza la deuda técnica TDR-002
- ADR: ADR-106 — enlaza la deuda técnica TDR-002
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — fila de TDR-002 en 13.2 Deuda Técnica

## [1.2.0] - 2026-10-19

### Added
- TDR: TDR-001 — La consulta de disponibilidad se sirve de una caché de 5 minutos (Open)

### Changed
- Contenedor: Servicio de Reservas — nombra su deuda técnica (TDR-001)
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — fila de TDR-001 en 13.2 Deuda Técnica

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
