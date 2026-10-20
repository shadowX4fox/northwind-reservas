---
status: In Progress
date: 2026-10-20
related-adrs: [ADR-105]
affected-components: ["Servicio de Reservas"]
tags: [zona-horaria, despliegue, INV-01, INV-04]
driver: Architecture
---

# TDR-004: Zona horaria de las sedes leída de una variable de despliegue

## Status

`In Progress`

**Initiative**: Reservas de Salas Northwind (architecture v1.6.0)
**Driver**: Architecture — la zona horaria de las sedes no está documentada en la arquitectura

## Description

La arquitectura 1.6.0 no documenta la zona horaria de las sedes (spec § 4, INV-01 e INV-04; escalado en [#62](https://github.com/shadowX4fox/northwind-reservas/issues/62)). Mientras #62 no tenga respuesta, el Servicio de Reservas la lee de la variable de despliegue `RESERVAS_ZONA_HORARIA` (identificador IANA, una sola zona para las 3 sedes), sin valor por defecto: sin ella, o con un identificador inválido, el servicio no arranca. El reloj de negocio usa esa zona para INV-01, INV-04 y [ADR-105](../adr/ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md).

## Impact

Quien despliega elige la zona; si no es la de las sedes, se aceptan o rechazan mal las franjas "en el pasado" (INV-01), las reservas "futuras" (INV-04) y las que "ya iniciaron" (ADR-105). Una sola zona para las 3 sedes: si las sedes tienen zonas distintas, la regla falla en alguna de ellas.

## Possible Solutions

- Opción A: la arquitectura responde #62 con la zona (o una por sede) y el Servicio de Reservas la fija en el código o en la configuración documentada, retirando la variable.
- Opción B: si cada sede tiene su zona, la zona pasa a ser un atributo de la sede en la Base de Datos de Reservas.

## Owner

- **Technical**: Servicio de Reservas — Team Owner: Not documented (spec línea 9)
- **Business (P&L)**: Gerencia de Producto Digital

---

## History

- 2026-10-20: Creado. Status: `Open`. Evidencia: PropiedadesReservas.java:36, application.yaml:47 y ConfiguracionReloj.java:13 en northwind-servicio-reservas@1cbd29c; solicitud https://github.com/shadowX4fox/northwind-reservas/issues/65.
- 2026-10-20: Open → In Progress; opción A: [ADR-110](../adr/ADR-110-hora-local-de-sede-con-zona-unica-america-bogota.md) fija America/Bogota para las 3 sedes (ESC-004, #62). Resolved cuando el servicio retire `RESERVAS_ZONA_HORARIA`.
