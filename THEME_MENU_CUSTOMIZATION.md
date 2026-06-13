# Personalizacion Menu por Rol - Tema Lambda

## Caso de Uso
Ocultar menu navegacion principal a usuarios con rol Supervisor FUNDAE.

## Archivo modificado
/theme/lambda/layout/includes/header.php (linea 86)

## Backup
header.php.bak_fundae

## Implementacion
Reemplazar OUTPUT->custom_menu() por bloque condicional que verifica:
- Si usuario tiene rol shortname=supervisor en contexto sistema: NO mostrar menu
- Si usuario tiene rol supervisor en algun curso: NO mostrar menu
- Otros casos: mostrar menu normal

## API Moodle
- get_user_roles(context, userid)
- context_system::instance()
- context_course::instance(courseid)
- enrol_get_users_courses(userid)

## Rollback
cp header.php.bak_fundae header.php
php admin/cli/purge_caches.php

## Version
1.0 - 2026-06-13
