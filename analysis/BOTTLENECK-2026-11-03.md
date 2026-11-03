# Análisis de Cuellos de Botella — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-03  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

Hallazgo de mayor severidad: B2-02, `Base de Datos de Reservas`. Es el único almacén de PostgreSQL 16, recibe todas las lecturas con caché vencida y todas las escrituras de `Servicio de Reservas` (I-04), y no documenta réplicas de lectura, tamaño del pool ni capacidad (docs/08 § 10.1, § 10.4).

Total: 2 hallazgos B2, 1 B3 y 0 B4. B2-01 es `Servidor de Identidad Northwind`: dos llamantes (I-01, I-03), sin límite de tasa ni capacidad documentados. B3-01 es `Servicio de Reservas`: HPA por CPU con mínimo 2 réplicas y máximo no documentado, acotado por la base de datos única.

Ningún componente alcanza fan-in ≥ 3, de modo que no hay B4. La demanda (FLOW-1 a FLOW-3) y la carga TPS no están documentadas: el modelo de carga no puede calcular holgura ni puntos de saturación, y toda la holgura queda como Not documented.

Prioridad de remediación: medir la demanda por caso de uso y fijar el máximo de réplicas y el tamaño del pool JDBC, porque cada réplica añade conexiones al mismo primario.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Cuellos de Botella Principales <!-- SECTION: Top Chokepoints -->

| # | Tier | Component | Max RPS / Limit | Current HPA | Fan-in Count | Bottleneck Reason | ADR Reference |
|---|---|---|---|---|---|---|---|
| B2-01 | B2 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | 2 (I-01, I-03) | Proveedor externo (Keycloak 25) sin límite de tasa ni capacidad documentados; I-01 lo llama en cada inicio de sesión e I-03 en la carga de claves JWKS. Sin claves, el servicio rechaza toda solicitud. | ADR-002 (docs/05 § 7, I-01 e I-03) |
| B2-02 | B2 | Base de Datos de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (almacén con estado; capacidad la dimensiona Plataforma Northwind) | 1 (I-04, desde cada réplica de Servicio de Reservas) | Único PostgreSQL 16 para lecturas con caché vencida y todas las escrituras. El tamaño del pool JDBC no está documentado y cada réplica añade conexiones, además de una conexión LISTEN fuera del pool. | ADR-003, ADR-109 (docs/08 § 10.1, § 10.4) |

### 2.2 Componentes con Riesgo de Escalado <!-- SECTION: Scaling Risk Components -->

| # | Tier | Component | Scale Blocker | Fan-in Count | Recommendation |
|---|---|---|---|---|---|
| B3-01 | B3 | Servicio de Reservas | Escala por HPA de CPU (mínimo 2 réplicas, máximo no documentado), pero depende de la Base de Datos de Reservas única y de un pool JDBC sin tamaño documentado; la caché Caffeine es por réplica, sin caché distribuida. | 1 (I-02) | Fijar el máximo de réplicas y el tamaño del pool de modo que réplicas × pool quede bajo el límite de conexiones de PostgreSQL 16. |

### 2.3 Resumen de Holgura de Capacidad <!-- SECTION: Capacity Headroom Summary -->

| # | Component | Current Load (est.) | Max Capacity | Headroom % | Risk Level |
|---|---|---|---|---|---|
| 1 | Portal de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (archivos estáticos en CDN) | [NOT DOCUMENTED] | Not documented |
| 2 | Servicio de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] (mínimo 2 réplicas, máximo no documentado) | [NOT DOCUMENTED] | Medium (B3-01) |
| 3 | Base de Datos de Reservas | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | High (B2-02) |
| 4 | Servidor de Identidad Northwind | [NOT DOCUMENTED] | [NOT DOCUMENTED] | [NOT DOCUMENTED] | High (B2-01) |

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
| 1 | ADR-109 (reemplaza a ADR-108) | Caché Caffeine por réplica con invalidación por LISTEN/NOTIFY; sin caché distribuida. | Cada réplica abre una conexión LISTEN fuera del pool y tiene su propia caché fría; más réplicas suman conexiones y lecturas al mismo primario. | Medium: tamaño máximo de caché y del pool Not documented (docs/08 § 10.4) |
| 2 | ADR-003 | PostgreSQL como base relacional institucional, con capacidad dimensionada por Plataforma Northwind. | Una sola instancia primaria para lectura y escritura; réplicas de lectura y límites no documentados. | High (B2-02) |

## 3. Top 5 Recomendaciones de Escalado <!-- SECTION: Top 5 Scaling Recommendations -->

**1. Dimensionar el primario de PostgreSQL y el pool JDBC (B2-02)**
Documentar el límite de conexiones de PostgreSQL 16, fijar el pool JDBC por réplica y evaluar réplicas de lectura para la consulta de disponibilidad. Compromiso: más complejidad operativa en Plataforma Northwind. Reduce el riesgo de agotar conexiones al escalar el HPA.
_Fuente: docs/08-scalability-and-performance.md § 10.1, § 10.4_

**2. Fijar el máximo de réplicas del HPA (B3-01)**
Declarar el máximo de réplicas de Servicio de Reservas de modo que réplicas × pool no supere las conexiones de la base. Compromiso: techo de escalado explícito. Reduce el riesgo de saturar el primario bajo pico.
_Fuente: docs/08-scalability-and-performance.md § 10.1_

**3. Documentar capacidad y límite de tasa del Servidor de Identidad Northwind (B2-01)**
Obtener de Plataforma Northwind el límite de tasa y la capacidad de Keycloak 25 para I-01 e I-03, y confirmar el TTL de la caché JWKS. Reduce el riesgo de rechazo masivo si el proveedor se satura.
_Fuente: docs/05-integration-points.md § 7 (I-03)_

---

## 4. Veredicto Resumen <!-- SECTION: Summary Verdict -->

La arquitectura escala de forma plausible: Servicio de Reservas es sin estado, usa HPA con mínimo 2 réplicas y Portal de Reservas se sirve desde CDN. El riesgo dominante es la ausencia de cifras: la Base de Datos de Reservas es un primario único sin pool ni capacidad documentados y la demanda no está medida. El mínimo de remediación es medir la demanda por caso de uso, fijar el pool y el máximo de réplicas, y documentar los límites del Servidor de Identidad Northwind.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Demanda por caso de uso (FLOW-1 a FLOW-3) y TPS — Valores de rps y factor de pico (docs/08-scalability-and-performance.md § 10.2 y docs/01-system-overview.md)
- [ ] `[NOT DOCUMENTED]` Servicio de Reservas — Máximo de réplicas del HPA, solicitudes y límites de CPU y memoria (docs/08-scalability-and-performance.md § 10.1)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas — Capacidad, límite de conexiones, tamaño del pool JDBC y réplicas de lectura (docs/08-scalability-and-performance.md § 10.1 y § 10.4; docs/06-technology-stack.md)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Capacidad, réplicas y límite de tasa; sin tabla Capacity (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Caché Caffeine — Tamaño máximo de la caché (docs/08-scalability-and-performance.md § 10.4)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/08-scalability-and-performance.md`, `docs/05-integration-points.md`, `docs/04-data-flow-patterns.md`, `adr/ADR-003`, `adr/ADR-109`
