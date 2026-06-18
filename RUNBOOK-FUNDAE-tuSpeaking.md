# RUNBOOK — Gestión FUNDAE tuSpeaking
**Servidor:** aula.tuspeaking.com (aulatuspeaking@vl24689)  
**DB:** aulatuspeaking35  
**Fecha:** 18 junio 2026  

---

## 1. REGISTRAR UN REQUERIMIENTO FUNDAE EN LA DB

Cuando llega un requerimiento de FUNDAE (PDF del SEPE), hay que registrarlo en `mdl_fundae_requerimientos`.

```sql
INSERT INTO mdl_fundae_requerimientos 
(c_fundae, id_grupo, csv_fundae, fecha_escrito, fecha_recepcion, fecha_vencimiento,
docs_solicitados, observaciones_sepe, estado, registro_salida,
empresa, modalidad, tipo_accion, timecreated)
VALUES
('00033LIN26-01', 202516, 'FUNDAEOO407A463059A8FB036570611', 
'2026-06-11', '2026-06-11', '2026-06-19',
'["guia_didactica","conexiones_zoom"]',
'Guía didáctica con información insuficiente. Registro conexiones al finalizar.',
'pendiente', 'X20260033657',
'LIN3S TRANSFORMACION DIGITAL, S.L.', 'Teleformación', 'Externa', UNIX_TIMESTAMP());
```

**Campos clave del PDF del requerimiento:**
- `c_fundae` — Nº AF + Nº Grupo (ej: 00033LIN26-01)
- `id_grupo` — ID Grupo FUNDAE
- `csv_fundae` — CSV del documento
- `registro_salida` — SGPAE REGISTRO DE SALIDA
- `fecha_vencimiento` — 10 días hábiles desde recepción
- `docs_solicitados` — array JSON con lo que piden
- `tipo_accion` — 'Propia' o 'Externa'

**Estados posibles:** `pendiente` → `en_curso` → `respondido` → `vencido`

---

## 2. REGISTRAR UNA ACCIÓN FORMATIVA EXTERNA (Lin3s, etc.)

Las acciones externas no van por el circuito normal. Hay que insertar en 3 tablas:

### 2a. fundae_externo_stg
```sql
INSERT INTO fundae_externo_stg 
(id_grupo, c_fundae, denominacion_oficial, modalidad, fecha_inicio, fecha_fin, duracion, estado)
VALUES
(202516, '00033LIN26-01', 'Curso de Inglés B1', 'Teleformación', 
'2026-02-18', '2026-06-30', 16, 'Válido');
```

### 2b. mdl_fundae
```sql
INSERT INTO mdl_fundae 
(courseid, c_fundae, denominacion_oficial, empresa, razon_social, cif,
modalidad, idioma, nivel, fecha_inicio, fecha_fin, horas_totales, 
horas_plataforma, horas_conversacion, bonificable, accion_bonificada, 
gestion_bonificacion, timecreated)
VALUES
(3203, '00033LIN26-01', 'Curso de Inglés B1', 'Lin3s',
'LIN3S TRANSFORMACION DIGITAL, S.L.', 'B16769135',
'Teleformación', 'Inglés', 'B1', '2026-02-18', '2026-06-30', 
16, 13, 3, 1, 1, 'Empresa Externa', UNIX_TIMESTAMP());
```

**Distribución de horas Lin3s 1to1 (acuerdo feb 2026):**
- Total: 16 horas
- Plataforma (autoestudio): 13 horas (80% mínimo FUNDAE)
- Conversación con tutor (Zoom): 3 horas (20% mínimo FUNDAE)

### 2c. mdl_fundae_guia_didactica
```sql
INSERT INTO mdl_fundae_guia_didactica 
(c_fundae, herramienta_sincrona, estado, tutor_real_userid, tutor_moodle_userid, 
timecreated, timemodified)
VALUES
('00033LIN26-01', 'Zoom', 'pendiente', 2395, 2395, 
UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
```

