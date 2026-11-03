# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El corpus no documenta ninguna cifra de capacidad: la demanda de FLOW-1, FLOW-2 y FLOW-3 es Not documented, el máximo de réplicas del Servicio de Reservas, el tamaño del pool JDBC y la capacidad de la Base de Datos de Reservas tampoco. El modelo de carga marca los cuatro componentes como idle; ningún ρ es calculable.

Hallazgo de mayor severidad: B2-02, la Base de Datos de Reservas. Es la única ruta de persistencia de los tres flujos (I-04), sin réplicas de lectura documentadas, con pool sin tamaño y con una conexión LISTEN por réplica fuera del pool (ADR-109). Hay 2 hallazgos B2, 1 B3 y 0 B4: ningún componente recibe tráfico de 3 o más llamantes (el mayor fan-in es 2).

Prioridad de remediación: documentar el pool JDBC, el máximo de réplicas del HPA y la capacidad de la base, y medir la demanda en TPS antes de dimensionar.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (Portal de Reservas I-01, Servicio de Reservas I-03) | Sistema externo (Keycloak 25) sin capacidad ni límite de tasa documentados; el Servicio de Reservas rechaza todo ante falta de claves JWKS (I-03, deny by default). Fuente: docs/05 § 7, I-03. | ADR-002 |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED]; pool JDBC: Not documented | No aplica (PostgreSQL 16; réplicas Not documented) | 1 (Servicio de Reservas, I-04) | Ruta única de persistencia de los 3 flujos; sin réplicas de lectura documentadas, pool sin tamaño y cada réplica del Servicio de Reservas abre además una conexión LISTEN fuera del pool. Fuente: docs/08 § 10.4, docs/05 § 7 I-04. | ADR-003, ADR-109 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala por HPA de CPU desde 2 réplicas, pero el máximo es Not documented y cada réplica suma conexiones JDBC y una LISTEN hacia una sola Base de Datos de Reservas. Sin límite de tasa documentado en la API pública. Fuente: docs/08 § 10.1. | 1 | Fijar el máximo de réplicas del HPA según el límite de conexiones de la base y documentar un límite de tasa en el ingress. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (archivos estáticos en CDN) | [NOT DOCUMENTED] | Sin evaluar |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (mínimo 2 réplicas, máximo Not documented) | [NOT DOCUMENTED] | B3 |
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
| 1 | ADR-109 | Invalidar la caché Caffeine con LISTEN/NOTIFY; caché en proceso por réplica, sin caché distribuida | Cada réplica mantiene una conexión LISTEN fuera del pool y recarga desde la base tras cada invalidación o a los 5 minutos; el conteo de conexiones crece con las réplicas. | Medio; tamaño máximo de la caché y del pool Not documented (docs/08 § 10.4) |
| 2 | ADR-101 | SPA y un microservicio dueño de su base; todos los flujos síncronos, sin procesamiento asíncrono | Sin cola que amortigüe picos: toda escritura (CU2, CU3) llega síncrona a la Base de Datos de Reservas. | Medio; demanda Not documented |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Documentar y acotar el pool de conexiones y la capacidad de la base (B2-02)**
Registrar el tamaño del pool JDBC, el máximo de conexiones de PostgreSQL 16 y la existencia de réplicas de lectura. Reservar cupo para las conexiones LISTEN de cada réplica. Reduce el riesgo de agotamiento (T11-D) al escalar el HPA.
_Fuente: docs/08-scalability-and-performance.md § 10.4_

**2. Fijar el máximo de réplicas del HPA (B3-01)**
Definir el máximo de réplicas del Servicio de Reservas como (conexiones disponibles) / (pool + 1 LISTEN por réplica). Evita que el escalado por CPU agote la base; se acepta un techo de throughput explícito.
_Fuente: docs/08-scalability-and-performance.md § 10.1_

**3. Documentar capacidad y límite de tasa del Servidor de Identidad Northwind (B2-01)**
Pedir a Plataforma Northwind la capacidad de Keycloak 25 y el límite de tasa de los endpoints de inicio de sesión y JWKS. Confirmar la caché local de claves del Servicio de Reservas como mitigación (I-03).
_Fuente: docs/05-integration-points.md § 7, I-03_

**4. Medir la demanda por caso de uso (B3-01)**
Registrar TPS promedio y pico de FLOW-1, FLOW-2 y FLOW-3 con su factor de pico, para que el modelo de carga calcule ρ y puntos de saturación. Hoy los tres valores son Not documented.
_Fuente: docs/08-scalability-and-performance.md § 10.2_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura es simple y sin estado en el servicio, con 2 réplicas mínimas, caché Caffeine invalidada por LISTEN/NOTIFY y portal en CDN. El riesgo dominante es la ausencia de cifras: sin demanda, pool, máximo de HPA ni capacidad de la base no se puede descartar saturación. El mínimo de remediación es documentar el pool JDBC, el máximo de réplicas, la capacidad de la Base de Datos de Reservas y la demanda en TPS.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda FLOW-1, FLOW-2, FLOW-3 — TPS promedio, pico y factor de pico (docs/08-scalability-and-performance.md § 10.2 y docs/01-system-overview.md § 1)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU y memoria, RPS por réplica (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, máximo de conexiones, tamaño del pool JDBC, réplicas de lectura (docs/08-scalability-and-performance.md § 10.1 y § 10.4; docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Tabla de capacidad, límite de tasa, réplicas (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Portal de Reservas — Límites del CDN (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`
