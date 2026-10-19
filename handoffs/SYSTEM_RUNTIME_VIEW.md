# Vista de Ejecución del Sistema — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión

<!-- managed by sa-skills:architecture-dev-handoff — do not edit manually -->
<!-- TEMPLATE_VERSION: 4.3.1 -->
| Field | Value |
|-------|-------|
| Versión | 4.3.1 |
| Responsable | Equipo de Arquitectura Northwind |
| Estado | draft |
| Versión de la arquitectura | 1.0.0 |
| Generado | 2026-10-18 |
| Proyecto | Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión |

### Índice por Rol <!-- SECTION: Role Quick Index -->

| Audience | Read first in this document |
|----------|-----------------------------|
| **Arquitecto** | Alcance → Flujos → Descomposición del Presupuesto → Justificación de Aristas → Ruta de Retorno |
| **Dev** | Flujos (los flujos donde participa) → Justificación de Aristas (aristas de su componente) |
| **Ops / SRE** | Descomposición del Presupuesto → Postura de Fallo → Ruta de Retorno |

El orden de lectura de los cuatro documentos del kit está en `handoffs/README.md`.

La Vista de Ejecución del Sistema es el **guion de todo el sistema**: la vista compartida que cada equipo de servicio recibe junto a su Especificación de Componente. Nombra cada arista, su justificación y el ADR que la decidió. Obliga a descomponer el presupuesto por salto, de modo que ningún equipo asuma que es dueño del SLO de extremo a extremo.

---

## Alcance <!-- SECTION: Scope -->

**En alcance**

- Portal de Reservas
- Servicio de Reservas
- Base de Datos de Reservas

**Fuera de alcance** (se nombra de forma explícita para que la ausencia no sea ambigua)

No se documentan componentes fuera de alcance.

---

## Flujos <!-- SECTION: Flows -->

Por cada flujo significativo de extremo a extremo: disparador, ruta, enlace al diagrama de secuencia, presupuesto global y postura de fallo. Los componentes de la ruta usan el nombre canónico.

### F-01 — Consultar disponibilidad

