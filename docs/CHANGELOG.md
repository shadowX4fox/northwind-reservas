# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

## [1.1.1] - 2026-10-18

### Changed
- Contenedor: Servicio de Reservas — motivo de cancelación de recepción de 10 a 120 caracteres; regla de las franjas sugeridas (PO Spec 1.1)
- Sección: Patrones de Flujo de Datos (`docs/04-data-flow-patterns.md`) — motivo de 10 a 120 caracteres en la Fase 5; regla de las franjas sugeridas en el Flujo 1
- Sección: Arquitectura de Seguridad (`docs/07-security-architecture.md`) — auditoría con motivo solo en cancelaciones de recepción; membresía vigente definida por la cuenta en el Proveedor de Identidad Northwind
- ESC-001 resolved by architecture-v1.1.0: Servicio de Reservas: contrato de API vacío y autenticación de I-02/I-03/I-04 sin documentar bloquean la construcción

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
