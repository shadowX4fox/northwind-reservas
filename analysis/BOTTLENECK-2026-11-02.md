# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-02  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Ningún componente supera el umbral con cifras documentadas: `docs/08-scalability-and-performance.md` § 10.2 declara la demanda de FLOW-1, FLOW-2 y FLOW-3 como Not documented, el máximo de réplicas y el pool JDBC también. El modelo de carga queda en `idle` para los 4 componentes.

Hallazgo principal: `Base de Datos de Reservas` (B2-01) es el único camino de datos de las 3 operaciones (I-04); cada fallo de la caché Caffeine, cada reserva y cada cancelación llegan a una sola instancia PostgreSQL 16 sin réplicas de lectura documentadas, y cada réplica del `Servicio de Reservas` añade conexiones JDBC y una conexión `LISTEN` fuera del pool.

Conteo: 0 B1 · 2 B2 · 1 B3 · 0 B4 (fan-in máximo 2). Prioridad de remediación: medir TPS por flujo y documentar pool, máximo de réplicas y límites de la base.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | Sin HPA; réplicas [NOT DOCUMENTED] | 1 | Único almacén de las 3 operaciones (I-04); el pool JDBC es Not documented y cada réplica del Servicio de Reservas suma una conexión LISTEN fuera del pool; sin réplicas de lectura documentadas. Fuente: docs/08 § 10.1 y § 10.4, docs/05 § 7. | ADR-003, ADR-102, ADR-109 |
| B2-02 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 | Dependencia externa llamada desde I-01 (inicio de sesión) e I-03 (JWKS); sin límite de tasa ni capacidad documentados y sin tabla de Capacity. El caché local de claves reduce la carga, pero el login depende de una instancia no dimensionada. Fuente: docs/05 § 7, ledger de componentes. | ADR-002 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala con HPA por CPU (mínimo 2 réplicas, máximo Not documented), pero toda réplica converge en Base de Datos de Reservas (I-04) con pool Not documented; más réplicas multiplican conexiones JDBC y LISTEN. Fuente: docs/08 § 10.1. | 1 | Documentar el máximo de réplicas y el tamaño del pool, y fijar que réplicas máx × pool + LISTEN no supere el límite de conexiones de PostgreSQL. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | No evaluable (estático en CDN, ADR-107) |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | 2 réplicas mínimas; máximo [NOT DOCUMENTED] | [NOT DOCUMENTED] | B3 |
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
| 1 | ADR-109 (reemplaza a ADR-108) | Caché Caffeine en proceso por réplica, 5 minutos, invalidada con LISTEN/NOTIFY; sin caché distribuida. | Cada réplica nueva arranca con caché vacía y lee de la base; cada réplica mantiene una conexión LISTEN fuera del pool; tamaño máximo de la caché Not documented. | Medio: sin TPS ni pool documentados no se puede cuantificar (docs/08 § 10.4). |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Dimensionar y documentar la Base de Datos de Reservas (B2-01)**
Documentar maxConnections, tamaño del pool JDBC por réplica y conexiones LISTEN, y confirmar con Plataforma Northwind si hay réplica de lectura de PostgreSQL 16. Reduce el riesgo de agotamiento de conexiones; el costo es una réplica adicional si la lectura la exige.
_Fuente: docs/08-scalability-and-performance.md § 10.1, § 10.4_

**2. Fijar el máximo de réplicas del HPA (B3-01)**
Declarar max de réplicas del Servicio de Reservas ligado al presupuesto de conexiones de la base, y medir el TPS pico de FLOW-1, FLOW-2 y FLOW-3 para registrarlo en docs/01. Acepta un techo explícito de escalado.
_Fuente: docs/08-scalability-and-performance.md § 10.1, § 10.2_

**3. Documentar capacidad y límites del Servidor de Identidad Northwind (B2-02)**
Obtener de Plataforma Northwind el límite de tasa de Keycloak 25 en login y JWKS, y registrar el TTL del caché de claves. Reduce el riesgo de rechazo masivo por deny by default en I-03.
_Fuente: docs/05-integration-points.md § 7 (I-01, I-03)_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura escala el Servicio de Reservas sin estado y descarga el Portal de Reservas al CDN, con fan-in máximo de 2 y sin colas. El riesgo dominante es la falta de cifras: demanda, pool JDBC, máximo de réplicas y capacidad de la base y del IdP son Not documented. El mínimo: medir TPS por flujo y documentar pool, máximo de HPA y límites del IdP.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda FLOW-1, FLOW-2, FLOW-3 — TPS promedio y pico, factor pico (docs/08-scalability-and-performance.md § 10.2; docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas HPA, solicitudes/límites de CPU y memoria, capacidad por réplica (docs/08 § 10.1; docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad máxima, pool JDBC, maxConnections, réplicas de lectura (docs/08 § 10.1 y § 10.4; docs/06-technology-stack.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, límite de tasa, réplicas, versión; el índice lo nombra Proveedor de Identidad Northwind (deriva de nombre) (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine — Tamaño máximo de la caché (docs/08 § 10.4)
- [ ] `[NOT DOCUMENTED]` Presupuesto de latencia por salto — Portal→Servicio y Servicio→Base sin presupuesto (docs/04-data-flow-patterns.md § Presupuesto de latencia)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`
