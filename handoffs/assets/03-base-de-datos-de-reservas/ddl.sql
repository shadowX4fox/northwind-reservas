-- Engine: PostgreSQL 16
-- Component: 5.3 — Base de Datos de Reservas
-- Source: docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md
--
-- Propietario: Servicio de Reservas (ADR-003). Esquema versionado con migraciones (ADR-003).

-- Entidad documentada: salas (42 salas de 3 sedes, con capacidad y equipamiento).
-- TODO: [NOT DOCUMENTED — nombre de tabla y columnas de salas: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- Entidad documentada: reservas (con su estado, incluidas las cancelaciones).
-- TODO: [NOT DOCUMENTED — nombre de tabla y columnas de reservas: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- Restricción documentada (ADR-102): restricción de exclusión que rechaza dos reservas confirmadas superpuestas de la misma sala.
-- TODO: [NOT DOCUMENTED — columnas de sala, rango de tiempo y estado confirmado de la restricción de exclusión: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- Entidad documentada: registro de auditoría de cancelaciones.
-- TODO: [NOT DOCUMENTED — nombre de tabla y columnas del registro de auditoría de cancelaciones: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- Entidad documentada: claves de idempotencia.
-- TODO: [NOT DOCUMENTED — nombre de tabla y columnas de claves de idempotencia: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