- **Trigger:** El miembro abre "Salas" o cambia sede, fecha o franja
- **Path:** Portal de Reservas → Proveedor de Identidad Northwind → Portal de Reservas → Servicio de Reservas → Proveedor de Identidad Northwind → Servicio de Reservas → Base de Datos de Reservas
- **Phases:** 1 (Inicio de sesión) → 2 (Validación del token) → 3 (Consulta de disponibilidad)
- **Sequence:** [docs/04-data-flow-patterns.md#flujo-1--consultar-disponibilidad](../docs/04-data-flow-patterns.md#flujo-1--consultar-disponibilidad)
- **Global budget:** ≤ 1 s p95
- **Governed by:** ADR-001, ADR-002
- **Failure posture:** fase 1: Proveedor no disponible: sin sesión no hay operación · fase 2: Token ausente, inválido o vencido: 401 · fase 3: Base no disponible: error 5xx
- **Delta:** solo lectura; con ninguna sala libre, el portal muestra las 3 franjas de 30 minutos más cercanas con una sala libre.

```mermaid
sequenceDiagram
  actor MIE as Miembro del cowork
  participant POR as Portal de Reservas
  participant IDP as Proveedor de Identidad Northwind
  participant SRV as Servicio de Reservas
  participant BDR as Base de Datos de Reservas
  MIE->>POR: 1.1 Abre el portal
  POR->>IDP: 1.2 Redirige con código de autorización y PKCE
  IDP-->>POR: 1.3 Devuelve el código tras el inicio de sesión
  POR->>IDP: 1.4 Canjea el código con el verificador PKCE
  IDP-->>POR: 1.5 Devuelve los tokens de acceso y de refresco
  POR->>POR: 1.6 Guarda los tokens en memoria
  POR->>SRV: 2.1 Envía la solicitud con el token de acceso
  opt Claves JWKS no cargadas
  SRV->>IDP: 2.2 Pide las claves públicas JWKS
  IDP-->>SRV: 2.3 Devuelve las claves
  end
  SRV->>SRV: 2.4 Valida firma RS256 y vigencia del token
  alt Token inválido o ausente
  SRV-->>POR: 2.5 Responde 401
  end
  SRV->>BDR: 3.1 Lee las salas de la sede y sus reservas confirmadas en la franja
  BDR-->>SRV: 3.2 Devuelve salas, capacidad, equipamiento y ocupación
  SRV-->>POR: 3.3 Devuelve cada sala libre u ocupada
  POR->>POR: 3.4 Muestra primero las libres, por capacidad ascendente
```

### F-02 — Reservar una sala

- **Trigger:** El miembro pulsa "Reservar" y confirma
- **Path:** Portal de Reservas → Servicio de Reservas → Proveedor de Identidad Northwind → Servicio de Reservas → Base de Datos de Reservas
- **Phases:** 2 (Validación del token) → 4 (Creación de reserva)
- **Sequence:** [docs/04-data-flow-patterns.md#flujo-2--reservar-una-sala](../docs/04-data-flow-patterns.md#flujo-2--reservar-una-sala)
- **Global budget:** ≤ 2 s p95
- **Governed by:** ADR-001, ADR-003
- **Failure posture:** fase 2: Token ausente, inválido o vencido: 401 · fase 4: Superposición o límite diario: rechazo de negocio
- **Delta:** única escritura con clave de idempotencia; la superposición la rechaza la Base de Datos de Reservas, no el código.

```mermaid
sequenceDiagram
  participant POR as Portal de Reservas
  participant SRV as Servicio de Reservas
  participant IDP as Proveedor de Identidad Northwind
  participant BDR as Base de Datos de Reservas
  POR->>SRV: 2.1 Envía la solicitud con el token de acceso
  opt Claves JWKS no cargadas
  SRV->>IDP: 2.2 Pide las claves públicas JWKS
  IDP-->>SRV: 2.3 Devuelve las claves
  end
  SRV->>SRV: 2.4 Valida firma RS256 y vigencia del token
  alt Token inválido o ausente
  SRV-->>POR: 2.5 Responde 401
  end
  SRV->>BDR: 4.1 Busca la clave de idempotencia
  alt Clave ya registrada
  BDR-->>SRV: 4.2 Devuelve la respuesta guardada
  else Clave nueva
  SRV->>BDR: 4.3 Cuenta las reservas futuras del miembro ese día
  SRV->>BDR: 4.4 Inserta la reserva confirmada y la clave
  BDR-->>SRV: 4.5 Acepta o rechaza por superposición
  end
  SRV-->>POR: 4.6 Devuelve el código de reserva o el problema RFC 9457
```

### F-03 — Cancelar una reserva

- **Trigger:** El miembro o el recepcionista pulsa "Cancelar" y confirma
- **Path:** Portal de Reservas → Servicio de Reservas → Proveedor de Identidad Northwind → Servicio de Reservas → Base de Datos de Reservas
- **Phases:** 2 (Validación del token) → 5 (Cancelación de reserva)
- **Sequence:** [docs/04-data-flow-patterns.md#flujo-3--cancelar-una-reserva](../docs/04-data-flow-patterns.md#flujo-3--cancelar-una-reserva)
- **Global budget:** ≤ 2 s p95
- **Governed by:** ADR-002
- **Failure posture:** fase 2: Token ausente, inválido o vencido: 401 · fase 5: No autorizado o reserva en curso: rechazo de negocio
- **Delta:** la autorización depende del dueño o del rol recepcion con el atributo sede del token.

```mermaid
sequenceDiagram
  participant POR as Portal de Reservas
  participant SRV as Servicio de Reservas
  participant IDP as Proveedor de Identidad Northwind
  participant BDR as Base de Datos de Reservas
  POR->>SRV: 2.1 Envía la solicitud con el token de acceso
  opt Claves JWKS no cargadas
  SRV->>IDP: 2.2 Pide las claves públicas JWKS
  IDP-->>SRV: 2.3 Devuelve las claves
  end
  SRV->>SRV: 2.4 Valida firma RS256 y vigencia del token
  alt Token inválido o ausente
  SRV-->>POR: 2.5 Responde 401
  end
  SRV->>BDR: 5.1 Lee la reserva
  BDR-->>SRV: 5.2 Devuelve dueño, sede, estado e inicio
  SRV->>SRV: 5.3 Verifica dueño o rol recepcion de esa sede
  alt No autorizado o reserva en curso
  SRV-->>POR: 5.4 Rechaza con el motivo
  else Autorizado
  SRV->>BDR: 5.5 Cambia el estado a Cancelada con autor, hora y motivo
  SRV-->>POR: 5.6 Confirma la cancelación
  end
```

---

## Catálogo de Fases <!-- SECTION: Phase Catalog -->

Cada fase que ejecutan los flujos anteriores, dibujada una sola vez. Un paso `4.2` en cualquier imagen principal es el paso 2 de la Fase 4 de este catálogo.
`Used by` es el índice inverso: los flujos que alcanza un cambio en esa fase.

### Phase 1 — Inicio de sesión
- Used by: F-01

```mermaid
sequenceDiagram
    actor MIE as Miembro del cowork
    participant POR as Portal de Reservas
    participant IDP as Proveedor de Identidad Northwind
    MIE->>POR: 1. Abre el portal
    POR->>IDP: 2. Redirige con código de autorización y PKCE
    IDP-->>POR: 3. Devuelve el código tras el inicio de sesión
    POR->>IDP: 4. Canjea el código con el verificador PKCE
    IDP-->>POR: 5. Devuelve los tokens de acceso y de refresco
    POR->>POR: 6. Guarda los tokens en memoria
```

### Phase 2 — Validación del token
- Used by: F-01, F-02, F-03

```mermaid
sequenceDiagram
    participant POR as Portal de Reservas
    participant SRV as Servicio de Reservas
    participant IDP as Proveedor de Identidad Northwind
    POR->>SRV: 1. Envía la solicitud con el token de acceso
    opt Claves JWKS no cargadas
        SRV->>IDP: 2. Pide las claves públicas JWKS
        IDP-->>SRV: 3. Devuelve las claves
    end
    SRV->>SRV: 4. Valida firma RS256 y vigencia del token
    alt Token inválido o ausente
        SRV-->>POR: 5. Responde 401
    end
```

### Phase 3 — Consulta de disponibilidad
- Used by: F-01

```mermaid
sequenceDiagram
    participant POR as Portal de Reservas
    participant SRV as Servicio de Reservas
    participant BDR as Base de Datos de Reservas
    SRV->>BDR: 1. Lee las salas de la sede y sus reservas confirmadas en la franja
    BDR-->>SRV: 2. Devuelve salas, capacidad, equipamiento y ocupación
    SRV-->>POR: 3. Devuelve cada sala libre u ocupada
    POR->>POR: 4. Muestra primero las libres, por capacidad ascendente
```

### Phase 4 — Creación de reserva
- Used by: F-02

```mermaid
sequenceDiagram
    participant POR as Portal de Reservas
    participant SRV as Servicio de Reservas
    participant BDR as Base de Datos de Reservas
    SRV->>BDR: 1. Busca la clave de idempotencia
    alt Clave ya registrada
        BDR-->>SRV: 2. Devuelve la respuesta guardada
    else Clave nueva
        SRV->>BDR: 3. Cuenta las reservas futuras del miembro ese día
        SRV->>BDR: 4. Inserta la reserva confirmada y la clave
        BDR-->>SRV: 5. Acepta o rechaza por superposición
    end
    SRV-->>POR: 6. Devuelve el código de reserva o el problema RFC 9457
```

### Phase 5 — Cancelación de reserva
- Used by: F-03

```mermaid
sequenceDiagram
    participant POR as Portal de Reservas
    participant SRV as Servicio de Reservas
    participant BDR as Base de Datos de Reservas
    SRV->>BDR: 1. Lee la reserva
    BDR-->>SRV: 2. Devuelve dueño, sede, estado e inicio
    SRV->>SRV: 3. Verifica dueño o rol recepcion de esa sede
    alt No autorizado o reserva en curso
        SRV-->>POR: 4. Rechaza con el motivo
    else Autorizado
        SRV->>BDR: 5. Cambia el estado a Cancelada con autor, hora y motivo
        SRV-->>POR: 6. Confirma la cancelación
    end
```

---

## Descomposición del Presupuesto <!-- SECTION: Budget Decomposition -->

Cada número global se asigna a números por salto. Las asignaciones deben sumar dentro de la restricción global de cada flujo. El margen sin asignar se declara de forma explícita.

Sin análisis de latency-budget. Las filas reproducen los objetivos declarados en `docs/04-data-flow-patterns.md` § Presupuesto de latencia. Los saltos sin cifra quedan como brecha.

### F-01 — Consultar disponibilidad

| Hop | Component | p99 allocation | Error budget | Notes |
|----:|-----------|---------------:|-------------:|-------|
| 1 | CDN → navegador (primera carga) | ≤ 2,5 s LCP p75 en 4G (PO Spec §8) | — | objetivo documentado — sin análisis de latency-budget |
| 2 | Portal de Reservas → Servicio de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 3 | Servicio de Reservas → Base de Datos de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 4 | Servicio de Reservas → Proveedor de Identidad Northwind (JWKS) | Fuera del camino crítico salvo carga de claves | — | objetivo documentado — sin análisis de latency-budget |
|   | **Sum** | **≤ 1 s consulta; ≤ 2 s reserva y cancelación (PO Spec §8)** | — | total p95 de la tabla; global del flujo ≤ 1 s p95 |

### F-02 — Reservar una sala

| Hop | Component | p99 allocation | Error budget | Notes |
|----:|-----------|---------------:|-------------:|-------|
| 1 | CDN → navegador (primera carga) | ≤ 2,5 s LCP p75 en 4G (PO Spec §8) | — | objetivo documentado — sin análisis de latency-budget |
| 2 | Portal de Reservas → Servicio de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 3 | Servicio de Reservas → Base de Datos de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 4 | Servicio de Reservas → Proveedor de Identidad Northwind (JWKS) | Fuera del camino crítico salvo carga de claves | — | objetivo documentado — sin análisis de latency-budget |
|   | **Sum** | **≤ 1 s consulta; ≤ 2 s reserva y cancelación (PO Spec §8)** | — | total p95 de la tabla; global del flujo ≤ 2 s p95 |

### F-03 — Cancelar una reserva

| Hop | Component | p99 allocation | Error budget | Notes |
|----:|-----------|---------------:|-------------:|-------|
| 1 | CDN → navegador (primera carga) | ≤ 2,5 s LCP p75 en 4G (PO Spec §8) | — | objetivo documentado — sin análisis de latency-budget |
| 2 | Portal de Reservas → Servicio de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 3 | Servicio de Reservas → Base de Datos de Reservas | [NOT DOCUMENTED — run /sa-analysis:architecture-analysis latency-budget] | — | objetivo documentado — sin análisis de latency-budget |
| 4 | Servicio de Reservas → Proveedor de Identidad Northwind (JWKS) | Fuera del camino crítico salvo carga de claves | — | objetivo documentado — sin análisis de latency-budget |
|   | **Sum** | **≤ 1 s consulta; ≤ 2 s reserva y cancelación (PO Spec §8)** | — | total p95 de la tabla; global del flujo ≤ 2 s p95 |

---

## Justificación de Aristas <!-- SECTION: Edge Rationale -->

Cada arista del diagrama lleva una línea y un enlace al ADR. No hay aristas sin explicar: si una arista carece de justificación, el diseño no está listo para el traspaso.

| Edge | Style | Rationale (one line) | Decision |
|------|-------|----------------------|---------:|
| Portal de Reservas → Proveedor de Identidad Northwind | sync | Autenticación del usuario (I-01) | [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md) |
| Portal de Reservas → Servicio de Reservas | sync | Consulta, reserva y cancelación (I-02) | ADR-103, [ADR-001](../adr/ADR-001-rest-openapi-apis.md) |
| Servicio de Reservas → Proveedor de Identidad Northwind | sync | Validación de tokens (I-03) | [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md) |
| Servicio de Reservas → Base de Datos de Reservas | sync | Persistencia de reservas (I-04) | ADR-102, [ADR-003](../adr/ADR-003-postgresql-relational-store.md) |

---

## Postura de Fallo de un Vistazo <!-- SECTION: Failure Posture at a Glance -->

Resumen entre flujos del comportamiento en cascada y la postura de mamparos. Procede de `analysis/BLAST_RADIUS-*.md`.

No se encontró análisis de Blast Radius — ejecute /sa-analysis:architecture-analysis blast-radius para poblar esta sección.

---

## Ruta de Retorno <!-- SECTION: Return Path -->

La analogía del guion es de un solo sentido; el software no. El equipo más cercano a la ejecución suele ver lo que el arquitecto no vio. Esta sección nombra cómo cuestionar la vista de ejecución después del traspaso.

- **Interface Challenge** — una suposición de un Contrato de Interfaz es errónea o inimplementable. Se plantea antes de implementar. La resolución actualiza el Contrato de Interfaz y, si cambia el estilo de interacción, produce un ADR nuevo.
- **Budget Challenge** — una asignación no es alcanzable. La resolución vuelve a descomponer el flujo; la restricción global solo se renegocia con su dueño.
- **Standards Exception** — una regla global no encaja. Se registra como desviación fechada y con vencimiento en [`CROSS_CUTTING_STANDARDS.md § Deviations`](CROSS_CUTTING_STANDARDS.md#deviations). Nunca como una desviación local silenciosa.
- **Finding** — cualquier otro hallazgo durante la construcción que invalide la vista de ejecución. Se registra contra el flujo y se prioriza en la siguiente revisión de arquitectura.

Todo lo anterior tiene un dueño nombrado y un registro de decisión. Los hilos de Slack no son una ruta de retorno.

---

*Generado por `sa-skills:architecture-dev-handoff` el 2026-10-18*
*Fuente: /home/shadowx4fox/Project/Personal/northwind-reservas/ARCHITECTURE.md*
