# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los 3 flujos de usuario tienen SLO p95 de extremo a extremo (≤ 1 s consulta, ≤ 2 s reserva y cancelación; docs/08 § 10.3), pero ningún salto tiene p95 documentado. Los 12 saltos quedan Untracked.

No se puede clasificar ningún salto como Over Budget ni calcular tasa de consumo del SLO. No hay p99 documentado, por lo que no hay puntos calientes de cola. La prioridad es documentar p95 por salto en docs/04 y en los componentes Servicio de Reservas, Base de Datos de Reservas y Servidor de Identidad Northwind.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: ≤ 1 s p95

Fases 1, 2 y 3 síncronas; el salto a Servidor de Identidad Northwind (JWKS) queda fuera del camino crítico salvo carga de claves. Presupuesto por salto no documentado (docs/04 § Presupuesto de latencia); la participación proporcional por defecto no es calculable sin p95 por salto.

Consultar disponibilidad (SLO: ≤ 1 s p95)
|──────────────────────────────────────────────────| ≤ 1 s p95

Portal de Reservas                 [?????????????????????????????????????]  p95 Not documented
Servicio de Reservas               [?????????????????????????????????????]  p95 Not documented
Servidor de Identidad Northwind    [?????????????????????????????????????]  p95 Not documented
Base de Datos de Reservas          [?????????????????????????????????????]  p95 Not documented
─────────────────────────────────────────────────
TOTAL  Not documented (sin base para sumar)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | gateway | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Sin determinar: ningún salto tiene p95 |

#### Flow: Reservar una sala — SLO: ≤ 2 s p95

Fases 2 y 4 síncronas; escritura con restricción de exclusión en Base de Datos de Reservas. Presupuesto por salto no documentado (docs/04 § Presupuesto de latencia); la participación proporcional por defecto no es calculable sin p95 por salto.

Reservar una sala (SLO: ≤ 2 s p95)
|──────────────────────────────────────────────────| ≤ 2 s p95

Portal de Reservas                 [?????????????????????????????????????]  p95 Not documented
Servicio de Reservas               [?????????????????????????????????????]  p95 Not documented
Servidor de Identidad Northwind    [?????????????????????????????????????]  p95 Not documented
Base de Datos de Reservas          [?????????????????????????????????????]  p95 Not documented
─────────────────────────────────────────────────
TOTAL  Not documented (sin base para sumar)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | gateway | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Sin determinar: ningún salto tiene p95 |

#### Flow: Cancelar una reserva — SLO: ≤ 2 s p95

Fases 2 y 5 síncronas. Presupuesto por salto no documentado (docs/04 § Presupuesto de latencia); la participación proporcional por defecto no es calculable sin p95 por salto.

Cancelar una reserva (SLO: ≤ 2 s p95)
|──────────────────────────────────────────────────| ≤ 2 s p95

Portal de Reservas                 [?????????????????????????????????????]  p95 Not documented
Servicio de Reservas               [?????????????????????????????????????]  p95 Not documented
Servidor de Identidad Northwind    [?????????????????????????????????????]  p95 Not documented
Base de Datos de Reservas          [?????????????????????????????????????]  p95 Not documented
─────────────────────────────────────────────────
TOTAL  Not documented (sin base para sumar)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | gateway | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Sin determinar: ningún salto tiene p95 |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO está definido pero no descompuesto: sin p95 por salto, el presupuesto no es verificable. El riesgo dominante es la falta de datos, no un salto medido fuera de presupuesto. Mínimo: documentar p95 de Portal de Reservas → Servicio de Reservas (I-02), Servicio de Reservas → Base de Datos de Reservas (I-04) y la validación JWKS (I-03), más p99.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Presupuesto p95 por salto, 3 flujos (I-02, I-04) — Los saltos Portal de Reservas → Servicio de Reservas y Servicio de Reservas → Base de Datos de Reservas figuran Not documented (docs/04-data-flow-patterns.md § Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` Latencia de Servidor de Identidad Northwind (I-01, I-03) — p95 de login y de carga JWKS (docs/05-integration-points.md y docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de operaciones — Columnas p50 y p99 Not documented en las 4 operaciones (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine (ADR-109) — Latencia de acierto y tasa de aciertos de la caché en la consulta de disponibilidad (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` Demanda (TPS) de FLOW-1, FLOW-2, FLOW-3 — Carga medida para dimensionar la latencia bajo carga (docs/08-scalability-and-performance.md § 10.2)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`
