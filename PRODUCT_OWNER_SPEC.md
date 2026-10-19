<!-- ARCHITECTURE_SYNC: 1.1.0 (2026-10-19) -->
# Reservas de Salas Northwind - Product Owner Specification

> Portal web donde los miembros de Northwind Cowork consultan la disponibilidad de salas de reunión, las reservan y cancelan sus reservas sin pasar por recepción.

**Product Owner**: Gerencia de Producto Digital — Northwind Cowork *(empresa ficticia)*
**Date**: 2026-10-19
**Version**: 1.1

---

## 1. Contexto de Negocio <!-- SECTION: Business Context -->

### Planteamiento del Problema <!-- SECTION: Problem Statement -->

**Situación actual:**
- Las 42 salas de reunión de las 3 sedes de Northwind Cowork (Centro, Norte y Puerto) se reservan por correo a recepción, que registra cada reserva en una hoja de cálculo compartida por sede.
- Recepción atiende en promedio 310 solicitudes de reserva por semana y dedica 26 horas semanales a registrarlas, confirmarlas y cancelarlas.
- En agosto de 2026 se registraron 37 reservas dobles (dos miembros con la misma sala a la misma hora), que generaron 37 reclamos y 11 bonificaciones de un día de membresía.
- El miembro no sabe si una sala está libre hasta que recepción responde; la mediana de respuesta es de 2 horas 40 minutos en horario hábil.

**Situación deseada:**
- El miembro ve la disponibilidad de todas las salas de las 3 sedes en tiempo real y reserva en menos de 1 minuto, las 24 horas.
- El sistema impide por construcción dos reservas confirmadas de la misma sala con horarios superpuestos.
- Recepción deja de registrar reservas y solo atiende excepciones.

### Contexto de Mercado <!-- SECTION: Market Context -->

**Tendencias de la industria:**
- Los espacios de trabajo compartido de la región ofrecen autoservicio de reservas desde 2024; el autoservicio es un criterio de elección citado por el 64 % de los prospectos en la encuesta comercial de junio de 2026.

**Panorama competitivo:**
- Los dos competidores directos en la ciudad ofrecen reservas web con confirmación inmediata. Northwind es el único operador de la zona que todavía confirma por correo.

### Alineación Estratégica <!-- SECTION: Strategic Alignment -->

**Objetivos estratégicos:**
- Plan 2027 de Northwind Cowork: digitalizar los servicios de recepción y liberar el 50 % del tiempo de recepción para atención comercial.

**Oportunidad:**
- La temporada de renovación de membresías empieza el 2027-02-01; el portal debe estar en producción antes de esa fecha.

---

## 2. Stakeholders y Usuarios <!-- SECTION: Stakeholders and Users -->

### Stakeholders Principales <!-- SECTION: Primary Stakeholders -->

| Stakeholder | Role | Interest/Concern | Influence Level |
|-------------|------|------------------|-----------------|
| Dirección de Operaciones | Patrocinador | Menos horas de recepción, cero reservas dobles | High |
| Recepción de sedes (6 personas) | Usuario interno | Dejar de registrar reservas a mano | Medium |
| Equipo de Plataforma Northwind | Opera la infraestructura | Un servicio más que operar en el clúster existente | Medium |
| Seguridad de la Información | Control | Autenticación con el proveedor de identidad corporativo | High |

### Personas de Usuario <!-- SECTION: User Personas -->

#### Persona 1: Miembro del cowork

**Perfil**: profesional independiente o empleado de una empresa cliente, de 24 a 55 años, que usa una sala entre 2 y 8 veces al mes desde el navegador del portátil o del teléfono.

**Objetivos**: encontrar una sala libre para una hora concreta y tener la confirmación al instante.

**Frustraciones**: esperar la respuesta de recepción y llegar a una sala ocupada por una reserva doble.

#### Persona 2: Recepcionista de sede

**Perfil**: empleado de Northwind que atiende la recepción de una sede en turnos de 8 horas.

**Objetivos**: ver las reservas del día de su sede y cancelar una reserva cuando la sala queda fuera de servicio.

**Frustraciones**: conciliar a mano la hoja de cálculo con los correos.

### Segmentos de Usuario <!-- SECTION: User Segments -->

**Segmento 1: Miembros activos**
- Tamaño: 1.850 miembros con membresía vigente al 2026-09-30.
- Prioridad: High

**Segmento 2: Recepción**
- Tamaño: 6 recepcionistas.
- Prioridad: Medium

### Análisis de Impacto <!-- SECTION: Impact Analysis -->

