# Estado / punto de retomada — Inspector FUNDAE (22-jul-2026)

> Documento de handoff. Dónde nos quedamos y cómo continuar sin perder contexto.

## Los dos bloques (no confundir)

| Bloque (componente) | Título visible | Qué es | Carpeta | Repo |
|---|---|---|---|---|
| `block_fundae` | **Dashboard FUNDAE** | Resumen de TODOS los cursos con enlace "Ver". Área personal del inspector (lo que ve FUNDAE al entrar). | `blocks/fundae/` | este repo, carpeta `fundae/` |
| `block_fundae_inspector` | **Inspector FUNDAE** | Accesos directos **dentro de cada curso** (Tutorías, Registros, Finalización, Calificaciones). El que sale en Lin3s. | `blocks/fundae_inspector/` | este repo, carpeta `fundae_inspector/` (versionado por primera vez el 22-jul) |

Regla rápida: **Dashboard = resumen general** · **Inspector = dentro del curso**.

## Hecho y en producción hoy (22-jul)

- **Modalidad Nettrim corregida** a "Teleformación" en `mdl_fundae` (4 cursos: 042-02, 045-01, 048-01, 049-01). El dato lo pinta el bloque desde la columna `modalidad`; no había cálculo, era dato guardado mal.
- **Dashboard FUNDAE revertido a su original**: se probó meterle un panel de inspector y filtro por curso, pero era el bloque equivocado → revertido (commit `b3950d1`). El Dashboard queda como estaba.
- **Pantalla "Actualizar base de datos Moodle" resuelta**: la disparó el cambio de versión de `block_fundae` (hash de versiones). Se cerró pulsando el botón. `block_fundae` no tiene esquema de BD, fue seguro.

## Trabajo EN CURSO (guardado en working tree, pendiente de decidir despliegue)

### `block_fundae_inspector` — enlace Calificaciones añadido
- Fichero: `fundae_inspector/block_fundae_inspector.php`.
- Se añadió el 4º enlace: **Calificaciones** → `/grade/report/grader/index.php?id=COURSEID` (calificador del curso).
- `version.php` dejado en **2026061800 (SIN bump a propósito)** para no re-disparar la pantalla de actualización en Dina.
- Este bloque **no estaba en ningún repo** hasta hoy → capturarlo/commitearlo también resuelve el hueco de la migración a Hetzner.

### `fundae_guia.php` (repo aula, sin desplegar)
- Endpoint que genera/sirve la Guía Didáctica PDF bajo demanda (solo admin/supervisor). En el working tree de `~/Proyectos/aula.tuspeaking.com.moodle3.5` + excepción en `.gitignore`. **Sin commitear ni desplegar.** Se enlazaría desde el inspector cuando se retome.

## EL MURO: OPcache en Dinaserver

- Dina tiene OPcache con `opcache.restrict_api` activo → no se puede vaciar el bytecode desde PHP (`purge_caches`/`touch` NO bastan).
- El SAPI **web** no recarga los ficheros PHP cambiados (aunque el CLI diga `validate_timestamps=On`). **Comprobado**: tras revertir `version.php` en disco a 2026061301, la web seguía leyendo 2026072201 (cacheado).
- **Consecuencia**: cualquier cambio en un bloque PHP (incluido este enlace de Calificaciones) **no se ve en Dina hasta reiniciar PHP-FPM**. En **Hetzner (Docker)** esto no pasa: desplegar = rebuild/restart del contenedor.

## DECISIÓN PENDIENTE (no elegida aún)

Cómo hacer visible el enlace Calificaciones en Dina:
1. **Desplegar + reinicio graceful de PHP-FPM** (panel Dinaserver). Se ve hoy, bajo riesgo (Moodle legacy de poco tráfico), y desbloquea futuros cambios de bloque.
2. **Desplegar sin reiniciar**. Se verá cuando PHP recicle solo, o ya validado en Hetzner.
3. **Bloque HTML** (contenido en BD, sin OPcache). Inmediato y sin reinicio, pero `courseid` fijo por curso y no es el plugin.

## Cómo retomar

1. Asegurar el WIP en git (si no se hizo):
   ```bash
   cd ~/Proyectos/Moodle-3.5-block-for-FUNDAE-2026-dashboard
   git add fundae_inspector/ fundae/version.php ESTADO-2026-07-22-inspector-fundae.md
   git commit -m "wip(fundae_inspector): enlace Calificaciones + doc de estado"
   # (sin push ni scp hasta decidir despliegue)
   ```
2. Elegir opción de despliegue/visibilidad (1/2/3 de arriba).
3. Si se despliega el `.php`: `scp` a `blocks/fundae_inspector/block_fundae_inspector.php` del server. NO subir versión del bloque (re-dispara la pantalla de actualización).
4. Verificar en un curso (ej. Lin3s `id=3203`): `https://aula.tuspeaking.com/app/moodle/course/view.php?id=3203` → el bloque "Inspector FUNDAE" debe mostrar los 4 enlaces.

## Flecos menores
- Verificar si `fundae/version.php` (2026072201) se commiteó/subió tras el revert del Dashboard.
- `fundae_guia.php` + su `.gitignore`: commitear cuando se retome el enlace de guía.
- Rotar la contraseña de BD `moodle35` (se pegó en el chat el 22-jul).

## URLs útiles
- Moodle vive bajo **`/app/moodle/`** (no en la raíz). Curso: `https://aula.tuspeaking.com/app/moodle/course/view.php?id=X`.
- Lin3s: courseid **3203**, c_fundae `00033LIN26-01`, categoría 530.
