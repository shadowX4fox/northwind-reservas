# Runbook — demo asistido y desatendido

De la arquitectura al código, con y sin una persona en el medio. Unos 45 minutos sobre los tres repositorios de Northwind Reservas.

| Repositorio | Rol | Modo |
|---|---|---|
| `shadowX4fox/northwind-reservas` | Arquitectura (main) | El arquitecto |
| `shadowX4fox/northwind-servicio-reservas` | Servicio de Reservas (master) | Desatendido, merge automático |
| `shadowX4fox/northwind-portal-reservas` | Portal de Reservas (main) | Asistido, con revisión de arquitectura |

| # | Caso | Modo | Tiempo |
|---|---|---|---|
| 1 | El IDE le pregunta a la arquitectura | Asistido | 5 min |
| 2 | Release A: asunto de 80 a 120 caracteres (v1.10.0) | Ambos | 15 min |
| 2a | Servicio de Reservas: del release al merge sin nadie | Desatendido | (en paralelo) |
| 2b | Portal de Reservas: el desarrollador actualiza en el IDE | Asistido | (en paralelo) |
| 3 | Una desviación queda retenida (HELD) | Asistido | 10 min |
| 4 | El arquitecto responde | — | 5 min |
| 5 | Un pedido desde un issue: `@alia` | Asistido, desde GitHub | 5 min |
| 6 | Respaldo: métrica de cancelaciones (v1.11.0) | Desatendido | si sobra tiempo o falla 2a |

Variables de este runbook:

```bash
SA=$(bun ~/.claude/plugins/marketplaces/shadowx4fox-solution-architect-marketplace/scripts/plugin-root.ts --quiet)
ARCH=~/Project/Personal/northwind-reservas
SVC=~/Project/Personal/northwind-servicio-reservas
PORTAL=~/Project/Personal/northwind-portal-reservas
```

---

## 0. Preparación (el día anterior y una hora antes, fuera de cámara)

### El día anterior

1. **Portal al día en 1.9.0.** El Portal sigue ligado a 1.8.0. Actualizarlo antes para que el caso 2b muestre solo el cambio del asunto. En una sesión de Claude Code en `$PORTAL`: *"actualiza el Portal a la versión 1.9.0 de la arquitectura"*. PR → revisión PASS → merge.
2. **Ramas de arquitectura listas, sin release.** Cada cambio en su rama, con commit, sin push:
   - `arch/asunto-120`: en `docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md`, `subject (80 caracteres o menos)` → `120`, la fila `VALIDATION_FAILED` (asunto de más de 120 caracteres), versión del contrato `1.2.0` → `1.3.0`; una línea en `docs/CHANGELOG.md` § [Unreleased].
   - `arch/metrica-cancelaciones` (respaldo): en `docs/09-operational-considerations.md` § Métricas, un contador de cancelaciones por `sede` y rol (miembro / `recepcion`), emitido por el Servicio de Reservas con OpenTelemetry; una línea en § [Unreleased].
   - Correr `bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js check $ARCH` en cada rama: sin bloqueos.
