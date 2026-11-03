# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El análisis detecta 3 hallazgos: 2 B2 (`Servidor de Identidad Northwind` y `Base de Datos de Reservas`) y 1 B3 (`Servicio de Reservas`). Ningún componente llega a B1 ni a B4: el mayor fan-in documentado es 2.

El hallazgo principal es `Base de Datos de Reservas`, único camino de datos de los 3 flujos (I-04). Es con estado, el tamaño del pool JDBC no está documentado y cada réplica añade una conexión `LISTEN` fuera del pool (ADR-109).

La holgura no es calculable: docs/08 §10.2 y §10.3 declaran TPS, máximo de réplicas y capacidad de la base como Not documented. El modelo de carga marca los 4 componentes como idle por falta de demanda. La prioridad es medir la demanda por caso de uso y fijar pool y máximo de réplicas.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Keycloak 25 recibe el inicio de sesión del Portal de Reservas (I-01) y el JWKS del Servicio de Reservas (I-03); sin capacidad ni límite de tasa documentados. Sin claves en caché se rechaza toda solicitud (docs/05 § I-03). | ADR-002 |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | No aplica (con estado); réplicas [NOT DOCUMENTED] | 1 (I-04) | Único camino de datos de los 3 flujos (I-04). Pool JDBC no documentado (docs/08 § 10.4) y cada réplica del Servicio de Reservas abre una conexión LISTEN fuera del pool; sin réplicas de lectura documentadas. | ADR-003, ADR-109 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala por HPA de CPU desde 2 réplicas, pero el máximo de réplicas es Not documented y la base de datos aguas abajo limita el caudal efectivo (docs/08 § 10.1). | 1 (I-02) | Documentar máximo de réplicas y tamaño del pool JDBC por réplica, de modo que réplicas × pool no supere las conexiones de la base. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (estáticos en CDN, ADR-107) | [NOT DOCUMENTED] | Adequate |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (mínimo 2 réplicas, máximo no documentado) | [NOT DOCUMENTED] | B3 |
| 3 | Base de Datos de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | B2 |
| 4 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | B2 |

### 2.4 Holgura de Capacidad por Componente <!-- SECTION: Capacity Headroom -->

```
Capacity Headroom by Component (estimated)
══════════════════════════════════════════
Portal de Reservas               [NOT DOCUMENTED]
Servicio de Reservas             [NOT DOCUMENTED]
Base de Datos de Reservas        [NOT DOCUMENTED]
Servidor de Identidad Northwind  [NOT DOCUMENTED]
```

### 2.5 Cuellos de Botella Introducidos por ADR <!-- SECTION: ADR-Driven Bottlenecks -->

| # | ADR | Decision | Bottleneck Introduced | Current Risk |
|---|---|---|---|---|
| 1 | ADR-109 | Invalidar la caché Caffeine con LISTEN/NOTIFY (reemplaza ADR-108) | Cada réplica mantiene una conexión LISTEN fuera del pool; el consumo de conexiones crece con las réplicas. Caché por proceso con tamaño máximo Not documented. | Medio: sin máximo de réplicas ni límite de conexiones documentados no se puede acotar (docs/05 § I-04, docs/08 § 10.4). |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Dimensionar y documentar el pool JDBC y las conexiones LISTEN (B2-02)**
Fijar maxConnections por réplica en el pool y reservar conexiones para LISTEN (1 por réplica). Verificar réplicas máximas × (pool + 1) contra el límite de conexiones de PostgreSQL 16. Riesgo reducido: agotamiento de conexiones (T12-D); costo: tope explícito al escalado.
_Fuente: docs/08-scalability-and-performance.md § 10.4; docs/05-integration-points.md § I-04_

**2. Fijar el máximo de réplicas del HPA (B3-01)**
Declarar el máximo de réplicas del Servicio de Reservas y las solicitudes/límites de CPU y memoria, coherentes con la capacidad de la base. Compromiso: un tope protege la base pero limita el pico.
_Fuente: docs/08-scalability-and-performance.md § 10.1_

**3. Documentar capacidad y límite de tasa de Keycloak 25 (B2-01)**
Obtener de Plataforma Northwind el caudal de inicio de sesión soportado y el límite de tasa, y confirmar la vigencia de la caché JWKS del Servicio de Reservas para que una caída no rechace todo.
_Fuente: docs/05-integration-points.md § I-03; adr/ADR-002_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura escala el Servicio de Reservas sin estado con HPA desde 2 réplicas y absorbe lecturas con Caffeine invalidada por LISTEN/NOTIFY. El riesgo dominante es la falta de cifras: TPS, pool, máximo de réplicas y capacidad de la base y de Keycloak son Not documented, de modo que la holgura no se puede calcular. El conjunto mínimo es medir la demanda por caso de uso, fijar el pool y el máximo de réplicas, y documentar la capacidad del proveedor de identidad.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda por caso de uso (FLOW-1, FLOW-2, FLOW-3) — RPS promedio y pico, factor de pico (docs/08-scalability-and-performance.md § 10.2; docs/01-system-overview.md (TPS))
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU/memoria, capacidad por réplica (docs/08-scalability-and-performance.md § 10.1; docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Tamaño del pool JDBC, máximo de conexiones, réplicas de lectura, capacidad dimensionada (docs/08-scalability-and-performance.md § 10.1 y § 10.4; docs/06-technology-stack.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, límite de tasa y réplicas de Keycloak 25 (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`
