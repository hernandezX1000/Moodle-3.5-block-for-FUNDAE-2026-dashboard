# Agente de reconciliación de datos FUNDAE (diseño)

**Fecha:** 2026-08-06
**Contexto:** el dashboard nuevo (`block_fundae`) destapó que `mdl_fundae` tiene huecos
(c_fundae/razón social/CIF NULL, ID sin reconciliar). Rellenar a mano es lento y repetitivo.
Este agente automatiza el trabajo de la **Fase 2**, con validación humana antes de tocar prod.

> **CORRECCIÓN 6-ago (Hansel):** InvoiceNinja **NO** es la fuente (no tiene las facturas, no se
> usa a diario). La fuente de los datos de EXTERNAS es: (a) el **correo** de la empresa (el agente
> lo busca), y (b) un **campo de PEGAR** donde Hansel pega la factura/correo y el agente extrae
> Acción/Grupo + participante + sociedad. Las PROPIAS siguen saliendo de `fundae_oficial_stg`.

---

## Catálogo de FUNCIONES del agente (a confirmar/priorizar con Hansel)

El agente no es solo reconciliar códigos. Funciones candidatas (marcar cuáles entran y en qué orden):

**A. Datos del dashboard (núcleo — parcialmente hecho a mano hoy)**
1. Reconciliar **código (Acción/Grupo)** por alumno/curso.
2. Rellenar **razón social + CIF + sociedad** (soporta N sociedades por marca).
3. Fijar **Tipo** (Externa/Propia) según regla (código propio→Externa / en oficial→Propia).
4. **Refrescar `fundae_oficial_stg`** desde el export del portal (Propias).
5. **Detectar huecos** → informe "qué falta" con confianza.
6. Verificar **enlace curso ↔ acción** (courseid válido y con alumnos).

**B. Alimentación / ingesta (cómo "come" el agente)**
7. **Buscar en el correo** códigos/fichas/facturas de empresas.
8. **Campo de PEGAR**: pegas factura/correo/escrito → extrae y clasifica a campos.
9. Leer **notificaciones de inicio/fin de grupo** (PDF FUNDAE) y fichas.

**C. Cumplimiento / expediente (más allá del dashboard — por decidir)**
10. **Requerimientos SEPE** (Componente C): registrar escrito, vencimiento (10 días), documentos, estado.
11. **Inspector** (Componente B): accesos de consulta/validación por curso.
12. **Verificar participación/asistencia** para bonificación (detectar "Nunca"/baja actividad, p.ej. Elena/Luis).
13. **Generar documentos FUNDAE**: guía didáctica, CV docente, calificaciones, control de asistencia.
14. **Alertas de vencimientos/plazos** (avisar antes de que caduquen).

> Estado: A y B están diseñados (este doc). C está identificado pero sin diseñar en detalle.
> Hansel confirma cuáles entran en el agente y el orden.

---

## PARTE 1 — alcance acordado (6-ago) + análisis de viabilidad

Agente que **mantiene actualizado y conforme el dashboard FUNDAE**, corriendo **todos los días**:

1. **Vigilar cursos nuevos (diario):** detectar cursos creados desde la última corrida.
   → `mdl_course.timecreated` / cursos sin fila en `mdl_fundae`. **Viable.**
2. **Clasificar FUNDAE / no-FUNDAE:** heurística (patrón de nombre "2026.x - Empresa - ...",
   alumnos con email de empresa ≠ tuspeaking.com, grupo con código) + **preguntar a Hansel** los
   dudosos. **Viable** (con confirmación humana en lo ambiguo).
3. **Si es FUNDAE, alimentarse de los datos que faltan:** detecta huecos (código, razón social,
   CIF, sociedad, enlace) y los **pide** (busca en el correo / te avisa / redacta correo a la
   empresa). No inventa. **Viable.**
   - **PROPIAS:** la fuente es el **Excel del portal FUNDAE** (`rptListadoGruposformativos`). Como
     solo Hansel puede descargarlo (login del portal), el agente lo **pide proactivamente** (cuando
     detecta propias nuevas o en cadencia) y **refresca `fundae_oficial_stg`** con él (→ `refrescar_fundae_oficial_stg.sql`). **Viable** (hecho hoy).
   - **EXTERNAS:** la fuente es el **correo/factura** de la empresa (busca o pide/pega).