**Tutores Lin3s frecuentes:**
- Amber Gendron → userid 2395
- Kiara Johnston → userid 2461
- Jessica Lee Bedford → userid 2557
- Clara Blomfield → userid 2235

---

## 3. GENERAR GUÍA DIDÁCTICA (PDF)

```bash
# 1. Verificar que horas_totales está bien en mdl_fundae
mysql aulatuspeaking35 -e "SELECT horas_totales FROM mdl_fundae WHERE c_fundae = '00033LIN26-01';"

# 2. Verificar que duracion está bien en fundae_externo_stg
mysql aulatuspeaking35 -e "SELECT duracion FROM fundae_externo_stg WHERE c_fundae = '00033LIN26-01';"

# 3. Generar el PDF
python3 /home/aulatuspeaking/gen_guia_didactica.py --c_fundae 00033LIN26-01 --output /home/aulatuspeaking/fundae_docs

# 4. Procesar con ghostscript para embeber fuentes (OBLIGATORIO para que se vea en navegadores)
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite \
-dEmbedAllFonts=true -dSubsetFonts=true \
-sOutputFile=/home/aulatuspeaking/fundae_docs/Doc4_Guia_Didactica_IDGRUPO_CFUNDAE_final.pdf \
/home/aulatuspeaking/fundae_docs/Doc4_Guia_Didactica_IDGRUPO_CFUNDAE.pdf

# 5. Descargar a Mac
# (ejecutar desde el Mac, NO desde el servidor)
scp aulatuspeaking@aula.tuspeaking.com:/home/aulatuspeaking/fundae_docs/Doc4_Guia_Didactica_IDGRUPO_CFUNDAE_final.pdf ~/Desktop/
```

**IMPORTANTE:** Si el PDF muestra "0 horas", el problema está en `fundae_externo_stg.duracion` = NULL. Actualizarlo con `UPDATE fundae_externo_stg SET duracion = 16 WHERE c_fundae = '...'` y regenerar.

---

## 4. CREAR GUÍA DIDÁCTICA COMO PÁGINA MOODLE

Alternativa al PDF cuando el PDF no se visualiza bien en el navegador. 

```bash
python3 << 'EOF'
import subprocess

def run_sql(sql, db='aulatuspeaking35'):
    result = subprocess.run(['mysql', db, '-e', sql], capture_output=True, text=True)
    lines = result.stdout.strip().split('\n')
    if len(lines) < 2: return []
    headers = lines[0].split('\t')
    return [dict(zip(headers, l.split('\t'))) for l in lines[1:] if l.strip()]

# Adaptar: courseid, c_fundae, id_grupo, nivel, tutor_userid, horas
courseid = 3203
c_fundae = '00033LIN26-01'
horas_total = 16
horas_conv = 3
horas_plat = 13

t = run_sql(f"SELECT firstname, lastname, email FROM mdl_user WHERE id = 2395")[0]
p = run_sql(f"SELECT u.firstname, u.lastname, u.email FROM mdl_user u JOIN mdl_user_enrolments ue ON ue.userid = u.id JOIN mdl_enrol e ON e.id = ue.enrolid WHERE e.courseid = {courseid} AND u.deleted = 0 AND u.email NOT LIKE '%tuspeaking%'")
participantes = ''.join([f"<li>{x['firstname']} {x['lastname']} — {x['email']}</li>" for x in p])

html = f"""<h2>1. Datos identificativos</h2>
<table border="1" cellpadding="6" style="border-collapse:collapse;width:100%">
...
</table>"""  # Completar con el HTML de la guía

html_escaped = html.replace("'", "\\'")
sql = f"INSERT INTO mdl_page (course, name, intro, introformat, content, contentformat, legacyfiles, display, displayoptions, revision, timemodified) VALUES ({courseid}, 'Guía Didáctica Actualizada', '', 1, '{html_escaped}', 1, 0, 0, '', 1, UNIX_TIMESTAMP());"
subprocess.run(['mysql', 'aulatuspeaking35', '-e', sql])
page_id = run_sql(f"SELECT MAX(id) AS id FROM mdl_page WHERE course = {courseid}")[0]['id']
print(f"✓ Página creada con id = {page_id}")
EOF
```

