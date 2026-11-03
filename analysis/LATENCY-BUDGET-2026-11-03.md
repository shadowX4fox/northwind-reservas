# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Los tres flujos de usuario tienen SLO p95 de extremo a extremo documentado: 1 s para Consultar disponibilidad, 2 s para Reservar una sala y 2 s para Cancelar una reserva (docs/08 § 10.3, PO Spec §8).

Ningún salto tiene p95 documentado. La tabla Presupuesto de latencia de docs/04 declara `Not documented` para Portal de Reservas → Servicio de Reservas y Servicio de Reservas → Base de Datos de Reservas, y las cinco fases del Catálogo de Fases no declaran presupuesto propio. Los 5, 3 y 3 saltos de los flujos 1, 2 y 3 quedan `Untracked`.

No hay saltos fuera de presupuesto ni puntos calientes de cola: ningún p99 está documentado (docs/08 § 10.3). La suma de saltos y el reparto proporcional no se calculan para no inventar un presupuesto; la brecha dominante es la falta de p95 por salto y de p99.

Prioridad de remediación: medir y documentar el p95 y el p99 de I-02, I-04 y del salto a la caché Caffeine, con las métricas OpenTelemetry que ADR-004 ya prevé.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: 1000 ms

Fases 1, 2 y 3 (síncrono). Sin p95 por salto documentado; no se calcula reparto proporcional. El salto Servicio de Reservas → Servidor de Identidad Northwind (JWKS) queda fuera del camino crítico salvo carga de claves (docs/04, Presupuesto de latencia).

Consultar disponibilidad (SLO: 1000ms)
|──────────────────────────────────────────────────| 1000ms

Portal de Reservas → Servidor de Identidad Northwind   [sin dato]  Not documented
Portal de Reservas → Servicio de Reservas              [sin dato]  Not documented
Servicio de Reservas → Servidor de Identidad (JWKS)    [sin dato]  Not documented
Servicio de Reservas → caché Caffeine                  [sin dato]  Not documented
Caché → Base de Datos de Reservas                      [sin dato]  Not documented
─────────────────────────────────────────────────
TOTAL                                                  Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Servidor de Identidad Northwind (desde Portal de Reservas, I-01) | external-API | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas (desde Portal de Reservas, I-02) | service | Not documented | Not documented | Untracked |
| 3 | Servidor de Identidad Northwind (JWKS desde Servicio de Reservas, I-03) | external-API | Not documented | Not documented | Untracked |
| 4 | Caché Caffeine del Servicio de Reservas | cache | Not documented | Not documented | Untracked |
| 5 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Reservar una sala — SLO: 2000 ms

Fases 2 y 4 (síncrono). Sin p95 por salto documentado; no se calcula reparto proporcional.

Reservar una sala (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal de Reservas → Servicio de Reservas              [sin dato]  Not documented
Servicio de Reservas → Servidor de Identidad (JWKS)    [sin dato]  Not documented
Servicio de Reservas → Base de Datos de Reservas       [sin dato]  Not documented
─────────────────────────────────────────────────
TOTAL                                                  Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Servicio de Reservas (desde Portal de Reservas, I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servidor de Identidad Northwind (JWKS desde Servicio de Reservas, I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

#### Flow: Cancelar una reserva — SLO: 2000 ms

Fases 2 y 5 (síncrono). Sin p95 por salto documentado; no se calcula reparto proporcional.

Cancelar una reserva (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal de Reservas → Servicio de Reservas              [sin dato]  Not documented
Servicio de Reservas → Servidor de Identidad (JWKS)    [sin dato]  Not documented
Servicio de Reservas → Base de Datos de Reservas       [sin dato]  Not documented
─────────────────────────────────────────────────
TOTAL                                                  Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Servicio de Reservas (desde Portal de Reservas, I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servidor de Identidad Northwind (JWKS desde Servicio de Reservas, I-03) | external-API | Not documented | Not documented | Untracked |
| 3 | Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not documented |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

Los SLO de extremo a extremo existen (1 s, 2 s, 2 s), pero el presupuesto por salto no: ningún p95 ni p99 está documentado, así que la conformidad con el SLO no se puede verificar ni refutar. No se detectan saltos fuera de presupuesto ni colas largas porque faltan los datos, no porque el diseño los excluya. El mínimo de remediación es documentar el p95 y el p99 de I-02, I-04 y la caché Caffeine, y el presupuesto de cada fase del catálogo de docs/04.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Portal de Reservas → Servicio de Reservas (I-02) — p95 y p99 del salto (docs/04-data-flow-patterns.md, Presupuesto de latencia; docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Base de Datos de Reservas (I-04) — p95 y p99 de la consulta y de la escritura (docs/04-data-flow-patterns.md, Presupuesto de latencia; docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Portal de Reservas → Servidor de Identidad Northwind (I-01) — p95 del inicio de sesión (Fase 1) (docs/04-data-flow-patterns.md, Fase 1)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas → Servidor de Identidad Northwind, JWKS (I-03) — p95 de la carga de claves JWKS (fuera del camino crítico salvo carga de claves) (docs/04-data-flow-patterns.md, Fase 2; docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — p95 de acierto y de fallo de caché y tasa de aciertos objetivo (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` Fases 1 a 5 del Catálogo de Fases — presupuesto de latencia p95 por fase (docs/04-data-flow-patterns.md, Catálogo de Fases)
- [ ] `[NOT DOCUMENTED]` Operaciones de Metas de Rendimiento — p50 y p99 de consulta, reserva y cancelación (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Demanda por caso de uso (FLOW-1, FLOW-2, FLOW-3) — rps y factor pico; sin ellos no se modela la latencia bajo carga (docs/08-scalability-and-performance.md § 10.2)
- [ ] `[NOT DOCUMENTED]` Sobrecarga de ingress y red — latencia del ingress del clúster y del segundo cifrado TLS hacia los pods (docs/03-architecture-layers.md o docs/09-operational-considerations.md)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
