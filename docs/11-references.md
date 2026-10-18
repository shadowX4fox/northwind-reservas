# Referencias

<!-- EXPLORER_HEADER
key_concepts: registros de decisiones de arquitectura, ADR institucionales, documentos del proyecto, glosario, PO Spec, HLD
technologies: OpenAPI 3.1, OIDC, PostgreSQL 16, OpenTelemetry, Kubernetes, Keycloak 25
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas, proveedor-de-identidad-northwind
scope: Índice de ADR, enlaces a documentos del proyecto y glosario; no repite el contenido de los ADR
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005
-->

> Enlaces a los ADR, a los documentos del proyecto y a las fuentes de Reservas de Salas Northwind, más el glosario de términos del dominio.

## 12. Registros de Decisiones de Arquitectura (ADRs) <!-- SECTION: Architecture Decision Records (ADRs) -->

**Índice**: [adr/README.md](../adr/README.md).

**ADR institucionales aplicables**: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005.

### Documentos del Proyecto

| Documento | Contenido |
|---|---|
| [PRODUCT_OWNER_SPEC.md](../PRODUCT_OWNER_SPEC.md) | Especificación del Product Owner |
| [reservas-hld.mmd](../reservas-hld.mmd) | Diseño de alto nivel (Mermaid) |
| [Resumen del Sistema](01-system-overview.md) | Secciones 1 y 2 |
| [Principios de Arquitectura](02-architecture-principles.md) | Sección 3 |
| [Capas de Arquitectura](03-architecture-layers.md) | Sección 4 |
| [Patrones de Flujo de Datos](04-data-flow-patterns.md) | Sección 6 |
| [Puntos de Integración](05-integration-points.md) | Sección 7 |
| [Stack Tecnológico](06-technology-stack.md) | Sección 8 |
| [Arquitectura de Seguridad](07-security-architecture.md) | Sección 9 |
| [Escalabilidad y Rendimiento](08-scalability-and-performance.md) | Sección 10 |
| [Consideraciones Operacionales](09-operational-considerations.md) | Sección 11 |
| [Riesgos y Deuda Técnica](10-risks-and-technical-debt.md) | Sección 13 |
| [Índice de componentes](components/README.md) | Descriptores C4 |

### Especificaciones BIAN

Not applicable: el proyecto no usa alineación de capacidades.

### Documentación de Tecnologías

| Tecnología | Uso |
|---|---|
| OpenAPI 3.1 | Contrato de la API del `Servicio de Reservas` |
| OpenID Connect y PKCE | Autenticación del `Portal de Reservas` |
| Keycloak 25 | `Proveedor de Identidad Northwind` |
| PostgreSQL 16 | `Base de Datos de Reservas` |
| OpenTelemetry | Trazas, métricas y logs |
| Kubernetes | Ejecución del `Servicio de Reservas` |

### Glosario

| Término | Definición |
|---|---|
| Sede | Ubicación física de Northwind Cowork: Centro, Norte o Puerto |
| Recepción | Rol `recepcion` del token; cancela reservas de salas de su `sede` |
| Reserva doble | Dos reservas confirmadas superpuestas para la misma sala |
| PKCE | Extensión del código de autorización OIDC para aplicaciones de una página |
| JWKS | Conjunto de llaves públicas con que se valida la firma del token |