Tras crear la página, hay que añadirla al course module:

```sql
-- 1. Buscar el contexto del curso
SELECT id FROM mdl_context WHERE instanceid = 3203 AND contextlevel = 50;
-- Resultado ejemplo: 586624

-- 2. Crear el course module
INSERT INTO mdl_course_modules (course, module, instance, section, visible, visibleold, 
groupmode, groupingid, completion, completionview, completiongradeitemnumber, 
completionexpected, availability, showdescription, added)
SELECT 3203, id, PAGE_ID, SECTION_ID, 1, 1, 0, 0, 0, 0, NULL, 0, NULL, 0, UNIX_TIMESTAMP()
FROM mdl_modules WHERE name = 'page';

SET @cm_id = LAST_INSERT_ID();

-- 3. Insertar contexto con el path correcto del curso
INSERT INTO mdl_context (contextlevel, instanceid, path, depth)
SELECT 70, @cm_id, CONCAT('/1/578068/CONTEXT_CURSO/', @cm_id), 4
FROM dual;

-- 4. Añadir al sequence de la sección
UPDATE mdl_course_sections 
SET sequence = CONCAT(sequence, ',', @cm_id)
WHERE id = SECTION_ID;
```

---

## 5. CORREGIR CLASES CON zoom_clasecompletada = 3

Cuando una clase aparece como "Pendiente" en Success/Moodle pero sí se impartió:

```sql
-- Ver clases problemáticas del alumno
SELECT id, acuity_datetime, zoom_meetingid, zoom_clasecompletada, zoom_duration
FROM mdl_i3code_acuityZoom
WHERE studentid = USERID
ORDER BY acuity_datetime DESC;

-- Verificar asistencia real en participantes Zoom
SELECT p.zoom_name, p.zoom_email, p.zoom_jointime, p.zoom_leavetime, p.zoom_duration
FROM mdl_i3code_acuityZoom az
JOIN mdl_i3code_acuityZoom_participants p ON p.zoom_meetingid = az.zoom_meetingid
WHERE az.id = ID_CLASE;

-- Corregir (solo si se confirma que se impartió)
UPDATE mdl_i3code_acuityZoom
SET zoom_clasecompletada = 1
WHERE id = ID_CLASE AND studentid = USERID;
```

Después ejecutar el script de sync:
```bash
/usr/local/bin/php73 -d disable_functions= -d "memory_limit=4096M" \
  /home/aulatuspeaking/www/app/moodle/admin/cli/i3code_download_zoomdata.php
```

---

## 6. CORREGIR PROGRESO DE PLATAFORMA (completionstate)

Cuando un alumno tiene actividades hechas pero no aparecen como completadas:

```sql
-- Ver estado actual del alumno
SELECT COUNT(*) AS total,
  SUM(CASE WHEN cmc.completionstate > 0 THEN 1 ELSE 0 END) AS completadas,
  ROUND(SUM(CASE WHEN cmc.completionstate > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS porcentaje
FROM mdl_course_modules cm
JOIN mdl_modules m ON m.id = cm.module
LEFT JOIN mdl_course_modules_completion cmc ON cmc.coursemoduleid = cm.id AND cmc.userid = USERID
WHERE cm.course = COURSEID AND cm.completion > 0 AND cm.visible = 1;

-- Verificar que realmente ha hecho las actividades (OBLIGATORIO antes de corregir)
SELECT COUNT(*) AS hvp_vistos
FROM mdl_logstore_standard_log
WHERE userid = USERID AND courseid = COURSEID
AND component = 'mod_hvp' AND action = 'viewed';

-- Solo si hvp_vistos > 0, marcar actividades como completadas
INSERT INTO mdl_course_modules_completion 
(coursemoduleid, userid, completionstate, viewed, overrideby, timemodified)
SELECT cm.id, USERID, 1, 1, NULL, UNIX_TIMESTAMP()
FROM mdl_course_modules cm
JOIN mdl_modules m ON m.id = cm.module
LEFT JOIN mdl_course_modules_completion cmc ON cmc.coursemoduleid = cm.id AND cmc.userid = USERID
WHERE cm.course = COURSEID
AND cm.completion > 0
AND cm.visible = 1
AND cmc.completionstate IS NULL
AND m.name != 'assign'
ON DUPLICATE KEY UPDATE completionstate = 1, timemodified = UNIX_TIMESTAMP();
```