4. **Enlace al curso correcto:** cruza participantes de factura con matrículas. **Viable.**
5. **Coherencia NOMBRE:** denominación en FUNDAE (`fundae_oficial_stg`/factura) = nombre del curso
   (`mdl_course`). Marca diferencias (comparación normalizada, confirma dudosos). **Viable.**
6. **Coherencia CÓDIGO:** el `c_fundae` informado a FUNDAE existe como **grupo del curso** con el
   alumno dentro. Si no, alerta (riesgo de auditoría). **Viable.**

**Corre a diario** (una activación puede pasar en cualquier momento) → **tarea programada**.
Dónde vive: la detección (BD) puede ser cron en el servidor; la parte de investigar/pedir (correo,
redactar) encaja en una **tarea programada de Cowork** (tiene acceso a Gmail). Recomendado: 1 tarea
diaria de Cowork que hace 1→6 y te deja informe + borradores para aprobar.

**Veredicto: el agente PUEDE hacer todo Parte 1** con los datos actuales + ingesta correo/pegar +
tu aprobación. Sin infra nueva, sin InvoiceNinja.

---

## Objetivo — Fase 1 del agente

Que en `mdl_fundae` queden **descritos TODOS los cursos bonificables ACTIVOS**, con:
1. **Descripción correcta** (denominación oficial, empresa, razón social, CIF, modalidad, fechas,
   código c_fundae, ID de grupo FUNDAE).
2. **Enlazados al curso real** de Moodle donde los alumnos reciben la formación (`courseid`
   válido y verificado).
…sin que Hansel tenga que introducir los datos uno a uno.

Alcance: **solo Moodle 3.5** (excluir lo migrado a Learn). Solo **bonificables activos** (no
finalizadas/anuladas).

**Función ÚNICA (aclarado por Hansel 6-ago):** mantener actualizada la tabla `mdl_fundae` que el
dashboard muestra a FUNDAE. Nada más. No es un gestor de requerimientos ni de facturación; su
único cometido es que lo que ve FUNDAE esté correcto y al día.

**Cómo se alimenta (fuentes):**
1. **Hansel le pasa los datos** directamente (p.ej. ficha fiscal: "GDES EFFICIENCY, S.L. / B02734945").
2. El agente puede **pedir proactivamente** los datos que faltan de las empresas de gestión externa.
3. El agente puede **buscar en el correo de Hansel (Gmail)** las conversaciones con el cliente para
   determinar los **nombres de las acciones formativas** que el cliente envía y la **información de
   la empresa**. (Conector Gmail disponible.)
4. Maestro fiscal automatizable: **InvoiceNinja** (`cfo_invoiceninja`) para razón social + CIF.

Toda propuesta pasa por revisión humana antes de escribir en prod (backup + apply gated).

---

## Qué es "descrito correctamente y enlazado" (definición de hecho)

Una fila de `mdl_fundae` está COMPLETA cuando:
- `courseid` → apunta a un curso Moodle existente y con alumnos reales (formación efectiva).
- `c_fundae` + `id_grupo` → casan con `fundae_oficial_stg` (fuente de la verdad FUNDAE).
- `denominacion_oficial`, `modalidad`, `fecha_inicio/fin` → tomadas del oficial.
- `empresa`, `razon_social`, `cif` → del maestro fiscal (ver fuentes).
- `gestion_bonificacion` → Propia/Externa correcto.

---

## Fuentes de datos por campo (el agente NO inventa)

| Campo | Fuente de verdad | Cómo se obtiene |
|---|---|---|
| c_fundae / id_grupo / denom. oficial / modalidad / fechas | `fundae_oficial_stg` | JOIN por c_fundae; si c_fundae NULL, ver reconciliación abajo |
| courseid (enlace al curso) | `mdl_course` + `mdl_groups`/`groups_members` | el grupo del curso lleva el c_fundae como nombre |
| empresa | `mdl_fundae` (ya presente) | — |
| **razón social + CIF** | ⚠️ **fuente por confirmar** | candidatos: InvoiceNinja (billing, tiene razón social+CIF de clientes), tabla de empresas interna, u otro export del portal FUNDAE con datos fiscales |
| gestión (Propia/Externa) | criterio de negocio | regla confirmada + correcciones puntuales |

**Punto crítico:** los datos fiscales (razón social/CIF) de GDES/Lactalis/Naqua NO están en
`mdl_fundae` ni en `fundae_oficial_stg`. El agente necesita un **maestro fiscal** de dónde
copiarlos. Sin esa fuente, esos campos siguen requiriendo input humano.

---

## Pipeline del agente

