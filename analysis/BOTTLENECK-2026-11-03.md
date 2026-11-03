# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

El hallazgo de mayor severidad es `Base de Datos de Reservas` (B2-02): PostgreSQL 16 único, con la pool JDBC de cada réplica y una conexión `LISTEN` por réplica, sin límites ni pool documentados (docs/08 § 10.1, § 10.4).

Se registran 3 hallazgos: 2 B2 (`Servidor de Identidad Northwind`, `Base de Datos de Reservas`) y 1 B3 (`Servicio de Reservas`). No hay B1 ni B4: ningún componente recibe tráfico de 3 o más llamadores distintos.

Ningún componente tiene carga ni capacidad máxima documentada: el TPS, el máximo de réplicas y el tamaño del pool figuran como Not documented, por lo que la holgura no se puede calcular. Prioridad: medir la demanda de FLOW-1 a FLOW-3 y fijar máximo de réplicas y pool.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Dependencia externa (Keycloak 25) sin límite de tasa ni capacidad documentados; I-01 la llama desde el navegador y I-03 desde el Servicio de Reservas para JWKS. Sin claves disponibles, el servicio rechaza todas las solicitudes (deny by default). | ADR-002; docs/05 § 7 (I-01, I-03) |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | No aplica (base de datos); réplicas Not documented | 1 (I-04) | PostgreSQL 16 sin réplicas de lectura documentadas; todas las lecturas sin entrada vigente en caché y todas las escrituras pasan por una instancia. El tamaño del pool JDBC por réplica es Not documented y cada réplica añade una conexión LISTEN fuera del pool. | ADR-003; ADR-109; docs/08 § 10.4 |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala horizontalmente por HPA de CPU con mínimo 2 réplicas, pero el máximo de réplicas es Not documented y cada réplica abre sus conexiones a la Base de Datos de Reservas, que limita el caudal efectivo. | 1 (I-02) | Documentar el máximo de réplicas y dimensionar el pool JDBC por réplica contra las conexiones máximas de PostgreSQL. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (archivos estáticos en CDN, ADR-107) | [NOT DOCUMENTED] | Adequate |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (mínimo 2 réplicas; máximo Not documented) | [NOT DOCUMENTED] | B3 |
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
| 1 | ADR-109 (reemplaza a ADR-108) | Caché Caffeine en proceso por réplica, invalidada con LISTEN/NOTIFY; sin caché distribuida. | Cada réplica mantiene una conexión LISTEN fuera del pool y cada caché fría lee de la base; el tamaño máximo de la caché es Not documented. | Medio: las conexiones crecen con las réplicas y el máximo de réplicas es Not documented. |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Dimensionar el pool JDBC y las conexiones de PostgreSQL (B2-02)**
Documentar el tamaño del pool por réplica, las conexiones máximas de la instancia y la reserva para las conexiones LISTEN; evaluar una réplica de lectura. Reduce el riesgo de agotamiento de conexiones; costo: más capacidad de Plataforma Northwind.
_Fuente: docs/08-scalability-and-performance.md § 10.4; adr/ADR-003_

**2. Fijar el máximo de réplicas del HPA (B3-01)**
Declarar un máximo de réplicas del Servicio de Reservas coherente con las conexiones disponibles de la base. Reduce la saturación en picos; el costo es el techo de escalado.
_Fuente: docs/08-scalability-and-performance.md § 10.1; adr/ADR-005_

**3. Documentar capacidad y límites del Servidor de Identidad Northwind (B2-01)**
Obtener de Plataforma Northwind los RPS máximos, réplicas y límites de tasa de Keycloak 25, y confirmar la caché JWKS en I-03. Reduce el riesgo de rechazo masivo ante lentitud del proveedor.
_Fuente: docs/05-integration-points.md § 7 (I-01, I-03); adr/ADR-002_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura evita estado en el servicio y usa CDN y caché local, pero no documenta carga, máximos de réplicas ni pool de conexiones. El riesgo dominante es la instancia única de PostgreSQL con conexiones por réplica. El conjunto mínimo es medir la demanda, fijar el máximo de réplicas y dimensionar el pool.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda FLOW-1 a FLOW-3 — TPS de lectura y escritura y factor de pico (docs/08-scalability-and-performance.md § 10.2; docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU y memoria (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, conexiones máximas, tamaño del pool JDBC y réplicas de lectura (docs/08-scalability-and-performance.md § 10.1, § 10.4; docs/06-technology-stack.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, réplicas y límite de tasa de Keycloak 25 (docs/components/proveedor-de-identidad-northwind.md (tabla Capacity))
- [ ] `[NOT DOCUMENTED]` Caché Caffeine — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`