---

## 7. DOCUMENTACIÓN PARA RESPONDER UN REQUERIMIENTO

### Documentos Word a generar (en Mac, con Node.js + docx):
1. **Carta de respuesta** — con enlaces a curso, tutorías y logs
2. **Relación de clases** — tabla con fechas, horas y Zoom IDs
3. **Guía didáctica** — PDF generado en servidor

### URLs útiles para incluir en la carta:
```
Curso: https://aula.tuspeaking.com/app/moodle/course/view.php?id=COURSEID
Tutorías: https://aula.tuspeaking.com/app/moodle/tutorias_con_profesor.php?courseid=COURSEID
Logs: https://aula.tuspeaking.com/app/moodle/report/log/index.php?chooselog=1&showusers=0&showcourses=0&id=COURSEID&user=USERID&date=&modid=&modaction=&origin=&edulevel=-1&logreader=logstore_standard
```

### Subir documentación a FUNDAE:
- Portal: https://empresas.fundae.es/
- Pestaña: "DOC PENDIENTE ADJUNTAR"
- Seleccionar el grupo por ID Grupo

### Actualizar estado en DB tras responder:
```sql
UPDATE mdl_fundae_requerimientos
SET estado = 'respondido',
    fecha_respuesta = CURDATE(),
    docs_entregados = '["carta_respuesta","relacion_clases","guia_didactica"]',
    timemodified = UNIX_TIMESTAMP()
WHERE c_fundae = '00033LIN26-01';
```

---

## 8. ACCESO INSPECTOR FUNDAE

```
URL: https://aula.tuspeaking.com
Usuario: fundaemicro2026@tuspeaking.com
Contraseña: Fundae2026+
```

El inspector tiene acceso solo lectura a los cursos bonificables. Si un curso nuevo hay que añadirlo, hay que enrolarlo manualmente en Moodle.

---

## 9. TABLAS CLAVE EN LA DB

| Tabla | Descripción |
|---|---|
| `mdl_fundae` | Registro de todas las acciones formativas |
| `mdl_fundae_requerimientos` | Requerimientos recibidos de FUNDAE |
| `mdl_fundae_guia_didactica` | Datos para generación de guías didácticas |
| `mdl_fundae_documentos` | PDFs generados y su ubicación en el servidor |
| `fundae_externo_stg` | Acciones formativas externas (Lin3s, etc.) |
| `fundae_oficial_stg` | Acciones formativas propias |
| `mdl_i3code_acuityZoom` | Registro de clases Zoom |
| `mdl_i3code_acuityZoom_participants` | Participantes de cada clase Zoom |
| `mdl_course_modules_completion` | Estado de finalización de actividades por alumno |

---

## 10. COMANDOS FRECUENTES

```bash
# Purgar caché Moodle
php /home/aulatuspeaking/www/app/moodle/admin/cli/purge_caches.php

# Sync Zoom
/usr/local/bin/php73 -d disable_functions= -d "memory_limit=4096M" \
  /home/aulatuspeaking/www/app/moodle/admin/cli/i3code_download_zoomdata.php

# Generar guía didáctica
python3 /home/aulatuspeaking/gen_guia_didactica.py --c_fundae CODIGO --output /home/aulatuspeaking/fundae_docs

# Procesar PDF con ghostscript
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dEmbedAllFonts=true -dSubsetFonts=true \
-sOutputFile=OUTPUT.pdf INPUT.pdf

# Descargar PDF del servidor al Mac
scp aulatuspeaking@aula.tuspeaking.com:/home/aulatuspeaking/fundae_docs/ARCHIVO.pdf ~/Desktop/
```
