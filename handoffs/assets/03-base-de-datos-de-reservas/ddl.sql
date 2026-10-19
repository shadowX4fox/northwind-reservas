-- Engine: PostgreSQL 16
-- Component: 5.3 — Base de Datos de Reservas
-- Source: docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md

-- TODO: [NOT DOCUMENTED — columnas de la tabla salas: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- Documentado: 42 salas de 3 sedes, con capacidad y equipamiento.

-- TODO: [NOT DOCUMENTED — columnas de la tabla reservas: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- Documentado: reservas y su estado, incluidas las cancelaciones.

-- TODO: [NOT DOCUMENTED — columnas del registro de auditoría de cancelaciones: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- TODO: [NOT DOCUMENTED — columnas de las claves de idempotencia: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- TODO: [NOT DOCUMENTED — definición de la restricción de exclusión (columnas, tipo de rango, predicado de estado confirmado) de ADR-102: agregar a docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- Documentado (ADR-102): restricción de exclusión que rechaza dos reservas confirmadas superpuestas de la misma sala.
