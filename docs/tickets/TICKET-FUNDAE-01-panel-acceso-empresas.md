# TICKET FUNDAE-01 — Panel FUNDAE del aula: alcance, presentación y validación

**Estado:** 🟡 ABIERTO — recogida de requisitos (se irá ampliando según dictado)
**Fecha inicio:** 2026-08-06
**Repo:** `Moodle-3.5-block-for-FUNDAE-2026-dashboard`
**Docs de referencia en el repo:** `FUNDAE_DATA_MODEL.md`, `RUNBOOK-FUNDAE-tuSpeaking.md`,
`TICKETS_FUNDAE.md`, `ESTADO-2026-07-22-inspector-fundae.md`
**Objetivo:** dejar el panel FUNDAE con el ALCANCE correcto (todas las acciones formativas
bonificables, de todas las empresas), la PRESENTACIÓN correcta, y el flujo de VALIDACIÓN del
inspector. Este documento recoge requisitos → luego **diseño técnico** → luego **plan de ejecución**.

---

## 0. Los DOS componentes (¡no confundir!)

| # | Componente | Fichero | Para qué | Dónde se pinta |
|---|---|---|---|---|
| **A** | **Dashboard FUNDAE** | `fundae/block_fundae.php` (`block_fundae`) | **Mostrar** la información: recuadro agregado + tabla filtrable de todas las acciones | `applicable_formats => all` (todas las páginas) |
| **B** | **Inspector FUNDAE** | `fundae_inspector/block_fundae_inspector.php` (`block_fundae_inspector`) | Donde **FUNDAE consulta y valida** parte de la info del expediente | Solo `course-view` (dentro de un curso) |
| **C** | **Gestión de incidencias y requerimientos** | ⚠️ CÓDIGO PERDIDO (wipe 1-ago) — datos vivos en BD | Registrar/seguir requerimientos SEPE y sus documentos, con estados y vencimientos | (app/UI a reconstruir) |

---

## 1. Requisitos (dictados por Hansel)

### R1 — [Dashboard A] Deben figurar TODAS las empresas / acciones bonificables
En el acceso FUNDAE del aula deben aparecer **todas** las acciones formativas **bonificables**,
sin excepción: las **propias** (alta por tuSpeaking) y las que **dan de alta las empresas**
partner. El listado debe ser **completo** respecto a lo bonificable, venga el alta de donde venga.

### R2 — [Dashboard A] Quitar el recuadro agregado de cabecera
El bloque resumen superior **NO debe mostrarse**:

> **FUNDAE 2026** — Total: **140** · Bonificables: **133** · Acciones bonificadas: **8**

(La información de arriba debe ser **menos**: fuera esa línea agregada.)

**Estado:** ✅ APLICADO en código (`fundae/block_fundae.php`: eliminado el recuadro
líneas ~51–56 + las 3 consultas que solo lo alimentaban). Pendiente commit + deploy
(copiar al server + `purge_caches`).

### R3 — [Inspector B] Consulta y validación
_(pendiente de dictado — el inspector es donde FUNDAE valida; requisitos por recoger)_

### R4 — [Gestión C] Reconstruir el sistema de incidencias y requerimientos
Se salvó la **base de datos** pero NO el **desarrollo** (código perdido en el wipe del
1-ago-2026). Hay que reconstruir la app/UI de gestión de requerimientos SEPE. Objetivo: volver
a tener el sistema para registrar/seguir requerimientos y sus documentos (estados, vencimientos).
_(detalle funcional pendiente de dictado)_

### R5 — [Dashboard A] Normalizar la terminología con el portal FUNDAE
Nuestro dashboard debe usar la **misma terminología y columnas que ve FUNDAE** en su portal,
para que haya correspondencia 1:1 (normalización). Comparativa de las dos capturas (6-ago):