**Impactados positivamente:**
- Miembros: confirmación inmediata, 24 horas.
- Recepción: 26 horas semanales liberadas.

**Gestión del cambio:**
- Recepción recibe una sesión de 1 hora de capacitación antes del lanzamiento.
- Los miembros reciben un correo de anuncio 7 días antes del lanzamiento.

---

## 3. Objetivos de Negocio <!-- SECTION: Business Objectives -->

### Metas Principales <!-- SECTION: Primary Business Goals -->

1. **Objetivo 1: Eliminar las reservas dobles**
   - Métrica: reservas confirmadas superpuestas para la misma sala, por mes.
   - Meta: 0.
   - Plazo: desde el lanzamiento (2027-01-25).

2. **Objetivo 2: Reducir el tiempo de recepción dedicado a reservas**
   - Métrica: horas semanales de recepción registradas en la categoría "reservas".
   - Meta: 4 horas semanales o menos (frente a 26).
   - Plazo: 3 meses después del lanzamiento (2027-04-25).

3. **Objetivo 3: Adopción del autoservicio**
   - Métrica: porcentaje de reservas creadas en el portal sobre el total de reservas.
   - Meta: 90 % o más.
   - Plazo: 3 meses después del lanzamiento (2027-04-25).

### Criterios de Éxito <!-- SECTION: Success Criteria -->

**Obligatorios:**
- Cero reservas dobles confirmadas.
- Confirmación de la reserva en pantalla en 2 segundos o menos para el 95 % de las reservas.

**Importantes:**
- El 90 % de las reservas se crean en el portal a los 3 meses.

### Expectativas de ROI <!-- SECTION: ROI Expectations -->

**Inversión:**
- Desarrollo: USD 85.000.
- Plazo de implementación: 14 semanas.
- Costo operativo: USD 900 por mes (clúster y base de datos existentes).

**Retornos esperados:**
- Ahorro de recepción: 22 horas semanales × USD 18 por hora = USD 20.600 por año.
- Bonificaciones evitadas por reservas dobles: USD 7.900 por año.
- Recuperación de la inversión: 36 meses.

### Cronograma e Hitos <!-- SECTION: Timeline and Milestones -->

**Fase 1: Piloto en la sede Centro**
- Fecha: 2027-01-11.
- Entregables: consulta, reserva y cancelación para las 18 salas de la sede Centro.
- Criterio de éxito: 2 semanas sin reservas dobles y 80 % de las reservas de la sede en el portal.

**Fase 2: Las 3 sedes**
- Fecha: 2027-01-25.
- Entregables: las 42 salas.
- Criterio de éxito: los objetivos 1 a 3.

---

## 4. Casos de Uso <!-- SECTION: Use Cases -->

### Caso de Uso 1: Consultar disponibilidad de salas

**Descripción**: el miembro elige una sede, una fecha y una franja horaria y ve qué salas están libres, con su capacidad y equipamiento.

**Actores**: Miembro del cowork · Portal de Reservas · Servicio de Reservas

**Disparador**: el miembro abre la página "Salas" del Portal de Reservas o cambia la sede, la fecha o la franja del filtro.

**Precondiciones**: el miembro inició sesión con su cuenta de miembro en el Proveedor de Identidad Northwind y su membresía está vigente.

**Flujo principal**:
1. El miembro elige sede (Centro, Norte o Puerto), fecha y franja horaria (inicio y fin en múltiplos de 30 minutos).
2. El Portal de Reservas solicita al Servicio de Reservas las salas de esa sede y su ocupación en esa franja.
3. El Servicio de Reservas devuelve cada sala con nombre, capacidad, equipamiento (pantalla, videoconferencia, pizarra) y estado: libre u ocupada.
4. El Portal de Reservas muestra las salas libres primero, ordenadas por capacidad ascendente.

**Flujos alternativos**:
- **Alternativa 1: Ninguna sala libre**
  - Difiere en: paso 4.
  - Flujo: el portal muestra el mensaje "No hay salas libres en esta franja" y las 3 franjas de 30 minutos más cercanas con al menos una sala libre.

**Casos borde**:
- Franja en el pasado: el portal no permite elegir una hora de inicio anterior a la hora actual.
- Franja de más de 8 horas: el portal la rechaza con el mensaje "Una reserva dura como máximo 8 horas".

**Postcondiciones**: el miembro ve el estado de cada sala de la sede en la franja elegida; ningún dato cambia.

