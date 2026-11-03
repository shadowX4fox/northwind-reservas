# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-02  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los tres flujos de cara al usuario tienen SLO p95 de extremo a extremo documentado: consulta de disponibilidad ≤ 1 s, reserva ≤ 2 s y cancelación ≤ 2 s (docs/08 § 10.3, PO Spec §8).

Ningún salto tiene p95 documentado: los presupuestos por fase de docs/04 y los de Portal de Reservas → Servicio de Reservas y Servicio de Reservas → Base de Datos de Reservas figuran como Not documented. Los 12 saltos de los tres flujos quedan Untracked; no hay base para clasificar saltos Over Budget.

Tampoco hay p99 documentado, así que no se puede evaluar la variación de cola. La prioridad es medir y documentar el p95 y el p99 por salto, empezando por la Base de Datos de Reservas y el endpoint JWKS.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: ≤ 1000 ms

SLO de extremo a extremo: ≤ 1000 ms (docs/08 § 10.3, PO Spec §8). Ningún salto tiene p95 documentado (docs/04 § Presupuesto de latencia, Not documented); la suma y la participación no se calculan.

Consultar disponibilidad (SLO: ≤ 1000 ms)
|──────────────────────────────────────────────────| ≤ 1000 ms

Portal de Reservas → Servidor de Identid [sin p95 documentado]  Untracked
Portal de Reservas → Servicio de Reserva [sin p95 documentado]  Untracked
Servicio de Reservas → Servidor de Ident [sin p95 documentado]  Untracked
Servicio de Reservas → caché Caffeine (A [sin p95 documentado]  Untracked
Servicio de Reservas → Base de Datos de  [sin p95 documentado]  Untracked
─────────────────────────────────────────────────
TOTAL: Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servidor de Identidad Northwind (I-01, inicio de sesión) | external-API | Not documented | Not documented | Untracked |
| 2 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 4 | Servicio de Reservas → caché Caffeine (ADR-109) | cache | Not documented | Not documented | Untracked |
| 5 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

#### Flow: Reservar una sala — SLO: ≤ 2000 ms

SLO de extremo a extremo: ≤ 2000 ms (docs/08 § 10.3, PO Spec §8). Ningún salto tiene p95 documentado (docs/04 § Presupuesto de latencia, Not documented); la suma y la participación no se calculan.

Reservar una sala (SLO: ≤ 2000 ms)
|──────────────────────────────────────────────────| ≤ 2000 ms

Portal de Reservas → Servicio de Reserva [sin p95 documentado]  Untracked
Servicio de Reservas → Servidor de Ident [sin p95 documentado]  Untracked
Servicio de Reservas → Base de Datos de  [sin p95 documentado]  Untracked
─────────────────────────────────────────────────
TOTAL: Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

#### Flow: Cancelar una reserva — SLO: ≤ 2000 ms

SLO de extremo a extremo: ≤ 2000 ms (docs/08 § 10.3, PO Spec §8). Ningún salto tiene p95 documentado (docs/04 § Presupuesto de latencia, Not documented); la suma y la participación no se calculan.

Cancelar una reserva (SLO: ≤ 2000 ms)
|──────────────────────────────────────────────────| ≤ 2000 ms

Portal de Reservas → Servicio de Reserva [sin p95 documentado]  Untracked
Servicio de Reservas → Servidor de Ident [sin p95 documentado]  Untracked
Servicio de Reservas → Base de Datos de  [sin p95 documentado]  Untracked
─────────────────────────────────────────────────
TOTAL: Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO de extremo a extremo está definido, pero el presupuesto por salto no existe: ningún p95 ni p99 por componente ni por integración. No se puede demostrar que los flujos cumplan 1 s y 2 s. El conjunto mínimo es medir con OpenTelemetry (ADR-004) el p95 y el p99 de I-02, I-03 y I-04 y registrarlos en docs/04 y docs/08.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Presupuesto p95 de Portal de Reservas → Servicio de Reservas (I-02) — p95 del salto (docs/04-data-flow-patterns.md § Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` Presupuesto p95 de Servicio de Reservas → Base de Datos de Reservas (I-04) — p95 del salto y de consultas (docs/04-data-flow-patterns.md § Presupuesto de latencia; docs/08 § 10.4)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) e inicio de sesión (I-01) — p95 de validación JWKS y de inicio de sesión (docs/05-integration-points.md; docs/04 Fases 1 y 2)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — p95 de acierto, tasa de aciertos y tamaño máximo (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de todas las operaciones — p50 y p99 (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Presupuestos por fase 1 a 5 — Latency budget (p95) por fase (docs/04-data-flow-patterns.md § Catálogo de fases)
- [ ] `[NOT DOCUMENTED]` Demanda (TPS) por flujo — rps y factor pico (docs/08-scalability-and-performance.md § 10.2)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
