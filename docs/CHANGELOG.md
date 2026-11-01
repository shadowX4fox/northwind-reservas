# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.10.4] - 2026-10-31

### Added
- Servicio de Reservas: métrica operativa de las reservas rechazadas por superposición, por sede.

### Changed
- Contenedor: Servicio de Reservas — contenido

## [1.10.3] - 2026-10-31

### Added
- Servicio de Reservas: métrica operativa de la tasa de aciertos de la caché de disponibilidad, por sede.

### Changed
- Contenedor: Servicio de Reservas — contenido

## [1.10.2] - 2026-10-31

### Added
- Portal de Reservas: métrica de experiencia de la consulta de disponibilidad, con meta p95 ≤ 1 s.

## [1.10.1] - 2026-10-27

### Added
- Portal de Reservas: en el listado, una reserva cancelada muestra la fecha y, si lo hay, el motivo de la cancelación.

## [1.10.0] - 2026-10-27

### Changed
- Servicio de Reservas: el asunto de una reserva (`BookingRequest.subject`) admite hasta 120 caracteres (antes 80); contrato 1.3.0.

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