**Criterios de aceptación**:
- Dada una sala con una reserva confirmada de 10:00 a 11:00, cuando el miembro consulta la franja 10:30–11:30 de esa sede, entonces la sala aparece como ocupada.
- Cuando el miembro consulta una sede con 18 salas, entonces la lista se muestra en 1 segundo o menos en el percentil 95.

**Métricas de éxito**:
- Tiempo de respuesta de la consulta: 1 segundo o menos en el percentil 95.
- Tasa de error del servidor: menos del 0,5 % de las consultas.

### Caso de Uso 2: Reservar una sala

**Descripción**: el miembro reserva una sala libre para una franja y recibe la confirmación en pantalla.

**Actores**: Miembro del cowork · Portal de Reservas · Servicio de Reservas

**Disparador**: el miembro pulsa "Reservar" sobre una sala libre en el resultado del caso de uso 1.

**Precondiciones**: el miembro tiene sesión iniciada y membresía vigente; la sala aparece como libre en la franja elegida.

**Flujo principal**:
1. El Portal de Reservas muestra el resumen: sala, sede, fecha, franja y un campo de asunto obligatorio de hasta 80 caracteres.
2. El miembro confirma.
3. El Portal de Reservas envía la solicitud de reserva al Servicio de Reservas con una clave de idempotencia generada en el navegador.
4. El Servicio de Reservas verifica que la sala no tenga otra reserva confirmada superpuesta y que el miembro no supere 3 reservas futuras por día, y registra la reserva con estado "Confirmada".
5. El Portal de Reservas muestra la confirmación con el código de reserva (formato `RS-` seguido de 8 caracteres alfanuméricos).

**Flujos alternativos**:
- **Alternativa 1: La sala se ocupó entre la consulta y la confirmación**
  - Difiere en: paso 4.
  - Flujo: el Servicio de Reservas rechaza la solicitud con el motivo "sala ocupada"; el portal muestra el mensaje "Otra persona acaba de reservar esta sala" y vuelve a la consulta con la misma franja.
- **Alternativa 2: Límite diario alcanzado**
  - Difiere en: paso 4.
  - Flujo: el Servicio de Reservas rechaza la solicitud con el motivo "límite diario"; el portal muestra "Ya tienes 3 reservas ese día".

**Casos borde**:
- Doble clic en "Confirmar" o reintento por pérdida de red: la misma clave de idempotencia devuelve la reserva ya creada, sin crear una segunda.
- Dos miembros confirman la misma sala y franja en el mismo segundo: exactamente una solicitud queda "Confirmada" y la otra recibe "sala ocupada".

**Postcondiciones**: existe una reserva "Confirmada" con código, sala, franja, miembro y asunto; la sala aparece ocupada en esa franja para todos los miembros.

**Criterios de aceptación**:
- Dadas 50 solicitudes simultáneas para la misma sala y franja, cuando se procesan, entonces exactamente 1 queda "Confirmada" y 49 reciben "sala ocupada".
- Cuando el miembro confirma, entonces el código de reserva aparece en 2 segundos o menos en el percentil 95.

**Métricas de éxito**:
- Tiempo hasta la confirmación: 2 segundos o menos en el percentil 95.
- Reservas dobles confirmadas: 0 por mes.

### Caso de Uso 3: Cancelar una reserva

**Descripción**: el miembro cancela una de sus reservas futuras, o un recepcionista cancela cualquier reserva de su sede, y la sala queda libre.

**Actores**: Miembro del cowork · Recepcionista de sede · Portal de Reservas · Servicio de Reservas

**Disparador**: el miembro pulsa "Cancelar" en la página "Mis reservas", o el recepcionista pulsa "Cancelar" en la página "Reservas de la sede".

**Precondiciones**: la reserva está "Confirmada" y su hora de inicio es posterior a la hora actual; quien cancela es el miembro dueño de la reserva o un recepcionista de la sede de la sala.

**Flujo principal**:
1. El Portal de Reservas pide confirmación ("¿Cancelar la reserva RS-…?").
2. El usuario confirma.
3. El Portal de Reservas envía la cancelación al Servicio de Reservas.
4. El Servicio de Reservas cambia el estado a "Cancelada", registra quién canceló y la hora.
5. El Portal de Reservas muestra "Reserva cancelada" y la quita de la lista de reservas futuras.

**Flujos alternativos**:
- **Alternativa 1: Cancelación por recepción**
  - Difiere en: paso 4.
  - Flujo: el Servicio de Reservas exige un motivo de hasta 120 caracteres y lo guarda con la reserva; el miembro ve el motivo en "Mis reservas".

