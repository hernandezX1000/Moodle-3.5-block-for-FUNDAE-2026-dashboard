# RUNBOOK — Reconciliación de datos FUNDAE (dashboard del aula)

**Objetivo:** que `mdl_fundae` (lo que muestra el dashboard a FUNDAE) esté completo y correcto:
cada curso bonificable activo con su **código (Acción/Grupo)**, **razón social + CIF**, **modalidad**
y **enlace al curso**, sin re-descubrir el proceso cada vez.

> Estado 6-ago-2026: reconciliadas ~130 filas. Externas cerradas (Alua, GDES/IYM/GD Energy,
> Lactalis, Lin3s, Senator). Propias vía Micro Ventures. Falta: id 109 cerrado con 001-01407.

---

## 1. Modelo (de dónde sale cada dato)

- **Dashboard** = `block_fundae` lee `mdl_fundae` (bonificable=1) + `LEFT JOIN fundae_oficial_stg` por `c_fundae`.
- **PROPIA** (la gestiona Micro Ventures/tuSpeaking): su código está en **`fundae_oficial_stg`**
  (export del portal FUNDAE, 132 grupos, aff 1–99). El **ID de grupo enciende** por el join.
- **EXTERNA** (la gestiona la empresa en su cuenta FUNDAE): su código es **propio** y NO está en
  nuestro oficial → **el ID se queda "—" y es CORRECTO**. Fuente del código: **las facturas
  (InvoiceNinja)** — pie de factura: "Acción Formativa X, Grupo Y, Participante Z".
- **Fechas/denominación/modalidad**: `COALESCE(fundae_oficial_stg, mdl_fundae)` → corrige bugs
  (p.ej. modalidad "Aula Virtual"→"Teleformación").

### Empresas EXTERNA (Tipo=Externa; gestion_bonificacion='Empresa Externa')
Alua Hotels · GDES (3 sociedades) · Lactalis Puleva · Lin3s · Senator Hotels (Grupo Hoteles Playa).
El resto = **PROPIA** ('Micro Ventures SL'). Regla: **código propio → Externa; código en nuestro 132 → Propia**.

### GDES = 3 sociedades (una marca, varios CIF)
- GDES EFFICIENCY, S.L. — B02734945
- GD ENERGY SERVICES, S.A.U. — A46103594
- INGENIERÍA Y MARKETING, S.A. (IYM) — A46194528
Se asigna por ALUMNO (el nº de pedido en la factura indica la sociedad: 101→GD Energy, 103→IYM, 109→Efficiency).

---

## 2. Fuentes de la verdad por caso

| Caso | Fuente | Cómo |
|---|---|---|
| Código Propia (ID incluido) | `fundae_oficial_stg` (refrescar desde el XLS "grupos" del portal) | join por c_fundae |
| Código Externa | **InvoiceNinja** (facturas) o notificación FUNDAE / correo de la empresa | pie de factura: Acción/Grupo + participante |
| Razón social + CIF | InvoiceNinja / factura / correo de la empresa | por alumno (ojo multi-sociedad) |
| Enlace curso | `mdl_fundae.courseid` → `mdl_course` | verificar existe y con alumnos |

**⚠️ Trampas conocidas:**
- Los **grupos de Moodle están sucios** (arrastran códigos de ediciones viejas y grupos de prueba
  "Alison/Emma/Kate/Tim/g1test"). Solo fiarse de un **código único y limpio** o de la página de
  participantes (Grupos del alumno). Confirmar con factura/notificación.
- **Solo edición 2026.** Ojo con códigos antiguos (p.ej. curso arrastra 034-01 viejo).
- **ID "—" en externas = correcto** (no es su expediente).

---

## 3. Consultas reutilizables (copia-pega)

Conexión: `ssh coreadmin@46.225.232.27` → `docker exec -it moodle35-db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" aulatuspeaking35'`

```sql
-- (A) Huecos por empresa
SELECT empresa, COUNT(*) filas, SUM(razon_social IS NULL OR razon_social='') sin_razon,
 SUM(cif IS NULL OR cif='') sin_cif, SUM(c_fundae IS NULL OR c_fundae='') sin_cfundae,
 GROUP_CONCAT(DISTINCT gestion_bonificacion) gestiones
FROM mdl_fundae WHERE bonificable=1 GROUP BY empresa ORDER BY sin_cif DESC, empresa;

-- (B) Tipo (Externa/Propia) por empresa
SELECT empresa, gestion_bonificacion, COUNT(*) FROM mdl_fundae WHERE bonificable=1
GROUP BY empresa, gestion_bonificacion ORDER BY empresa;

-- (C) Filas sin código + grupos del curso (recuperar c_fundae)
SELECT f.id, f.empresa, f.courseid, c.shortname,
 (SELECT GROUP_CONCAT(DISTINCT g.name SEPARATOR ' | ') FROM mdl_groups g WHERE g.courseid=f.courseid) grupos
FROM mdl_fundae f JOIN mdl_course c ON c.id=f.courseid
WHERE f.bonificable=1 AND (f.c_fundae IS NULL OR f.c_fundae='') ORDER BY f.empresa, f.id;

-- (D) Alumnos matriculados en un curso (para saber quién es)
SELECT CONCAT(u.firstname,' ',u.lastname) alumno, u.email
FROM mdl_user_enrolments ue JOIN mdl_enrol e ON e.id=ue.enrolid JOIN mdl_user u ON u.id=ue.userid
WHERE e.courseid = <COURSEID> AND u.email NOT LIKE '%tuspeaking.com';
```

## 4. Aplicar cambios (siempre reversible)

```sql
-- Backup una vez por sesión:
CREATE TABLE mdl_fundae_bak_YYYYMMDD AS SELECT * FROM mdl_fundae;
-- Código externa: c_fundae + razón social + CIF por id:
UPDATE mdl_fundae SET c_fundae='<AAA-BBBB>', razon_social='<...>', cif='<...>' WHERE id=<ID>;
-- Tipo: gestion_bonificacion='Empresa Externa' (Externa) o 'Micro Ventures SL' (Propia).
```
Después, en bash: `docker exec -u www-data moodle35-app php /var/www/html/app/moodle/admin/cli/purge_caches.php`
Rollback: `UPDATE mdl_fundae f JOIN mdl_fundae_bak_YYYYMMDD b ON f.id=b.id SET f.c_fundae=b.c_fundae WHERE ...`

## 5. Refrescar el oficial (Propias) desde el portal

Exportar "grupos" del portal FUNDAE (XLS `rptListadoGruposformativos`) → generar
`docs/ops/refrescar_fundae_oficial_stg.sql` (script Python que mapea columnas a `fundae_oficial_stg`,
c_fundae = `AFF(3)-Grupo(2)`), backup + DELETE + INSERT + COMMIT.

---

## 6. Automatización — el AGENTE (ver `AGENTE-FUNDAE-reconciliacion.md`)

**Aprendizaje grande de hoy:** los códigos de externas viven en **InvoiceNinja** (todas las
facturas con Acción/Grupo + participante), NO en el texto del correo. Por eso el agente debe:
1. **Detector (cron, solo lectura):** cruzar `InvoiceNinja` (códigos+sociedad externas) +
   `fundae_oficial_stg` (Propias) contra `mdl_fundae` → informe de huecos + `propuesta.sql` con confianza.
2. **Aplicador (gated):** backup + aplica lo aprobado + purge. Nunca escribe en prod sin visto bueno.

Bases de datos **suficientes** (mdl_fundae + fundae_oficial_stg + cfo_invoiceninja). NO hace falta
un panel nuevo para empezar: el agente + este runbook cubren el trabajo repetitivo.
