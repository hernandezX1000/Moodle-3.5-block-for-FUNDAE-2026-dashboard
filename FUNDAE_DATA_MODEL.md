# Modelo de Datos FUNDAE 2026

## Resumen
Documento que define el modelo de datos completo para la gestión FUNDAE 2026 en aula.tuspeaking.com.

## Arquitectura

### Tabla mdl_fundae (Datos FUNDAE consolidados)

Campos principales:
- courseid: ID del curso en Moodle
- c_fundae: Código completo (AFF-Grupo, ej: "001-01")
- aff: Código Accion Formativa (3 dígitos, ej: "001")
- grupo: Código Grupo (2 dígitos, ej: "01")
- denominacion_oficial: Nombre oficial registrado en FUNDAE
- empresa: Nombre comercial de la empresa
- razon_social: Razón social completa
- cif: NIF/CIF empresa
- modalidad: Teleformación / Mixta / Presencial
- idioma: Inglés / Castellano / Francés / etc.
- nivel: A2 / B1 / B2 / C1 / Intermedio / Advanced
- horas_totales: Total horas formación
- horas_plataforma: Horas plataforma
- horas_conversacion: Horas conversación
- num_sesiones: Número sesiones
- fecha_inicio / fecha_fin: Fechas
- bonificable: 1=SI / 0=NO
- accion_bonificada: 1=SI TuSpeaking bonificó / 0=NO
- gestion_bonificacion: "Micro Ventures SL" / "Empresa Externa"

### Tablas relacionadas

- mdl_course: Cursos Moodle (fullname, shortname)
- mdl_groups: Grupos por curso (name = C/Fundae)
- mdl_groups_members: Asignación alumnos a grupos

## Modelo de Relación

### Situación Actual (1:1)
Cada curso tiene 1 alumno único:

```
Curso "001-01 Andrea Landa"
└─ Grupo "AF001-01"
   └─ Andrea Landa
```

### Modelo Futuro (1:N) - Escalable
Un curso, múltiples alumnos con sus C/Fundae:

```
Curso "Curso de Inglés Nivel Intermedio"  (shortname = denominación oficial)
├─ Grupo "001-01" → Andrea Landa
├─ Grupo "001-02" → Carlos Pérez
└─ Grupo "001-03" → María García
```

### Ventajas Modelo Futuro
1. Un curso, múltiples participantes
2. Cada alumno con su C/Fundae individual
3. Contenido compartido (lecciones, recursos)
4. Reportes FUNDAE individualizados
5. Reduce mantenimiento

## Fuente de Verdad

### Orden de prioridad para denominaciones
1. denominacion_oficial (Excel portal FUNDAE)
2. shortname (Moodle renombrado)
3. fullname (Moodle original)

### Proceso de auditoría
1. Exportar Excel del portal FUNDAE
2. Cargar a tabla temporal tmp_fundae_oficial
3. Cruzar con mdl_fundae por c_fundae
4. Identificar coincidencias y discrepancias
5. Auditar grupos vs C/Fundae

## Caso de Uso Resuelto: E2Y Commerce

### Datos
- Empresa: E2Y Commerce
- Razón Social: e2ycommerce S.L.
- CIF: B87748331
- Cursos Q1: 9 (001-01 a 008-01) + 1 NO FUNDAE
- Cursos Q2: 8 (058-01 a 065-01) + 2 NO FUNDAE
- Total bonificables: 15
- Total no bonificables: 5

### Correcciones aplicadas
1. Andrea Landa Q2: 059-01 → 058-01
2. Linda Mohnssen Q2: Añadido 065-01
3. Javier Polo Q2: Marcado NO bonificable (tachado)
4. Grupos creados: 061-01 (Francisco Q2) y 062-01 (Nieves Q2)

## Estado empresas

| Empresa | Cursos | Status |
|---------|--------|--------|
| E2Y Commerce | 20 | ✓ Completo |
| Equivalenza | 1 | ⚠ Sin denominación oficial |
| Iberassekuranz | 10 | ⏳ Pendiente |
| Tekia | 23 | ⏳ Pendiente |
| GKN Automotive | 12 | ⏳ Pendiente |
| Lactalis | 7 | ⏳ Pendiente |
| Nettrim/Attrim | 9 | ⏳ Pendiente |
| Torres y Carrera | 3 | ⏳ Pendiente |
| Papelera Nervión | 4 | ⏳ Pendiente |
| Senator Hotels | 4 | ⏳ Pendiente |
| Naqua | 3 | ⏳ Pendiente |
| Lin3s | 6 | ⏳ Pendiente |
| Otras | 22 | ⏳ Pendiente |

## Roadmap

