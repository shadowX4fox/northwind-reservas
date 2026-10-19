[Architecture](../../../ARCHITECTURE.md) > [Components](../README.md) > [Reservas de Salas Northwind](.) > Servicio de Reservas

# Servicio de Reservas

<!-- EXPLORER_HEADER
key_concepts: microservicio de reservas, disponibilidad, creación de reserva, cancelación, validación JWT, JWKS, rol recepcion, atributo sede, contrato OpenAPI
technologies: Java 21, Spring Boot 3.3
component_self: servicio-de-reservas
component_type: api-service
scope: API REST de disponibilidad, reserva y cancelación de salas; no cubre la autenticación ni la interfaz
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-102, ADR-103, ADR-105
-->

> Servicio de Reservas es el único microservicio del sistema: expone la API REST de disponibilidad, reserva y cancelación, valida los tokens y es dueño de la Base de Datos de Reservas.

**Type:** API Service
**Technology:** [Java 21, Spring Boot 3.3]
**C4 Level:** Container (L2)
**Deploys as:** Docker container
**Communicates via:** HTTPS
**Description:** Servicio de Reservas expone la API REST de disponibilidad, reserva y cancelación de salas y aplica sus reglas.

**Component Version:** 1.1.0
**Architecture Version:** 1.0.0
**Last Updated:** 2026-10-18

**Bounded Context**: Reservas de salas — disponibilidad, creación y cancelación.
**Team Owner**: Not documented <!-- TODO: Add source reference -->

## Propósito <!-- LABEL: Purpose -->

Concentra las reglas de reserva de las 42 salas de las 3 sedes y es la única puerta a sus datos (ADR-003).

## Responsabilidades <!-- LABEL: Responsibilities -->

- Calcular la disponibilidad de salas por sede, fecha y franja.
- Crear reservas confirmadas sin superposición para la misma sala.
- Cancelar reservas: las propias del miembro, o cualquiera de su sede para el rol `recepcion`.
- Validar los tokens del Proveedor de Identidad Northwind con sus claves JWKS.

## Especificación de API <!-- LABEL: API Specification -->