**Lo que ve FUNDAE (portal):** `ID` · `Acción/Grupo` · `Tipo de acción` · `Denom.` ·
`Inicio` · `Fin` · `Not. Ini.` · `Not. Fin`
**Lo que mostramos (dashboard):** `Empresa` · `Razón Social` · `CIF` · `C/Fundae` · `Grupo` ·
`Denominación` · `F. Inicio` · `F. Fin` · `Modalidad` · `NO-FUNDAE` · `Bonificable` · `Gestión` · `URL`

Mapeo y acción de normalización:

| Portal FUNDAE | Nuestro dashboard | Acción |
|---|---|---|
| `ID` (ej. 56971 = id_grupo) | (no se muestra) | Añadir (join a `fundae_oficial_stg` que tiene `id_grupo`) |
| `Acción/Grupo` (`001/01`) | `C/Fundae` (`1826-01`) + `Grupo` (`01`) | Unificar al formato oficial `AFF/Grupo` con "/" |
| `Tipo de acción` (`Propia`) | `Gestión` (`Empresa Externa`/`Micro Ventures SL`) | Ejes distintos → añadir "Tipo de acción" (Propia/…) además de Gestión |
| `Denom.` | `Denominación` | Igual (adoptar rótulo "Denom.") |
| `Inicio` / `Fin` | `F. Inicio` / `F. Fin` | Renombrar a `Inicio` / `Fin` |
| `Not. Ini.` / `Not. Fin` | (no se muestran) | Añadir fechas de notificación inicio/fin |

**Discrepancias detectadas de paso (a revisar en el diseño):**
- Formato `Acción/Grupo`: FUNDAE usa `001/01`; nosotros `1826-01` (Alua) y `042-01` (Angela) —
  con guion y AFF inconsistente (los de Alua parecen malformados).
- `Modalidad`: Angela sale "Aula Virtual" cuando debería ser "Teleformación"
  (bug conocido, ver nota de modalidad Aula Virtual vs Teleformación).

---

## 2. Estado técnico actual (base para el diseño)

### Componente A — `fundae/block_fundae.php` (leído 2026-08-06)
- Lee de una sola tabla **`{fundae}`** (mdl_fundae). Recuadro de cabecera (líneas 20–22, 55–60):
  - `Total` = `count_records('fundae')` → **140**
  - `Bonificables` = `count_records('fundae',['bonificable'=>1])` → **133**
  - `Acciones bonificadas` = `count_records('fundae',['accion_bonificada'=>1])` → **8**
  - **R2 = eliminar el render de las líneas 55–60.**
- Buscador + filtros (empresa / modalidad / bonificable) + tabla de todas las filas de
  `{fundae}` unidas a `{course}` (SQL líneas 24–44, tabla 74–130).
- `applicable_formats => all` → se pinta en todas las páginas y NO filtra por curso (por eso
  dentro de un curso enseña los 140 globales).

### Componente B — `fundae_inspector/block_fundae_inspector.php` (leído 2026-08-06)
- Título "Inspector FUNDAE". Solo se pinta en contexto de curso (`course-view`; si no es curso,
  devuelve vacío).
- Muestra "Accesos inspector": 4 enlaces del curso → Tutorías con profesor
  (`/tutorias_con_profesor.php?courseid=`), Registros de actividad (`/report/log`),
  Finalización de actividad (`/report/progress`), Calificaciones (`/grade/report/grader`).

### Modelo de datos (de `FUNDAE_DATA_MODEL.md`)
- **`mdl_fundae`** = tabla consolidada (courseid, c_fundae, aff, grupo, empresa, razon_social,
  cif, modalidad, horas, fechas, `bonificable`, `accion_bonificada`, `gestion_bonificacion`…).
- **`fundae_oficial_stg`** = **FUENTE DE LA VERDAD ABSOLUTA** (export del portal FUNDAE). El doc
  advierte: usar SIEMPRE sobre `mdl_fundae` para denominación, modalidad y horas oficiales.
