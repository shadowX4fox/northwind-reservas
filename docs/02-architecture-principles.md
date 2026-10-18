# Principios de Arquitectura

<!-- EXPLORER_HEADER
key_concepts: principios de arquitectura, base de datos por servicio, bounded context, servicio sin estado, deny by default, idempotencia, restricción de exclusión, observabilidad, plataforma gestionada, estándares abiertos
technologies: React 18, Spring Boot 3.3, PostgreSQL 16, Flyway, Keycloak 25, OpenAPI 3.1, OpenTelemetry, Kubernetes, Helm
components: portal-de-reservas, servicio-de-reservas, base-de-datos-de-reservas, proveedor-de-identidad-northwind
scope: Reglas de decisión de Reservas de Salas Northwind y su costo; no describe componentes ni flujos
related_adrs: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-101, ADR-102, ADR-107
-->

> Nueve reglas de decisión de Reservas de Salas Northwind, cada una con su implementación y su costo. Las decisiones vienen de los ADR institucionales y de los candidatos resueltos en las Secciones 4, 5 y 8.

## Principios de Arquitectura (9 Principios Fundamentales) <!-- SECTION: Architecture Principles -->

### 1. Separación de Responsabilidades <!-- PRINCIPLE: Separation of Concerns -->

**Descripción:** <!-- LABEL: Description -->
Cada contenedor tiene una sola responsabilidad y solo el Servicio de Reservas accede a sus datos; se rechaza el acceso compartido a la base.

**Implementación:** <!-- LABEL: Implementation -->
- Portal de Reservas (React 18) presenta y autentica; las reglas de reserva viven en el Servicio de Reservas (Spring Boot 3.3).
- Database-per-service: solo el Servicio de Reservas lee y escribe la Base de Datos de Reservas, según [ADR-003](../adr/ADR-003-postgresql-relational-store.md).
- Un bounded context: disponibilidad, creación y cancelación de reservas en un microservicio, según [ADR-101](../adr/ADR-101-patron-de-arquitectura-spa-un-microservicio-dueno-de.md).
- La autenticación pertenece al Proveedor de Identidad Northwind (Keycloak 25), según [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Un reporte de ocupación no consulta PostgreSQL 16: exige una operación nueva en la API del Servicio de Reservas y su mantenimiento.
- Un ajuste de esquema, aun menor, exige una migración Flyway versionada en el repositorio del servicio ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).
- Los 2 desarrolladores backend comparten un solo servicio: cambios de disponibilidad y de cancelación salen en el mismo despliegue.

### 2. Alta Disponibilidad <!-- PRINCIPLE: High Availability -->

**Descripción:** <!-- LABEL: Description -->
Se acepta el costo de dos réplicas permanentes del Servicio de Reservas en zonas distintas en lugar de una sola réplica.

**Implementación:** <!-- LABEL: Implementation -->
- Servicio de Reservas con al menos 2 réplicas en zonas distintas del clúster Kubernetes, según [ADR-005](../adr/ADR-005-kubernetes-container-runtime.md).
- Sondas de vida y de disponibilidad sacan del tráfico una réplica fallida ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- PostgreSQL 16 gestionado por Plataforma Northwind, con respaldo diario y PITR de 7 días ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).
- Portal de Reservas servido desde el CDN de Plataforma Northwind, fuera del clúster ([ADR-107](../adr/ADR-107-publicacion-del-portal-de-reservas-como-archivos-estaticos.md)).
- Meta de 99,5 % mensual, con mantenimiento los domingos 02:00–04:00 (PO Spec §7).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- La réplica mínima adicional duplica (2x) el costo de cómputo del Servicio de Reservas para una carga baja.
- La disponibilidad de la Base de Datos de Reservas depende de Plataforma Northwind; el equipo no controla su RTO.
- El soporte cubre lunes a viernes 08:00–19:00: una falla de fin de semana espera al lunes (PO Spec §7).

### 3. Escalabilidad Primero <!-- PRINCIPLE: Scalability First -->

**Descripción:** <!-- LABEL: Description -->
Se prefiere escalar el Servicio de Reservas horizontalmente con réplicas sin estado en lugar de crecer verticalmente una instancia.

