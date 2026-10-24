<!-- managed by sa-skills:architecture-dev-handoff — do not edit manually -->
[Architecture](../ARCHITECTURE.md) > Development Handoffs

# Kit de Entrega a Desarrollo — Reservas de Salas Northwind - Autoservicio de reservas de salas de reunión

Kit de cuatro partes. Lee los documentos compartidos junto con tu Especificación de Componente.

## Documentos compartidos

| Documento | Generado |
|---|---|
| [SYSTEM_RUNTIME_VIEW.md](SYSTEM_RUNTIME_VIEW.md) | 2026-10-20 |
| [CROSS_CUTTING_STANDARDS.md](CROSS_CUTTING_STANDARDS.md) | 2026-10-20 |

## Referencia rápida — orden de lectura por rol

| Si eres… | Lee en este orden |
|---|---|
| **Dev** (construyes cada componente) | 1) tu Especificación de Componente §§ 1–4, 7, 8 · 2) cada Contrato de Interfaz listado en § 2 · 3) Estándares Transversales § Semántica de errores, Idempotencia, Resiliencia · 4) Vista de Ejecución § Flujos, para los flujos que cita § 2 |
| **QA** (pruebas cada componente) | 1) tu Especificación de Componente §§ 3, 4, 5, 9 · 2) cada Contrato de Interfaz § Semántica de fallos + Estado de entrada/salida · 3) Estándares Transversales § Idempotencia, Observabilidad · 4) los assets de contrato de `assets/NN-<slug>/` (`openapi.yaml`, `asyncapi.yaml`, `schema.graphql`, …) |
| **Ops / SRE** (despliegas y operas cada componente) | 1) Vista de Ejecución § Descomposición del presupuesto + § Postura ante fallos · 2) cada Contrato de Interfaz § Semántica de fallos + § Observabilidad · 3) Estándares Transversales § Observabilidad, Resiliencia, Datos · 4) tu Especificación de Componente §§ 5, 7, 10 (Assets) |
| **Arquitecto** (validas el kit) | 1) Vista de Ejecución completa · 2) Estándares Transversales (inventario de reglas + tabla de Desviaciones) · 3) cada Contrato de Interfaz (continuidad) · 4) `handoffs/.manifest.json` para saber qué se regeneró en esta corrida |

## Contratos de interfaz

| # | Arista | Contrato de Interfaz | ADR relacionados | Generado |
|---|---|---|---|---|
| 1 | Portal de Reservas → Proveedor de Identidad Northwind | [portal-de-reservas→proveedor-de-identidad-northwind.md](interfaces/portal-de-reservas→proveedor-de-identidad-northwind.md) | ADR-002, ADR-004, ADR-104 | 2026-10-20 |
| 2 | Portal de Reservas → Servicio de Reservas | [portal-de-reservas→servicio-de-reservas.md](interfaces/portal-de-reservas→servicio-de-reservas.md) | ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-102, ADR-103, ADR-104, ADR-105, ADR-106, ADR-109 | 2026-10-20 |
| 3 | Servicio de Reservas → Base de Datos de Reservas | [servicio-de-reservas→base-de-datos-de-reservas.md](interfaces/servicio-de-reservas→base-de-datos-de-reservas.md) | ADR-102, ADR-003, ADR-103, ADR-106, ADR-004, ADR-109 | 2026-10-20 |
| 4 | Servicio de Reservas → Proveedor de Identidad Northwind | [servicio-de-reservas→proveedor-de-identidad-northwind.md](interfaces/servicio-de-reservas→proveedor-de-identidad-northwind.md) | ADR-002, ADR-003, ADR-004, ADR-103, ADR-105, ADR-106 | 2026-10-20 |

## Especificaciones de Componente

| # | Componente | Especificación de Componente | Estado | Assets | Generado |
|---|---|---|---|---|---|
| 5.1 | Portal de Reservas | [01-portal-de-reservas.md](components/01-portal-de-reservas.md) | Ready | [c4-descriptor.md](assets/01-portal-de-reservas/c4-descriptor.md), [security.md](assets/01-portal-de-reservas/security.md) | 2026-10-24 |
| 5.2 | Servicio de Reservas | [02-servicio-de-reservas.md](components/02-servicio-de-reservas.md) | Ready | [openapi.yaml](assets/02-servicio-de-reservas/openapi.yaml), [c4-descriptor.md](assets/02-servicio-de-reservas/c4-descriptor.md), [security.md](assets/02-servicio-de-reservas/security.md) | 2026-10-24 |
| 5.3 | Base de Datos de Reservas | [03-base-de-datos-de-reservas.md](components/03-base-de-datos-de-reservas.md) | Ready | [ddl.sql](assets/03-base-de-datos-de-reservas/ddl.sql), [c4-descriptor.md](assets/03-base-de-datos-de-reservas/c4-descriptor.md), [security.md](assets/03-base-de-datos-de-reservas/security.md) | 2026-10-20 |

## Documentación relacionada

- [ARCHITECTURE.md](../ARCHITECTURE.md) — índice de navegación de la arquitectura
- [docs/components/README.md](../docs/components/README.md) — índice de componentes C4 L2
- [docs/05-integration-points.md](../docs/05-integration-points.md) — inventario de integraciones `I-nn`
- [adr/](../adr/) — decisiones de arquitectura citadas a lo largo del kit
