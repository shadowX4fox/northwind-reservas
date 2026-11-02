# Análisis de Dependencia de Proveedor — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión v1.10.5

**Fecha de análisis**: 2026-11-02  
**Fuente de arquitectura**: `ARCHITECTURE.md` v1.10.5 (Status: Released)  
**Analista**: Architecture Analysis Skill

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

No hay capacidades L1 (propietarias): el stack usa estándares abiertos (React 18, Java 21, Spring Boot 3.3, PostgreSQL 16, Keycloak 25, OpenAPI 3.1, OIDC, OpenTelemetry, Kubernetes, Helm). Ningún ADR cita una API propietaria de un proveedor comercial.

El riesgo es de dependencia interna: 4 de 7 elementos clasificados (57 %) dependen de Plataforma Northwind (Kubernetes, CDN, PostgreSQL gestionado, Keycloak). El principio 8 de `docs/02-architecture-principles.md` admite que salir de la plataforma reescribe el chart de Helm, los secretos y la publicación. El 57 % queda bajo el umbral de 60 %; el costo operativo mensual no está documentado y no permite evaluar la concentración por costo.

Hallazgos: 0 L1, 4 L2 (3 con costo de salida Medium, 1 Low), 3 L3 destacados. Prioridad principal: documentar el alcance propietario de la plataforma (gestor de secretos, CDN, PostgreSQL gestionado), que hoy figura como Not documented. No existe un ADR de estrategia multinube o de salida.

---

## 2. Concentración por Proveedor <!-- SECTION: Vendor Concentration -->

| # | Vendor | Component Count | % of Architecture | Lock Tier Distribution |
|---|---|---|---|---|
| 1 | Plataforma Northwind (operador interno) | 4 | 57 % (4 de 7 elementos clasificados); bajo el umbral de 60 % | 0 L1, 4 L2, 0 L3 |
| 2 | Código abierto / comunidad (software sin operador propietario) | 3 | 43 % (3 de 7 elementos clasificados) | 0 L1, 0 L2, 3 L3 |

## 3. Capacidades Bloqueadas (L1) <!-- SECTION: Locked Capabilities -->

_Sin hallazgos en esta corrida._

## 4. Capacidades Propensas al Bloqueo (L2) <!-- SECTION: Lock-prone Capabilities -->

| # | Component / Capability | Vendor | Open Standard Used | Vendor Extension | Migration Risk |
|---|---|---|---|---|---|
| L2-01 | Base de Datos de Reservas (PostgreSQL 16 gestionado) | Plataforma Northwind | SQL y JDBC (I-04) | Restricción de exclusión (ADR-102) y LISTEN/NOTIFY (ADR-109), propios de PostgreSQL; respaldo y PITR de 7 días gestionados por la plataforma (ADR-003) | Medium |
| L2-02 | Servicio de Reservas (Kubernetes y Helm de Plataforma Northwind) | Plataforma Northwind | Contenedor OCI, Kubernetes, Helm (ADR-005) | Versiones de Kubernetes fijadas por la plataforma, gestor de secretos del clúster e ingress; salir reescribe el chart, los secretos y la publicación (principio 8) | Medium |
| L2-03 | Portal de Reservas (publicación en el CDN de Plataforma Northwind) | Plataforma Northwind | Archivos estáticos HTTPS (ADR-107) | Mecanismo de publicación del CDN: Not documented | Low |
| L2-04 | Servidor de Identidad Northwind (Keycloak 25) | Plataforma Northwind (Keycloak, código abierto) | OpenID Connect con PKCE, JWT RS256, JWKS (ADR-002; I-01, I-03) | Claims `recepcion` y `sede` (ADR-105) emitidos por la configuración del realm; mapeadores y exportación del realm: Not documented | Medium |

## 5. Componentes Portables (L3) <!-- SECTION: Portable Components -->

| # | Component | Standard | Alternative Provider(s) |
|---|---|---|---|
| 1 | Servicio de Reservas (Java 21, Spring Boot 3.3) | REST con contrato OpenAPI 3.1 (ADR-001), contenedor OCI | Cualquier clúster Kubernetes (EKS, AKS, GKE u on-premise); sin cambio de código |
| 2 | Portal de Reservas (React 18, TypeScript) | Archivos estáticos HTTP, cliente OIDC | Cualquier CDN o almacenamiento compatible con S3 |
| 3 | Telemetría (OpenTelemetry, W3C Trace Context) | OTLP y OpenTelemetry (ADR-004) | Cualquier backend compatible con OTLP (Jaeger, Grafana Tempo, Datadog, etc.) |

## 6. Ranking de Costo de Salida <!-- SECTION: Exit Cost Ranking -->

