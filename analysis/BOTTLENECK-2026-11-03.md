# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El hallazgo de mayor severidad es B2-01: `Servidor de Identidad Northwind` recibe tráfico de 2 llamadores (I-01, I-03), es externo y no documenta capacidad ni límite de tasa. Un límite no documentado equivale a un riesgo de rechazo duro de todas las solicitudes (deny by default en I-03).

La postura es de capacidad no medida: TPS, pool JDBC, máximo de réplicas y tamaño de caché figuran como Not documented en docs/08. El modelo de carga no calcula ρ para ningún componente porque falta la demanda de FLOW-1, FLOW-2 y FLOW-3.

Hay 2 hallazgos B2 y 1 B3; ninguno B1 ni B4 (el fan-in máximo es 2). `Base de Datos de Reservas` (B2-02) es la única ruta de datos, sin réplicas de lectura documentadas. Prioridad: documentar demanda, pool y límites antes de dimensionar.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Dependencia externa (Keycloak 25) sin capacidad ni límite de tasa documentados; sin claves JWKS el servicio rechaza todo (I-03). Fuente: docs/05 § 7, docs/08 § 10.1. | ADR-002 |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | No aplica (PostgreSQL 16 gestionado); réplicas [NOT DOCUMENTED] | 1 (I-04) | Única ruta de datos de lectura y escritura; el pool JDBC por réplica y las réplicas de lectura no están documentados, y cada réplica del servicio añade conexiones. Fuente: docs/08 § 10.1 y § 10.4. | ADR-003 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala con HPA por CPU (mínimo 2) pero el máximo de réplicas es Not documented y depende de la Base de Datos de Reservas: cada réplica abre su pool JDBC y una conexión LISTEN fuera del pool (ADR-109). Fuente: docs/08 § 10.1, docs/05 § 7. | 1 | Documentar máximo de réplicas y tamaño del pool, y verificar que réplicas × (pool + 1 LISTEN) no supere el límite de conexiones de PostgreSQL. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | Adequate (archivos estáticos en CDN, ADR-107) |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | B3 |
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
| 1 | ADR-109 | Caché Caffeine en proceso por réplica, invalidada con LISTEN/NOTIFY y expiración de 5 minutos | Cada réplica mantiene una conexión LISTEN fuera del pool; tras una invalidación o una expiración, las lecturas vuelven a la Base de Datos de Reservas. Tamaño máximo de caché Not documented. | Medio: sin máximo de réplicas ni límite de conexiones documentados no se puede acotar (docs/08 § 10.4). |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Documentar pool JDBC y réplicas de lectura de la Base de Datos de Reservas (B2-02)**
Fijar maxConnections por réplica del servicio, el límite de conexiones de PostgreSQL 16 y evaluar una réplica de lectura para CU1. Costo: más operación en Plataforma Northwind; reduce el riesgo de agotar conexiones.
_Fuente: docs/08-scalability-and-performance.md § 10.1, § 10.4_

**2. Obtener capacidad y límite de tasa de Keycloak 25 (B2-01)**
Pedir a Plataforma Northwind la capacidad en rps, réplicas y cuota del Servidor de Identidad Northwind, y confirmar el TTL de la caché JWKS en I-03. Reduce el rechazo masivo ante caída o límite.
_Fuente: docs/05-integration-points.md § 7 (I-01, I-03); adr/ADR-002_

**3. Fijar máximo de réplicas del Servicio de Reservas (B3-01)**
Declarar maxReplicas del HPA y verificar réplicas × (pool + 1 LISTEN) contra el límite de conexiones de la base. Acota el escalado sin saturar PostgreSQL.
_Fuente: docs/08-scalability-and-performance.md § 10.1; adr/ADR-109_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura escala sin estado el Servicio de Reservas y sirve el portal desde CDN, pero la capacidad no está medida. El riesgo dominante es la ausencia de límites: pool JDBC, máximo de réplicas, TPS y capacidad de Keycloak. El mínimo de remediación es documentar demanda por caso de uso, pool y máximo de réplicas, y la cuota del Servidor de Identidad Northwind.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda FLOW-1, FLOW-2, FLOW-3 (TPS) — Valores de rps y factor de pico (docs/08-scalability-and-performance.md § 10.2; docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA y tamaño del pool JDBC (docs/08-scalability-and-performance.md § 10.1 y § 10.4)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, límite de conexiones y réplicas de lectura (docs/08-scalability-and-performance.md § 10.1; docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, réplicas y límite de tasa (docs/components/proveedor-de-identidad-northwind.md; docs/08-scalability-and-performance.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`