**Implementación:** <!-- LABEL: Implementation -->
- Stateless service: cada réplica valida el JWT con las claves JWKS, sin sesión de servidor, según [ADR-002](../adr/ADR-002-oidc-keycloak-identity.md).
- Kubernetes HPA por CPU sobre el Servicio de Reservas, con solicitudes y límites declarados ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- El Portal de Reservas escala con el CDN como archivos estáticos, sin réplicas propias ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- La restricción de exclusión de PostgreSQL 16 mantiene la integridad entre réplicas concurrentes ([ADR-102](../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- El HPA escala el Servicio de Reservas, no la Base de Datos de Reservas; su capacidad la dimensiona Plataforma Northwind.
- Cada réplica abre sus propias conexiones JDBC: más réplicas suman carga de conexiones sobre PostgreSQL 16.
- Cada réplica reserva CPU y memoria declaradas aunque la carga sea baja: costo de cómputo fijo por réplica ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).

### 4. Seguridad por Diseño <!-- PRINCIPLE: Security by Design -->

**Descripción:** <!-- LABEL: Description -->
Se rechaza por defecto toda solicitud sin un token válido del Proveedor de Identidad Northwind, en cada llamada al Servicio de Reservas.

**Implementación:** <!-- LABEL: Implementation -->
- Portal de Reservas: OIDC con PKCE; tokens en memoria, nunca en `localStorage` ni `sessionStorage` ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)).
- Servicio de Reservas valida cada JWT RS256 con JWKS y responde 401 sin token válido ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)).
- Autorización por el rol `recepcion` y el atributo `sede` del token (PO Spec §7).
- Credenciales de la Base de Datos de Reservas inyectadas desde el gestor de secretos del clúster ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- TLS 1.2 o superior en el Ingress del clúster ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Una recarga de página pierde los tokens en memoria y repite el flujo OIDC contra Keycloak 25.
- La validación local del JWT retrasa la baja de un rol `recepcion` hasta el vencimiento del token, hasta 5 min ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)).
- La verificación RS256 en cada solicitud agrega cómputo a cada llamada al Servicio de Reservas.

### 5. Observabilidad <!-- PRINCIPLE: Observability -->

**Descripción:** <!-- LABEL: Description -->
Se exige que todo contenedor emita trazas, métricas y logs con OpenTelemetry; un servicio sin métricas RED no pasa a producción.

**Implementación:** <!-- LABEL: Implementation -->
- Portal de Reservas y Servicio de Reservas envían telemetría OpenTelemetry al colector de Plataforma Northwind ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Distributed trace con W3C Trace Context (`traceparent`) del navegador a la Base de Datos de Reservas ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Métricas RED por operación: disponibilidad, creación y cancelación ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Logs JSON con `trace_id`, `span_id` y `service.name`, sin tokens ni datos personales completos ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- Tiempo de confirmación medido en el Portal de Reservas, meta p95 ≤ 2 s (PO Spec §8).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- El SDK de OpenTelemetry agrega peso al paquete del Portal de Reservas que descarga cada navegador.
- Excluir tokens y datos personales de los logs exige revisar cada cambio de logging: carga de mantenimiento permanente.
- Paneles y alertas dependen del colector de Plataforma Northwind, fuera del control del equipo de 4 personas.

### 6. Resiliencia <!-- PRINCIPLE: Resilience -->

**Descripción:** <!-- LABEL: Description -->
Se prefiere que el motor rechace los conflictos y que el cliente reintente con idempotencia, en lugar de coordinar bloqueos en la aplicación.

**Implementación:** <!-- LABEL: Implementation -->
- La restricción de exclusión de PostgreSQL 16 rechaza reservas superpuestas aun con réplicas concurrentes ([ADR-102](../adr/ADR-102-impedir-reservas-dobles-con-restriccion-de-exclusion-en.md)).
- El `POST` de reserva acepta `Idempotency-Key`; la misma clave en 24 horas devuelve el mismo resultado ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Tras un timeout de red, el Portal de Reservas reintenta con la misma `Idempotency-Key` sin crear una segunda reserva.
- Errores RFC 9457 con `code` estable: el Portal de Reservas distingue sala ocupada de falla transitoria ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- La sonda de vida reinicia una réplica bloqueada del Servicio de Reservas ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Sin la Base de Datos de Reservas no hay consulta ni reserva: el sistema no tiene modo degradado.
- Guardar cada clave de idempotencia y su respuesta 24 horas agrega almacenamiento y una purga al esquema ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Un conflicto de superposición aparece al confirmar: el miembro elige otra franja y repite la reserva.