- **Implicación para R1:** la completitud depende de que TODAS las acciones bonificables (propias
  y de empresas partner) estén en `mdl_fundae`. Si el alta de una empresa partner no acaba
  escribiendo en `mdl_fundae` / no está reconciliada con `fundae_oficial_stg`, no aparecerá
  aunque el bloque "liste todo". → hay que revisar el **poblado/reconciliación**, no solo la vista.

---

### Componente C — Gestión de incidencias y requerimientos (estado del rescate)
- **Datos VIVOS en BD** (sobrevivieron al wipe): `mdl_fundae_requerimientos` (~17 filas),
  `mdl_fundae_documentos` (~58), `mdl_fundae_docentes`, `mdl_fundae_guia_didactica`
  (esquema en `FUNDAE_DATA_MODEL.md` §16/06 y §16/06 tablas nuevas).
- **Código PERDIDO en el servidor** (wipe 1-ago): la app/UI de gestión.
- **Remanentes LOCALES recuperables** (junio) en `~/Proyectos`:
  - `requirimientos FUNDAE/` → **repo git** (remoto `origin/main`), misma base que el repo del
    dashboard + carpeta `fundae/` con PHP y ficheros `.sample`.
  - `requirimientos FUNDAE _local_backup/` → carpeta suelta (NO git) con scripts de junio:
    `gen_calificaciones.py`, `gen_calificaciones_single.py`, `gen_doc5_attrim.py`,
    `fundae_oficial_import.sql` (+`_128`), `fundae_moodle_grupos.py`, `fundae_feedback_query.py`,
    `insert_profiles.sql`, `rubi_insert.sql`, `grupos.xls`, etc.
- **Pendiente:** inventariar qué de esos remanentes es la base del sistema perdido y qué hay que
  rehacer desde cero. NADA de esto está versionado en el repo canónico todavía.

---

## 3. Preguntas abiertas (a confirmar con Hansel)

1. **R2 "menos info":** ¿SOLO quitar la línea agregada de cabecera, o también sobran columnas
   de la tabla?
2. **R1 alcance:** ¿cómo entra hoy en `mdl_fundae` una acción que **da de alta la empresa** (no
   tuSpeaking)? ¿Hay proceso que la escriba/reconcilie con `fundae_oficial_stg`, o falta?
3. **R1 filtro:** ¿el dashboard debe listar SOLO bonificables, o todas resaltando las bonificables?
4. **Inspector (R3):** ¿qué debe poder consultar/validar exactamente y con qué rol
   (`fundae_inspector`, usuario 5676)? ¿scoping por grupo/expediente?
5. ¿Quién ve cada componente? (rol, si es público dentro del aula, etc.)

---

### R6 — [Dashboard A] Conjunto FINAL de columnas (decidido 6-ago)

| Columna | Decisión | Nota |
|---|---|---|
| Empresa | **MANTENER** | Necesaria para el filtro (el filtro va por empresa) |
| Razón Social | **MANTENER** | |
| CIF | **MANTENER** | |
| C/Fundae (Acción/Grupo) | **MANTENER** | Normalizar formato a `AFF/Grupo` pendiente (R5) |
| Grupo | **MANTENER** | |
| Denominación | **MANTENER** | |
| Inicio | **MANTENER** | Fecha de inicio del curso (renombrar `F. Inicio`→`Inicio`) |
| Fin | **MANTENER** | Fecha de fin (renombrar `F. Fin`→`Fin`) |
| Not. Ini. / Not. Fin | **NO incluir** | Decisión: no las tendremos |
| Modalidad | **MANTENER** | (revisar bug Aula Virtual→Teleformación) |
| Gestión → **Tipo** | **MODIFICAR** | Valores `Propia` / `Externa`. Mapeo propuesto: `Micro Ventures SL`→**Propia**, `Empresa Externa`→**Externa** (CONFIRMAR) |
| Bonificable | **QUITAR** | |
| NO-FUNDAE | **MANTENER** | |
| URL (Ver) | **MANTENER** | Enlace al curso |