**Casos borde**:
- Reserva ya iniciada: el Servicio de Reservas rechaza la cancelación con el motivo "reserva en curso".
- Un miembro intenta cancelar la reserva de otro miembro: el Servicio de Reservas responde "no autorizado" y no cambia nada.

**Postcondiciones**: la reserva está "Cancelada" con autor y hora de cancelación; la sala aparece libre en esa franja en la consulta del caso de uso 1.

**Criterios de aceptación**:
- Dada una reserva confirmada de 15:00 a 16:00, cuando el miembro dueño la cancela a las 14:00, entonces una consulta de 15:00–16:00 muestra la sala libre.
- Cuando un miembro intenta cancelar la reserva de otro miembro, entonces la respuesta es "no autorizado" y el estado sigue "Confirmada".

**Métricas de éxito**:
- Tiempo de cancelación: 2 segundos o menos en el percentil 95.
- Cancelaciones no autorizadas aceptadas: 0.

---

### Fuera de Alcance <!-- SECTION: Out of Scope -->

- Cobro de salas por hora: las salas están incluidas en la membresía; el cobro se evaluará en el plan 2028.
- Aplicación móvil nativa: el portal web es responsivo y cubre el teléfono.
- Notificaciones por correo o SMS de la reserva: la confirmación es en pantalla; los avisos se evaluarán tras el piloto.
- Integración con calendarios externos (Google Calendar, Microsoft 365): fuera de la primera versión.
- Reservas de puestos de trabajo: solo salas de reunión.

## 5. Historias de Usuario <!-- SECTION: User Stories -->

### Épica: Autoservicio de salas

#### Historia 1: Ver salas libres

**Historia de usuario:**
Como miembro del cowork,
quiero ver qué salas están libres en una sede y franja,
para elegir una sin preguntar a recepción.

**Criterios de aceptación:**
- [ ] La lista muestra nombre, capacidad, equipamiento y estado de cada sala.
- [ ] Las salas libres aparecen primero.

**Prioridad**: Must Have

#### Historia 2: Reservar sin reservas dobles

**Historia de usuario:**
Como miembro del cowork,
quiero reservar una sala libre y recibir un código al instante,
para tener la sala asegurada.

**Criterios de aceptación:**
- [ ] Dos confirmaciones simultáneas de la misma sala y franja producen una sola reserva.
- [ ] Un reintento con la misma clave de idempotencia no crea otra reserva.

**Prioridad**: Must Have

#### Historia 3: Cancelar

**Historia de usuario:**
Como miembro o recepcionista,
quiero cancelar una reserva futura,
para liberar la sala.

**Criterios de aceptación:**
- [ ] Solo el dueño o un recepcionista de la sede pueden cancelar.
- [ ] La cancelación por recepción exige un motivo.

**Prioridad**: Must Have

---

## 6. Requisitos de Experiencia de Usuario <!-- SECTION: User Experience Requirements -->

### Expectativas de Rendimiento <!-- SECTION: Performance Expectations -->

**Carga de página:**
- Primera carga del portal: 2,5 segundos o menos (Largest Contentful Paint) en el percentil 75, en 4G.

**Velocidad de transacción:**
- Consulta de disponibilidad: 1 segundo o menos en el percentil 95.
- Reserva y cancelación: 2 segundos o menos en el percentil 95.

### Requisitos de Usabilidad <!-- SECTION: Usability Requirements -->

- Un miembro nuevo completa su primera reserva sin ayuda en 2 minutos o menos.
- Una reserva se completa en 3 clics o menos desde la página "Salas".

### Requisitos de Accesibilidad <!-- SECTION: Accessibility Requirements -->

- WCAG 2.1 nivel AA.
- Navegación completa por teclado.

### Consistencia entre Plataformas <!-- SECTION: Cross-Platform Consistency -->

**Plataformas soportadas:**
- Web: las 2 últimas versiones de Chrome, Edge, Firefox y Safari, en escritorio y en teléfono (ancho mínimo 360 px).

---

## 7. Restricciones de Negocio <!-- SECTION: Business Constraints -->

### Restricciones de Presupuesto <!-- SECTION: Budget Constraints -->

**Presupuesto total**: USD 95.000 (desarrollo USD 85.000, contingencia USD 10.000), aprobado por la Dirección de Operaciones el 2026-10-01.

### Restricciones de Plazo <!-- SECTION: Timeline Constraints -->

- Piloto en la sede Centro: 2027-01-11.
- Lanzamiento en las 3 sedes: 2027-01-25, antes de la renovación de membresías del 2027-02-01.

