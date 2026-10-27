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
| 6 | Cierre: el arquitecto responde una pregunta del build (v1.10.1) | Desatendido | 10 min |

Todo se hace **en vivo, frente al público**: ninguna rama, commit, PR ni issue se prepara antes. Cada rama se crea en el paso del caso que la usa. Punto de partida: arquitectura `architecture-v1.9.1`, Servicio y Portal ligados a 1.9.1, los tres repositorios en su rama principal y sin PRs abiertos.

### Quién ejecuta y dónde

Cada paso empieza con **quién** lo hace y **dónde**: `👤 rol · 📍 repositorio · herramienta`.

| Rol | Qué representa | Dónde trabaja |
|---|---|---|
| **Arquitecto** | Quien cambia y publica la arquitectura | `northwind-reservas` — terminal (`$ARCH`) y Claude Code |
| **Desarrollador del Portal** | El equipo asistido | `northwind-portal-reservas` — Claude Code (`$PORTAL`) y GitHub |
| **Alguien del equipo** | Cualquier persona con acceso al repositorio | `northwind-servicio-reservas` — un issue en GitHub |
| **CI (nadie)** | Lo que corre solo | GitHub Actions de cada repositorio |
| **Presentador** | Quien narra y prepara | Navegador, pestañas de Actions y PRs |

Una misma persona puede hacer todos los roles en la demo; lo que importa es decir en voz alta qué rol está haciendo en cada paso.

Variables de este runbook:

```bash
SA=$(bun ~/.claude/plugins/marketplaces/shadowx4fox-solution-architect-marketplace/scripts/plugin-root.ts --quiet)
ARCH=~/Project/Personal/northwind-reservas
SVC=~/Project/Personal/northwind-servicio-reservas
PORTAL=~/Project/Personal/northwind-portal-reservas
```

---

## 0. Preparación (el día anterior y una hora antes, fuera de cámara)

👤 Presentador · 📍 su máquina, fuera de cámara. Solo se verifica que todo esté arriba y limpio: **no se crea ninguna rama ni se abre ningún PR o issue**.

### El día anterior