### 7. Simplicidad <!-- PRINCIPLE: Simplicity -->

**Descripción:** <!-- LABEL: Description -->
Se elige un solo microservicio síncrono sin API Gateway, service mesh ni event bus hasta que un caso de uso los exija.

**Implementación:** <!-- LABEL: Implementation -->
- Tres contenedores internos: Portal de Reservas, Servicio de Reservas y Base de Datos de Reservas ([ADR-101](../adr/ADR-101-patron-de-arquitectura-spa-un-microservicio-dueno-de.md)).
- Llamadas REST síncronas sobre HTTPS para los tres casos de uso ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Integridad ante superposición declarada en PostgreSQL 16, no en código de coordinación ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).
- CDN, clúster Kubernetes y PostgreSQL 16 de Plataforma Northwind, sin infraestructura propia ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Un dominio nuevo exige separar el Servicio de Reservas y agregar enrutamiento: costo de migración diferido.
- Un recordatorio o notificación asíncrona no tiene event bus: agregarlo exige infraestructura nueva.
- Disponibilidad, creación y cancelación comparten imagen y versión: todo cambio despliega el servicio completo.

### 8. Nativo en la Nube <!-- PRINCIPLE: Cloud-Native -->

**Descripción:** <!-- LABEL: Description -->
Se delega a Plataforma Northwind la operación de cómputo, datos y publicación, aceptando sus normas en lugar de infraestructura propia.

**Implementación:** <!-- LABEL: Implementation -->
- Servicio de Reservas como container en el clúster Kubernetes, con chart de Helm e imagen firmada ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- Tráfico externo por el Ingress del clúster con TLS 1.2 o superior ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- Secretos desde el gestor de secretos del clúster, nunca en la imagen ni en el repositorio ([ADR-005](../adr/ADR-005-kubernetes-container-runtime.md)).
- PostgreSQL 16 gestionado y Portal de Reservas en el CDN de Plataforma Northwind ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Vendor lock-in interno: salir de Plataforma Northwind reescribe el chart de Helm, los secretos y la publicación.
- Plataforma Northwind fija las versiones de Kubernetes y PostgreSQL; cada actualización suya impone pruebas no planificadas.
- El equipo de 4 personas dedica parte de sus 14 semanas a capacitación en Helm y en las normas del clúster.

### 9. Estándares Abiertos <!-- PRINCIPLE: Open Standards -->

**Descripción:** <!-- LABEL: Description -->
Se prefieren protocolos abiertos —REST, OpenAPI, OIDC, OpenTelemetry— sobre productos propietarios en cada interfaz del sistema.

**Implementación:** <!-- LABEL: Implementation -->
- API REST descrita en OpenAPI 3.1, contrato escrito antes que el código y validado en CI ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Errores RFC 9457 en `application/problem+json` ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- OIDC con PKCE y JWT RS256 contra Keycloak 25 ([ADR-002](../adr/ADR-002-oidc-keycloak-identity.md)).
- Telemetría OpenTelemetry con W3C Trace Context ([ADR-004](../adr/ADR-004-opentelemetry-observability.md)).
- PostgreSQL 16 con migraciones Flyway ([ADR-003](../adr/ADR-003-postgresql-relational-store.md)).

**Compensaciones:** <!-- LABEL: Trade-offs -->
- Escribir el contrato OpenAPI 3.1 antes que el código retrasa el primer endpoint dentro de las 14 semanas.
- Un cambio incompatible publica `/v2` y mantiene `/v1` al menos 90 días: dos versiones en mantenimiento ([ADR-001](../adr/ADR-001-rest-openapi-apis.md)).
- Sin agente APM propietario, los paneles de diagnóstico se construyen sobre OpenTelemetry: trabajo propio del equipo.

<!-- PRINCIPLE_REVIEW: PASS 2026-10-18 sha256:d13050fdf1f0 -->