**Orden final:** Empresa · Razón Social · CIF · C/Fundae · Grupo · Denominación · Inicio ·
Fin · Modalidad · Tipo · NO-FUNDAE · URL

Pendiente confirmar: (a) mapeo `Micro Ventures SL`→Propia / `Empresa Externa`→Externa;
(b) bug de Modalidad (Angela sale "Aula Virtual", debería "Teleformación").

### R7 — [Dashboard A] Orden de columnas fiel a FUNDAE + añadir ID

**Orden propuesto (lo más parecido al portal FUNDAE, luego nuestros extras):**

`ID` · `Acción/Grupo` · `Tipo de acción` · `Denom.` · `Inicio` · `Fin` ·
`Empresa` · `Razón Social` · `CIF` · `Modalidad` · `NO-FUNDAE` · `Ver`

**Sobre el ID — SÍ se puede (analizado 6-ago):**
- El `ID` de FUNDAE = `fundae_oficial_stg.id_grupo` (INT). NO está en `mdl_fundae`.
- Se añade con `LEFT JOIN fundae_oficial_stg o ON o.c_fundae = f.c_fundae` y `SELECT o.id_grupo`.
- Caveats: (a) `id_grupo` sale en blanco si esa fila no está en el export oficial; (b)
  `fundae_oficial_stg` debe estar **poblada en prod**; (c) discrepancia conocida `033-01`
  (VIFERME y URRU comparten `c_fundae`) → el join puede duplicar/ambiguar ese ID.

**HALLAZGO IMPORTANTE (va más allá del ID):** hoy `block_fundae` lee TODO de `mdl_fundae`
(tabla interna, "puede tener discrepancias"). Pero según `FUNDAE_DATA_MODEL.md` la FUENTE DE LA
VERDAD para **denominación, modalidad, fechas y horas** es `fundae_oficial_stg`. Ese mismo JOIN
que añade el ID permite tomar `Denom.`, `Modalidad`, `Inicio`, `Fin` del origen autoritativo, y
`Empresa`/`CIF`/nivel de `mdl_fundae`. Con eso, en un solo cambio:
- se añade el ID (R7),
- se normaliza la denominación/fechas con FUNDAE (R5),
- **se corrige el bug de Modalidad** (Angela "Aula Virtual" → "Teleformación", porque saldría de
  `fundae_oficial_stg`, no de `mdl_fundae`).

**Reparto de origen por columna:**
| Columna | Origen |
|---|---|
| ID (`id_grupo`) | `fundae_oficial_stg` |
| Acción/Grupo | `c_fundae` (ya es AFF-Grupo; formatear con "/") → hace **redundante** la columna `Grupo` separada de R6 (se propone quitarla) |
| Tipo de acción (Propia/Externa) | derivado de `gestion_bonificacion` (mdl_fundae) |
| Denom. / Modalidad / Inicio / Fin | `fundae_oficial_stg` (fuente de la verdad) |
| Empresa / Razón Social / CIF | `mdl_fundae` |
| NO-FUNDAE | calculado (grupo "NO-FUNDAE" del curso) |
| Ver | `wwwroot/course/view.php?id=courseid` (mdl_fundae) |

Pendiente confirmar: combinar `C/Fundae`+`Grupo` en una sola columna `Acción/Grupo` (estilo FUNDAE).

### R8 — [Principio de diseño] Separar "vista auditor FUNDAE" de "control interno"

**Diagnóstico (análisis 6-ago):** el dashboard mezcla dos audiencias. `Bonificable` (SÍ/NO) y
`NO-FUNDAE` (nº alumnos no bonificables en el curso) son **controles internos** de tuSpeaking
(evitar meter alumnos en cursos no bonificables). El **auditor FUNDAE** no los necesita; a él le
basta con los **ID de grupo** y las **acciones formativas informadas**. Además `Bonificable` y
`NO-FUNDAE` **se solapan** (ambas = "¿está limpio para bonificar?").