1. **Inventariar gaps** — query por empresa (filas, sin_razon, sin_cif, sin_cfundae, sin_id,
   gestión). Es la foto que ya sacamos el 6-ago.
2. **Reconciliar c_fundae NULL** — recuperar el código:
   - a) del **nombre del grupo** del curso (`mdl_groups.name` suele ser el c_fundae);
   - b) por **match denominación + empresa + fechas** contra `fundae_oficial_stg` (fuzzy, con
     umbral de confianza).
   - Match único de alta confianza → propone; ambiguo → a revisión humana.
3. **Rellenar razón social + CIF** — cruzar `empresa` con el maestro fiscal (normalizando
   nombres). Alta confianza → propone; baja → a revisión.
4. **Verificar enlace al curso** — `courseid` existe, curso activo y con alumnos; detectar
   courseid huérfanos o cursos sin grupo FUNDAE.
5. **Excluir Learn** — no tocar acciones ya migradas a la plataforma nueva.
6. **Emitir PLAN revisable** — no ejecuta directo: genera un fichero de UPDATEs propuestos con
   **sello de confianza por fila** (alta/media/baja) + un `SELECT` "antes/después". Backup previo
   (`mdl_fundae_bak_<fecha>`). Un humano aprueba y ejecuta.

---

## Guardrails (innegociables — es prod y son datos FUNDAE)

- **No inventa datos fiscales.** Solo copia de una fuente identificada; si no hay, marca "falta fuente".
- **No auto-ejecuta en prod.** Produce un plan (dry-run) + backup; el humano revisa y aplica.
- **Sello de confianza por fila.** Solo auto-propone alta confianza; media/baja → revisión.
- **Idempotente.** Re-ejecutable sin duplicar ni pisar correcciones manuales.
- **Auditable.** Registra qué cambió, de qué fuente y con qué confianza.
- **Excluye Learn.** Alcance estricto Moodle 3.5.

---

## Lo que el agente NO puede resolver solo (queda a humano)

- Datos fiscales sin fuente accesible.
- Ambigüedades de identidad de empresa (p.ej. ¿"Lactalis" y "Lactalis ID" son la misma?).
- Denominaciones oficiales que no casan con ningún curso (posible acción sin montar o en Learn).

---

## Aprendizajes validados (búsqueda en correo 6-ago)

- **Los códigos de las externas SÍ están en los correos** (función de correo del agente validada).
  Lactalis usa su propio formato FUNDAE (ej. Luc → `001-01559/00001`); GDES los envía Daniela
  (`d.arteaga@gdes.com`) — Hansel ya los pidió el 16-jun ("Consulta - códigos FUNDAE").
- **Para externas, la columna ID se queda "—" y es CORRECTO:** su `id_grupo` vive en la cuenta
  FUNDAE de la empresa, no en `fundae_oficial_stg`. En esas filas se rellena Acción/Grupo (su
  código) pero el ID en blanco no es defecto.
- **Una "empresa" (marca) puede tener varias SOCIEDADES.** GDES = marca; sociedades:
  `GDES Efficiency S.L.` (B02734945) y `GD Energy Services, SAU`. El razón social/CIF hay que
  asignarlo por ALUMNO/curso, no por marca (el agente debe soportar N sociedades por empresa).
  Fuente para desambiguar: la lista de Daniela + facturación (InvoiceNinja) por nº de pedido.

## Códigos de externas hallados en correo (6-ago) — parcial

Cada empresa externa usa SU propio formato de código FUNDAE (no el de Micro Ventures):
- **Senator Hotels** (razón social "GRUPO HOTELES PLAYA SA"): ACC `26012, 26024, 26025, 26038, 26039`.
  Mapeo por alumno en el hilo "Facturas pendientes" (tabla ACC/GRUPO de Mirian, `senatorhr.com`).
- **Lactalis Puleva** (B18975599): expediente `001-01559`; ej. Luc → `001-01559/00001`.
- **GDES** (Efficiency B02734945 / GD Energy Services SAU): PENDIENTE lista de Daniela (`gdes.com`).
- **Papelera Nervión**: curso activo (Iván Álvarez); código sin localizar aún.

**Conclusión operativa:** los códigos están en correos/adjuntos dispersos; el mapeo exacto
alumno→código NO debe adivinarse (dato FUNDAE). Vía fiable = pedir a cada empresa externa una
lista limpia confirmada (o que el agente parsee la ficha/adjunto y la deje a validación humana).

