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