**Regla:** la vista que ve FUNDAE = SOLO acciones **informadas** (las presentes en
`fundae_oficial_stg` con `id_grupo`). Consecuencias:
- Al mostrar solo informadas, `Bonificable` es **implícito** → **columna fuera**.
- `NO-FUNDAE` es control interno → **fuera de la vista auditor** (mantener, si se quiere, en una
  vista interna separada).
- **Actualiza R6:** en la vista auditor salen FUERA tanto `Bonificable` como `NO-FUNDAE`.

**Máximo reuso (cambio mínimo):** cambiar SOLO la fuente del bloque — de `FROM {fundae}` a
**conducir desde `fundae_oficial_stg`** (informadas) con `LEFT JOIN mdl_fundae` para Empresa/CIF.
Se reutiliza tal cual el render existente (tabla, buscador, filtros empresa/modalidad). Ese mismo
cambio resuelve R1 (alcance = informadas), R5 (normalización), R7 (ID) y el bug de Modalidad.

**Gap a vigilar:** "informada" ≠ "bonificable pendiente de informar". Una bonificable aún no
comunicada no está en `fundae_oficial_stg` y no saldría. Confirmar que la vista auditor = informadas.

**Columnas finales de la vista auditor (tras R6+R7+R8):**
`ID` · `Acción/Grupo` · `Tipo de acción` · `Denom.` · `Inicio` · `Fin` · `Empresa` ·
`Razón Social` · `CIF` · `Modalidad` · `Ver`  (sin `Bonificable`, sin `NO-FUNDAE`, sin `Grupo` suelto).

---

### Verificación en prod (6-ago) — `fundae_oficial_stg`

- `fundae_oficial_stg`: **128 filas, 128 c_fundae distintos, todas con `id_grupo`** → poblada y limpia.
- Columnas reales en prod: `id_grupo, aff, grupo, c_fundae, denominacion_oficial, modalidad,
  duracion, fecha_inicio, fecha_fin, not_inicio, not_fin, estado, participantes, tipo_accion`.
  → tiene **`tipo_accion`** (Tipo de acción OFICIAL de FUNDAE) y **`not_inicio`/`not_fin`**.
- **Desajuste clave:** `mdl_fundae` = 140 filas, pero solo **99 casan** con la oficial por `c_fundae`.
  - ~29 oficiales SIN `mdl_fundae` → saldrían sin Empresa/CIF/URL (esos vienen de mdl_fundae).
  - 41 mdl_fundae SIN oficial → fuera de la vista auditor (¿sin informar o `c_fundae` mal formado,
    p.ej. Alua "1826-01"?).
- **Antes de voltear la fuente:** caracterizar el gap (query de diagnóstico) para saber si es
  formato de `c_fundae` (arreglable) o acciones realmente sin informar.

**Decisión pendiente — columna "Tipo de acción":** la oficial trae `tipo_accion` (valor FUNDAE,
p.ej. Propia/Agrupada). Es un EJE DISTINTO de tu "Propia/Externa" (que es quién gestiona la
bonificación). ¿La columna "Tipo de acción" muestra el valor oficial de FUNDAE o tu Propia/Externa?

---

### Diagnóstico del gap 99/140 (prod, 6-ago) — es problema de DATOS

Las 41 filas de `mdl_fundae` sin match oficial:
- **5 no bonificables** (E2Y, GKN, Rubi; `bonificable=0`) → fuera de la vista auditor (correcto).
- **6 `c_fundae` malformado** (AFF 4-5 díg): Alua `1826-01`/`3926-01`, Senator `26024-01`… → bonificables reales, clave mal escrita.
- **22 `c_fundae` NULL**: GDES (13), Lactalis (7), Naqua (2) → bonificables sin código FUNDAE.
- **9 formato Lin3s** `000XXLIN26-01` → codificación distinta.

