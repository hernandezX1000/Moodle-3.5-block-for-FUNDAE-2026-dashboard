# Modelo de Datos FUNDAE 2026

## Resumen
Documento que define el modelo de datos completo para la gestión FUNDAE 2026 en aula.tuspeaking.com.

## Arquitectura

### Tabla mdl_fundae (Datos FUNDAE consolidados)

Campos principales:
- courseid: ID del curso en Moodle
- c_fundae: Codigo completo (AFF-Grupo)
- aff: Codigo Accion Formativa (3 digitos)
- grupo: Codigo Grupo (2 digitos)
- denominacion_oficial: Nombre oficial registrado en FUNDAE
- empresa: Nombre comercial
- razon_social: Razon social completa
- cif: NIF/CIF empresa
- modalidad: Teleformacion / Mixta / Presencial
- idioma, nivel, horas, fechas
- bonificable, accion_bonificada, gestion_bonificacion

## Modelo de Relacion

### Situacion Actual (1:1)
Cada curso tiene 1 alumno unico.

### Modelo Futuro (1:N)
Un curso, multiples alumnos con sus C/Fundae:
- shortname = denominacion oficial
- Cada grupo = un C/Fundae individual
- Contenido compartido entre alumnos

## Caso de Uso Resuelto: E2Y Commerce

- Empresa: E2Y Commerce
- Razon Social: e2ycommerce S.L.
- CIF: B87748331
- Total: 20 cursos (15 bonificables + 5 NO bonificables)
- Q1: 001-01 a 008-01
- Q2: 058-01 a 065-01

### Correcciones aplicadas
1. Andrea Landa Q2: 059-01 a 058-01
2. Linda Mohnssen Q2: Anadido 065-01
3. Javier Polo Q2: NO bonificable
4. Grupos creados: 061-01 y 062-01

## Roadmap

### Corto plazo
- Resto empresas
- Auditar grupos
- Limpiar grupos basura

### Medio plazo
- Modelo 1:N
- Renombrar shortname = denominacion oficial
- Export CSV/Excel

## Autor
Equipo Desarrollo Aula TuSpeaking
Fecha: 2026-06-13
