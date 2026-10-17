# ADR-004: Observabilidad con OpenTelemetry

| Campo | Valor |
|-------|-------|
| **Estado** | Accepted |
| **Fecha** | 2026-03-02 |
| **Autores** | Equipo de Arquitectura Northwind |
| **Deciden** | Comité de Arquitectura Northwind |
| **Alcance** | Institucional |

## Contexto

Los incidentes de 2025 tardaron en diagnosticarse porque cada servicio registraba trazas y métricas con su propio formato.

## Decisión

- Todo servicio y aplicación web emite trazas, métricas y logs con OpenTelemetry hacia el colector de Plataforma Northwind.
- La propagación de contexto usa W3C Trace Context (`traceparent`) en cada llamada HTTP, desde el navegador hasta la base de datos.
- Los logs son JSON estructurado con `trace_id`, `span_id`, `service.name` y nivel; nunca incluyen tokens ni datos personales completos.
- Cada servicio publica las métricas RED (tasa, errores, duración) por operación.

## Justificación

- Un formato único permite seguir una solicitud de punta a punta.

## Consecuencias

- Un servicio sin trazas ni métricas RED no pasa a producción.

## Alternativas

| Alternativa | Motivo del descarte |
|-------------|---------------------|
| Agente propietario de APM | Atadura a un proveedor y costo por host |
