---
status: Open
date: 2026-11-03
related-adrs: [ADR-002]
affected-components: ["Servidor de Identidad Northwind"]
tags: [G2-03, data-sensitivity, cifrado-en-reposo, retencion, TOTP]
driver: Process
---

# TDR-005: El almacén de cuentas del Servidor de Identidad Northwind no documenta cifrado en reposo ni retención

## Status

`Open`

**Initiative**: Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión (architecture v1.10.5)
**Driver**: Process — control de la plataforma sin documentar

## Description

El `Servidor de Identidad Northwind` (Keycloak 25) guarda nombre, correo, credenciales y secretos TOTP de 1.850 miembros y 6 recepcionistas (S1). La arquitectura no documenta cómo se cifran en reposo ni cuánto se conservan las cuentas dadas de baja. Lo registra Data Sensitivity G2-03; se aceptó en el PR #134.

## Impact

Confidencialidad. Una copia del almacén o de sus respaldos expondría credenciales y semillas TOTP, y el segundo factor dejaría de proteger. Sin plazo de retención, las cuentas dadas de baja pueden conservarse más allá de los 24 meses de [ADR-106](../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md).

## Possible Solutions

- Option A: documentar en docs/07 § 9.3 el cifrado en reposo que ya aplica Plataforma Northwind y su plazo de retención de cuentas.
- Option B: si no existe, cifrado de volumen o TDE con llaves gestionadas, y purga de las cuentas dadas de baja.

## Owner

- **Technical**: Plataforma Northwind
- **Business (P&L)**: Dirección de Operaciones

---

## History

- 2026-11-03: Created. Status: `Open`. Data Sensitivity G2-03, aceptado en https://github.com/shadowX4fox/northwind-reservas/pull/134.
