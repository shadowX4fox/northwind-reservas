# Technical Debt Records

Registros de deuda técnica (TDR), formato breve según https://www.workingsoftware.dev/technical-debt-records/. Los ADR capturan *por qué se tomó una decisión*; los TDR capturan *qué se difirió o aceptó como subóptimo y cuánto costará después*.

## Index

| ID      | Title                                                             | Status | Driver       | Owner                          |
|---------|-------------------------------------------------------------------|--------|--------------|--------------------------------|
| TDR-001 | La consulta de disponibilidad se sirve de una caché de 5 minutos | Resolved | Architecture | Equipo del Servicio de Reservas |
| TDR-002 | Las claves de idempotencia vencidas nunca se purgan               | Resolved | Architecture | Equipo del Servicio de Reservas |
| TDR-003 | Los avisos de disponibilidad perdidos al reconectar LISTEN dejan la caché desactualizada hasta 5 minutos | Resolved | Architecture | Equipo del Servicio de Reservas |
| TDR-004 | Zona horaria de las sedes leída de una variable de despliegue | In Progress | Architecture | Servicio de Reservas — Team Owner: Not documented (spec línea 9) |
