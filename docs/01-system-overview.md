<!-- ARCHITECTURE_VERSION: 1.0.0 -->
<!-- ARCHITECTURE_STATUS: Draft -->
<!-- ARCHITECTURE_RELEASED: -->
<!-- DOC_LANGUAGE: es -->

# Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión

<!-- EXPLORER_HEADER
key_concepts: reserva de salas, disponibilidad en tiempo real, reservas dobles, autoservicio, cancelación, recepción de sede, sedes Centro Norte Puerto, piloto
technologies: React 18, Spring Boot 3.3, Java 21, PostgreSQL 16, Keycloak, OpenTelemetry, Kubernetes
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas
scope: Resumen ejecutivo, problema, solución, impulsores de diseño y casos de uso; no cubre capas ni componentes en detalle
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005
-->

> Los miembros de Northwind Cowork consultan, reservan y cancelan salas de las 3 sedes en un portal web. El sistema impide por construcción dos reservas confirmadas superpuestas de la misma sala.

<!-- DOC_LANGUAGE_GATE: PASSED (es, 2026-10-18) -->
<!-- PO_SPEC_SOURCE: PRODUCT_OWNER_SPEC.md (loaded 2026-10-18) -->
<!-- ALIGNMENT_GATE: NONE (no capability framework declared, 2026-10-18) -->
<!-- HLD_GATE: PASSED (ref: reservas-hld.mmd, 2026-10-18) -->
<!-- HLD_SOURCE: reservas-hld.mmd -->
<!-- HLD_FORMAT: mermaid -->

**Version**: 1.0.0
**Status**: Draft
**Released**:
**Architect**: Equipo de Arquitectura Northwind
**Supersedes**: —

---

## 1. Resumen Ejecutivo <!-- SECTION: Executive Summary -->

### Descripción General <!-- SECTION: System Overview -->

Reservas de Salas Northwind es una SPA web y un microservicio dueño de su base de datos. Cubre las 42 salas de reunión de las sedes Centro, Norte y Puerto, disponible las 24 horas.

**Métricas Clave:** <!-- LABEL: Key Metrics -->

#### TPS de Lectura

- **TPS de lectura promedio**: Not documented <!-- TODO: Add source reference -->
- **TPS de lectura pico**: Not documented <!-- TODO: Add source reference -->
- **Período de medición**: Not documented <!-- TODO: Add source reference -->

#### TPS de Procesamiento

- **TPS de procesamiento promedio**: Not documented <!-- TODO: Add source reference -->
- **TPS de procesamiento pico**: Not documented <!-- TODO: Add source reference -->
- **Período de medición**: Not documented <!-- TODO: Add source reference -->

#### TPS de Escritura

- **TPS de escritura promedio**: Not documented <!-- TODO: Add source reference -->
- **TPS de escritura pico**: Not documented <!-- TODO: Add source reference -->
- **Período de medición**: Not documented <!-- TODO: Add source reference -->

**Métricas Adicionales:**

| Métrica | Valor | Fuente |
|---|---|---|
| Tiempo hasta la confirmación | p95 ≤ 2 s, desde "Confirmar" hasta ver el código de reserva | PO Spec §8, Métrica 1 |
| Reservas dobles confirmadas | 0 por mes (línea base: 37 en agosto de 2026) | PO Spec §8, KPI 1 |
| Adopción del portal | ≥ 90 % de las reservas al 2027-04-25 (línea base: 0 %) | PO Spec §8, KPI 2 |
| Horas de recepción en reservas | ≤ 4 h semanales al 2027-04-25 (línea base: 26 h) | PO Spec §8, KPI 3 |
| Volumen actual de solicitudes | 310 solicitudes de reserva por semana | PO Spec §1 |
| Usuarios | 1.850 miembros activos y 6 recepcionistas | PO Spec §2 |
| SLA de disponibilidad | 99,5 % mensual; soporte lunes a viernes, 08:00–19:00 | PO Spec §7, Restricciones Operativas |

**Stack Tecnológico:** React 18 (Portal de Reservas), Spring Boot 3.3 sobre Java 21 (Servicio de Reservas), PostgreSQL 16 (Base de Datos de Reservas), Keycloak como Proveedor de Identidad Northwind, OpenTelemetry.

**Despliegue:** Kubernetes de la Plataforma Northwind (ADR-005), en el clúster y la base de datos existentes.

**Valor de Negocio:** <!-- LABEL: Business Value -->

- **Cero reservas dobles**: elimina las 37 reservas dobles mensuales y USD 7.900 anuales en bonificaciones.
- **85 % menos tiempo de recepción en reservas**: de 26 a 4 horas semanales, un ahorro de USD 20.600 por año.
- **Confirmación inmediata**: la confirmación pasa de una mediana de 2 h 40 min a 2 segundos en p95.
- **Paridad competitiva**: Northwind es el único operador de la zona que todavía confirma reservas por correo.

---

## 2. Descripción del Sistema <!-- SECTION: System Overview -->

### 2.1 Planteamiento del Problema <!-- SECTION: Problem Statement -->

Recepción registra a mano en hojas de cálculo 310 solicitudes semanales, con 26 horas de trabajo y 37 reservas dobles en agosto de 2026. El miembro espera una mediana de 2 h 40 min para saber si una sala está libre.

### 2.2 Solución <!-- SECTION: Solution -->

Reservas de Salas Northwind ofrece autoservicio web con disponibilidad en tiempo real y confirmación inmediata de las reservas.

Diferenciadores clave:

- La base de datos impide por construcción dos reservas confirmadas superpuestas de la misma sala.
- El miembro reserva en menos de 1 minuto, las 24 horas, desde el navegador o el teléfono.
- Recepción solo atiende excepciones y cancela reservas de su sede.

#### 2.2.1 Impulsores de Diseño <!-- SECTION: Design Drivers -->

| Driver | Measures | Threshold | Assessment | Justification |
|---|---|---|---|---|
| Entrega de Valor | Efectividad del cambio en la experiencia del cliente | >50% = High | HIGH | 85 % de reducción de horas de recepción en reservas (26 → 4), ver [Resumen Ejecutivo](01-system-overview.md#1-resumen-ejecutivo) |
| Escala | Clientes impactados | >100K = High | LOW | 1.850 miembros activos y 310 solicitudes semanales, ver [Casos de Uso Principales](01-system-overview.md#23-casos-de-uso-principales) |
| Impactos | Complejidad de implementación en configuración, desarrollo y aplicaciones | >5 = High | HIGH | 3 contenedores + 7 tecnologías = 10, ver [Componentes](components/README.md) y [Stack Tecnológico](06-technology-stack.md) |

**Last Calculated**: 2026-10-18
**Calculation Method**: Manual

### 2.3 Casos de Uso Principales <!-- SECTION: Primary Use Cases -->

1. **Consultar disponibilidad de salas**: el miembro elige sede, fecha y franja, y ve las salas libres con capacidad y equipamiento.
2. **Reservar una sala**: el miembro reserva una sala libre para una franja y recibe la confirmación en pantalla.
3. **Cancelar una reserva**: el miembro cancela una reserva futura propia, o recepción cancela cualquier reserva de su sede; la sala queda libre.

### 2.4 Fuera de Alcance <!-- SECTION: Out of Scope -->

- Cobro de salas por hora: incluido en la membresía, se evaluará en el plan 2028.
- Aplicación móvil nativa: el portal web es responsivo.
- Notificaciones por correo o SMS: la confirmación es en pantalla.
- Integración con calendarios externos (Google Calendar, Microsoft 365).
- Reservas de puestos de trabajo.