1. **Versiones al día.** Arquitectura `released` v1.9.1 (`lifecycle.js status $ARCH`); `.architecture.json` del Servicio y del Portal en 1.9.1. Verificado el 2026-10-26.
2. **Gates limpios en main.** `bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js check $ARCH --no-render`: `RELEASE GATES (clear)`. Verificado el 2026-10-26. Así, lo único que puede bloquear en vivo es el cambio que se hace en la demo.
3. **Grabar el respaldo.** Capturas o video de la corrida completa del 2026-10-22 (release #87 → kit #88 → servicio PR #8, 8,3 min). Se muestran si algo falla en vivo.
4. **Pestañas del navegador**, en este orden: Actions del repositorio de arquitectura · PRs del servicio · PRs del Portal · issues de arquitectura.
5. **Ensayo de la foto, sin release.** Se ensaya en local con el mismo script que usa el workflow (ensayado el 2026-10-26: pie `v1.9.1 · Vista lógica · L2 Servicios de negocio · Servicio de Reservas`):
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

👤 Desarrollador del Portal · 📍 `northwind-portal-reservas` · Claude Code. Sin rama: solo pregunta, no cambia nada.

1. Abrir Claude Code en `$PORTAL` (rama `main`).
2. Preguntar: *"¿Cuál es el límite de caracteres del asunto de una reserva?"*
3. **Esperado:** 80 caracteres, citando el paquete del Portal de Reservas (contrato del Servicio de Reservas, `BookingRequest.subject`) en la versión 1.9.1.
4. Mostrar `src/ui/SalasPage.tsx:220`: `maxLength={80}`. El código y la arquitectura coinciden.

**Si falla:** Alia caído → reiniciar con RUN.md y repetir. Si la respuesta no cita el paquete, preguntar *"¿de dónde sale ese dato?"*.

---

## Caso 2 — Release A: asunto de 80 a 120 (ambos modos, 15 min)

**Decir:** "Negocio pide asuntos más largos. El arquitecto cambia el contrato y publica. Desde aquí, el Servicio se construye solo; el Portal lo actualiza una persona. Mismo release, dos modos."

### El arquitecto publica

👤 Arquitecto · 📍 `northwind-reservas` · terminal y Claude Code.

1. **Crear la rama ahora, frente al público**, en la terminal de `$ARCH`:
   ```bash
   cd $ARCH && git checkout main && git pull -q && git checkout -b arch/asunto-120
   ```
   Luego, en Claude Code en `$ARCH`:
   > *"El asunto de una reserva pasa de 80 a 120 caracteres: actualiza el contrato del Servicio de Reservas."*
2. **Esperado:** no edita sin preguntar. Muestra el cambio antes → después en `docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md`: `subject (80 caracteres o menos)` → `120`, la fila `VALIDATION_FAILED` (asunto de más de 120 caracteres) y la versión del contrato (`1.2.0` → `1.3.0`), más una línea en `docs/CHANGELOG.md` § [Unreleased]. **Aprobar.**
   - Si no sube la versión del contrato o no escribe la línea del changelog, pedírselo: *"sube la versión del contrato y anota el cambio en [Unreleased]"*.
3. Commit y release, en la terminal de `$ARCH`:

```bash
git add -A && git commit -m "docs(servicio-de-reservas): asunto de hasta 120 caracteres"
git diff main --stat                                  # mostrar: una fila del contrato, la versión 1.3.0
bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js plan .        # el cambio y su bump: MINOR
bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js apply . --bump minor
```

`apply` propone el PR contra la rama actual; abrirlo **contra main** (brecha conocida del plugin):

```bash
git push -u origin release/architecture-v1.10.0
gh pr create -B main -H release/architecture-v1.10.0 --fill
```

- 👤 Presentador · 📍 GitHub, PR de `northwind-reservas`: mostrar los gates (`architecture-gates`): verdes.
- 👤 Arquitecto · 📍 GitHub: **merge del PR**. Anotar la hora: es el **T0**.

### Lo que pasa solo (narrar sobre Actions)

👤 CI (nadie) · 📍 Actions de `northwind-reservas` y de `northwind-servicio-reservas`. El presentador solo narra.

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

👤 CI (nadie) escribe y mergea · 📍 `northwind-servicio-reservas` · GitHub. El presentador solo muestra; nadie crea la rama ni el PR: los crea el build.

- Abrir el PR del servicio cuando aparezca. Mostrar:
  - el commit de contratos solo (`architecture/` byte a byte), y después el código;
  - la validación del asunto en 120 y su test;
  - `.architecture.json` en 1.10.0.
- Esperar el merge automático. **Decir:** "Nadie aprobó este PR. Lo aprobó la arquitectura más los tests."

### 2b — Portal de Reservas (asistido), mientras 2a corre

👤 Desarrollador del Portal · 📍 `northwind-portal-reservas` · terminal, Claude Code y GitHub.

Empezar cuando el índice publicó (+4:45), no antes: el paquete 1.10.0 aún no existe.

1. **Crear la rama ahora**, en la terminal de `$PORTAL`:
   ```bash
   cd $PORTAL && git checkout main && git pull -q && git checkout -b feat/arquitectura-1.10.0
   ```
   Luego, en Claude Code en `$PORTAL`: *"actualiza el Portal a la versión 1.10.0 de la arquitectura"*.
2. **Esperado:** `what_changed` nombra el límite del asunto; copia los contratos en `architecture/` en un commit propio; cambia `maxLength={80}` → `120`; actualiza los tipos y los tests.
3. Abrir el PR (Claude Code o `gh pr create --fill`). 👤 CI · 📍 Actions del Portal: el check **Architecture review** corre: **PASS**.
4. 👤 Desarrollador del Portal · 📍 GitHub: **merge**.

**Decir:** "Misma release, misma revisión contra el mismo paquete. Lo que cambia es quién escribe el código."

**Si falla:**
- Un check queda en `in_progress` aunque su job terminó (fallo de GitHub): `gh run rerun <run-id> -R <repo>`.
- El kit no se mergea solo: revisar `SA_HANDOFF_AUTOMERGE` y mergear el PR del kit a mano; el índice se despacha igual.
- El build del servicio no arranca: runner offline. Pasar al video del respaldo y seguir con el caso 3; el caso 6 vuelve a mostrar el modo desatendido al final.

---

## Caso 3 — Una desviación queda retenida (asistido, 10 min)

**Decir:** "¿Y si el desarrollador hace algo que la arquitectura no dice? La revisión lo frena, y la única salida es preguntarle al arquitecto."

👤 Desarrollador del Portal · 📍 `northwind-portal-reservas` · terminal, Claude Code y GitHub.

1. **Crear la rama ahora**, en la terminal de `$PORTAL` (después del merge del caso 2b):
   ```bash
   cd $PORTAL && git checkout main && git pull -q && git checkout -b feat/asunto-150
   ```
   Luego, en Claude Code en `$PORTAL`: *"el equipo de producto pide 150 caracteres en el asunto; cámbialo en el formulario"*.
   - **Esperado:** el agente advierte que el contrato dice 120. Pedirle que lo haga igual para la demo.
2. Abrir el PR. 👤 CI · 📍 Actions del Portal → **Architecture review: FAIL**. Mostrar el comentario en español: el hallazgo bloqueante cita el contrato 1.3.0 y la regla de BUILD.md.
3. 👤 Desarrollador del Portal · 📍 Claude Code en `$PORTAL`: *"escala esto a arquitectura"* → `preview_escalation` muestra la propuesta → **sí** → issue `[ESC-?]` en `northwind-reservas`. Anotar su número `#N`.
4. 👤 Desarrollador del Portal · 📍 GitHub, PR del Portal: citar el issue en el cuerpo del PR: `shadowX4fox/northwind-reservas#N`. La revisión vuelve a correr sola.
5. **Esperado:** estado **pending**, encabezado ⏸ EN ESPERA ("en espera de …#N"). El botón de merge sigue bloqueado.

**Decir:** "El código no se mezcla, pero tampoco se pierde: queda retenido hasta que el arquitecto decide."

---

## Caso 4 — El arquitecto responde (5 min)

**Decir:** "El arquitecto decide. Aquí dice que no: 120 es el límite del contrato."

👤 Arquitecto · 📍 `northwind-reservas` · terminal (`$ARCH`, rama `main`; sin rama nueva).

```bash
cd $ARCH && git checkout main && git pull -q
bun $SA/scripts/shared/escalate.js import . N                    # el registro, numerado ESC-NNN
bun $SA/scripts/shared/escalate.js retitle . ESC-NNN --apply     # el issue pasa a [ESC-NNN] …
bun $SA/scripts/shared/escalate.js close . ESC-NNN --by architecture-v1.10.0 --rejected "El contrato 1.3.0 fija 120 caracteres."
gh issue close N -R shadowX4fox/northwind-reservas --reason "not planned"
```

- 👤 CI · 📍 Actions de `northwind-reservas` y del Portal: el cierre dispara `architecture-escalations` → `architecture-escalation-closed` al Portal → job `recheck`.
- **Esperado** en el PR del Portal, en menos de un minuto: estado **failure**, "corrige el código".
- El registro `escalations/ESC-NNN-*.md` va en un PR aparte; mergearlo después de la demo.
- 👤 Desarrollador del Portal · 📍 GitHub: cerrar el PR `feat/asunto-150` sin merge.

**Decir:** "Si el arquitecto hubiera dicho que sí, sería una release nueva, y el Portal pasaría por el caso 2 otra vez."

---

## Caso 5 — Un pedido desde un issue: `@alia` (asistido desde GitHub, 5 min)

**Decir:** "No hace falta un IDE. Cualquiera del equipo le pide un cambio a Alia en un issue, y Alia responde con la arquitectura: lee el paquete, aplica sus reglas, y si la arquitectura no lo permite, no lo inventa."

👤 Alguien del equipo · 📍 `northwind-servicio-reservas` · GitHub, en el navegador. Sin IDE, sin terminal y sin rama.

1. Crear ahora un issue nuevo en el **servicio** (`northwind-servicio-reservas`), título *"Motivo en el log de cancelación"*, cuerpo:
   > @alia añade el motivo de la cancelación al log de aplicación cuando se cancela una reserva
2. 👤 CI · 📍 Actions del servicio: el job `Architecture mention` corre en el runner `sa-index`, el que llega a Alia. Tarda menos de un minuto.
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

## Caso 6 — Cierre: el arquitecto responde una pregunta del build (desatendido, 10 min)

**Decir:** "El build desatendido no inventa lo que la arquitectura no dice: lo deja anotado como pregunta. Cuando el arquitecto responde, el código se pone al día solo."

1. **La pregunta.** 👤 Presentador · 📍 `northwind-servicio-reservas` · terminal (`$SVC`, solo lectura). Mostrar lo que dejó el build:
   ```bash
   git -C $SVC checkout -q master && git -C $SVC pull -q
   rg -n "TODO\(architecture\)" $SVC/src/main/resources/application.yaml
   ```
   La línea de `intervalo-purga-claves`: TDR-002 (opción B) pide purgar las claves de idempotencia vencidas "de forma periódica", pero no dice cada cuánto. Hoy el valor lo tiene que dar el despliegue (`RESERVAS_INTERVALO_PURGA_CLAVES`); sin él, el servicio no arranca.
2. **El arquitecto responde.** 👤 Arquitecto · 📍 `northwind-reservas` · terminal y Claude Code. **Crear la rama ahora**, en la terminal de `$ARCH`:
   ```bash
   cd $ARCH && git checkout main && git pull -q && git checkout -b arch/purga-claves
   ```
   Luego, en Claude Code en `$ARCH`:
   > *"Las claves de idempotencia vencidas se purgan cada hora (TDR-002, opción B). Documéntalo en el Servicio de Reservas."*
3. **Esperado:** muestra el cambio antes → después en `docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md`: las claves de idempotencia, vencidas a las 24 horas, se purgan cada hora. Una línea en `docs/CHANGELOG.md` § [Unreleased]. **Aprobar.**
4. Commit y release, igual que en el caso 2:
   ```bash
   git add -A && git commit -m "docs(servicio-de-reservas): purga de claves de idempotencia cada hora"
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js plan .        # bump recomendado: PATCH
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js apply . --bump patch
   git push -u origin release/architecture-v1.10.1
   gh pr create -B main -H release/architecture-v1.10.1 --fill
   ```
   Gates verdes → 👤 Arquitecto · 📍 GitHub: **merge**. Anotar el **T0**.
5. **Lo que pasa solo** (👤 CI · 📍 Actions de `northwind-reservas` y del servicio; el presentador narra): la misma cadena del caso 2: tag, kit editado en sitio, índice. Solo cambió el paquete del Servicio de Reservas, así que solo el Servicio abre un PR. El Portal no se toca.
6. **Esperado en el PR del servicio:**
   - `intervalo-purga-claves` con `PT1H` (una hora) en `application.yaml`, sin el `TODO(architecture)`. El comentario de `PropiedadesReservas.java` ya no dice que el intervalo no está documentado;
   - `.architecture.json` en 1.10.1;
   - tests verdes y merge automático por `github-actions`, sin nadie.

**Decir:** "Un PATCH de documentación también llega al código. La pregunta que dejó el build la respondió el arquitecto, no el desarrollador."

**Si falla:**
- El servicio no abre PR: revisar el job del build en Actions del servicio. Si el agente decidió que no había nada que cambiar, mostrar el `what_changed` del paquete 1.10.1, que nombra el cambio de la especificación.
- Los tests fallan: el PR queda abierto sin merge. Así está diseñado (el merge automático exige tests verdes). Mostrarlo como tal.
- **Corrida equivalente de referencia:** el PATCH 1.9.1 (2026-10-24): el PR #13 del servicio se abrió a las 17:01:04 y `github-actions` lo mergeó a las 17:02:04.

---

## Después de la demo

- Mergear el PR del registro de la escalación (caso 4).
- Cerrar el issue del caso 5 en el servicio (o crear la escalación que Alia renderizó, si se quiere seguir el ciclo del caso 4).
- Borrar las ramas que se crearon en vivo: `arch/asunto-120` y `arch/purga-claves` en `$ARCH`, `feat/arquitectura-1.10.0` y `feat/asunto-150` en `$PORTAL`.
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
