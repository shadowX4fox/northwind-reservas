# ADR-003: PostgreSQL como base de datos relacional institucional

| Campo | Valor |
|-------|-------|
| **Estado** | Accepted |
| **Fecha** | 2026-03-02 |
| **Autores** | Equipo de Arquitectura Northwind |
| **Deciden** | Comité de Arquitectura Northwind |
| **Alcance** | Institucional |

## Contexto

Northwind opera tres motores relacionales distintos. Plataforma Northwind quiere un solo motor gestionado, con respaldos y monitoreo comunes.

## Decisión

- PostgreSQL 16, gestionado por Plataforma Northwind, es el motor relacional institucional.
- Cada servicio es dueño de su esquema; ningún otro servicio lee ni escribe sus tablas directamente.
- El esquema se versiona con migraciones en el repositorio del servicio (Flyway en Java).
- Las restricciones de integridad que el negocio exige (unicidad, no superposición) se declaran en la base, no solo en el código.
- Respaldo diario con retención de 30 días y recuperación a un punto en el tiempo de 7 días.

## Justificación

- Un solo motor reduce la operación y la capacitación.
- Las restricciones en la base resisten la concurrencia entre réplicas.

## Consecuencias

- Un servicio que necesita datos de otro los pide por su API.
- Plataforma Northwind provee la instancia, los respaldos y el monitoreo.

## Alternativas

| Alternativa | Motivo del descarte |
|-------------|---------------------|
| Base por equipo a elección | Tres motores ya demostraron el costo operativo |
| Base documental | Las reservas y sus restricciones son relacionales |
