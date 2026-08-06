-- GDES / IYM / GD Energy — código de acción formativa + sociedad por alumno
-- Fuente: correo "DATOS FACTURAS LICENCIAS GDES" (Daniela, 23-feb y 24-mar 2026) + facturas emitidas.
-- OJO (edición): datos de 2026 (inicios 16/02 y 02-16/03). Revisar antes de ejecutar.
-- Reversible: backup en tabla mdl_fundae_bak_20260806. Externas -> ID en "—" (correcto).
-- Sociedades: IYM=INGENIERIA Y MARKETING S.A. (A46194528) | GD ENERGY SERVICES S.A.U. (A46103594) | GDES EFFICIENCY S.L. (B02734945)

-- ---- IYM (Ingeniería y Marketing, S.A. / A46194528) ----
UPDATE mdl_fundae SET c_fundae='699-6991', razon_social='INGENIERIA Y MARKETING, S.A.', cif='A46194528' WHERE id=133; -- Noelia Juan, Inglés B1-B2
UPDATE mdl_fundae SET c_fundae='697-6971', razon_social='INGENIERIA Y MARKETING, S.A.', cif='A46194528' WHERE id=136; -- Raquel Torres, Francés B1
UPDATE mdl_fundae SET c_fundae='696-6961', razon_social='INGENIERIA Y MARKETING, S.A.', cif='A46194528' WHERE id=137; -- Noelia Juan, Francés Int. Alto
UPDATE mdl_fundae SET c_fundae='720-7201', razon_social='INGENIERIA Y MARKETING, S.A.', cif='A46194528' WHERE id=141; -- Adoración Arnaldos, Inglés B2-C1
UPDATE mdl_fundae SET c_fundae='718-7181', razon_social='INGENIERIA Y MARKETING, S.A.', cif='A46194528' WHERE id=142; -- Eduardo Castelló, Francés B1

-- ---- GD ENERGY SERVICES, S.A.U. / A46103594 ----
UPDATE mdl_fundae SET c_fundae='700-7001', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=134; -- J.M. Villalonga, Inglés B2
UPDATE mdl_fundae SET c_fundae='701-7011', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=135; -- Roberto Diego, Inglés C1
UPDATE mdl_fundae SET c_fundae='698-6981', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=138; -- Roberto Diego, Francés Int. Alto
UPDATE mdl_fundae SET c_fundae='707-7071', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=139; -- Julián Mendoza, Italiano

-- ---- GDES EFFICIENCY, S.L. / B02734945 ----
UPDATE mdl_fundae SET c_fundae='707-7072', razon_social='GDES EFFICIENCY, S.L.', cif='B02734945' WHERE id=144; -- David Pecondon, Italiano

-- ---- GD ENERGY (confirmadas por facturas F2026/198 y /200: grupos de 2 alumnos) ----
UPDATE mdl_fundae SET c_fundae='717-7171', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=140; -- Inglés B1-B2: Daniela Arteaga + Lorena Hernández
UPDATE mdl_fundae SET c_fundae='719-7191', razon_social='GD ENERGY SERVICES, S.A.U.', cif='A46103594' WHERE id=143; -- Francés Int. Alto: Nicolás Bilanin + Luis Miguel Alonso