Las 30 oficiales sin `mdl_fundae` (Tekia, Torres, Iberassekuranz, Papelera Nervión, Nettrim…) son
en parte los MISMOS cursos con la clave divergente. **`tipo_accion` oficial = 'Propia' en las 128**
(no discrimina → la columna "Tipo de acción" usa Propia/Externa de `gestion_bonificacion`).

**Conclusión:** conducir SOLO desde `fundae_oficial_stg` dejaría fuera a Alua y ~35 bonificables
(rompe R1). El bloqueo real es de datos: reconciliar `c_fundae` interna ↔ oficial.

### Plan en 2 fases (revisión de R8)

**FASE 1 — presentación (aplicable YA, sin tocar datos):** fuente sigue siendo `mdl_fundae`
filtrada a `bonificable=1` (quita las 5 no bonificables), con `LEFT JOIN fundae_oficial_stg` para
enriquecer: `ID`(id_grupo), y `Denom./Modalidad/Inicio/Fin` con `COALESCE(oficial, mdl)`. Aplica
R2 (fuera recuadro), columnas finales (fuera Bonificable/NO-FUNDAE/Grupo suelto), Tipo=Propia/Externa,
orden FUNDAE. Resultado: se ven TODAS las bonificables (incl. Alua); el `ID` sale relleno en las
reconciliadas y **en blanco en las demás** — ese hueco es una señal útil de "pendiente de reconciliar".

**Estado Fase 1:** ✅ **DESPLEGADO Y VERIFICADO 6-ago** (commit `a9c31ed` rama `dev`; deploy a
`/mnt/moodle-data/moodle-code/blocks/fundae/` + purge_caches). Verificado en prod: 133 acciones,
columnas FUNDAE, sin recuadro/Bonificable/NO-FUNDAE, ID relleno donde reconcilia y "—" donde no
(Alua), Tipo Propia/Externa, y **modalidad corregida a Teleformación** (bug resuelto vía join oficial).
Los "—" del ID son la lista de trabajo de la **Fase 2** (reconciliar c_fundae).
Detalle técnico: SQL `FROM {fundae} f JOIN {course} c LEFT JOIN fundae_oficial_stg o ON o.c_fundae=f.c_fundae WHERE f.bonificable=1`; `fundae_oficial_stg` SIN llaves (no lleva prefijo Moodle); `get_records_sql` keyea por `f.id` (único). Columnas: ID · Acción/Grupo · Tipo de acción · Denom. · Inicio · Fin · Empresa · Razón Social · CIF · Modalidad · Ver.

**FASE 2 — reconciliación de datos (tarea aparte):** corregir `c_fundae` en `mdl_fundae`
(malformados Alua/Senator, NULL de GDES/Lactalis/Naqua, formato Lin3s) para casar con el oficial.
Al hacerlo, los ID se rellenan y la modalidad se corrige en todas. Luego (opcional) se podría
voltear la fuente a oficial.

**Decisión de alcance (confirmar):** ¿la vista muestra TODAS las bonificables (R1, con ID en blanco
para las no informadas) — recomendado — o SOLO las informadas en oficial (perdería Alua hasta la Fase 2)?

---

### Alcance: SOLO Moodle 3.5 producción (no Learn)

Este ticket mejora **solo** lo que vive en Moodle 3.5 prod. **Algunas acciones formativas de
Papelera Nervión, Senator y GDES ya están en Learn** (plataforma nueva) → esas NO están en
`mdl_fundae` y **no deben aparecer** en este dashboard (es correcto, no forzarlas). Esto explica
parte de las "30 oficiales sin `mdl_fundae`": no son errores, se migraron a Learn.
Nota: Senator y GDES "lo llevan ellos" → gestión **Externa**. La Fase 2 de reconciliación debe
excluir lo que ya esté en Learn (no intentar recuperar esas claves en Moodle).

---

### Principio de uso (6-ago) — la tabla es un ÍNDICE, no reporting

