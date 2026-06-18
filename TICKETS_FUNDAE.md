# TICKETS - Proyecto FUNDAE 2026

## ✅ COMPLETADOS

### [TICKET-001] Crear tabla mdl_fundae
- Status: COMPLETADO 2026-06-13
- 21 campos finales (incluye AFF, Grupo, Denominación Oficial, CIF, Razón Social, etc.)

### [TICKET-002] Datos test Equivalenza
- Status: COMPLETADO 2026-06-13

### [TICKET-003] Estructura Moodle 3.5
- Status: COMPLETADO 2026-06-13
- Decisión: Usar tabla personalizada mdl_fundae (no custom fields)

### [TICKET-004] Documentación base
- Status: COMPLETADO 2026-06-13

### [TICKET-005] Bloque FUNDAE v1.0.0
- Status: COMPLETADO 2026-06-13
- Repo: github.com/hernandezX1000/Moodle-3.5-block-for-FUNDAE-2026-dashboard

### [TICKET-006] Bloque instalado en producción
- Status: COMPLETADO 2026-06-13
- Capabilities añadidas, permisos a roles, instalado en área personal Inspector FUNDAE

### [TICKET-007.1] E2Y Commerce sincronizado FUNDAE
- Status: COMPLETADO 2026-06-13
- 20 cursos cargados, 15 bonificables
- Denominaciones oficiales importadas del portal FUNDAE
- Correcciones: 058-01 Andrea, 065-01 Linda, 064-01 NO BONIF

### [TICKET-008] Auditoría grupos E2Y
- Status: COMPLETADO 2026-06-13
- 15/15 cursos bonificables con C/Fundae en grupo correcto
- Creados grupos 061-01 y 062-01 (faltaban)

### [TICKET-009] Filtros y búsqueda en dashboard
- Status: COMPLETADO 2026-06-13
- Búsqueda textual, filtros por empresa/modalidad/bonificable

### [TICKET-010] Importar denominaciones oficiales FUNDAE
- Status: COMPLETADO 2026-06-13
- Fuente: grupos.xls (Excel portal FUNDAE)
- 85 grupos formativos disponibles

## ⏳ PENDIENTES

### [TICKET-011] Iberassekuranz (Cat 543)
- 10 cursos
- AFF: 067-076 (Q2)
- Estimado: 30 min

### [TICKET-012] Tekia (Cat 537/551)
- 23 cursos
- AFF: 050-054 (Q1), 083-088 (Q2)
- Estimado: 1 hora

### [TICKET-013] GKN Automotive (Cat 521)
- 12 cursos
- AFF: 014-018, 032, 079
- Estimado: 30 min

### [TICKET-014] CENIEH (Cat 535)
- 5 cursos
- AFF: 035-039
- Estimado: 20 min

### [TICKET-015] Nettrim/Attrim/Angela/DataIE (Cat 536)
- 9 cursos
- AFF: 040-049
- Estimado: 30 min

### [TICKET-016] Torres y Carrera (Cat 538)
- 3 cursos
- AFF: 055, 056
- Estimado: 15 min

### [TICKET-017] Papelera del Nervión (Cat 554)
- 4 cursos
- AFF: 089-092
- Estimado: 20 min

### [TICKET-018] Lactalis (Cat 524, 552)
- 7 cursos
- Pendiente: AFF (verificar)
- Estimado: 30 min

### [TICKET-019] Lin3s (Cat 530)
- 6 cursos
- Pendiente: AFF (verificar)
- Estimado: 30 min

### [TICKET-020] Senator Hotels (Cat 525)
- 4 cursos
- Pendiente: AFF (verificar)
- Estimado: 20 min

### [TICKET-021] Resto empresas
- ~22 cursos (Alua, BCN, Bydemes, CENIEH, GDES, Lookiero, Rubi, Salvi, etc.)
- Estimado: 2 horas