| # | Component | Vendor | Exit Cost | Blocking Factor |
|---|---|---|---|---|
| L2-02 | Servicio de Reservas (Kubernetes y Helm de Plataforma Northwind) | Plataforma Northwind | Medium | Reescritura del chart de Helm, secretos y publicación (principio 8); Not documented el alcance del gestor de secretos |
| L2-01 | Base de Datos de Reservas (PostgreSQL 16 gestionado) | Plataforma Northwind | Medium | Exportación vía formato estándar de PostgreSQL no documentada; la restricción de exclusión y LISTEN/NOTIFY exigen PostgreSQL en destino |
| L2-04 | Servidor de Identidad Northwind (Keycloak 25) | Plataforma Northwind (Keycloak) | Medium | Mapeadores de claims y exportación del realm no documentados |
| L2-03 | Portal de Reservas (publicación en el CDN de Plataforma Northwind) | Plataforma Northwind | Low | Solo el paso de publicación del CDN; los artefactos son archivos estáticos |

## 7. Mapa de Calor de Dependencia de Proveedor <!-- SECTION: Vendor Lock-in Heat Map -->

```
LOCK SEVERITY │
HIGH (L1)     │                                  │                                  │                                  
              ├──────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────
MID           │                                  │                                  │ [L2-01] [L2-02] [L2-03] [L2-04]  
              ├──────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────
LOW (L3)      │                                  │                                  │                                  
              └──────────────────────────────────┴──────────────────────────────────┴──────────────────────────────────
                LOW                               MID                               HIGH                              
                STRATEGIC IMPORTANCE →
```

## 8. Cinco Recomendaciones de Portabilidad <!-- SECTION: Top 5 Portability Recommendations -->

**1. Documentar la superficie propia de Plataforma Northwind (L2-02)**
Registrar en `docs/06-technology-stack.md` las versiones de Kubernetes y Helm, el gestor de secretos y el ingress. Mantener el chart sin recursos exclusivos de la plataforma. Reduce el costo de reescritura del principio 8 a un cambio de configuración.
_Fuente: docs/06-technology-stack.md § 8.4; docs/02-architecture-principles.md § 8_

**2. Probar la exportación y restauración de PostgreSQL fuera de la plataforma (L2-01)**
Ejecutar `pg_dump` y restaurar en una instancia PostgreSQL 16 independiente, verificando la restricción de exclusión (ADR-102) y LISTEN/NOTIFY (ADR-109). Documentar el resultado y la ubicación de los respaldos. Riesgo reducido: salida sin formato de exportación probado.
_Fuente: docs/09-operational-considerations.md § 11.3; adr/ADR-003; adr/ADR-102_

**3. Versionar la configuración del realm de Keycloak (L2-04)**
Exportar el realm y los mapeadores de los claims `recepcion` y `sede` a un repositorio, y documentar la versión de Keycloak 25. Permite reemplazar el proveedor con cualquier servidor OIDC sin cambiar el código del Servicio de Reservas.
_Fuente: docs/06-technology-stack.md § 8.6; adr/ADR-002; adr/ADR-105_

**4. Documentar el paso de publicación al CDN (L2-03)**
Describir el comando o el pipeline que publica los archivos estáticos y mantenerlo detrás de un script portable. Compensación: un paso de documentación; el artefacto ya es portable.
_Fuente: docs/09-operational-considerations.md § 11.1; adr/ADR-107_

---

## 9. Veredicto Resumen <!-- SECTION: Summary Verdict -->

El stack es abierto y portable en sus interfaces (OIDC, REST/OpenAPI, SQL/JDBC, OTLP, Kubernetes). El riesgo dominante es la dependencia operativa de Plataforma Northwind, admitida en el principio 8, sin detalle de su alcance. El conjunto mínimo de remediación: documentar la superficie de la plataforma (L2-02), probar la exportación de PostgreSQL (L2-01) y versionar el realm de Keycloak (L2-04).

---

## 10. Brechas de Documentación <!-- SECTION: Documentation Gaps -->

- [ ] `[NOT DOCUMENTED]` Kubernetes y Helm de Plataforma Northwind — Versiones y recursos exclusivos de la plataforma (docs/06-technology-stack.md § 8.4)
- [ ] `[NOT DOCUMENTED]` Gestor de secretos del clúster — Producto y API usada (docs/06-technology-stack.md § 8.6)
- [ ] `[NOT DOCUMENTED]` Publicación en el CDN de Plataforma Northwind — Mecanismo de publicación (docs/09-operational-considerations.md § 11.1)
- [ ] `[NOT DOCUMENTED]` Servidor de Identidad Northwind — Versión exacta, mapeadores de claims y exportación del realm (docs/components/proveedor-de-identidad-northwind.md)
- [ ] `[NOT DOCUMENTED]` Costo operativo mensual — Costo por proveedor para evaluar la concentración por costo (docs/09-operational-considerations.md § 11.5)
- [ ] `[NOT DOCUMENTED]` Ubicación de los respaldos de la Base de Datos de Reservas — Ubicación y formato de exportación (docs/09-operational-considerations.md § 11.3)
- [ ] `[NOT DOCUMENTED]` Estrategia multinube o de salida — Ningún ADR la registra (adr/ (nuevo ADR))
- [ ] `[NOT DOCUMENTED]` Herramienta de CI/CD — Producto usado (docs/06-technology-stack.md § 8.7)

---

**Fuentes citadas**: `ARCHITECTURE.md`, `docs/06-technology-stack.md`, `docs/05-integration-points.md`, `docs/09-operational-considerations.md`, `docs/02-architecture-principles.md`
