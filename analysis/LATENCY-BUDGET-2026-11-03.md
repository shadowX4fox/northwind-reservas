# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los tres flujos de usuario tienen SLO p95 de extremo a extremo documentado: 1 s para consultar disponibilidad y 2 s para reservar y cancelar (docs/08 § 10.3). Ningún salto tiene p95 documentado, de modo que los 10 saltos de los tres flujos quedan como Untracked.

No se puede clasificar ningún salto como Over Budget ni calcular un total por flujo sin inventar valores. No hay p99 documentado, por lo que tampoco hay puntos calientes de latencia de cola.

Prioridad máxima: documentar el p95 por salto de I-02 y I-04, que componen los tres flujos, y medir el p99 de las operaciones.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: 1000 ms

Presupuesto proporcional por defecto: 1000 ms ÷ 4 saltos = 250 ms por salto (supuesto del spec; docs/04 no define presupuestos por salto). Ningún salto tiene p95 documentado.

Consultar disponibilidad (SLO: 1000ms)
|──────────────────────────────────────────────────| 1000ms

Portal -> Servicio (I-02)   [Not documented]
JWKS Identidad (I-03)       [Not documented]
Caché Caffeine              [Not documented]
BD Reservas (I-04)          [Not documented]
──────────────────────────────────────────────────
TOTAL                       Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Caché Caffeine del Servicio de Reservas | cache | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Reservar una sala — SLO: 2000 ms

Presupuesto proporcional por defecto: 2000 ms ÷ 3 saltos ≈ 667 ms por salto (supuesto del spec). Ningún salto tiene p95 documentado.

Reservar una sala (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal -> Servicio (I-02)   [Not documented]
JWKS Identidad (I-03)       [Not documented]
BD Reservas (I-04)          [Not documented]
──────────────────────────────────────────────────
TOTAL                       Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Cancelar una reserva — SLO: 2000 ms

Presupuesto proporcional por defecto: 2000 ms ÷ 3 saltos ≈ 667 ms por salto (supuesto del spec). Ningún salto tiene p95 documentado.

Cancelar una reserva (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal -> Servicio (I-02)   [Not documented]
JWKS Identidad (I-03)       [Not documented]
BD Reservas (I-04)          [Not documented]
──────────────────────────────────────────────────
TOTAL                       Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO de extremo a extremo está definido (1 s consulta, 2 s reserva y cancelación), pero el desglose por salto no existe en docs/04 ni en docs/08. Sin p95 por salto ni p99, no hay saltos fuera de presupuesto demostrables ni puntos calientes de cola, y el cumplimiento del SLO no es verificable. Mínimo de remediación: documentar el p95 de I-02, I-03 y I-04 y del acierto de caché, y registrar el p99 de las cuatro operaciones.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Portal de Reservas → Servicio de Reservas (I-02) — p95 del salto (docs/04-data-flow-patterns.md § Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Base de Datos de Reservas (I-04) — p95 de consulta y escritura (docs/04-data-flow-patterns.md § Presupuesto de latencia; docs/08 § 10.3)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) — p95 de la carga de claves JWKS (docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — p95 de acierto y tasa de aciertos (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` Fases 1 a 5 del catálogo de fases — Latency budget (p95) por fase (docs/04-data-flow-patterns.md § Catálogo de fases)
- [ ] `[NOT DOCUMENTED]` Metas de rendimiento p50 y p99 — p50 y p99 de consulta, reserva y cancelación; sin ellos no se evalúa la cola (docs/08-scalability-and-performance.md § 10.3)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
