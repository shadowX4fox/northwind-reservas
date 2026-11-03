# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El SLO de extremo a extremo está documentado: consulta de disponibilidad p95 ≤ 1 s; reserva y cancelación p95 ≤ 2 s (docs/08 § 10.3, PO Spec §8). El desglose por salto no existe: las 5 fases de docs/04 declaran `Not documented` como presupuesto p95.

Sin p95 por salto, ningún salto se clasifica como Within Budget, Tight u Over Budget; los 3 flujos quedan Untracked y no se suma un total. No hay saltos fuera de presupuesto ni puntos calientes de cola: docs/08 § 10.3 no documenta p50 ni p99 de ninguna operación.

La prioridad es medir y documentar el p95 de los saltos I-02, I-03 e I-04 y del acierto de la caché Caffeine. Hasta entonces, el presupuesto del SLO no se puede defender.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: 1000 ms

Fases 1, 2 y 3 (docs/04). Cuota proporcional por defecto: 1000 ms ÷ 5 saltos = 200 ms por salto (supuesto de este análisis; docs/04 no declara presupuesto por salto). Ningún salto tiene p95 documentado.

Consultar disponibilidad (SLO: 1000ms)
|──────────────────────────────────────────────────| 1000ms

Portal → Identidad (I-01)   [?]  Not documented
Portal → Servicio (I-02)    [?]  Not documented
Servicio → Identidad (I-03) [?]  Not documented (JWKS fuera del camino crítico salvo carga de claves)
Servicio → caché Caffeine   [?]  Not documented
Caché → Base de Datos (I-04)[?]  Not documented
─────────────────────────────────────────────────
TOTAL                            Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servidor de Identidad Northwind (I-01) | service | Not documented | Not documented | Untracked |
| 2 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | service | Not documented | Not documented | Untracked |
| 4 | Servicio de Reservas → caché Caffeine | cache | Not documented | Not documented | Untracked |
| 5 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Reservar una sala — SLO: 2000 ms

Fases 2 y 4 (docs/04). Cuota proporcional por defecto: 2000 ms ÷ 3 saltos ≈ 667 ms por salto (supuesto de este análisis). Ningún salto tiene p95 documentado.

Reservar una sala (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal → Servicio (I-02)    [?]  Not documented
Servicio → Identidad (I-03) [?]  Not documented
Servicio → Base de Datos (I-04) [?]  Not documented
─────────────────────────────────────────────────
TOTAL                            Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Cancelar una reserva — SLO: 2000 ms

Fases 2 y 5 (docs/04). Cuota proporcional por defecto: 2000 ms ÷ 3 saltos ≈ 667 ms por salto (supuesto de este análisis). Ningún salto tiene p95 documentado.

Cancelar una reserva (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal → Servicio (I-02)    [?]  Not documented
Servicio → Identidad (I-03) [?]  Not documented
Servicio → Base de Datos (I-04) [?]  Not documented
─────────────────────────────────────────────────
TOTAL                            Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO de extremo a extremo está definido (1 s consulta; 2 s reserva y cancelación) y la arquitectura es síncrona, de 4 integraciones, con caché Caffeine invalidada por LISTEN/NOTIFY (ADR-109). El riesgo dominante es la ausencia total de p95 por salto: los 3 flujos quedan Untracked y no hay hallazgos OB ni TL que rankear. El mínimo de remediación es documentar el p95 y p99 de I-02, I-03, I-04 y de la caché en docs/04 y docs/08, y registrar los valores medidos.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Presupuesto p95 por salto: Portal de Reservas → Servicio de Reservas (I-02) — p95 del salto (docs/04-data-flow-patterns.md, Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` Presupuesto p95 por salto: Servicio de Reservas → Base de Datos de Reservas (I-04) — p95 de la consulta y la escritura (docs/04-data-flow-patterns.md, Presupuesto de latencia; docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Fases 1 a 5 del catálogo de fases — Latency budget (p95) de cada fase (docs/04-data-flow-patterns.md, Phase Catalog)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) y Portal de Reservas → Servidor de Identidad Northwind (I-01) — p95 de la validación de tokens y del inicio de sesión (docs/05-integration-points.md § 7; docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — p95 de acierto, tasa de aciertos objetivo y tamaño máximo (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de consulta, reserva y cancelación — percentiles p50 y p99; sin ellos no se evalúa la cola p99/p95 (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Demanda FLOW-1, FLOW-2 y FLOW-3 — rps y factor de pico (docs/08-scalability-and-performance.md § 10.2)
- [ ] `[NOT DOCUMENTED]` Sobrecarga de red e ingress — latencia del ingress del clúster y del re-cifrado TLS hacia los pods (I-02) (docs/03-architecture-layers.md o docs/09-operational-considerations.md)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`, `docs/09-operational-considerations.md`