### Requisitos Regulatorios y de Cumplimiento <!-- SECTION: Regulatory and Compliance Requirements -->

- Ley de protección de datos personales aplicable: el portal guarda nombre, correo y reservas del miembro; los datos de reservas se conservan 24 meses y luego se eliminan.
- Registro de auditoría de cada cancelación (quién, cuándo, motivo), conservado 24 meses.

### Restricciones de Integración <!-- SECTION: Integration Constraints -->

**Sistemas existentes:**
- Proveedor de Identidad Northwind (Keycloak 25, OpenID Connect): única fuente de autenticación de miembros y recepcionistas; el rol `recepcion` y el atributo `sede` vienen en el token.

### Restricciones Tecnológicas <!-- SECTION: Technology Constraints -->

- El portal es una aplicación de una página (SPA) en React 18 con TypeScript, servida como archivos estáticos (norma de Plataforma Northwind).
- El backend es un microservicio Java 21 con Spring Boot 3.3 desplegado en el clúster Kubernetes existente de Plataforma Northwind.
- La base de datos es PostgreSQL 16 gestionada por Plataforma Northwind.
- Prohibido guardar tokens en `localStorage` o `sessionStorage`; la sesión vive solo en la memoria del navegador (política de Seguridad de la Información).

### Restricciones Operativas <!-- SECTION: Operational Constraints -->

- Disponibilidad: 99,5 % mensual; soporte en horario hábil (lunes a viernes, 08:00–19:00).
- Ventana de mantenimiento: domingos 02:00–04:00.

### Restricciones de Recursos <!-- SECTION: Resource Constraints -->

- Un equipo de 4 personas (2 backend, 1 frontend, 1 QA) asignado al 100 % durante 14 semanas.

---

## 8. Métricas de Éxito y KPIs <!-- SECTION: Success Metrics and KPIs -->

### KPIs de Negocio <!-- SECTION: Business KPIs -->

**KPI 1: Reservas dobles**
- **Definición**: reservas confirmadas superpuestas para la misma sala.
- **Línea base**: 37 por mes (agosto de 2026).
- **Meta**: 0 por mes.
- **Plazo**: desde 2027-01-25.
- **Método de medición**: consulta mensual sobre la base de reservas.
- **Responsable**: Dirección de Operaciones.

**KPI 2: Adopción del portal**
- **Definición**: reservas creadas en el portal sobre el total de reservas.
- **Línea base**: 0 %.
- **Meta**: 90 % o más.
- **Plazo**: 2027-04-25.
- **Método de medición**: reservas del portal frente a reservas registradas por recepción.
- **Responsable**: Gerencia de Producto Digital.

**KPI 3: Horas de recepción en reservas**
- **Definición**: horas semanales de recepción en la categoría "reservas".
- **Línea base**: 26 horas.
- **Meta**: 4 horas o menos.
- **Plazo**: 2027-04-25.
- **Método de medición**: registro de actividades de recepción.
- **Responsable**: Dirección de Operaciones.

### Métricas de Experiencia de Usuario <!-- SECTION: User Experience Metrics -->

**Métrica 1: Tiempo hasta la confirmación**
- **Definición**: desde "Confirmar" hasta ver el código de reserva.
- **Meta**: 2 segundos o menos en el percentil 95.
- **Método de medición**: métricas del Servicio de Reservas y del navegador.

---

## Apéndice <!-- SECTION: Appendix -->

### Supuestos <!-- SECTION: Assumptions -->
- El Proveedor de Identidad Northwind ya tiene las cuentas de los 1.850 miembros y de los 6 recepcionistas.
- Las 42 salas, con capacidad y equipamiento, se cargan una vez desde la hoja de cálculo de recepción antes del piloto.

### Riesgos <!-- SECTION: Risks -->
- Baja adopción en la sede Puerto (miembros de mayor edad): sesión de acompañamiento en recepción la primera semana.

### Preguntas Abiertas <!-- SECTION: Open Questions -->
- [ ] ¿Se permite reservar con más de 30 días de anticipación? — Dirección de Operaciones, 2026-11-15.

### Aspiraciones <!-- SECTION: Aspirations -->
- Que el portal sugiera la sala adecuada según el número de asistentes.

### Registro de sincronización <!-- SECTION: Sync log -->

| Date | Spec version | Architecture version | Applied | Declined |
|---|---|---|---|---|
| 2026-10-19 | 1.1 | 1.1.0 | 1, 2 | — |

---

**Document Status**: Approved
**Approval Date**: 2026-10-17
**Approved By**: Dirección de Operaciones, Northwind Cowork
