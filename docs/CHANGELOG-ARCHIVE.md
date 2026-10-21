# Changelog — archivo

Entradas rotadas desde `CHANGELOG.md`; cada una se conserva íntegra. Las más recientes están en [CHANGELOG.md](CHANGELOG.md).

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

## [1.1.1] - 2026-10-18

### Changed
- Contenedor: Servicio de Reservas — motivo de cancelación de recepción de 10 a 120 caracteres; regla de las franjas sugeridas (PO Spec 1.1)
- Sección: Patrones de Flujo de Datos (`docs/04-data-flow-patterns.md`) — motivo de 10 a 120 caracteres en la Fase 5; regla de las franjas sugeridas en el Flujo 1
- Sección: Arquitectura de Seguridad (`docs/07-security-architecture.md`) — auditoría con motivo solo en cancelaciones de recepción; membresía vigente definida por la cuenta en el Proveedor de Identidad Northwind
- ESC-001 resolved by architecture-v1.1.0: Servicio de Reservas: contrato de API vacío y autenticación de I-02/I-03/I-04 sin documentar bloquean la construcción

## [1.1.0] - 2026-10-18

### Changed
- Contenedor: Portal de Reservas — sección de propiedad de datos (ADR-104)
- Contenedor: Servicio de Reservas — contrato de API v1 (consulta, reserva, listado y cancelación), esquemas, tipos, errores RFC 9457, patrones de comunicación y propiedad de datos (ESC-001)
- Contenedor: Base de Datos de Reservas — patrones de comunicación y propiedad de datos
- Sección: Arquitectura de Seguridad (`docs/07-security-architecture.md`) — autenticación por integración (I-01 a I-04), TLS en I-04 y gestión de secretos (ADR-005)

## [1.0.0] - 2026-10-18

### Added
- Arquitectura inicial desde la PO Spec y el HLD.
- 2 sistemas, 4 componentes (ver `docs/components/README.md`).
- 5 ADR institucionales y 7 ADR de proyecto, ADR-101 a ADR-107, en estado Proposed (ver `adr/`).
- Tipo de arquitectura: Microservices.
- 11 archivos de sección en `docs/`.
