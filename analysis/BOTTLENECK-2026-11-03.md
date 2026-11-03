# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El hallazgo de mayor severidad es B2-01: el `Servidor de Identidad Northwind` (Keycloak 25) recibe I-01 e I-03 y no documenta capacidad, límite de tasa ni réplicas. Un flood de inicio de sesión lo satura (STRIDE T7-D).

La documentación no declara ninguna cifra de capacidad: TPS, máximo de réplicas del HPA, tamaño del pool JDBC y capacidad de PostgreSQL son `Not documented` (docs/08 §10.1–10.3). El modelo de carga queda en `idle` y no calcula ρ ni holgura.

Hay 2 hallazgos B2, 1 B3 y ningún B1 ni B4. La `Base de Datos de Reservas` (B2-02) es la única ruta de escritura y su pool no está dimensionado. Ningún componente tiene 3 o más llamantes: no hay fan-in B4.

Prioridad de remediación: medir la demanda (TPS por flujo) y documentar pool, máximo del HPA y límite de tasa del IdP antes de la próxima revisión.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Dependencia externa sin límite de tasa ni capacidad documentados; un flood de inicio de sesión agota Keycloak (STRIDE T7-D). Con claves JWKS vencidas el servicio rechaza toda solicitud (T12-D). Fuente: docs/05 § 7, SPOF C2. | ADR-002 |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 1 (I-04) | Única ruta de escritura (I-04); cada réplica abre su pool JDBC de tamaño no documentado y una conexión LISTEN fuera del pool. Consultas costosas agotan las conexiones de la instancia única (STRIDE T16-D). Fuente: docs/08 § 10.4, docs/05 § 7. | ADR-003, ADR-109 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala con HPA por CPU (mínimo 2 réplicas, máximo no documentado), pero cada réplica abre conexiones propias a una única Base de Datos de Reservas: más réplicas multiplican conexiones sobre un destino de capacidad no documentada. La caché Caffeine no tiene tamaño máximo documentado (docs/08 § 10.1, § 10.4). | 1 (I-02) | Fijar el máximo de réplicas del HPA según el pool JDBC por réplica y el límite de conexiones de PostgreSQL; documentar ambos y el tamaño máximo de Caffeine. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | Sin evaluar; archivos estáticos en CDN (ADR-107) |
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
| 1 | ADR-109 | Invalidar la caché Caffeine con LISTEN/NOTIFY; una conexión LISTEN por réplica fuera del pool | Cada réplica añadida consume una conexión permanente de PostgreSQL adicional al pool JDBC; no hay caché distribuida (docs/08 § 10.4) | Medio: el límite de conexiones de la base no está documentado |
| 2 | ADR-005 | Mínimo de 2 réplicas en zonas distintas, HPA por CPU | Máximo de réplicas no documentado; el tope efectivo lo fija la Base de Datos de Reservas | Medio: sin máximo ni solicitudes y límites de CPU documentados |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Dimensionar el pool JDBC y las conexiones de PostgreSQL (B2-02)**
Definir `maximumPoolSize` por réplica y verificar que réplicas máximas × pool + conexiones LISTEN quede bajo `max_connections` de PostgreSQL 16, con margen. Costo: más conexiones reservadas. Reduce el riesgo de saturación (T16-D).
_Fuente: docs/08-scalability-and-performance.md § 10.4_

**2. Documentar el máximo de réplicas del HPA (B3-01)**
Fijar el máximo del HPA del `Servicio de Reservas` y los umbrales de CPU, solicitudes y límites. Se acepta un tope de escalado a cambio de proteger la base única de más conexiones.
_Fuente: docs/08-scalability-and-performance.md § 10.1_

**3. Documentar capacidad y límite de tasa de Keycloak (B2-01)**
Declarar réplicas, capacidad de inicio de sesión y límite de tasa de Keycloak 25 con Plataforma Northwind. Añadir protección por tasa en el endpoint de login (T7-D) y fijar el TTL de la caché JWKS (I-03).
_Fuente: docs/05-integration-points.md § 7_

**4. Medir la demanda por flujo y habilitar el modelo de carga (B2-02)**
Registrar rps promedio y pico de FLOW-1, FLOW-2 y FLOW-3 en docs/08 § 10.2 con factor pico, para que el modelo calcule ρ y holgura sobre la base de datos y el servicio.
_Fuente: docs/08-scalability-and-performance.md § 10.2_

**5. Fijar el tamaño máximo de Caffeine (B3-01)**
Documentar el máximo de entradas de la caché por réplica, ya que absorbe las lecturas de CU1 y protege a la base. Riesgo reducido: más lecturas a PostgreSQL ante evicción no medida.
_Fuente: docs/08-scalability-and-performance.md § 10.4_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura escala el Servicio de Reservas sin estado y descarga lecturas con CDN y Caffeine, y todo flujo es síncrono con una sola escritura. El riesgo dominante es la ausencia de cifras de capacidad: pool JDBC, máximo del HPA, capacidad de PostgreSQL y de Keycloak, y TPS. El mínimo de remediación es documentar esos cuatro valores y medir la demanda por flujo.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda por flujo (FLOW-1, FLOW-2, FLOW-3) — rps promedio, pico y factor pico (docs/08-scalability-and-performance.md § 10.2 y docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU y memoria, tamaño de Caffeine (docs/08-scalability-and-performance.md § 10.1, § 10.4)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, max_connections, tamaño del pool JDBC y réplicas de lectura (docs/08-scalability-and-performance.md § 10.1, § 10.4 y docs/components/reservas-de-salas-northwind/03-base-de-datos-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Tabla de capacidad, réplicas y límite de tasa (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Portal de Reservas — Límites del CDN (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Presupuesto de latencia por salto (I-02, I-04) — Budget p95 por salto (docs/04-data-flow-patterns.md, Latency budget breakdown)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`, `analysis/SPOF-2026-11-03.md`, `analysis/STRIDE-2026-11-03.md`