**Propósito:** que FUNDAE **identifique la acción formativa y navegue al curso** en Moodle.
NO replicar lo que FUNDAE ya muestra en su portal. No hay sistema integrado que mantenga
`estado`/participantes/etc., así que **no se añaden filtros de reporting** (Estado, Vigencia…):
serían datos sin mantener y duplicarían FUNDAE.

**Filtros/buscadores relevantes (decisión):**
- **Buscador** = pieza central. Ya filtra por texto completo de la fila → localiza por ID,
  Acción/Grupo, empresa, CIF y denominación. Mejora pendiente: placeholder explícito
  ("Buscar por ID, acción/grupo, empresa, CIF o denominación…").
- **Empresa** = se mantiene.
- **Tipo (Propia/Externa)** = opcional, valor bajo.
- **Descartados:** Estado, Vigencia, Modalidad como filtros (reporting, no mantenido, duplica FUNDAE).

---

### Fase 2 — hallazgos de calidad de datos (6-ago)

El dashboard nuevo destapó huecos en `mdl_fundae` (esto es su valor). Caso GDES (12 filas):
`c_fundae` NULL, `razon_social` NULL, `cif` NULL, `gestion_bonificacion`="Micro Ventures SL"
(→ Tipo sale "Propia" cuando Hansel dice que GDES es **Externa**).

Correcciones de datos pendientes (Fase 2, con backup + confirmación):
- **Tipo/gestión:** si empresa es Externa pero `gestion_bonificacion`="Micro Ventures SL",
  corregir a "Empresa Externa". (CONFIRMAR por empresa — "Micro Ventures SL" suele = gestión
  propia de tuSpeaking.)
- **Razón social / CIF NULL:** rellenar (valores los aporta Hansel; no inventar).
- **`c_fundae` NULL / malformado:** parte de la reconciliación con `fundae_oficial_stg`
  (excluir lo migrado a Learn).
- **Método:** primero query de alcance (por empresa: filas, sin_razon, sin_cif, sin_cfundae,
  gestiones) para limpiar en bloque, no fila a fila.

**Worklist de datos incompletos (query alcance 6-ago) — SOLO 4 empresas:**
- GDES (12 filas), Lactalis (5), Lactalis ID (2), Naqua (2 de 3) → sin razón social, sin CIF, sin c_fundae.
- Las otras 21 empresas están completas.
- Dudas a resolver con Hansel: (a) ¿GDES es Externa (corregir gestión) o Propia por dato?;
  (b) ¿"Lactalis" y "Lactalis ID" son la misma empresa (duplicado)?; (c) razón social + CIF reales
  (los aporta Hansel); (d) ¿alguna de las 4 se va a Learn? (si sí, no tocar en Moodle).
- Tipo/gestión: regla confirmada — "Empresa Externa"→Externa (la gestiona la empresa),
  "Micro Ventures SL"→Propia (la gestiona tuSpeaking). Solo Alua y Lin3s son Externa hoy.

**✅ HECHO 6-ago — corrección de gestión (Tipo):** `UPDATE mdl_fundae SET
gestion_bonificacion='Empresa Externa' WHERE empresa IN ('GDES','Lactalis','Lactalis ID')`
(19 filas). Naqua se queda Propia. Backup: tabla `mdl_fundae_bak_20260806` (borrar cuando se
valide). Ahora Externa hoy: Alua, Lin3s, GDES, Lactalis, Lactalis ID.

**PENDIENTE Fase 2 (necesita valores de Hansel):** rellenar `razon_social` + `cif` de GDES,
Lactalis, Lactalis ID y Naqua (todos NULL). Y reconciliar `c_fundae` NULL con el oficial
(excluyendo lo migrado a Learn). Pendiente también: ¿Lactalis y Lactalis ID son la misma empresa?

---

## 4. Diseño técnico
_(pendiente — se completa cuando terminen de recogerse los requisitos)_

## 5. Plan de ejecución
_(pendiente — tras el diseño)_
