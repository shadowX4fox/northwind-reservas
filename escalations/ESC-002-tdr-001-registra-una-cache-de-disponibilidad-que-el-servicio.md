---
id: ESC-002
status: Open
date: 2026-10-20
architecture: architecture-v1.3.2
route: tier-1
triggers: [low-confidence]
components: [Servicio de Reservas, Base de Datos de Reservas]
integrations: []
adrs: []
tdrs: [TDR-001]
requested_by: Equipo del Servicio de Reservas
issue: https://github.com/shadowX4fox/northwind-reservas/issues/38
resolution:
closed:
---
# ESC-002 — TDR-001 registra una caché de disponibilidad que el Servicio de Reservas no tiene

## Request

```text
TDR-001 registra una caché que el código del Servicio de Reservas no tiene. Llévalo al arquitecto como escalación.
```

## Why it needs an architect

| Trigger | Evidence |
|---|---|
| low-confidence | build pack 1.3.2, tdr:TDR-001, § Description y § History — Describe una caché de 5 minutos; la evidencia citada es una prueba de CI sin commit real (solicitud https://github.com/shadowX4fox/northwind-reservas/issues/19). |
| low-confidence | northwind-servicio-reservas@d358ee9 src/main/java/northwind/reservas/dominio/ServicioReservas.java:64-76 — CU1 lee salas y ocupación de la Base de Datos de Reservas en cada consulta (RepositorioReservas.java:48 y :65); no hay caché delante. Ningún commit del repositorio la introdujo (git log -S). |

**Route**: Tier 1 — SA office hours.

## What the AI would propose (not applied)

- Nothing proposed.

## Open questions for the architect

- TDR-001 (Open) dice que el Servicio de Reservas sirve la consulta de disponibilidad (CU1) desde una caché en memoria de 5 minutos por sede y fecha. El código del Servicio de Reservas nunca ha tenido esa caché: CU1 consulta siempre la Base de Datos de Reservas. ¿Cómo se cierra TDR-001, dado que la deuda que registra no existe?
- La solicitud que creó TDR-001 (#19) da como evidencia una "prueba de CI de la etapa 9, sin commit real". ¿Se retira TDR-001 de la arquitectura o se conserva con una nota que explique que no corresponde a código desplegado? Un movimiento a Won't Fix no se puede pedir como Tier 0.

## Resolution

- Pending.
