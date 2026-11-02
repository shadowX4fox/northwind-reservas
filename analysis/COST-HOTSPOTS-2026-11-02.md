# Análisis de Puntos Calientes de Costo — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-02  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

La documentación no contiene ninguna cifra de costo mensual (Q1 o Q2). El `docs/09-operational-considerations.md § 11.5` declara el costo operativo mensual como `Not documented`, y `docs/06-technology-stack.md` no registra precios ni niveles de servicio. No es posible construir la tabla de Pareto ni calcular la concentración por proveedor.

Las únicas cifras son el presupuesto de desarrollo de USD 95.000 (USD 85.000 más USD 10.000 de contingencia, aprobado el 2026-10-01), que es un gasto único y no se normaliza a USD/mes, y el costo fijo cualitativo de dos réplicas permanentes del `Servicio de Reservas`. Ningún ADR cita cifras de costo.

Normalización: sin cifras Q1/Q2 no se aplicó ninguna conversión. Ningún componente cumple el criterio de sobredimensionamiento: el mínimo de 2 réplicas lo exige ADR-005 para zonas distintas y no hay utilización documentada.

---

## 2. Hallazgos <!-- SECTION: Findings -->

### 2.1 Tabla de Pareto de Costo <!-- SECTION: Pareto Cost Table -->

_Sin hallazgos en esta corrida._

### 2.2 Menciones Cualitativas de Costo <!-- SECTION: Qualitative Cost Mentions -->

| # | Component | Cost Mention | Source | Recommended Action |
|---|---|---|---|---|
| Q-01 | Servicio de Reservas | Costo fijo: dos réplicas permanentes en zonas distintas, sin costo por réplica documentado | docs/09-operational-considerations.md § 11.5; adr/ADR-005 | Documentar el costo mensual por réplica y el de Kubernetes de Plataforma Northwind |
| Q-02 | Reservas de Salas Northwind | Presupuesto de desarrollo USD 95.000 (desarrollo 85.000, contingencia 10.000), gasto único; el costo operativo mensual es Not documented | docs/09-operational-considerations.md § 11.5 | Registrar el costo operativo mensual y el modelo de cobro de Plataforma Northwind |

### 2.3 Concentración por Proveedor <!-- SECTION: Vendor Concentration Summary -->

| # | Vendor / Provider | Monthly Cost | % of Total |
|---|---|---|---|
| 1 | Plataforma Northwind (Kubernetes, CDN, PostgreSQL gestionado, colector) | Not documented | Not documented |
| 2 | Total documented | USD 0 documentado | 100 % |

## 3. Cinco Recomendaciones de Ajuste de Capacidad <!-- SECTION: Recommendations -->

**1. Documentar el costo operativo mensual (Q-02)**
Completar `docs/09-operational-considerations.md § 11.5` con USD/mes de cómputo, base de datos, CDN y observabilidad. Sin esa cifra no se puede ejecutar el Pareto. Riesgo reducido: costo no visible.
_Fuente: docs/09-operational-considerations.md § 11.5_

**2. Costear las dos réplicas permanentes (Q-01)**
Registrar el costo por réplica del `Servicio de Reservas` y su utilización (CPU del HPA) en `docs/08-scalability-and-performance.md`. Permite evaluar si el mínimo de 2 réplicas de ADR-005 sobredimensiona con 42 salas y 3 sedes. Compromiso: la disponibilidad entre zonas se mantiene.
_Fuente: adr/ADR-005; docs/06-technology-stack.md § 8.4_

**3. Registrar el modelo de cobro de Plataforma Northwind (Q-02)**
Documentar si Plataforma Northwind cobra por uso o por contrato interno; todos los servicios de infraestructura dependen de ese proveedor y el 60 % de concentración no puede evaluarse.
_Fuente: docs/06-technology-stack.md § 8.3, § 8.4_

**4. Añadir costo a los ADR de infraestructura (Q-01)**
Incluir cifras de costo en ADR-003, ADR-005 y ADR-107 (base de datos gestionada, clúster, CDN), de modo que la sección de decisiones de costo deje de estar vacía.
_Fuente: adr/ADR-003; adr/ADR-005; adr/ADR-107_

**5. Repetir el análisis tras documentar costos (Q-02)**
Volver a ejecutar cost-hotspots cuando existan cifras Q1/Q2 para producir la tabla de Pareto, la señal V y los candidatos O.
_Fuente: docs/09-operational-considerations.md § 11.5_

---

## 4. Veredicto <!-- SECTION: Summary Verdict -->

La arquitectura es simple (cuatro contenedores, 4 integraciones) y la única decisión de costo explícita es el mínimo de 2 réplicas. El riesgo dominante es la ausencia total de cifras mensuales: no se puede identificar ningún hotspot ni concentración por proveedor. El conjunto mínimo de remediación es documentar el costo operativo mensual y el costo por réplica.

---

## 5. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Costo operativo mensual — Not documented: USD/mes de la operación (docs/09-operational-considerations.md § 11.5)
- [ ] `[NOT DOCUMENTED]` Costo por réplica del Servicio de Reservas y Kubernetes de Plataforma Northwind — Costo mensual y utilización (docs/06-technology-stack.md § 8.4; docs/08-scalability-and-performance.md)
- [ ] `[NOT DOCUMENTED]` Base de Datos de Reservas (PostgreSQL 16 gestionado) y CDN de Plataforma Northwind — Nivel de servicio y costo mensual (docs/06-technology-stack.md § 8.3, § 8.4)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind (Keycloak 25) — Costo de licencia u operación (docs/06-technology-stack.md § 8.6; docs/05-integration-points.md)
- [ ] `[NOT DOCUMENTED]` Observabilidad y CI/CD — Costo del colector y de la herramienta de CI/CD (Not documented) (docs/06-technology-stack.md § 8.5, § 8.7)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/09-operational-considerations.md`, `docs/06-technology-stack.md`, `docs/05-integration-points.md`