3. **Grabar el respaldo.** Capturas o video de la corrida completa del 2026-10-22 (release #87 → kit #88 → servicio PR #8, 8,3 min). Se muestran si algo falla en vivo.
4. **Pestañas del navegador**, en este orden: Actions del repositorio de arquitectura · PRs del servicio · PRs del Portal · issues de arquitectura.
5. **Ensayo de la foto, sin release.** La foto del PR del kit en vista de plano llega con sa-skills 10.21.0 y todavía no corrió en un release real. Un release de ensayo cambiaría las versiones de todo el runbook, así que se ensaya en local con el mismo script que usa el workflow:
   ```bash
   V=$SA/plugins/sa-visualization/skills/architecture-command-center/scripts
   bun $V/render.js $ARCH/visualizations/architecture-command-center.scene.json /tmp/cc.html --lang es
   bun $V/snapshot.js /tmp/cc.html /tmp/ensayo.png --plan servicio-de-reservas   # imprime el pie de la foto
   ```
   Esperado: el piso L2 con el Servicio de Reservas seleccionado y sus tres puertos. Es la foto que trae el PR del kit en el caso 2, con la versión 1.10.0.

### Una hora antes

```bash
# 1. Los tres runners (no son servicios: un reinicio los apaga)
for r in northwind-reservas northwind-servicio-reservas northwind-portal-reservas; do
  cd ~/actions-runner/$r && { pgrep -f "$PWD/bin/Runner.Listener" >/dev/null || setsid nohup ./run.sh > runner.log 2>&1 < /dev/null & }
done
for r in northwind-reservas northwind-servicio-reservas northwind-portal-reservas; do
  gh api repos/shadowX4fox/$r/actions/runners --jq '.runners[] | "\(.name) \(.status)"'
done                                                      # esperado: 3 líneas "online"

# 2. Alia en :18080 y Ollama en :11434
docker ps --filter name=sa-index-northwind --format '{{.Names}} {{.Status}}'
curl -s localhost:11434/api/tags >/dev/null && echo ollama ok
# si Alia no está arriba: el comando de RUN.md § Servidor de la demo (con compose.escalation.yaml)

# 3. Repos limpios y al día
for d in $ARCH $SVC $PORTAL; do git -C $d checkout -q $(git -C $d symbolic-ref --short refs/remotes/origin/HEAD | cut -d/ -f2) && git -C $d pull -q && git -C $d status --short; done

# 4. Nada abierto que confunda
for r in northwind-reservas northwind-servicio-reservas northwind-portal-reservas; do gh pr list -R shadowX4fox/$r; done
gh issue list -R shadowX4fox/northwind-reservas --state open
gh issue list -R shadowX4fox/northwind-servicio-reservas --state open   # el caso 5 abre el suyo
```

5. **Workflows en orden.** En Claude Code, en `$ARCH`: *"check the architecture workflows"*, y para el servicio y el Portal *"connect a service repository"* en modo check. Esperado: "nothing to do" en ambos lados, schedules `active`. El servicio tiene `architecture-mention.yml` (v10.20.2 o posterior) y la variable `SA_MENTION_RUNS_ON`; sin ellos, el caso 5 no corre.
6. **Alia responde.** En `$PORTAL`, `/mcp`: el servidor `architecture` conectado.

**No arrancar la demo** si un runner está offline o Alia no responde: la revisión del Portal falla cerrada (`pack-unreadable`) y el build desatendido no corre.

---

## Caso 1 — El IDE le pregunta a la arquitectura (asistido, 5 min)

**Decir:** "El desarrollador no adivina ni busca en un wiki: le pregunta a la arquitectura publicada, desde su IDE."

1. Claude Code en `$PORTAL`.
2. Preguntar: *"¿Cuál es el límite de caracteres del asunto de una reserva?"*
3. **Esperado:** 80 caracteres, citando el paquete del Portal de Reservas (contrato del Servicio de Reservas, `BookingRequest.subject`) en la versión 1.9.0.
4. Mostrar `src/ui/SalasPage.tsx:220`: `maxLength={80}`. El código y la arquitectura coinciden.

**Si falla:** Alia caído → reiniciar con RUN.md y repetir. Si la respuesta no cita el paquete, preguntar *"¿de dónde sale ese dato?"*.

---

## Caso 2 — Release A: asunto de 80 a 120 (ambos modos, 15 min)

**Decir:** "Negocio pide asuntos más largos. El arquitecto cambia el contrato y publica. Desde aquí, el Servicio se construye solo; el Portal lo actualiza una persona. Mismo release, dos modos."

### El arquitecto publica

```bash
cd $ARCH && git checkout arch/asunto-120
git diff main --stat                                  # mostrar: una fila del contrato, la versión 1.3.0
bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js plan .        # el cambio y su bump: MINOR
bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js apply . --bump minor
```

`apply` propone el PR contra la rama actual; abrirlo **contra main** (brecha conocida del plugin):

```bash
git push -u origin release/architecture-v1.10.0
gh pr create -B main -H release/architecture-v1.10.0 --fill
```

- Mostrar los gates en el PR (`architecture-gates`): verdes.
- **Merge del PR** (la persona). Anotar la hora: es el **T0**.

### Lo que pasa solo (narrar sobre Actions)

| Paso | Tiempo aproximado desde T0 | Dónde se ve |
|---|---|---|
| Tag `architecture-v1.10.0`, índice fase 1 | +0:05 | Actions de arquitectura · `architecture-release` |
| Kit de handoff editado en sitio, PR que se mergea solo | +4:30 | PR "Kit de handoff de architecture-v1.10.0" |
| Índice con los paquetes, despacho `architecture-released` | +4:45 | Actions · `architecture-index` |
| Build desatendido del Servicio, PR | +7:00 | PRs del servicio |
| Tests y merge automático | +8:30 | PR del servicio, mergeado por `github-actions` |

**Decir sobre el kit:** "No regenera todo: edita solo lo que cambió. El diff es el contrato y la especificación del servicio."

**Mostrar la foto en el PR del kit** (sa-skills 10.21.0): debajo del texto del PR va una imagen del centro de mando en **vista de plano**, en el piso **L2 · Servicios de negocio**, con el **Servicio de Reservas** seleccionado y sus puertos (hacia L3 Base de Datos, hacia L4 Proveedor de Identidad, desde L1 Portal). El pie dice la versión 1.10.0, el piso y el componente. Archivo: `visualizations/evidence/architecture-v1.10.0-servicio-de-reservas.png`.

**Decir:** "El release trae su propia evidencia: una foto de cada componente que cambió, en su piso. Aquí cambió solo el Servicio de Reservas."

- Hay una foto por componente cuyo paquete cambió, hasta tres. Si el Portal también cambiara, aparecería una segunda foto en L1.
- **Si no hay foto**, el paso dejó un aviso (`the command-center evidence was not produced`) en el job `handoff`. El kit sigue siendo válido; seguir con la demo.

### 2a — Servicio de Reservas (desatendido)

- Abrir el PR del servicio cuando aparezca. Mostrar:
  - el commit de contratos solo (`architecture/` byte a byte), y después el código;
  - la validación del asunto en 120 y su test;
  - `.architecture.json` en 1.10.0.
- Esperar el merge automático. **Decir:** "Nadie aprobó este PR. Lo aprobó la arquitectura más los tests."

### 2b — Portal de Reservas (asistido), mientras 2a corre

Empezar cuando el índice publicó (+4:45), no antes: el paquete 1.10.0 aún no existe.

1. Claude Code en `$PORTAL`, rama nueva: *"actualiza el Portal a la versión 1.10.0 de la arquitectura"*.
2. **Esperado:** `what_changed` nombra el límite del asunto; copia los contratos en `architecture/` en un commit propio; cambia `maxLength={80}` → `120`; actualiza los tipos y los tests.
3. Abrir el PR. El check **Architecture review** corre: **PASS**.
4. Merge (la persona).

**Decir:** "Misma release, misma revisión contra el mismo paquete. Lo que cambia es quién escribe el código."

**Si falla:**
- Un check queda en `in_progress` aunque su job terminó (fallo de GitHub): `gh run rerun <run-id> -R <repo>`.
- El kit no se mergea solo: revisar `SA_HANDOFF_AUTOMERGE` y mergear el PR del kit a mano; el índice se despacha igual.
- El build del servicio no arranca: runner offline. Pasar al video del respaldo y seguir con el caso 3.

---

## Caso 3 — Una desviación queda retenida (asistido, 10 min)

**Decir:** "¿Y si el desarrollador hace algo que la arquitectura no dice? La revisión lo frena, y la única salida es preguntarle al arquitecto."

1. En `$PORTAL`, rama nueva `feat/asunto-150`: *"el equipo de producto pide 150 caracteres en el asunto; cámbialo en el formulario"*.
   - **Esperado:** el agente advierte que el contrato dice 120. Pedirle que lo haga igual para la demo.
2. Abrir el PR → **Architecture review: FAIL**. Mostrar el comentario en español: el hallazgo bloqueante cita el contrato 1.3.0 y la regla de BUILD.md.
3. En el IDE: *"escala esto a arquitectura"* → `preview_escalation` muestra la propuesta → **sí** → issue `[ESC-?]` en `northwind-reservas`. Anotar su número `#N`.
4. Citar el issue en el cuerpo del PR: `shadowX4fox/northwind-reservas#N`. Se vuelve a correr la revisión.
5. **Esperado:** estado **pending**, encabezado ⏸ EN ESPERA ("en espera de …#N"). El botón de merge sigue bloqueado.

**Decir:** "El código no se mezcla, pero tampoco se pierde: queda retenido hasta que el arquitecto decide."

---

## Caso 4 — El arquitecto responde (5 min)

**Decir:** "El arquitecto decide. Aquí dice que no: 120 es el límite del contrato."

```bash
cd $ARCH && git checkout main && git pull -q
bun $SA/scripts/shared/escalate.js import . N                    # el registro, numerado ESC-NNN
bun $SA/scripts/shared/escalate.js retitle . ESC-NNN --apply     # el issue pasa a [ESC-NNN] …
bun $SA/scripts/shared/escalate.js close . ESC-NNN --by architecture-v1.10.0 --rejected "El contrato 1.3.0 fija 120 caracteres."
gh issue close N -R shadowX4fox/northwind-reservas --reason "not planned"
```

- El cierre dispara `architecture-escalations` → `architecture-escalation-closed` al Portal → job `recheck`.
- **Esperado** en el PR del Portal, en menos de un minuto: estado **failure**, "corrige el código".
- El registro `escalations/ESC-NNN-*.md` va en un PR aparte; mergearlo después de la demo.
- Cerrar el PR `feat/asunto-150` del Portal sin merge.

**Decir:** "Si el arquitecto hubiera dicho que sí, sería una release nueva, y el Portal pasaría por el caso 2 otra vez."

---

## Caso 5 — Un pedido desde un issue: `@alia` (asistido desde GitHub, 5 min)

**Decir:** "No hace falta un IDE. Cualquiera del equipo le pide un cambio a Alia en un issue, y Alia responde con la arquitectura: lee el paquete, aplica sus reglas, y si la arquitectura no lo permite, no lo inventa."

1. Issue nuevo en el **servicio** (`northwind-servicio-reservas`), título *"Motivo en el log de cancelación"*, cuerpo:
   > @alia añade el motivo de la cancelación al log de aplicación cuando se cancela una reserva
2. Mostrar Actions del servicio: el job `Architecture mention` corre en el runner `sa-index`, el que llega a Alia. Tarda menos de un minuto.
3. **Esperado:** Alia actualiza su comentario en español:
   - leyó el paquete del Servicio de Reservas (`get_build_pack`, BUILD.md, `security`, `cross-cutting-standards`, ADR-106);
   - **no cambió código**: los estándares de observabilidad (ADR-004) prohíben datos personales completos en los logs, y el motivo es texto libre que el paquete no clasifica (`security`: datos que maneja, `NOT DOCUMENTED`);
   - la auditoría con el motivo ya existe en la tabla `auditoria_cancelacion` (ADR-106);
   - trae la escalación renderizada por `preview_escalation` (`[ESC-?]`, Tier 1, `trigger:low-confidence`, dos preguntas para el arquitecto) para que una persona la cree en `northwind-reservas`: el job no puede abrir issues en otro repositorio.
4. **Mostrar el contraste:** `@claude` en el mismo repositorio sigue siendo el asistente genérico, sin arquitectura. `@alia` es el que trabaja con el paquete.

**Decir:** "La misma regla que en el caso 3, sin IDE: lo que la arquitectura no dice no se escribe en código; se le pregunta al arquitecto."

**Si Alia pregunta primero** qué falta (pasa si el pedido es vago, por ejemplo *"añade un log de auditoría"*: la auditoría ya existe), responder en el issue `@alia opción 1, solo motivo`. Es la corrida de referencia.

**Si falla:** el comentario dice que no tiene las herramientas del servidor de arquitectura → Alia caído o el runner offline (sección 0); arreglarlo y comentar `@alia` otra vez. No sigue sin el paquete: así está escrita la regla.

**Corrida de referencia** (2026-10-24, issue #11, run 40058145824): 31 s, `get_build_pack` → `get_build_instructions` → `get_build_part` ×3 → `preview_escalation`, sin cambios de código.

---

## Caso 6 — Respaldo: métrica de cancelaciones (desatendido)

Solo si sobra tiempo, o si el caso 2a falló y hay que mostrar el modo desatendido de punta a punta.

Igual que el caso 2, con la rama `arch/metrica-cancelaciones`, release `v1.11.0` (MINOR). El Portal no cambia (la métrica es del Servicio de Reservas): solo el servicio abre su PR y se mergea solo.

---

## Después de la demo

- Mergear el PR del registro de la escalación (caso 4).
- Cerrar el issue del caso 5 en el servicio (o crear la escalación que Alia renderizó, si se quiere seguir el ciclo del caso 4).
- Si no se usó, borrar la rama `arch/metrica-cancelaciones` o dejarla para la próxima.
- Los runners siguen arriba hasta el próximo reinicio.

## Datos de la corrida de referencia (2026-10-22, v1.9.0)

| Paso | Hora | Δ desde el merge |
|---|---|---|
| Merge del release #87 | 16:44:42 | 0:00 |
| Kit #88 mergeado solo | 16:49:11 | 4:29 |
| Índice, despacho | 16:49:26 | 4:44 |
| Servicio PR #8 abierto | 16:51:32 | 6:50 |
| Tests OK | 16:52:50 | 8:08 |
| Merge automático | 16:53:00 | 8:18 |
