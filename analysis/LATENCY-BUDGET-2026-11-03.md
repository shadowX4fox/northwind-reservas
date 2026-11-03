# Análisis de Presupuesto de Latencia — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

La documentación fija tres SLO de extremo a extremo (consulta ≤ 1 s, reserva ≤ 2 s, cancelación ≤ 2 s, p95; docs/08 § 10.3), pero ningún salto tiene p95 documentado. Los 3 flujos quedan con todos sus saltos en estado Untracked.

No se puede clasificar ningún salto como Over Budget ni sumar un p95 por flujo sin inventar valores. Hay 0 saltos fuera de presupuesto y 0 puntos calientes de cola: p99 es Not documented en todas las operaciones.

Prioridad: documentar el p95 de los saltos Portal de Reservas → Servicio de Reservas, Servicio de Reservas → Base de Datos de Reservas y la validación JWKS contra Servidor de Identidad Northwind (docs/04 § Presupuesto de latencia, con TODO abiertos).

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Desglose de Presupuesto por Flujo <!-- SECTION: Per-Flow Budget Breakdown -->

#### Flow: Consultar disponibilidad — SLO: 1000 ms

Presupuesto por salto Not documented (docs/04 § Presupuesto de latencia). Sin reparto proporcional ni suma posible. Fases 1, 2 y 3 (docs/04 Flujo 1); la caché Caffeine del Servicio de Reservas (ADR-109) evita la consulta a la base con entrada vigente.

Consultar disponibilidad (SLO: 1000ms)
|──────────────────────────────────────────────────| 1000ms

Portal -> Identidad (login) [?]  Not documented
Portal -> Servicio           [?]  Not documented
Servicio -> Identidad (JWKS) [?]  Not documented
Servicio -> caché Caffeine   [?]  Not documented
Caché -> Base de Datos       [?]  Not documented
─────────────────────────────────────────────────
TOTAL                             Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servidor de Identidad Northwind (I-01) | external-API | Not documented | Not documented | Untracked |
| 2 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 4 | Servicio de Reservas → caché Caffeine | cache | Not documented | Not documented | Untracked |
| 5 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not evaluable |

#### Flow: Reservar una sala — SLO: 2000 ms

Presupuesto por salto Not documented. Fases 2 y 4 (docs/04 Flujo 2); única escritura, con clave de idempotencia (ADR-103) y restricción de exclusión (ADR-102).

Reservar una sala (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal -> Servicio           [?]  Not documented
Servicio -> Identidad (JWKS) [?]  Not documented
Servicio -> Base de Datos    [?]  Not documented
─────────────────────────────────────────────────
TOTAL                             Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not evaluable |

#### Flow: Cancelar una reserva — SLO: 2000 ms

Presupuesto por salto Not documented. Fases 2 y 5 (docs/04 Flujo 3); la autorización usa el rol `recepcion` y el atributo `sede` del token.

Cancelar una reserva (SLO: 2000ms)
|──────────────────────────────────────────────────| 2000ms

Portal -> Servicio           [?]  Not documented
Servicio -> Identidad (JWKS) [?]  Not documented
Servicio -> Base de Datos    [?]  Not documented
─────────────────────────────────────────────────
TOTAL                             Not documented

| Hop # | Component | Role | p95 (ms) | % of SLO | Status |
|---|---|---|---|---|---|
| 1 | Portal de Reservas → Servicio de Reservas (I-02) | service | Not documented | Not documented | Untracked |
| 2 | Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) | external-API | Not documented | Not documented | Untracked |
| 3 | Servicio de Reservas → Base de Datos de Reservas (I-04) | database | Not documented | Not documented | Untracked |
| TOTAL | — | — | Not documented | Not documented | Not evaluable |

### 2.2 Saltos Fuera de Presupuesto <!-- SECTION: Hops Over Budget -->

_Sin hallazgos en esta corrida._

## 3. Top 5 Recomendaciones de Latencia <!-- SECTION: Top 5 Remediation Recommendations -->

---

## 4. Veredicto Resumido <!-- SECTION: Summary Verdict -->

El presupuesto de latencia no es verificable: los 3 SLO de extremo a extremo existen (1 s y 2 s p95), pero ningún salto ni percentil p99 está documentado, por lo que no hay saltos fuera de presupuesto ni puntos calientes de cola que reportar. El riesgo dominante es la falta de desglose. El conjunto mínimo de remediación es documentar el p95 de I-02, I-03 (JWKS) e I-04 y el p99 de las 3 operaciones.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` p95 Portal de Reservas → Servicio de Reservas (I-02) — Presupuesto de latencia del salto (docs/04-data-flow-patterns.md § Presupuesto de latencia)
- [ ] `[NOT DOCUMENTED]` p95 Servicio de Reservas → Base de Datos de Reservas (I-04) — Presupuesto de latencia del salto y de las consultas (docs/04-data-flow-patterns.md § Presupuesto de latencia; docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` p95 Servicio de Reservas → Servidor de Identidad Northwind (I-03, JWKS) y Portal de Reservas → Servidor de Identidad Northwind (I-01) — p95 de la validación de token y del inicio de sesión (la fila de JWKS solo dice fuera del camino crítico) (docs/04-data-flow-patterns.md § Fases 1 y 2; docs/05-integration-points.md § 7)
- [ ] `[NOT DOCUMENTED]` p95 de la caché Caffeine del Servicio de Reservas — Latencia con acierto y sin acierto de caché; tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)
- [ ] `[NOT DOCUMENTED]` p50 y p99 de consulta, reserva y cancelación — Percentiles p50 y p99; sin p99 no se calcula la razón p99/p95 (docs/08-scalability-and-performance.md § 10.3)
- [ ] `[NOT DOCUMENTED]` Demanda por caso de uso (FLOW-1, FLOW-2, FLOW-3) — rps y factor de pico; no se puede modelar la latencia bajo carga (docs/08-scalability-and-performance.md § 10.2)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/04-data-flow-patterns.md`, `docs/05-integration-points.md`, `docs/08-scalability-and-performance.md`
