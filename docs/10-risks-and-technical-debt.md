# Riesgos y Deuda Técnica

<!-- EXPLORER_HEADER
key_concepts: riesgos, deuda técnica, TDR, adopción del portal, piloto sede Centro, carga inicial de salas, anticipación de reservas
technologies: Keycloak
scope: Riesgos conocidos y resumen de deuda técnica aceptada; los TDR completos viven en tdr/
related_adrs: ADR-002
-->

> Riesgos de la arquitectura de Reservas de Salas Northwind y resumen de la deuda técnica aceptada. Los registros completos de deuda viven en `tdr/`; esta sección solo los resume y enlaza.

## 13. Riesgos y Deuda Técnica <!-- SECTION: Risks and Technical Debt -->

Los registros de deuda técnica (TDR) completos están en [`/tdr/`](../tdr/); esta sección es la vista resumen.

### 13.1 Riesgos <!-- LABEL: Risks -->

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Baja adopción del portal en la sede Puerto, con miembros de mayor edad | Medium | Medium | Sesión de acompañamiento en recepción la primera semana (PO Spec, Apéndice, Riesgos) |
| Retraso de la Fase 2 más allá de la renovación de membresías del 2027-02-01 | Low | High | Piloto en la sede Centro el 2027-01-11 y las 3 sedes el 2027-01-25 |
| Carga inicial incompleta de las 42 salas desde la hoja de cálculo de recepción | Medium | Medium | Carga única y verificada antes del piloto (PO Spec, Apéndice, Supuestos) |
| Cuentas de miembros o recepcionistas ausentes en el Proveedor de Identidad Northwind | Low | High | Verificar las 1.856 cuentas antes del piloto; autenticación según ADR-002 |
| Límite de anticipación de reservas sin definir (¿más de 30 días?) | Medium | Low | Pregunta abierta a Dirección de Operaciones, respuesta prevista el 2026-11-15 |

### 13.2 Deuda Técnica <!-- LABEL: Technical Debt -->

Ítems de deuda técnica abiertos. Los registros completos están en [`/tdr/`](../tdr/).

| ID | Title | Status | Owner |
|----|-------|--------|-------|
| [TDR-001](../tdr/TDR-001-la-consulta-de-disponibilidad-se-sirve-de-una-cache-de-5-min.md) | La consulta de disponibilidad se sirve de una caché de 5 minutos | Open | Equipo del Servicio de Reservas |

### Convenciones <!-- LABEL: Conventions -->

- Los TDR se crean con el flujo del skill `technical-debt-records`.
- Los ids son globales, con ceros a la izquierda (`TDR-NNN`), y nunca se reutilizan.
- Valores de estado: `Open`, `Planned`, `In Progress`, `Resolved`, `Won't Fix` — exactamente uno por registro.
- Un TDR en `Resolved` o `Won't Fix` permanece en `/tdr/` por trazabilidad y sale de esta tabla resumen.