### [TICKET-022] Limpiar grupos "basura" en cursos
- Algunos cursos tienen grupos como "11/01, 27/01, Alison, Emma, Kate, Tim"
- Necesitan limpieza
- Estimado: 1 hora

### [TICKET-FUTURO-01] Migrar a modelo 1:N
- Cuando lleguen cursos con múltiples alumnos
- Renombrar shortname = denominación oficial
- Estimado: 4 horas

### [TICKET-FUTURO-02] Reportes y export
- Export CSV/Excel desde dashboard
- Reportes PDF automáticos
- Estimado: 6 horas

## Total
- Completados: 10 tickets
- Pendientes: 12+ tickets
- Tiempo estimado restante: ~10-15 horas

## [NOTA-001] Cursos NO bonificables a revisar

### GKN Automotive - Alemán (3 cursos sin alta FUNDAE)
- **3162** - Jon Garcia (Alemán)
- **3163** - Maddi Olarriaga (Alemán)
- **3164** - Ion Mikel Arin (Alemán)
- ⚠️ Revisar si se olvidó dar de alta en FUNDAE
- ⚠️ Si era intención bonificar: dar de alta + actualizar bonificable=1
- Fecha nota: 2026-06-13

## [NOTA-003] CIF VIFERME Asesores S.L. - verificar
- CIF actual en BBDD: B6355458 (8 caracteres, INVÁLIDO)
- Los CIF españoles son 1 letra + 8 dígitos
- Verificar con cliente o registro mercantil
- Fecha: 2026-06-13

---

## Sesión 16/06/2026 — Requerimientos SEPE Navarra

### [TICKET-023] Requerimientos SEPE — Infraestructura BD
- Creadas 4 tablas nuevas en aulatuspeaking35:
  - `mdl_fundae_guia_didactica` — metadatos guías didácticas por curso
  - `mdl_fundae_requerimientos` — registro requerimientos SEPE recibidos
  - `mdl_fundae_documentos` — repositorio central documentos generados
  - `mdl_fundae_docentes` — perfiles estructurados docentes FUNDAE
- Poblada `mdl_fundae_guia_didactica` con todos los cursos activos
- Registrados 23 CVs de docentes en `mdl_fundae_documentos`
- Registrados 8 requerimientos en `mdl_fundae_requerimientos`
- Estado: ✅ Completado

### [TICKET-024] Scripts generadores FUNDAE
- `gen_guia_didactica.py` — generador genérico guías didácticas PDF (aulatuspeaking)
- `gen_perfil_docente.py` — generador perfiles docentes Moodle (aulatuspeaking)
- `gen_calificaciones.py` — libro calificaciones 6 alumnos e2y Commerce
- `gen_calificaciones_single.py` — calificaciones alumno individual
- Paneles PHP: `fundae_grupos.php`, `fundae_calificaciones.php`
- Estado: ✅ Completado

### [TICKET-025] Requerimiento 119222 — Dermostética AF029/01
- Empresa: Dermatología Científica S.L. (CIF B97436331)
- Alumnas: Ana Franqueza + Imma Torres (course 3178)
- Tutora: Amber Gendron
- Documentos generados: contrato, Doc2, CV, Doc4, Doc5 (x2), Doc6 (x2)
- Carpeta: `06:029-01 - Dermoestetica - Naqua/`
- BD: registrado en mdl_fundae_requerimientos + mdl_fundae_documentos
- Estado: ✅ Docs generados · ⏳ Pendiente subir a empresas.fundae.es

### [TICKET-026] Requerimiento 254387 — Attrim AF040/01
- Empresa: Attrim Impact Technology Group S.L. (CIF B72808983)
- Alumna: Inés Guillén Luengo (course 3211)
- Tutor: Rj Reddy
- Documentos generados: contrato, Doc2, CV, Doc4, Doc5, Doc6
- Carpeta: `07:040-01 - Attrim - Ines Guillen/`
- BD: registrado en mdl_fundae_requerimientos + mdl_fundae_documentos
- Estado: ✅ Docs generados · ⏳ Pendiente subir a empresas.fundae.es

