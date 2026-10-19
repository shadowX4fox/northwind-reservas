# Contrato de Interfaz: Servicio de Reservas → Proveedor de Identidad Northwind

<!-- managed by sa-skills:architecture-dev-handoff — do not edit manually -->
<!-- TEMPLATE_VERSION: 4.3.1 -->
| Field | Value |
|-------|-------|
| Arista relacionada | E-03 |
| Versión de la Vista de Ejecución | 4.3.1 |
| Versión de los Estándares | 4.3.1 |
| Decisión | [ADR-002](../../adr/ADR-002-oidc-keycloak-identity.md) |
| Generado | 2026-10-18 |

### Índice rápido por rol <!-- SECTION: Role Quick Index -->

| Audience | Read first in this document |
|----------|-----------------------------|
| **Dev** | Interacción → Estado de entrada → Estado de salida → Supuestos mutuos → Propiedad |
| **QA** | Semántica de fallos → Estado de entrada → Estado de salida → Supuestos mutuos |
| **Ops / SRE** | Semántica de fallos → Observabilidad en la interfaz → Registro de cambios |

El orden de lectura de los cuatro documentos del handoff está en `../README.md`.

Contrato de continuidad entre dos servicios adyacentes. Aquí se originan la mayoría de los defectos de integración: cada supuesto mutuo es vinculante. Cambiar uno es un cambio de interfaz, no un cambio local.

---

## Interacción <!-- SECTION: Interaction -->

| Aspect | Value |
|--------|-------|
| Estilo | sync (request-response) |
| Transporte | HTTPS/JSON [Auth] |
| Contrato | [NOT DOCUMENTED — add contract reference to docs/05-integration-points.md] |
| Compatibilidad | ver [CROSS_CUTTING_STANDARDS § Versioning](../CROSS_CUTTING_STANDARDS.md#versioning) |

**Panel** — el par en el diagrama de contenedores, recortado de `docs/03` (generado, nunca editado a mano):

[NOT DOCUMENTED — the container diagram has no node labelled Proveedor de Identidad Northwind]

---

## Estado de entrada <!-- SECTION: Entry state -->

Lo que el Proveedor de Identidad Northwind puede asumir como cierto cuando se le invoca:

- [NOT DOCUMENTED — docs/components/proveedor-de-identidad-northwind.md has no Inbound communication table]

---

## Estado de salida <!-- SECTION: Exit state -->

Lo que el Proveedor de Identidad Northwind garantiza al responder o emitir:

- [NOT DOCUMENTED — docs/components/proveedor-de-identidad-northwind.md has no Inbound communication table]

---

## Supuestos mutuos (vinculantes) <!-- SECTION: Mutual assumptions -->

Los supuestos listados aquí son vinculantes. Cambiar uno es un cambio de interfaz, no un cambio local.

**El upstream asume:**

- El Proveedor de Identidad Northwind publica las claves públicas JWKS con las que el Servicio de Reservas valida firma y claims de cada token (I-03).
- Las claves JWKS se pueden conservar en caché local en el Servicio de Reservas.
- Los tokens son JWT firmados con RS256, emitidos por el Proveedor de Identidad Northwind (Keycloak 25) como única fuente de autenticación ([ADR-002](../../adr/ADR-002-oidc-keycloak-identity.md)).

**El downstream asume:**

- [NOT DOCUMENTED — docs/components/proveedor-de-identidad-northwind.md has no Inbound communication table]

---

## Semántica de fallos <!-- SECTION: Failure semantics -->

Responsabilidades fila por fila ante cada condición de fallo. Las celdas del upstream y del downstream definen juntas el contrato de recuperación.

| Condition | Upstream behaviour | Downstream behaviour |
|-----------|--------------------|----------------------|
| timeout | [NOT DOCUMENTED] | [NOT DOCUMENTED] |
| downstream no disponible | Usa las claves JWKS en caché; sin claves disponibles rechaza la solicitud (deny by default) | — |
| poison message | — | [NOT DOCUMENTED] |
| fallo parcial | [NOT DOCUMENTED] | [NOT DOCUMENTED] |
| versiones incompatibles | [NOT DOCUMENTED] | [NOT DOCUMENTED] |

Clasificación de cascada (de `analysis/BLAST_RADIUS-*.md`): [NOT DOCUMENTED — run /sa-analysis:architecture-analysis blast-radius]

---

## Propiedad <!-- SECTION: Ownership -->

Datos propiedad del upstream y de solo lectura a través del contrato desde el lado del downstream. No existe propiedad mutable compartida en el sistema.

| Direction | Fields / entities |
|-----------|-------------------|
| Propiedad del upstream | Salas; reservas (con su cancelación y motivo); registro de auditoría de cancelaciones ([ADR-106](../../adr/ADR-106-retencion-de-24-meses-purga-de-datos-y.md)); claves de idempotencia con su respuesta durante 24 horas (ADR-103). Todo se guarda en la Base de Datos de Reservas (ADR-003) |
| Propiedad del downstream | [NOT DOCUMENTED — docs/components/proveedor-de-identidad-northwind.md has no data-ownership section] |
| Solo lectura (vía esta interfaz) | Claves públicas JWKS del Proveedor de Identidad Northwind (I-03); `sub`, rol `recepcion` y atributo `sede` del JWT validado (ADR-002, ADR-105) |

---

## Observabilidad en la interfaz <!-- SECTION: Observability at the interface -->

La interfaz debe poder depurarse desde cualquier extremo sin cruzar logs entre equipos.

| Signal | Requirement |
|--------|-------------|
| Correlación | per [CROSS_CUTTING_STANDARDS § Observability](../CROSS_CUTTING_STANDARDS.md#observability-conventions) |
| Métricas requeridas (ambos lados) | Métricas RED (tasa, errores, duración) por operación, según [ADR-004](../../adr/ADR-004-opentelemetry-observability.md) |
| Campos de log | JSON estructurado con `trace_id`, `span_id`, `service.name` y nivel; sin tokens ni datos personales completos ([ADR-004](../../adr/ADR-004-opentelemetry-observability.md)) |

---

## Registro de cambios <!-- SECTION: Change log -->

Los cambios de interfaz requieren un nuevo ADR — ver [Return Path](../SYSTEM_RUNTIME_VIEW.md#return-path).

| Date | Change | ADR |
|------|--------|----:|
| 2026-10-18 | Contrato de interfaz inicial | [ADR-002](../../adr/ADR-002-oidc-keycloak-identity.md) |

---

*Generado por `sa-skills:architecture-dev-handoff` el 2026-10-18*
*Fuentes: `docs/05-integration-points.md`, `analysis/BLAST_RADIUS-*.md`, `adr/`*
