# ADR-001: APIs síncronas REST con contrato OpenAPI

| Campo | Valor |
|-------|-------|
| **Estado** | Accepted |
| **Fecha** | 2026-03-02 |
| **Autores** | Equipo de Arquitectura Northwind |
| **Deciden** | Comité de Arquitectura Northwind |
| **Alcance** | Institucional |

## Contexto

Los equipos de Northwind publican APIs con formatos distintos: algunas con JSON sin contrato, otras con RPC propio. Cada integración nueva exige leer el código del otro equipo.

## Decisión

- Toda API síncrona entre un canal y un servicio es REST sobre HTTPS con cuerpos JSON.
- Cada API se describe con un contrato OpenAPI 3.1 versionado en el repositorio del servicio; el contrato se escribe antes que el código.
- La versión mayor va en la ruta (`/v1/…`); un cambio incompatible publica `/v2` y mantiene `/v1` al menos 90 días.
- Los errores siguen RFC 9457 (`application/problem+json`) con un campo `code` estable.
- Toda operación que crea un recurso acepta la cabecera `Idempotency-Key`; la misma clave en 24 horas devuelve el mismo resultado.

## Justificación

- Un contrato explícito permite construir el consumidor y el proveedor en paralelo.
- RFC 9457 da a los canales un formato único de error.

## Consecuencias

- Cada servicio mantiene su contrato OpenAPI y lo valida en CI.
- Las operaciones de creación guardan la clave de idempotencia y su respuesta 24 horas.

## Alternativas

| Alternativa | Motivo del descarte |
|-------------|---------------------|
| gRPC entre canal y servicio | El navegador no habla gRPC sin un proxy adicional |
| GraphQL | Ningún equipo tiene experiencia; un esquema por servicio no aporta en APIs pequeñas |
