# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los tres flujos tienen SLO de punta a punta documentado: consulta ≤ 1 s p95, reserva y cancelación ≤ 2 s p95 (docs/08 § 10.3, PO Spec §8).

Ningún salto tiene p95 documentado: la tabla Presupuesto de latencia de docs/04 marca Not documented en I-02 e I-04, y las 5 fases no declaran presupuesto. Los 5 saltos distintos quedan Untracked; no se estima ni se reparte el SLO.

Sin p95 ni p99 por salto no hay saltos Over Budget ni puntos calientes de cola. La prioridad es instrumentar y documentar el p95 de I-02, I-03 e I-04 con las métricas RED de ADR-004.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: ≤ 1 s p95

El SLO de punta a punta está documentado en docs/08 § 10.3; ningún salto tiene p95 en docs/04 (Presupuesto de latencia) ni en docs/05. Todos los saltos son Untracked y el total no se calcula.

Consultar disponibilidad (SLO: ≤ 1 s p95)
|──────────────────────────────────────────────────| ≤ 1 s p95

Salto 1 Portal de Reservas → Servidor de Identid [sin p95 documentado]
Salto 2 Portal de Reservas → Servicio de Reserva [sin p95 documentado]
Salto 3 Servicio de Reservas → Servidor de Ident [sin p95 documentado]
Salto 4 Servicio de Reservas (caché Caffeine)    [sin p95 documentado]
Salto 5 Base de Datos de Reservas (I-04)         [sin p95 documentado]
─────────────────────────────────────────────────
TOTAL  Not documented (ningún salto tiene p95; no se suma)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servidor de Identidad Northwind (I-01, inicio de sesión) | external-API | Not documented | Not documented | Untracked |
| 2 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 4 | Servicio de Reservas (caché Caffeine) | cache | Not documented | Not documented | Untracked |
| 5 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

#### Flow: Reservar una sala — SLO: ≤ 2 s p95

El SLO de punta a punta está documentado en docs/08 § 10.3; ningún salto tiene p95 en docs/04 (Presupuesto de latencia) ni en docs/05. Todos los saltos son Untracked y el total no se calcula.

Reservar una sala (SLO: ≤ 2 s p95)
|──────────────────────────────────────────────────| ≤ 2 s p95

Salto 1 Portal de Reservas → Servicio de Reserva [sin p95 documentado]
Salto 2 Servicio de Reservas → Servidor de Ident [sin p95 documentado]
Salto 3 Base de Datos de Reservas (I-04)         [sin p95 documentado]
─────────────────────────────────────────────────
TOTAL  Not documented (ningún salto tiene p95; no se suma)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

#### Flow: Cancelar una reserva — SLO: ≤ 2 s p95

El SLO de punta a punta está documentado en docs/08 § 10.3; ningún salto tiene p95 en docs/04 (Presupuesto de latencia) ni en docs/05. Todos los saltos son Untracked y el total no se calcula.

Cancelar una reserva (SLO: ≤ 2 s p95)
|──────────────────────────────────────────────────| ≤ 2 s p95

Salto 1 Portal de Reservas → Servicio de Reserva [sin p95 documentado]
Salto 2 Servicio de Reservas → Servidor de Ident [sin p95 documentado]
Salto 3 Base de Datos de Reservas (I-04)         [sin p95 documentado]
─────────────────────────────────────────────────
TOTAL  Not documented (ningún salto tiene p95; no se suma)

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented (sin p95 por salto) |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO por flujo existe, pero el presupuesto por salto no: no se puede afirmar que algún flujo cumpla ni incumpla. No hay saltos fuera de presupuesto demostrables. El conjunto mínimo es documentar el p95 por salto (I-02, I-03, I-04, caché Caffeine) y el p99 de las operaciones.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` p95 de Portal de Reservas → Servicio de Reservas (I-02) — Presupuesto de latencia por salto (docs/04-data-flow-patterns.md, Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` p95 de Servicio de Reservas → Base de Datos de Reservas (I-04) y de la caché Caffeine — p95 de consulta y de acierto de caché (docs/04 Presupuesto de latencia; docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` p95 de I-01 e I-03 (Servidor de Identidad Northwind) — Latencia de inicio de sesión y validación JWKS (docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` Presupuesto de las fases 1 a 5 — Latency budget (p95) por fase (docs/04-data-flow-patterns.md, Catálogo de Fases)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de las cuatro operaciones — Percentiles p50/p99 para el análisis de cola (docs/08-scalability-and-performance.md § 10.3)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
