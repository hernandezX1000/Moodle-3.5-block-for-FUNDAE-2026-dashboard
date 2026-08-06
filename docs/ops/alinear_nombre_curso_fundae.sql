-- Alinear el NOMBRE del curso (fullname) con la denominación oficial de FUNDAE (propias).
-- El alumno verá el mismo nombre que está informado en FUNDAE y en el dashboard.
-- shortname NO se toca (sigue siendo la referencia única de edición/alumno).
-- Reversible: backup mdl_course_bak_20260806. Externas no entran (su código no está en el oficial).

-- Paso 1: backup (fuera de transacción)
CREATE TABLE IF NOT EXISTS mdl_course_bak_20260806 AS SELECT id, fullname, shortname FROM mdl_course;

-- Paso 2: alinear (transaccional, reversible con ROLLBACK)
START TRANSACTION;
UPDATE mdl_course c
JOIN mdl_fundae f       ON f.courseid = c.id
JOIN fundae_oficial_stg o ON o.c_fundae = f.c_fundae
SET c.fullname = o.denominacion_oficial
WHERE f.bonificable = 1
  AND o.denominacion_oficial IS NOT NULL AND o.denominacion_oficial <> '';

-- Paso 3: verificar (nº de cursos ya alineados)
SELECT COUNT(DISTINCT c.id) AS cursos_alineados
FROM mdl_course c
JOIN mdl_fundae f ON f.courseid = c.id
JOIN fundae_oficial_stg o ON o.c_fundae = f.c_fundae
WHERE f.bonificable = 1 AND c.fullname = o.denominacion_oficial;
-- Si el número es razonable (~90+):  COMMIT;   si no:  ROLLBACK;
