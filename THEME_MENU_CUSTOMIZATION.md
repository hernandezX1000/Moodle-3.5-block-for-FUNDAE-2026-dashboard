# Personalización del Menú por Rol - Tema Lambda

## Caso de Uso
Ocultar menú navegación principal a usuarios con rol Supervisor FUNDAE.

## Archivo modificado
/home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php (línea 86)

## Backup
header.php.bak_fundae

## Implementación
Modificacion del custom_menu() condicional por rol:

- Si el usuario tiene rol shortname='supervisor' en cualquier contexto (sistema o curso): NO mostrar menu
- En cualquier otro caso: mostrar menu normalmente

## API Moodle utilizada
- get_user_roles(context, userid)
- context_system::instance()
- context_course::instance(courseid)
- enrol_get_users_courses(userid)

## Adaptación para otros roles
Cambiar shortname === 'supervisor' por el rol deseado.

## Rollback
cp header.php.bak_fundae header.php
php admin/cli/purge_caches.php

## Versión
1.0 - 2026-06-13 - Inicial