## Preguntas abiertas (para arrancar)

1. **¿Cuál es el maestro fiscal** de razón social + CIF? (InvoiceNinja / tabla interna / export FUNDAE).
   Es lo que decide si la Fase 1 del agente es 100% automatizable o deja huecos para input humano.
2. ¿El nombre del grupo del curso (`mdl_groups.name`) contiene de forma fiable el c_fundae?
   (determina si se puede recuperar el c_fundae NULL sin fuzzy matching).
3. ¿Dónde corre el agente? (mismo patrón que el de secretos: rama propia, plan revisable, sin
   tocar prod hasta validar).

---

## Despliegue día a día

Dos piezas (por los guardrails: nada auto-escribe en prod):

**1) Detector automático (solo lectura, corre solo).**
- Script `fundae_reconciliar.py` en el **servidor** (donde está la BD; misma máquina).
- Lanzado por **cron** (p.ej. lunes 08:00, o diario).
- Hace: inventario de gaps → propone c_fundae/razón social/CIF/enlace con **sello de confianza**.
- Salidas: (a) informe legible; (b) `propuesta_updates_<fecha>.sql` (UPDATEs propuestos, no ejecutados).
- Notifica a Hansel por **Resend** (ya se usa) o deja el informe en una carpeta.
- Encaja con los scripts FUNDAE existentes (`gen_*.py` en `/home/aulatuspeaking/`) + crons ya montados.

**2) Aplicador con visto bueno (escribe en prod, gated).**
- `fundae_aplicar.sh`: Hansel revisa la propuesta y lo lanza → **backup** (`mdl_fundae_bak_<fecha>`)
  + aplica solo los UPDATEs aprobados + verifica + `purge_caches`. Rollback disponible.

**Resultado día a día:** cada semana llega un informe "esto falta / esto propongo con confianza X".
Hansel aprueba de un vistazo y aplica. Lo repetitivo lo hace el agente; la decisión, el humano.

**Dependencia para autonomía total:** confirmar el **maestro fiscal** (candidato fuerte:
InvoiceNinja, BD `cfo_invoiceninja` en la misma máquina) para que el detector rellene
razón social/CIF sin intervención. Sin eso, esos dos campos van a "revisión humana".
→ CONFIRMADO por Hansel: la fuente fiscal es InvoiceNinja.

---

## Interfaz de alimentación (el agente necesita por dónde "comer")

No basta con el cron: hace falta un **panel donde entre información** (estructurada o no), el
agente la **clasifique** y la **aplique al campo correcto** de `mdl_fundae`, con revisión humana.
El foco de la función única: datos de empresa (razón social/CIF) y nombres de acciones formativas
para que el dashboard esté correcto. (Reusar esta misma vía para escritos del SEPE / Componente C
sería una **extensión futura**, no la función única del agente.)

**Entradas admitidas:**
- **Subir fichero:** export Excel/CSV del portal FUNDAE, ficha fiscal de empresa, listados.
- **Pegar texto:** un correo, un escrito del SEPE, datos sueltos.
- **Conectores:** InvoiceNinja (razón social/CIF), `fundae_oficial_stg` (ya existe).

**Clasificador (el agente):**
- Estructurado → mapeo de columnas por reglas.
- No estructurado (correo/escrito) → el agente extrae entidades (empresa, c_fundae, CIF, fechas,
  qué pide el SEPE, vencimiento…) y las mapea a campos.
- Casa con la fila correcta de `mdl_fundae` (por empresa/curso/c_fundae) con **sello de confianza**.

**Staging + revisión:** los cambios propuestos se muestran **campo a campo (antes/después)** con
confianza; Hansel aprueba / edita / rechaza. Patrón de tabla de staging (como `fundae_oficial_stg`).

**Aplicador:** escribe lo aprobado (backup, verify, `purge_caches`).

**Auditoría:** qué entró, cómo se clasificó, qué se aplicó, cuándo y quién aprobó.

**Dónde vive:** un panel PHP (patrón `admin-panel/` que ya existe en el aula) con su tabla de
staging; es, en la práctica, la **reconstrucción del Componente C potenciada por agente**
(clasifica y propone en vez de teclear a mano).

**Extensión futura (no la función única) — un escrito del SEPE:** entra pegado o subido → el agente identifica grupo/acción,
qué documentos piden y el vencimiento → propone alta en `mdl_fundae_requerimientos` → Hansel
aprueba. Mismo circuito que los datos de empresa.
