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
| 2a | Servicio de Reservas: del release al merge sin nadie | Desatendido | ✅ corrió el 2026-10-27, se muestra como evidencia |
| 2b | Portal de Reservas: el desarrollador actualiza en el IDE | Asistido | ✅ corrió el 2026-10-27, se muestra como evidencia |
| 2c | Retomar: un release solo desatendido (v1.10.3) | Desatendido | 10 min |
| 3 | Una desviación queda retenida (HELD) | Asistido | 10 min |
| 4 | El arquitecto responde | — | 5 min |
| 5 | Un pedido desde un issue: `@alia` | Asistido, desde GitHub | 5 min |
| 6 | Cierre: el arquitecto responde una pregunta del build (v1.10.4) | Desatendido | 10 min |
| 7 | Grabado para video: el Portal se actualiza en el IDE (v1.10.1) | Asistido | ✅ grabado el 2026-10-27, antes de la sesión 2 |

### Segunda sesión: se retoma en el caso 2c

La primera sesión (2026-10-27) mostró el caso 1 y la parte del arquitecto del caso 2: el release `architecture-v1.10.0` (PR #103). Mientras tanto, 2a y 2b corrieron detrás de escena y no se vieron. La segunda sesión empieza así:

1. **Recordar en 2 minutos** lo que pasó con la evidencia de 2a y 2b, sin repetirlo (tablas «Ya corrió» en el caso 2).
2. **Caso 2c, en vivo:** un release nuevo que solo toca el Servicio, para ver el desatendido de punta a punta.
3. Casos 3 a 6 como están. El caso 6 publica `architecture-v1.10.4`.

Punto de partida de la segunda sesión: arquitectura `architecture-v1.10.2` (la del cambio de prueba del Portal, posterior al caso 7), el Servicio ligado a 1.10.0 (su paquete no cambió en 1.10.1) y el Portal a 1.10.1, los tres repositorios en su rama principal y sin PRs abiertos.

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

> **Ya corrió (2026-10-27).** Mostrarlo como evidencia; no se repite. Lo que se ve en vivo es el caso 2c.
>
> | Paso | Hora UTC | Δ desde el merge | Evidencia |
> |---|---|---|---|
> | Merge del release | 19:54:43 | 0:00 | `northwind-reservas` PR #103 |
> | Kit mergeado solo por `github-actions` | 19:58:58 | 4:15 | `northwind-reservas` PR #104 |
> | Build desatendido arranca | 19:59:17 | 4:34 | Actions del servicio · `Architecture build` |
> | PR del servicio abierto | 20:00:50 | 6:07 | `northwind-servicio-reservas` PR #14 |
> | Tests OK | 20:02:02 | 7:19 | Actions del servicio · `Tests` |
> | Merge automático por `github-actions` | 20:02:12 | 7:29 | PR #14, *merged by github-actions* |
>
> En el PR #14, mostrar los dos commits (primero los contratos solos, después el código), la validación del asunto en 120 y `.architecture.json` en 1.10.0.

👤 CI (nadie) escribe y mergea · 📍 `northwind-servicio-reservas` · GitHub. El presentador solo muestra; nadie crea la rama ni el PR: los crea el build.

- Abrir el PR del servicio cuando aparezca. Mostrar:
  - el commit de contratos solo (`architecture/` byte a byte), y después el código;
  - la validación del asunto en 120 y su test;
  - `.architecture.json` en 1.10.0.
- Esperar el merge automático. **Decir:** "Nadie aprobó este PR. Lo aprobó la arquitectura más los tests."

### 2b — Portal de Reservas (asistido), mientras 2a corre

> **Ya corrió (2026-10-27).** Mostrarlo como evidencia; no se repite.
>
> | Paso | Hora UTC | Evidencia |
> |---|---|---|
> | PR del Portal abierto | 20:02:46 | `northwind-portal-reservas` PR #20 (rama `arquitectura-1.10.0`) |
> | Architecture review: PASS | 20:03:53 | Actions del Portal · `Architecture review` |
> | Merge por el desarrollador | 20:05:37 | PR #20 |
>
> En el PR #20, mostrar el commit de contratos solo, `maxLength` en 120 y el comentario de la revisión.

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

## Caso 2c — Retomar: un release solo desatendido (v1.10.3, 10 min)

**Decir:** "La vez pasada el Servicio se construyó solo mientras mirábamos el Portal. Hoy lo vemos de punta a punta: un cambio de rutina en la arquitectura, y nadie toca el código."

Deck: slide 15 (*Del merge al código, sin nadie*), con el resumen de 2a y 2b abajo a la izquierda.

El cambio: negocio quiere contar las cancelaciones. Es una métrica nueva del Servicio de Reservas. No cambia ningún contrato ni el Portal, así que solo el paquete del Servicio cambia y solo el Servicio abre un PR.

1. **El arquitecto cambia la arquitectura.** 👤 Arquitecto · 📍 `northwind-reservas` · terminal y Claude Code. **Crear la rama ahora**, en la terminal de `$ARCH`:
   ```bash
   cd $ARCH && git checkout main && git pull -q && git checkout -b arch/metrica-cancelaciones
   ```
   Luego, en Claude Code en `$ARCH`:
   > *"Negocio quiere contar las cancelaciones: agrega al Servicio de Reservas una métrica de negocio con las reservas canceladas, por sede y por rol de quien cancela."*
2. **Esperado:** muestra el cambio antes → después en `docs/components/reservas-de-salas-northwind/02-servicio-de-reservas.md` § Observabilidad: una línea nueva junto a la del tiempo de confirmación, con un contador de reservas canceladas por sede y por rol (miembro o `recepcion`). Una línea en `docs/CHANGELOG.md` § [Unreleased]. Ningún contrato cambia. **Aprobar.**
   - Si propone cambiar el contrato OpenAPI o el Portal, decirle que no: *"es solo una métrica interna del servicio; no cambia la API"*.
3. Commit y release, en la terminal de `$ARCH`:
   ```bash
   git add -A && git commit -m "docs(servicio-de-reservas): métrica de cancelaciones por sede y rol"
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js plan .        # bump recomendado (lo decide el código): PATCH
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js apply . --bump patch
   git push -u origin release/architecture-v1.10.3
   gh pr create -B main -H release/architecture-v1.10.3 --fill
   ```
   - Si `plan` recomienda MINOR, usar `--bump minor` y la rama `release/architecture-v1.11.0`. Desde ahí, el caso 6 sería 1.11.1.
   - 👤 Presentador · 📍 GitHub: gates verdes. 👤 Arquitecto · 📍 GitHub: **merge**. Anotar el **T0**.
4. **Lo que pasa solo.** 👤 CI (nadie) · 📍 Actions de `northwind-reservas` y del servicio. El presentador narra con la tabla del caso 2: tag, kit editado en sitio y mergeado solo (unos 4 min), índice y despacho, build del servicio, tests y merge. Total: unos 7 a 8 minutos.
   - Mientras espera, mostrar el slide 14 (*El camino al desatendido*): este cambio es justo la rutina que el Servicio ya puede hacer sin nadie.
5. **Esperado en el PR del servicio** (👤 CI · 📍 `northwind-servicio-reservas`):
   - `.architecture.json` en 1.10.3;
   - el contador de cancelaciones con Micrometer (que ya exporta por OTLP, ADR-004), con etiquetas de sede y rol, sumado en la cancelación;
   - un test que lo cubre;
   - tests verdes y merge automático por `github-actions`, sin nadie.
   - El Portal no recibe PR: su paquete no cambió.

**Decir:** "Nadie escribió este código ni aprobó el PR. La arquitectura cambió y el servicio la siguió, con sus tests como única puerta."

**Si falla:**
- El build del servicio no arranca: runner offline. Levantarlo (`~/actions-runner/northwind-servicio-reservas`) y re-despachar con `gh run rerun` del job `architecture-index`; si no hay tiempo, mostrar la evidencia de 2a.
- Los tests fallan: el PR queda abierto sin merge. Así está diseñado; mostrarlo como tal.
- El agente no cambia nada: mostrar el `what_changed` del paquete 1.10.3, que nombra el cambio de la especificación.

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
   git push -u origin release/architecture-v1.10.4
   gh pr create -B main -H release/architecture-v1.10.4 --fill
   ```
   Gates verdes → 👤 Arquitecto · 📍 GitHub: **merge**. Anotar el **T0**.
5. **Lo que pasa solo** (👤 CI · 📍 Actions de `northwind-reservas` y del servicio; el presentador narra): la misma cadena del caso 2: tag, kit editado en sitio, índice. Solo cambió el paquete del Servicio de Reservas, así que solo el Servicio abre un PR. El Portal no se toca.
6. **Esperado en el PR del servicio:**
   - `intervalo-purga-claves` con `PT1H` (una hora) en `application.yaml`, sin el `TODO(architecture)`. El comentario de `PropiedadesReservas.java` ya no dice que el intervalo no está documentado;
   - `.architecture.json` en 1.10.4;
   - tests verdes y merge automático por `github-actions`, sin nadie.

**Decir:** "Un PATCH de documentación también llega al código. La pregunta que dejó el build la respondió el arquitecto, no el desarrollador."

**Si falla:**
- El servicio no abre PR: revisar el job del build en Actions del servicio. Si el agente decidió que no había nada que cambiar, mostrar el `what_changed` del paquete 1.10.4, que nombra el cambio de la especificación.
- Los tests fallan: el PR queda abierto sin merge. Así está diseñado (el merge automático exige tests verdes). Mostrarlo como tal.
- **Corrida equivalente de referencia:** el PATCH 1.9.1 (2026-10-24): el PR #13 del servicio se abrió a las 17:01:04 y `github-actions` lo mergeó a las 17:02:04.

---

## Caso 7 — Grabado para video: el Portal se actualiza en el IDE (asistido, v1.10.1)

No se hace frente al público: se graba para armar un video del modo asistido de punta a punta que el equipo revisa por su cuenta. Es el mismo recorrido de 2b, pero esta vez con un cambio que **solo toca el Portal de Reservas**: el Servicio no recibe nada, así que no hay un build desatendido en paralelo que distraiga.

El cambio: hoy una reserva cancelada se ve en el listado del Portal solo como «cancelada». Negocio quiere que muestre **el motivo y la fecha de la cancelación**. Los dos datos ya vienen en el contrato (`cancellationReason`, `cancelledAt` de `Booking`), así que ningún contrato cambia: cambia la descripción del Portal y, por lo tanto, solo su paquete.

**Se grabó el 2026-10-27, antes de la sesión 2**, sobre la arquitectura de ese momento: por eso publicó **`architecture-v1.10.1`** y no la 1.10.3 que se había planeado. Las tomas, arregladas (1920×1080, un cuadro clave por segundo para que el video se pueda adelantar), están en `~/Downloads/DemoVideo/arreglados/`.

### Lo que pasó (mejor de lo planeado)

La primera revisión del PR del Portal **falló**, y la corrección la pasó. El video muestra la revisión haciendo su trabajo, no solo un PASS.

| Paso | Hora UTC | Evidencia |
|---|---|---|
| PR del release abierto | 02:18:20 | `northwind-reservas` PR #107 |
| Merge del release (T0) | 02:18:54 | PR #107 |
| Kit mergeado solo por `github-actions` | 02:23:05 | PR #108 (+4:11) |
| Índice publicado, paquete del Portal 1.10.1 | 02:23:08 | Actions · `architecture-index` |
| PR del Portal abierto | 02:30:57 | `northwind-portal-reservas` PR #21 |
| **Architecture review: ⛔ FAIL** | 02:32:02 | Comentario del PR #21 (primera versión) |
| Corrección empujada | 02:38:16 | Dos commits nuevos en el PR #21 |
| **Architecture review: ✅ PASS** | 02:39:26 | El mismo comentario, actualizado |
| Merge del desarrollador | 02:40:47 | PR #21 |

**Qué marcó la revisión en el primer intento:**
- ⛔ **Bloqueante `assets-mixed`:** el commit de contratos (`architecture: contracts 1.10.1`) cambiaba `architecture/c4-descriptor.md` junto con otro archivo. Los contratos se comitean solos, para que el diff muestre qué cambió del contrato.
- ⚠ **Advertencia, regla 3:** el código convertía `cancelledAt` a hora de America/Bogota con formato `YYYY-MM-DD HH:mm` citando ADR-110. Pero ADR-110 deja las marcas técnicas como `cancelledAt` en ISO 8601, e INV-11 no fija zona ni formato de presentación. Lo que corresponde es un `TODO(architecture)` o una escalación, no inventar.

**La corrección:** el commit de contratos quedó solo, y el formato inventado se cambió por un `TODO(architecture)` que deja la pregunta al arquitecto. La revisión pasó con 0 bloqueantes, 0 advertencias y 1 nota (`todo-added`: la pregunta queda registrada).

**Decir en el video:** "La revisión no es un sello. Encontró un commit mezclado y una regla inventada, el desarrollador corrigió en el IDE, y lo que la arquitectura no dice quedó como pregunta para el arquitecto."

### Tomas

| Toma | Archivo | 👤 Rol · 📍 Dónde | Qué se ve | Duración |
|---|---|---|---|---|
| 1 | `toma-1.mp4` | Arquitecto · `northwind-reservas` · terminal + Claude Code | Rama, pedido, antes → después aprobado | 2:35 |
| 2 | `toma-2.mp4` | Arquitecto · terminal | Commit, `plan` (PATCH), `apply`, push, PR contra main | 0:57 |
| 3 | `toma-3.mp4` | Arquitecto · GitHub | Gates verdes, merge (T0) y la cadena del kit y el índice | 4:02 |
| 4 | `toma-4.mp4` | Desarrollador del Portal · `northwind-portal-reservas` · Claude Code | Rama, pedido de actualización, `what_changed`, el agente trabaja | 3:35 |
| 5a | `toma-5a-review-falla.mp4` | Desarrollador del Portal · GitHub | PR #21, la revisión corre y da **FAIL**: el comentario con el bloqueante y la advertencia | 1:19 |
| 5b | `toma-5b-correccion.mp4` | Desarrollador del Portal · Claude Code | Le pasa el resultado de la revisión al agente, que separa el commit de contratos y cambia el formato por un `TODO(architecture)` | 2:00 |
| 5c + 6 | `toma-5c-pass-y-toma-6.mp4` | Desarrollador del Portal · GitHub | La revisión vuelve a correr: **PASS** con una nota; merge | 3:05 |

1. **Toma 1.** 👤 Arquitecto · 📍 `northwind-reservas`. En la terminal de `$ARCH`:
   ```bash
   cd $ARCH && git checkout main && git pull -q && git checkout -b arch/motivo-cancelacion
   ```
   En Claude Code en `$ARCH`:
   > *"En el listado de reservas del Portal, una reserva cancelada debe mostrar el motivo y la fecha de la cancelación. Documéntalo en el Portal de Reservas."*

   **Esperado:** muestra el antes → después en `docs/components/reservas-de-salas-northwind/01-portal-de-reservas.md` § Responsabilidades (una responsabilidad nueva) y una línea en `docs/CHANGELOG.md` § [Unreleased]. No toca el Servicio ni el contrato. **Aprobar.**
   - Si propone cambiar el contrato o el Servicio: *"los datos ya vienen en Booking; es solo del Portal"*.
2. **Toma 2.** En la terminal de `$ARCH`:
   ```bash
   git add -A && git commit -m "docs(portal-de-reservas): motivo y fecha de una reserva cancelada en el listado"
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js plan .        # bump recomendado: PATCH
   bun $SA/skills/architecture-lifecycle/scripts/lifecycle.js apply . --bump patch
   git push -u origin release/architecture-v1.10.1
   gh pr create -B main -H release/architecture-v1.10.1 --fill
   ```
3. **Toma 3.** 👤 Arquitecto · 📍 GitHub: gates verdes → **merge**. Anotar la hora (T0). Esperar a que el índice publique (unos 5 min; Actions · `architecture-index` en verde). El Servicio no abre PR: su paquete no cambió.
4. **Toma 4.** 👤 Desarrollador del Portal · 📍 `northwind-portal-reservas`. En la terminal de `$PORTAL`:
   ```bash
   cd $PORTAL && git checkout main && git pull -q && git checkout -b feat/arquitectura-1.10.1
   ```
   En Claude Code en `$PORTAL`:
   > *"Actualiza el Portal a la versión 1.10.1 de la arquitectura."*

   **Esperado:** `what_changed` nombra solo el Portal de Reservas y la responsabilidad nueva; ningún contrato cambió.
5. **Toma 5.** **Esperado:** `.architecture.json` en 1.10.1 (y los contratos en `architecture/` si el paquete los reescribe, en su propio commit); en `ReservasPage.tsx`, una reserva cancelada muestra el motivo y la fecha; un test nuevo. Si el Portal se puede levantar en local, mostrar una reserva cancelada en el navegador.
6. **Tomas 5a a 6.** Abrir el PR (Claude Code o `gh pr create --fill`). 👤 CI · 📍 Actions del Portal: **Architecture review: PASS**. 👤 Desarrollador del Portal · 📍 GitHub: **merge**.

**Si falla:**
- La review da FAIL: grabarlo igual, es material para el video. Pasarle al agente el comentario (*"revisa el resultado de la revisión de arquitectura del PR y corrígelo"*) y volver a empujar. Así fue la grabación.
- `what_changed` no muestra nada: el índice todavía no publicó la 1.10.1. Esperar al job `architecture-index`.

### Lo que armo yo con la grabación

Con las tomas arregladas y los PRs #107 (release), #108 (kit) y #21 del Portal:
1. Saco capturas en 1920×1080 de GitHub: el PR del release con los gates, el kit mergeado solo y su foto del centro de mando, la corrida de `architecture-index`, el PR del Portal (commits, archivos, las dos versiones del comentario de la revisión, FAIL y PASS) y el merge.
2. Armo el video con las tomas y las capturas, con subtítulos en español y la línea de tiempo real (T0 → índice → PR → FAIL → corrección → PASS → merge).
3. Te paso un primer corte para revisarlo antes de compartirlo.

---

## Después de la demo

- Mergear el PR del registro de la escalación (caso 4).
- Cerrar el issue del caso 5 en el servicio (o crear la escalación que Alia renderizó, si se quiere seguir el ciclo del caso 4).
- Borrar las ramas que se crearon en vivo: `arch/asunto-120`, `arch/metrica-cancelaciones` y `arch/purga-claves` en `$ARCH`, `feat/arquitectura-1.10.0` y `feat/asunto-150` en `$PORTAL`. Del caso 7: `arch/motivo-cancelacion` en `$ARCH` y `feat/arquitectura-1.10.1` en `$PORTAL`.
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
