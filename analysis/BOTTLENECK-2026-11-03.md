# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El corpus no documenta ninguna cifra de capacidad: TPS, máximo de réplicas, tamaño del pool JDBC y límites de CPU y memoria figuran como Not documented en docs/08 § 10.1–10.4. El modelo de carga no calcula ρ para ningún componente, por lo que no hay holgura medible ni cuello confirmado.

Hallazgo de mayor severidad: B2-02, `Base de Datos de Reservas`. Cada réplica del `Servicio de Reservas` abre su propio pool JDBC más una conexión `LISTEN` fuera del pool (ADR-109), con máximo de réplicas y tamaño de pool sin documentar. El total de conexiones no tiene techo conocido.

Total: 2 B2, 1 B3, 0 B1, 0 B4. Ningún componente recibe tráfico de 3 o más llamadores (fan-in máximo 2). Prioridad: documentar máximo de réplicas, tamaño de pool y TPS pico, y fijar límites de tasa para `Servidor de Identidad Northwind`.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Dependencia externa (Keycloak 25) de inicio de sesión y validación JWKS sin límite de tasa ni capacidad documentados; sin Capacity table. T5-D ya registra la inundación del login. | ADR-002 · docs/05 § 7 (I-01, I-03) |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED]; pool JDBC por réplica sin tamaño documentado | No aplica (PostgreSQL 16 gestionado); réplicas Not documented | 1 (I-04) | Conexiones totales = réplicas × pool + una conexión `LISTEN` por réplica fuera del pool; máximo de réplicas y tamaño de pool sin documentar, por lo que el agotamiento no se puede descartar. Réplicas de lectura Not documented. | ADR-003 · ADR-109 · docs/08 § 10.4 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala por HPA de CPU (mínimo 2, máximo Not documented), pero cada réplica nueva suma conexiones a `Base de Datos de Reservas`, cuya capacidad no está documentada; la caché Caffeine es por réplica y arranca vacía. | 1 (I-02) | Documentar el máximo de réplicas y acotarlo según las conexiones que admite la base; fijar el tamaño del pool por réplica. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (estático en CDN) | [NOT DOCUMENTED] | Adequate |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (HPA mínimo 2, máximo Not documented) | [NOT DOCUMENTED] | B3 |
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
| 1 | ADR-109 (reemplaza a ADR-108) | Caché en proceso Caffeine con invalidación por `LISTEN/NOTIFY`, sin caché distribuida | Una conexión `LISTEN` por réplica fuera del pool consume conexiones de `Base de Datos de Reservas`; cada réplica nueva arranca con caché vacía y lee de la base. | Medio: el número de réplicas y el límite de conexiones de la base no están documentados (ver B2-02). |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Documentar y acotar el presupuesto de conexiones a la base (B2-02)**
Fijar el tamaño del pool JDBC por réplica y el máximo de réplicas del HPA, y verificar que réplicas × pool + conexiones `LISTEN` queden bajo el límite de conexiones de PostgreSQL 16. Se acepta un techo de escalado a cambio de evitar el agotamiento de la base.
_Fuente: docs/08-scalability-and-performance.md § 10.4; docs/05-integration-points.md § 7 (I-04)_

**2. Declarar el máximo de réplicas del Servicio de Reservas (B3-01)**
Documentar el máximo del HPA por CPU y las solicitudes y límites de CPU y memoria. Alinear el máximo con la capacidad de conexiones de la base para que el escalado no traslade el cuello a `Base de Datos de Reservas`.
_Fuente: docs/08-scalability-and-performance.md § 10.1_

**3. Documentar capacidad y límite de tasa del proveedor de identidad (B2-01)**
Obtener de Plataforma Northwind la capacidad de Keycloak 25 y su límite de tasa, y confirmar el TTL de la caché JWKS en el `Servicio de Reservas` para que I-03 no dependa del proveedor en cada solicitud.
_Fuente: docs/05-integration-points.md § 7 (I-01, I-03); adr/ADR-002_

**4. Medir la demanda por caso de uso (B2-02)**
Registrar TPS promedio y pico de FLOW-1, FLOW-2 y FLOW-3 en docs/08 § 10.2 para que el modelo de carga calcule ρ y puntos de ruptura. Sin demanda, el análisis de holgura no produce cifras.
_Fuente: docs/08-scalability-and-performance.md § 10.2_

**5. Fijar el tamaño máximo de la caché Caffeine (B3-01)**
Documentar el tamaño máximo de la caché por réplica (hoy Not documented) para acotar la memoria y la carga sobre la base cuando la caché arranca vacía tras un escalado.
_Fuente: docs/08-scalability-and-performance.md § 10.4; adr/ADR-109_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura es sencilla y sin estado en el servicio, con CDN para el portal y mínimo de 2 réplicas, y ningún componente tiene fan-in de 3 o más. El riesgo dominante es la ausencia de cifras de capacidad: sin máximo de réplicas, pool JDBC, límites del proveedor de identidad ni TPS, no se puede descartar el agotamiento de conexiones de la base (B2-02) ni el límite del proveedor de identidad (B2-01). El mínimo de remediación es documentar esos cuatro valores y medir la demanda.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU y memoria (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, límite de conexiones, réplicas de lectura y tamaño del pool JDBC (docs/08-scalability-and-performance.md § 10.1 y § 10.4; docs/06-technology-stack.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, límite de tasa y tabla Capacity (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Portal de Reservas — Límites del CDN (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` FLOW-1, FLOW-2, FLOW-3 — TPS promedio y pico, factor de pico (docs/08-scalability-and-performance.md § 10.2 y docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine del Servicio de Reservas — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`, `adr/ADR-002`, `adr/ADR-003`, `adr/ADR-109`