### Corto plazo
- [ ] Resto empresas (cargar datos FUNDAE)
- [ ] Auditar grupos vs C/Fundae
- [ ] Limpiar grupos "basura"

### Medio plazo
- [ ] Migrar a modelo 1:N
- [ ] Renombrar shortname = denominación oficial
- [ ] Vista detalle por empresa
- [ ] Export CSV/Excel

### Largo plazo
- [ ] Integración API FUNDAE
- [ ] Reportes automáticos PDF
- [ ] Notificaciones automáticas

## Autor
Equipo Desarrollo Aula TuSpeaking
Fecha: 2026-06-13


---

## Actualizacion 16/06/2026 - Nuevas tablas para gestion de requerimientos

### Tabla fundae_oficial_stg (Fuente de la verdad absoluta)
Datos exportados directamente del portal FUNDAE. No editar manualmente.
- id_grupo, aff, grupo, c_fundae
- denominacion_oficial, modalidad, duracion
- fecha_inicio, fecha_fin, estado, participantes

ADVERTENCIA: Esta tabla es la FUENTE DE LA VERDAD. Siempre usar sobre mdl_fundae para denominacion, modalidad y horas oficiales.

### Tabla mdl_fundae_guia_didactica
Metadatos para generacion automatica de guias didacticas PDF.
- c_fundae (UNIQUE) → fundae_oficial_stg
- tutor_fundae_nombre, tutor_moodle_userid, tutor_real_userid, tutor_teams_userid
- herramienta_sincrona: ENUM(Zoom, Teams, Meet)
- objetivo_general, objetivos_especificos, criterio_evaluacion
- pdf_path, pdf_generado_at
- estado: ENUM(pendiente, generado, revisado)

### Tabla mdl_fundae_requerimientos
Registro de requerimientos recibidos del SEPE Navarra.
- c_fundae, id_grupo, csv_fundae
- fecha_escrito, fecha_recepcion, fecha_vencimiento (10 dias habiles)
- docs_solicitados (JSON), docs_entregados (JSON)
- observaciones_sepe, estado: ENUM(pendiente, en_curso, respondido, vencido)
- empresa, modalidad, registro_salida, respondido_por, tipo_accion

### Tabla mdl_fundae_documentos
Repositorio central de todos los documentos FUNDAE generados.
- tipo_documento: ENUM(contrato_encomienda, cv_docente, guia_didactica, acceso_plataforma, conexiones_zoom, seguimiento_tutorial, control_asistencia, hoja_actuacion_fpe, entrevista_fpe, material_didactico, diplomas, calificaciones)
- c_fundae (NULL si es documento reutilizable de empresa)
- cif_empresa, user_id (para CVs)
- path_archivo, nombre_archivo, fecha_documento
- reutilizable: 1=contrato/CV, 0=especifico por expediente
- vigente: 1=activo, 0=reemplazado

### Tabla mdl_fundae_docentes
Perfiles estructurados de docentes para cumplimiento FUNDAE.
- user_id (UNIQUE) → mdl_user
- nombre_completo, titulo_rol, perfil_profesional
- experiencia_json, formacion_json, competencias_json
- anos_teleformacion, certificado_tefl, horas_tefl, idiomas
- perfil_html (HTML generado con template corporativo tuSpeaking)
- perfil_sync: 1=sincronizado con mdl_user.description

---

## Scripts disponibles en /home/aulatuspeaking/

| Script | Descripcion |
|---|---|
| gen_guia_didactica.py | Generador guias didacticas PDF — python3 gen_guia_didactica.py --c_fundae 040-01 |
| gen_perfil_docente.py | Generador perfiles docentes Moodle — python3 gen_perfil_docente.py --all |
| gen_calificaciones.py | Libro calificaciones e2y Commerce — python3 gen_calificaciones.py --output /tmp |
| gen_calificaciones_single.py | Calificaciones alumno individual |

---

## Estado requerimientos 16/06/2026

| ID Grupo | AF | Empresa | Estado |
|---|---|---|---|
| 119222 | 029/01 | Dermostetica | Docs generados - Pendiente subir a FUNDAE |
| 254387 | 040/01 | Attrim | Docs generados - Pendiente subir a FUNDAE |
| 104208 | 012/05 | RUBI Kiara | Vencido -13 dias |
| 102770 | 010/02 | RUBI Kate | Vencido -12 dias |
| 250586 | 034/01 | Naqua Eduardo | Vencido -11 dias |
| 102348 | 009/04 | Micro Ventures Jessica | Vencido -7 dias |
| 102907 | 010/06 | RUBI Amber | Vencido -4 dias |
| 57996 | 007/01 | e2y Linda | Vence 19/06 |
