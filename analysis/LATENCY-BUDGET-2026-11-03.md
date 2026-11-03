# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los 3 flujos tienen un SLO p95 de extremo a extremo documentado: consulta de disponibilidad ≤ 1 s, reserva ≤ 2 s y cancelación ≤ 2 s (`docs/08-scalability-and-performance.md` § 10.3). Ningún salto tiene un p95 documentado, de modo que los 3 flujos quedan sin desglose verificable.

Sin valores por salto no se puede clasificar ningún salto como Within Budget, Tight u Over Budget. La tabla de saltos fuera de presupuesto queda vacía y no hay puntos calientes de cola, porque el p99 es `Not documented` en todas las operaciones. La ausencia de hallazgos refleja falta de datos, no cumplimiento.

Prioridad de remediación: documentar el p95 de los saltos Portal de Reservas → Servicio de Reservas (I-02), Servicio de Reservas → Base de Datos de Reservas (I-04) y la consulta con caché Caffeine, además del p99 de cada operación. El presupuesto de `docs/04-data-flow-patterns.md` marca esos saltos como `Not documented`.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: 1000 ms

Presupuesto por salto sin documentar; se omite la cuota proporcional (SLO ÷ saltos) porque ningún salto tiene p95. Fuente del SLO: `docs/08-scalability-and-performance.md` § 10.3.

```
Consultar disponibilidad (SLO: 1000ms)
|──────────────────────────────────────────────────| 1000ms

Portal de Reservas                  [?]  Not documented
Servicio de Reservas                [?]  Not documented
Servidor de Identidad Northwind     [?]  Not documented (JWKS, fuera del camino crítico)
Caché Caffeine                      [?]  Not documented
Base de Datos de Reservas           [?]  Not documented
─────────────────────────────────────────────────
TOTAL                                    Not documented
```

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Caché Caffeine del Servicio de Reservas | cache | Not documented | Not documented | Untracked |
| 5 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Untracked |

#### Flow: Reservar una sala — SLO: 2000 ms

Presupuesto por salto sin documentar; no hay cuota proporcional calculable. Fuente del SLO: `docs/08-scalability-and-performance.md` § 10.3.

```
Reservar una sala (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal de Reservas                  [?]  Not documented
Servicio de Reservas                [?]  Not documented
Servidor de Identidad Northwind     [?]  Not documented (JWKS, fuera del camino crítico)
Base de Datos de Reservas           [?]  Not documented
─────────────────────────────────────────────────
TOTAL                                    Not documented
```

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Untracked |

#### Flow: Cancelar una reserva — SLO: 2000 ms

Presupuesto por salto sin documentar; no hay cuota proporcional calculable. Fuente del SLO: `docs/08-scalability-and-performance.md` § 10.3.

```
Cancelar una reserva (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal de Reservas                  [?]  Not documented
Servicio de Reservas                [?]  Not documented
Servidor de Identidad Northwind     [?]  Not documented (JWKS, fuera del camino crítico)
Base de Datos de Reservas           [?]  Not documented
─────────────────────────────────────────────────
TOTAL                                    Not documented
```

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind | external-API | Not documented | Not documented | Untracked |
| 4 | Base de Datos de Reservas | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Untracked |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El SLO de extremo a extremo existe para los 3 flujos, pero ningún salto tiene p95 y ninguna operación tiene p99, así que el presupuesto no es verificable. No hay saltos fuera de presupuesto ni puntos calientes de cola comprobables. El riesgo dominante es la falta de datos sobre I-02, I-04 y la caché Caffeine; el mínimo de remediación es documentar el p95 por salto y el p99 por operación.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Portal de Reservas → Servicio de Reservas (I-02) — p95 del salto (docs/04-data-flow-patterns.md § Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Base de Datos de Reservas (I-04) — p95 del salto y de las consultas (docs/04-data-flow-patterns.md § Presupuesto de latencia; docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` Fases 1 a 5 del catálogo de fases — Latency budget (p95) de cada fase (docs/04-data-flow-patterns.md § Fases 1-5)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — p95 de acierto y de fallo de caché (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind (I-01, I-03) — p95 del inicio de sesión y de la carga de JWKS (docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de consulta, reserva y cancelación — p99 por operación; impide detectar puntos calientes de cola (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Sobrecarga del ingress y del gateway — latencia del ingress del clúster (docs/03-architecture-layers.md)
- [ ] `[NOT DOCUMENTED]` Demanda (rps) de FLOW-1, FLOW-2 y FLOW-3 — TPS medido (docs/08-scalability-and-performance.md § 10.2)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
