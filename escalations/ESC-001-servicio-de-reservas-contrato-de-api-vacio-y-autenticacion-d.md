---
id: ESC-001
status: Open
date: 2026-10-19
architecture: architecture-v1.0.0
route: tier-1
triggers: [security-iam, low-confidence]
components: [Servicio de Reservas, Portal de Reservas, Proveedor de Identidad Northwind, Base de Datos de Reservas]
integrations: [I-02, I-03, I-04]
adrs: [ADR-001, ADR-002, ADR-005, ADR-102, ADR-103, ADR-105]
tdrs: []
requested_by: shadowX4fox (equipo de desarrollo del Servicio de Reservas)
issue: https://github.com/shadowX4fox/northwind-reservas/issues/5
resolution:
closed:
---
# ESC-001 — Servicio de Reservas: contrato de API vacío y autenticación de I-02/I-03/I-04 sin documentar bloquean la construcción

## Request

```text
sí, adelante
```

## Why it needs an architect

| Trigger | Evidence |
|---|---|
| security-iam | build pack servicio-de-reservas, part security, líneas 11, 19 y 20 — La autenticación de I-02, I-03 e I-04 está como NOT DOCUMENTED; I-02 debe fallar cerrada y el servicio no puede atender ninguna llamada |
| low-confidence | build pack servicio-de-reservas, part asset:openapi.yaml, líneas 19, 20, 21 y 31 — El contrato OpenAPI no tiene operaciones ni esquemas: no hay nada que implementar sin inventar el contrato |

**Route**: Tier 1 — SA office hours.

## What the AI would propose (not applied)

- Nothing proposed.

## Open questions for the architect

- [Bloqueante] ¿Cuál es el método y la ruta de "Consultar disponibilidad" (CU1)? — asset:openapi.yaml línea 19
- [Bloqueante] ¿Cuál es el método y la ruta de "Crear reserva" (CU2), con la cabecera Idempotency-Key de ADR-103? — asset:openapi.yaml línea 20
- [Bloqueante] ¿Cuál es el método y la ruta de "Cancelar reserva" (CU3), incluido el motivo de hasta 120 caracteres de recepción (ADR-105)? — asset:openapi.yaml línea 21
- [Bloqueante] ¿Cuáles son los esquemas de solicitud y respuesta (components.schemas está vacío) y los valores del campo `code` de los errores RFC 9457 (ADR-001)? — asset:openapi.yaml línea 31
- [Bloqueante] ¿Cómo se autentica I-02 (Portal de Reservas → Servicio de Reservas)? ADR-002 fija JWT RS256 con JWKS y la Especificación de Componente lo recoge como INV-04, pero docs/07-security-architecture.md no lo declara para I-02; hasta entonces la interfaz falla cerrada — security línea 11
- [Bloqueante] ¿Cómo se autentica I-03 (Servicio de Reservas → Proveedor de Identidad Northwind, lectura de JWKS)? Además I-03 no tiene Interface Contract — security línea 19
- [Bloqueante] ¿Cómo se autentica I-04 (Servicio de Reservas → Base de Datos de Reservas)? ADR-005 dice que las credenciales salen del gestor de secretos del clúster, pero el mecanismo de I-04 no está declarado — security línea 20
- ¿Cuál es la versión de la API (info.version es NOT-DOCUMENTED) y la versión del contrato en la Especificación de Componente § 3? — asset:openapi.yaml línea 5; spec línea 112
- ¿Cuál es la URL base del servidor (servers omitido)? — asset:openapi.yaml línea 13
- ¿Cuál es el presupuesto de latencia de cada fase (2 Validación del token, 3 Consulta de disponibilidad, 4 Creación de reserva, 5 Cancelación de reserva)? Solo están las metas del flujo completo (≤ 1 s y ≤ 2 s p95) — runtime-view; BUILD.md § Flows
- ¿Cuáles son la latencia p99, el error budget, el throughput pico y sostenido y el techo de costo? — spec líneas 140–144
- ¿Cuál es la semántica de fallo de I-02: política de reintento y presupuesto ante timeout, downstream no disponible, fallo parcial y versiones incompatibles? — interface:portal-de-reservas→servicio-de-reservas líneas 120–124
- ¿Qué amenazas STRIDE debe mitigar la construcción? — security línea 53
- ¿Cuál es la clasificación de los datos que maneja el componente? — security línea 57
- ADR-102, ADR-103 y ADR-105 están Proposed: ¿se construye sobre ellos o se espera su aceptación? ADR-105 rige la cancelación pero no está en el build pack — adr:ADR-102, adr:ADR-103
- [Menor] ¿Qué equipo es el responsable (campo Owner)? — spec línea 9; asset:c4-descriptor.md
- [Menor] ¿Cuáles son el host, la IP, el SO y el dominio para la CMDB? — asset:c4-descriptor.md (docs/09-operational-considerations.md)
- [Menor] Falta la referencia del contrato en docs/05-integration-points.md, las tablas Inbound/Outbound de 01-portal-de-reservas.md y 02-servicio-de-reservas.md, las garantías de orden y la propiedad de datos del upstream — interface:portal-de-reservas→servicio-de-reservas líneas 33, 82, 104, 109, 136, 138
- [Menor] ¿Qué ID tienen los diagramas en el registro? — spec línea 82; interface:portal-de-reservas→servicio-de-reservas línea 58

## Resolution

- Pending.
