# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
