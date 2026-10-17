# Guion de prueba — Reservas de Salas Northwind (sintético)

Proyecto **inventado** (Northwind Cowork es ficticio) para probar el pipeline completo de los skills de
[solutions-architect-skills](https://github.com/shadowX4fox/solutions-architect-skills): PO Spec → arquitectura →
release → handoff → índice → servidor MCP (Alia) → escalación RUN. Dos contenedores C4 L2:

| Contenedor | Tipo | Tecnología |
|---|---|---|
| Portal de Reservas | SPA | React 18 + TypeScript, estático en CDN |
| Servicio de Reservas | Microservicio | Java 21, Spring Boot 3.3, Kubernetes |

Más la **Base de Datos de Reservas** (PostgreSQL 16, propiedad del servicio) y un sistema externo, el
**Proveedor de Identidad Northwind** (Keycloak 25, OIDC). Si Workflow 1 modela la base como un tercer contenedor,
es lo esperado: es el store del microservicio.

## Entradas (lo único versionado al inicio)

| Archivo | Qué es |
|---|---|
| `PRODUCT_OWNER_SPEC.md` | PO Spec, 3 casos de uso (consultar, reservar, cancelar); checkability PASS |
| `reservas-hld.mmd` | HLD Mermaid: 4 nodos, 3 subgraphs, 6 aristas |
| `adr/ADR-001…005` | 5 ADRs institucionales inventados (REST/OpenAPI, OIDC, PostgreSQL, OpenTelemetry, Kubernetes) + `adr/README.md` |
| `.sa-skills/project.json` | `"support": "run"` (equipo RUN, Tier 0 tras el primer release) y `"framework": "none"` (sin alineación de capacidades) |
| `.claude/settings.json` | marketplace, plugins, permisos, `defaultMode: auto`, `SA_JUDGE=agent` |

Volver a las entradas: `git clean -fdx && git checkout .` (borra también los tags `architecture-v*` locales sólo si los quitas: `git tag -l 'architecture-v*' | xargs -r git tag -d`).

## Instalar una vez

```bash
claude plugin marketplace add shadowX4fox/solutions-architect-skills
claude plugin install sa-skills@shadowx4fox-solution-architect-marketplace --scope project
cd "$(bun ~/.claude/plugins/marketplaces/shadowx4fox-solution-architect-marketplace/scripts/plugin-root.ts --quiet)" && bun install --frozen-lockfile && cd -
```

Luego `/sa-skills:setup` en una sesión dentro de esta carpeta (escribe el bloque de CLAUDE.md).

## Etapas

Cada etapa en una **sesión nueva** (`claude --permission-mode auto`).

| # | Prompt | Resultado esperado |
|---|---|---|
| 1 | `genera mi arquitectura y usa las respuestas en RUN.md` | `ARCHITECTURE.md`, `docs/`, ADRs de proyecto (101+), todos los gates en verde |
| 2 | `release my architecture` | tag `architecture-v1.0.0` (PR por defecto; `--direct` en `main`) — habilita Tier 0 |
| 3 | `generate dev handoff` | `handoffs/` — kit de 4 partes; `openapi.yaml` del Servicio de Reservas, `ddl.sql` PostgreSQL, `security.md` |
| 4 | commit del kit | `kit-check.js` pasa sobre la versión 1.0.0 |
| 5 | `test the architecture index` | `publish-index.js . --up`: bundle draft con build packs en el servidor local |
| 6 | IDE + MCP | preguntar a Alia; construir el Portal de Reservas o el Servicio de Reservas desde su build pack |
| 7 | escalación | una petición que cruza un trigger (p. ej. «agrega notificaciones por correo», fuera de alcance en el PO Spec) → `escalations/ESC-001-….md` → issue en este repo (`escalate.js issue … --create`, tras el sí) |

**Servidor de prueba**: el servidor `sa-architecture-index` de :8080 de esta máquina tiene otros datos; usa otro
proyecto compose y puerto: `SA_INDEX_PORT=18080` con `--server http://localhost:18080`, y al terminar
`docker compose -p sa-index-test down -v`.

## Respuestas de la etapa 1, en el orden en que llegan

| Paso | Pregunta | Respuesta |
|---|---|---|
| 0.1 | Idioma | **Español (es)** |
| 0.2 | PO Spec | `PRODUCT_OWNER_SPEC.md` (aceptar) |
| 0.3 | Framework de capacidades | declarado `none` en `.sa-skills/project.json` — no pregunta |
| 0.4 | HLD | `reservas-hld.mmd` (Mermaid; confirmar la extracción) |
| 0.5 | Contexto adicional | **ninguno** |
| 0.6 | ADR Context Block | **confirmar** la lista propuesta |
| 0.65 | Catálogo institucional | ya en `adr/` (5 ADRs) — continuar |
| 1–4 | Tipo de arquitectura | **MICROSERVICES** |
| 4.9 | Checkpoints | **automáticos** |
| 4.9 | Sistemas (4a) | **Reservas de Salas Northwind** interno; **Proveedor de Identidad Northwind** externo |
| 4.9 | Sistema foco (4b) | **Reservas de Salas Northwind** |
| 4.9 | Estado de ADRs de proyecto | **todos Proposed** (por defecto) |
| 4.9 | Candidatos que ninguna sección resuelve | **escribirlos** (Proposed) |
| 4.9 | Diagramas opcionales | **ninguno** |
| 4.9 | Arquitecto | `Equipo de Arquitectura Northwind` |
| 7.3 | ¿Crear los TDRs pendientes ahora? | **no por ahora** |

Cualquier otra pregunta: su respuesta por defecto, anotada aquí.
