---
id: ESC-004
status: Open
date: 2026-10-20
architecture: architecture-v1.6.0
route: tier-1
triggers: [low-confidence]
components: [Servicio de Reservas, Base de Datos de Reservas]
integrations: [I-02]
adrs: [ADR-105]
tdrs: []
requested_by: "Luis Borja (desarrollador del Servicio de Reservas), build desatendido"
issue: https://github.com/shadowX4fox/northwind-reservas/issues/62
resolution:
closed:
---
# ESC-004 — Zona horaria de las sedes no documentada (INV-01, INV-04, ADR-105)

## Request

```text
Construye desde el build pack (BUILD.md, vía Alia): resuelve el TODO(architecture) de la zona horaria de las sedes en PropiedadesReservas (application.yaml, spec § 4, INV-01 e INV-04). Trabaja en una rama y termina en un pull request en este repositorio.
```

## Why it needs an architect

| Trigger | Evidence |
|---|---|
| low-confidence | spec § 4 (INV-01, INV-04); northwind-servicio-reservas src/main/java/northwind/reservas/configuracion/PropiedadesReservas.java:19, src/main/resources/application.yaml:45 — INV-01 exige franjas "nunca en el pasado" e INV-04 cuenta "reservas futuras en un mismo día"; ADR-105 habla de reservas que "ya iniciaron". Las tres reglas dependen de la hora local de las sedes Centro, Norte y Puerto, pero ninguna parte de la arquitectura 1.6.0 documenta su zona horaria. El servicio la exige hoy como configuración obligatoria sin valor por defecto (RESERVAS_ZONA_HORARIA). |

**Route**: Tier 1 — SA office hours.

## What the AI would propose (not applied)

- Documentar la zona horaria de las sedes (o de cada sede) en docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md y en la spec § 4
- Con ese valor, el Servicio de Reservas lo fija en application.yaml (o por sede) y retira el TODO(architecture) de PropiedadesReservas

## Open questions for the architect

- ¿Cuál es la zona horaria (identificador IANA, p. ej. America/Bogota) de las sedes Centro, Norte y Puerto, contra la que el Servicio de Reservas decide si una franja está en el pasado (INV-01), si una reserva es futura (INV-04) y si ya inició (ADR-105)?
- ¿Comparten las tres sedes una única zona horaria, o cada sede tiene la suya? Si difieren, ¿dónde se documenta la zona de cada sede?
- ¿Las horas `start`/`end` del contrato (asset:openapi.yaml) son hora local de la sede, sin desfase, como asume hoy el esquema de la Base de Datos de Reservas?

## Resolution

- Pending.
