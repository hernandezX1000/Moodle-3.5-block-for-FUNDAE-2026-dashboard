# Personalización del Menú por Rol - Tema Lambda

## Resumen
Documento que explica cómo personalizar el menú de navegación principal del tema Lambda según el rol del usuario en Moodle 3.5.

## Caso de Uso: Ocultar menú para Supervisor FUNDAE

El usuario Inspector FUNDAE solo debe ver el Dashboard FUNDAE, sin acceso a las opciones de navegación general del usuario interno (Mis Clases, Mis Cursos, Dashboard RRHH, etc.).

## Ubicación del Archivo

```
/home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php
```

El menú se renderiza en la **línea 86** mediante:
```php
<?php echo $OUTPUT->custom_menu(); ?>
```

## Solución Implementada

### Backup primero
```bash
cp /home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php \
   /home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php.bak_fundae
```

### Modificación del header.php

Reemplazar:
```php
<div class="nav-collapse collapse">
    <?php echo $OUTPUT->custom_menu(); ?>
```

Por:
```php
<div class="nav-collapse collapse">
    <?php 
    // FUNDAE: Ocultar menu navegacion para rol Supervisor
    $es_supervisor_fundae = false;
    if (isloggedin() && !isguestuser()) {
        global $USER;
        
        // Comprobar rol a nivel SISTEMA
        $supervisor_roles = get_user_roles(context_system::instance(), $USER->id);
        foreach ($supervisor_roles as $rol) {
            if ($rol->shortname === 'supervisor') {
                $es_supervisor_fundae = true;
                break;
            }
        }
        
        // Si no es supervisor a nivel sistema, comprobar a nivel CURSO
        if (!$es_supervisor_fundae) {
            $user_courses = enrol_get_users_courses($USER->id);
            foreach ($user_courses as $c) {
                $roles_curso = get_user_roles(context_course::instance($c->id), $USER->id);
                foreach ($roles_curso as $r) {
                    if ($r->shortname === 'supervisor') {
                        $es_supervisor_fundae = true;
                        break 2;
                    }
                }
            }
        }
    }
    
    // Solo mostrar el menú si NO es supervisor FUNDAE
    if (!$es_supervisor_fundae) {
        echo $OUTPUT->custom_menu();
    }
    ?>
```

## Cómo Adaptar para Otros Roles

Para cambiar el rol que se filtra, modificar las dos líneas con `shortname === 'supervisor'`:

```php
// Ejemplo: ocultar para rol "manager"
if ($rol->shortname === 'manager') {

// Ejemplo: ocultar para múltiples roles
$roles_ocultar = array('supervisor', 'visitor', 'auditor');
if (in_array($rol->shortname, $roles_ocultar)) {
```

## Ocultar Componentes Específicos del Menú

Si en vez de ocultar TODO el menú quieres ocultar solo algunos items, modifica el `custommenuitems` o usa CSS:

### Por configuración (afecta a todos):
```bash
mysql -u moodle35 -p... DB -e "
SELECT name, value FROM mdl_config WHERE name = 'custommenuitems';"
```

### Por CSS (selectivo por rol):
Añadir al customcss del tema:
```css
/* Ocultar items específicos para Supervisor */
body.userhasrole-supervisor .nav-collapse .nav > li[data-key="my-classes"],
body.userhasrole-supervisor .nav-collapse .nav > li[data-key="my-courses"] {
    display: none !important;
}
```

⚠️ NOTA: Moodle 3.5 con tema Lambda NO pone clases de rol en el body automáticamente. 
Esta es la razón por la que optamos por la modificación PHP en lugar de CSS.

## Verificación

1. Login como **Admin normal** → debe ver TODO el menú
2. Login como **Fundae Micro2026** → solo debe ver "Área personal" + Dashboard FUNDAE
3. Login como **Profesor/Tutor** → debe ver TODO el menú

## Rollback (si algo va mal)

```bash
cp /home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php.bak_fundae \
   /home/aulatuspeaking/.ftp-users/moodle/theme/lambda/layout/includes/header.php

php /home/aulatuspeaking/.ftp-users/moodle/admin/cli/purge_caches.php
```

## Información Técnica

### API utilizada
- `get_user_roles($context, $userid)`: Devuelve los roles de un usuario en un contexto
- `context_system::instance()`: Contexto a nivel de sistema
- `context_course::instance($courseid)`: Contexto a nivel de curso
- `enrol_get_users_courses($userid)`: Cursos donde está matriculado el usuario
- `$OUTPUT->custom_menu()`: Renderiza el menú custom de Moodle

### Estructura del menú en HTML
```html
<div class="nav-collapse collapse">
  <ul class="nav">
    <li><a href="...">Mis Clases</a></li>
    <li class="dropdown">Mis cursos</li>
    <li><a href="...">Dashboard RRHH</a></li>
    <li class="dropdown langmenu">Español</li>
  </ul>
</div>
```

## Cambios futuros recomendados

1. **Crear plugin de tema dedicado** en lugar de modificar archivos del tema
2. **Variables de configuración** en settings.php del tema para definir roles a ocultar
3. **Aplicar a otros layouts** si es necesario (frontpage.php, columns2.php, etc.)

## Historial

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-06-13 | 1.0 | Implementación inicial: oculta menú a rol "supervisor" |

## Autor
Equipo Desarrollo Aula TuSpeaking
Fecha: 2026-06-13
