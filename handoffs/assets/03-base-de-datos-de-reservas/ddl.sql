-- Engine: PostgreSQL 16
-- Component: 5.3 — Base de Datos de Reservas
-- Source: docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md

-- Entidades documentadas: salas, reservas, registro de auditoría de cancelaciones, claves de idempotencia.
-- Ninguna tiene columnas documentadas; no se genera ningún CREATE TABLE.

-- TODO: [NOT DOCUMENTED — columns of salas (42 salas de 3 sedes, con capacidad y equipamiento): add to docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- TODO: [NOT DOCUMENTED — columns of reservas (estado, incluidas las cancelaciones): add to docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- TODO: [NOT DOCUMENTED — columns of registro de auditoría de cancelaciones: add to docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
-- TODO: [NOT DOCUMENTED — columns of claves de idempotencia: add to docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]

-- Restricción de exclusión (ADR-102): rechaza dos reservas confirmadas superpuestas de la misma sala.
-- TODO: [NOT DOCUMENTED — columnas, tipo de rango y condición de estado confirmado de la restricción de exclusión: add to docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md]
