# Changelog de Arquitectura

Todos los cambios relevantes de esta arquitectura se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Este proyecto sigue [Versionado Semántico](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.11.0] - 2026-11-03

### Added
- TDR: TDR-005 — El almacén de cuentas del Servidor de Identidad Northwind no documenta cifrado en reposo ni retención (Open)
- TDR: TDR-006 — El bloqueo por cuenta del Servidor de Identidad Northwind permite bloquear cuentas ajenas (Open)

### Changed
- Sistema: Proveedor de Identidad Northwind — la tabla de Comunicación apunta al Servidor de Identidad Northwind; enlaza TDR-005 y TDR-006
- Sistema: Reservas de Salas Northwind — la tabla de Comunicación apunta al Servidor de Identidad Northwind
- Contenedor: Portal de Reservas — su contraparte de inicio de sesión es el Servidor de Identidad Northwind (1.0.3)
- Contenedor: Servicio de Reservas — I-03 apunta al Servidor de Identidad Northwind (1.4.1)
- Integración: I-01 — ruta: Proveedor de Identidad Northwind → Servidor de Identidad Northwind
- Integración: I-03 — ruta: Proveedor de Identidad Northwind → Servidor de Identidad Northwind
- Sección: Capas de Arquitectura (`docs/03-architecture-layers.md`) — nodo de identidad de los Diagramas 3 y 4: Servidor de Identidad Northwind
- Sección: Puntos de Integración (`docs/05-integration-points.md`) — I-02 documenta el re-cifrado TLS 1.2+ del ingress a los pods
- Sección: Arquitectura de Seguridad (`docs/07-security-architecture.md`) — re-cifrado TLS hasta los pods; MFA TOTP y bloqueo de 15 minutos tras 5 intentos
- Sección: Riesgos y Deuda Técnica (`docs/10-risks-and-technical-debt.md`) — TDR-005 y TDR-006 en la tabla de deuda abierta

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

> Versiones anteriores: [CHANGELOG-ARCHIVE.md](CHANGELOG-ARCHIVE.md).