**API Type**: REST sobre HTTPS con cuerpos JSON (ADR-001).
**Contrato**: OpenAPI 3.1 versionado en el repositorio del servicio, escrito antes que el código (ADR-001).
**Versión del contrato**: 1.0.0; la versión mayor va en la ruta, `/v1` (ADR-001).
**URL base**: `/v1`, detrás del ingress del clúster de Plataforma Northwind (ADR-005); host: Not documented.
**Autenticación**: JWT del Proveedor de Identidad Northwind en `Authorization: Bearer` (ADR-002); ver [Sección 9](../../07-security-architecture.md#93-controles-de-seguridad).

| Operación | Caso de uso | Endpoint | Éxito |
|---|---|---|---|
| Consultar disponibilidad | CU1 | `GET /v1/availability?site=&date=&start=&end=` | 200 `AvailabilityResponse` |
| Crear reserva | CU2 | `POST /v1/bookings` con cabecera `Idempotency-Key` ([ADR-103](../../../adr/ADR-103-idempotencia-de-la-creacion-de-reservas-con-clave.md)) | 201 `Booking`; la misma clave en 24 horas devuelve la respuesta guardada |
| Listar reservas | CU3 (páginas "Mis reservas" y "Reservas de la sede") | `GET /v1/bookings` · `GET /v1/bookings?scope=site` | 200 lista de `Booking` futuras: las propias, o las de la `sede` del token con rol `recepcion` ([ADR-105](../../../adr/ADR-105-autorizacion-por-rol-recepcion-y-atributo-sede-del.md)) |
| Cancelar reserva | CU3 | `POST /v1/bookings/{code}/cancel` | 200 `Booking` con `status: cancelled` |

**Esquemas**

| Esquema | Campos |
|---|---|
| Parámetros de CU1 | `site`: `centro` · `norte` · `puerto`; `date`: fecha ISO 8601; `start`, `end`: `HH:mm` en múltiplos de 30 minutos, duración de 8 horas o menos |
| `AvailabilityResponse` | `rooms`: lista de `RoomAvailability`; `suggestedSlots`: hasta 3 franjas `{start, end}` cuando no hay salas libres (CU1, alternativa 1) |
| `RoomAvailability` | `roomId`, `name`, `capacity`, `equipment` (`screen` · `videoconference` · `whiteboard`), `status` (`free` · `occupied`) |
| `BookingRequest` | `roomId`, `date`, `start`, `end`, `subject` (80 caracteres o menos) |
| `Booking` | `code` (`RS-` seguido de 8 caracteres alfanuméricos), `roomId`, `site`, `date`, `start`, `end`, `subject`, `memberId`, `status` (`confirmed` · `cancelled`), `cancelledBy`, `cancelledAt`, `cancellationReason` |
| `CancellationRequest` | `reason` (120 caracteres o menos; obligatorio para el rol `recepcion`, ADR-105) |

**Errores**: RFC 9457 (`application/problem+json`) con el campo `code` (ADR-001).

| `code` | HTTP | Cuándo |
|---|---|---|
| `UNAUTHENTICATED` | 401 | Token ausente, inválido o expirado (ADR-002) |
| `FORBIDDEN` | 403 | "no autorizado": reserva ajena sin rol `recepcion` de la misma `sede` (ADR-105) |
| `VALIDATION_FAILED` | 400 | Franja fuera de múltiplos de 30 minutos, de más de 8 horas o en el pasado; asunto de más de 80 caracteres; motivo de más de 120 caracteres o ausente para `recepcion` |
| `BOOKING_NOT_FOUND` | 404 | Código de reserva inexistente |
| `ROOM_OCCUPIED` | 409 | "sala ocupada" (CU2, [ADR-102](../../../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)) |
| `DAILY_LIMIT_REACHED` | 409 | "límite diario": 3 reservas futuras ese día (CU2) |
| `BOOKING_IN_PROGRESS` | 409 | "reserva en curso" (CU3, ADR-105) |

## Gestión de Datos <!-- LABEL: Data Management -->

- **Almacén**: [Base de Datos de Reservas](03-base-de-datos-de-reservas.md), de su propiedad exclusiva (ADR-003).
- **Acceso**: JDBC; ningún otro servicio lee ni escribe sus tablas (ADR-003).
- **Consistencia**: fuerte; la superposición la rechaza la base de datos ([ADR-102](../../../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).

## Dependencias <!-- LABEL: Dependencies -->

| Dependencia | Protocolo | Uso |
|---|---|---|
| [Base de Datos de Reservas](03-base-de-datos-de-reservas.md) | JDBC | Lee y escribe salas y reservas |
| [Proveedor de Identidad Northwind](../proveedor-de-identidad-northwind.md) | HTTPS (JWKS) | Claves para validar tokens |

**Consumido por**: [Portal de Reservas](01-portal-de-reservas.md).

## Despliegue <!-- LABEL: Deployment -->

- Contenedor en el clúster Kubernetes de Plataforma Northwind, con al menos 2 réplicas en zonas distintas (ADR-005).
- Solicitudes y límites de CPU y memoria, sondas de vida y de disponibilidad declaradas (ADR-005).

## Observabilidad <!-- LABEL: Observability -->

- Trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind (ADR-004).
- Contexto W3C Trace Context recibido del Portal de Reservas (ADR-004).
- Métrica de negocio: tiempo de confirmación de reservas, meta p95 ≤ 2 s (PO Spec §8).

## Capacidad <!-- LABEL: Capacity -->

| Metric | Value | Unit | Source |
|---|---|---|---|
| capacity_per_replica | Not documented | rps | |
| replicas | 2 | count | Mínimo de ADR-005 |
| max_replicas | Not documented | count | |
| requests_per_transaction | Not documented | ratio | |
| documented_demand | Not documented | rps | PO Spec §1: 310 solicitudes por semana con el proceso por correo |
