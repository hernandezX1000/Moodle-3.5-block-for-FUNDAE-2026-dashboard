-- Matricular al usuario FUNDAE 2026 (id 5676) con rol Supervisor/inspector FUNDAE (id 10)
-- en TODOS los cursos de TELEFORMACIÓN bonificables, EXCEPTO Alua Hotels (cursos 3209, 3258).
-- Idempotente (NOT EXISTS), reversible (backups). Sólo cursos con enrol=manual.

-- Paso 1: backups (fuera de transacción)
CREATE TABLE IF NOT EXISTS mdl_user_enrolments_bak_20260806 AS SELECT * FROM mdl_user_enrolments;
CREATE TABLE IF NOT EXISTS mdl_role_assignments_bak_20260806 AS SELECT * FROM mdl_role_assignments;

-- Paso 2: (comprobación previa) cuántos cursos entran
SELECT COUNT(DISTINCT e.courseid) AS cursos_objetivo
FROM mdl_enrol e
JOIN mdl_fundae f ON f.courseid=e.courseid
LEFT JOIN fundae_oficial_stg o ON o.c_fundae=f.c_fundae
WHERE e.enrol='manual' AND f.bonificable=1
  AND COALESCE(o.modalidad,f.modalidad) LIKE '%eleforma%'
  AND e.courseid NOT IN (3209,3258);

-- Paso 3: transacción
START TRANSACTION;

-- 3a) Matrícula (user_enrolments) vía enrol manual de cada curso
INSERT INTO mdl_user_enrolments (status, enrolid, userid, timestart, timeend, modifierid, timecreated, timemodified)
SELECT DISTINCT 0, e.id, 5676, 0, 0, 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()
FROM mdl_enrol e
JOIN mdl_fundae f ON f.courseid=e.courseid
LEFT JOIN fundae_oficial_stg o ON o.c_fundae=f.c_fundae
WHERE e.enrol='manual' AND f.bonificable=1
  AND COALESCE(o.modalidad,f.modalidad) LIKE '%eleforma%'
  AND e.courseid NOT IN (3209,3258)
  AND NOT EXISTS (SELECT 1 FROM mdl_user_enrolments ue WHERE ue.enrolid=e.id AND ue.userid=5676);

-- 3b) Rol supervisor (10) en el contexto del curso (sólo donde hay enrol manual)
INSERT INTO mdl_role_assignments (roleid, contextid, userid, timemodified, modifierid, component, itemid, sortorder)
SELECT DISTINCT 10, ctx.id, 5676, UNIX_TIMESTAMP(), 2, '', 0, 0
FROM mdl_context ctx
JOIN mdl_enrol e ON e.courseid=ctx.instanceid AND e.enrol='manual'
JOIN mdl_fundae f ON f.courseid=ctx.instanceid
LEFT JOIN fundae_oficial_stg o ON o.c_fundae=f.c_fundae
WHERE ctx.contextlevel=50 AND f.bonificable=1
  AND COALESCE(o.modalidad,f.modalidad) LIKE '%eleforma%'
  AND ctx.instanceid NOT IN (3209,3258)
  AND NOT EXISTS (SELECT 1 FROM mdl_role_assignments ra WHERE ra.contextid=ctx.id AND ra.userid=5676 AND ra.roleid=10);

-- Paso 4: verificar
SELECT
 (SELECT COUNT(*) FROM mdl_user_enrolments ue JOIN mdl_enrol e ON e.id=ue.enrolid WHERE ue.userid=5676 AND e.enrol='manual') AS matriculas_5676,
 (SELECT COUNT(*) FROM mdl_role_assignments WHERE userid=5676 AND roleid=10) AS roles_supervisor_5676;
-- Si cuadran (~98 y ~98):  COMMIT;   si no:  ROLLBACK;