### [TICKET-027] Perfiles docentes FUNDAE — mdl_fundae_docentes
- Template HTML corporativo creado con secciones FUNDAE obligatorias
- Amber Gendron (user_id=2395) — perfil completo registrado y sincronizado
- Perfil Moodle actualizado con competencias tecnológicas teleformación
- CV URL curso 3178 corregido: Kate Klopper → Amber Gendron
- 18 docentes pendientes de poblar
- 5 sin CV: Eldina, Guillaume, Odile, Paola, Rj Reddy
- Estado: 🔄 En curso

### [TICKET-028] Requerimientos pendientes — Próximas acciones
- 🔴 250586 · AF034/01 · Naqua · Eduardo · Vencido -11 días
- 🔴 102770 · AF010/02 · RUBI · Kate · Vencido -12 días
- 🔴 104208 · AF012/05 · RUBI · Kiara · Vencido -13 días
- 🔴 102348 · AF009/04 · Micro Ventures · Jessica · Vencido -7 días
- 🔴 102907 · AF010/06 · RUBI · Amber · Vencido -4 días
- 🟠 57996 · AF007/01 · e2y Linda · Vence 19/06 (+3 días)
- Estado: ⏳ Pendiente

## TICKET: Bloque Inspector FUNDAE dentro del curso
**Fecha:** 18/06/2026
**Prioridad:** Media

### Problema
El inspector FUNDAE al entrar en un curso ve la vista del alumno con demasiado ruido:
- 24 participantes mezclados (alumnos + profesores)
- Tiene que navegar por varios menús para encontrar la info relevante
- No hay acceso directo a los informes clave

### Solución propuesta
Crear un bloque custom visible SOLO para el rol `supervisor` dentro de cada curso con:
1. **Alumno** — nombre, DNI, email
2. **Clases realizadas** — link directo a `tutorias_con_profesor.php?courseid=X`
3. **Progreso plataforma** — % completado + link al informe
4. **Evaluación tutorial** — link al seguimiento
5. **Calificación** — estado (pendiente hasta fecha fin)

### Archivos a modificar
- `~/.ftp-users/moodle/blocks/fundae/block_fundae.php` (servidor)
- `/Users/tuspeaking/Proyectos/requirimientos FUNDAE/fundae/block_fundae.php` (local)

### Notas
- El bloque debe leer el `c_fundae` y `courseid` de `mdl_fundae` para identificar al alumno
- Solo visible para rol `supervisor`
- Acceso directo a los 3 puntos clave sin navegación adicional

### Acceso directo necesario
- URL objetivo: tutorias_con_profesor.php?courseid=X&userid=Y
- 'Mis Clases' aparece vacío para supervisor — ocultar para ese rol
- Navegación actual: Administración → Tutorías con profesor → seleccionar alumno (3 pasos)
- Con bloque: 1 clic directo al informe del alumno correcto


### Bug: Descargar Excel en Tutorías con profesor
- El botón 'Descargar Excel' a veces da errores
- Revisar el handler de exportación
- Prioridad: Media (el inspector puede necesitar descargar el informe)


### Informes relevantes para inspector
De la pestaña Informes, solo son útiles:
- Registros (logs): /report/log/index.php?id=X
- Finalización de actividad: para ver % completado (75% requerido)
- Participación en el curso: tiempo dedicado

El bloque debería tener acceso directo a estos 3 informes específicos.
Ocultar o simplificar el resto para el rol supervisor.


### URLs clave para el inspector
- Tutorías con profesor: /app/moodle/tutorias_con_profesor.php?courseid=X
- Registros (logs): /app/moodle/report/log/index.php?id=X
- Finalización de actividad: /app/moodle/report/progress/index.php?course=X

Estas 3 URLs deben ser acceso directo en el bloque inspector FUNDAE.

