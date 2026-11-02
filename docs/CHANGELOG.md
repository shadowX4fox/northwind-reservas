# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.10.5] - 2026-11-02

### Changed
- Proveedor de Identidad Northwind: su contenedor L2 se llama Servidor de Identidad Northwind, para distinguirlo del sistema.
- Capas de Arquitectura: el Diagrama 3 (C4 L2) muestra el contenedor con su nuevo nombre.

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

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
