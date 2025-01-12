SELECT uuid();

CREATE TABLE tbl_audit(
  u_id_audit INT AUTO_INCREMENT PRIMARY KEY,
  u_action TEXT,
  u_user VARCHAR(100) NULL,
  u_date_register TIMESTAMP DEFAULT now()
);

CREATE TABLE tbl_geography(
  g_id_geography INT AUTO_INCREMENT PRIMARY KEY,
  g_name VARCHAR(100) NOT NULL,
  g_code VARCHAR(20) NOT NULL,
  g_lvl SMALLINT NOT NULL,
  g_fk_geography INT NULL,
  g_status BOOL DEFAULT true,
  g_date_register TIMESTAMP DEFAULT now(),
  g_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_geography_fk1 FOREIGN KEY(g_fk_geography) REFERENCES tbl_geography(g_id_geography)
);

CREATE OR REPLACE VIEW vta_geography_chain AS
WITH RECURSIVE geography_chain AS (
  SELECT
    g_id_geography,
    g_name,
    g_fk_geography
  FROM
    tbl_geography
  WHERE
    g_fk_geography IS NULL
  UNION ALL
  SELECT
    tg.g_id_geography,
    CONCAT(gc.g_name, '-', tg.g_name) AS g_name,
    tg.g_fk_geography
  FROM
    tbl_geography tg
  INNER JOIN
    geography_chain gc
  ON
    tg.g_fk_geography = gc.g_id_geography
) SELECT
  gc.*
FROM
  geography_chain gc;

CREATE OR REPLACE VIEW vta_geography AS
SELECT tg.*, vgc.g_name AS g_belong FROM tbl_geography tg 
left JOIN vta_geography_chain vgc ON vgc.g_id_geography = tg.g_fk_geography;

INSERT INTO tbl_geography (g_code, g_name, g_lvl)
VALUES ('593','Ecuador',1);

CREATE TABLE tbl_role(
  r_id_role VARCHAR(36) NOT NULL PRIMARY KEY,
  r_name VARCHAR(100) NOT NULL,
  r_code VARCHAR(5) NOT NULL,
  r_editable BOOL DEFAULT true,
  r_status BOOL DEFAULT true,
  r_date_register TIMESTAMP DEFAULT now(),
  r_date_modify TIMESTAMP ON UPDATE now()
);

INSERT INTO tbl_role (r_id_role, r_name, r_code, r_editable) 
VALUES (uuid(), 'Administrador', 'ADM01', false),
(uuid(), 'Tecnico', 'TEC01', false),
(uuid(), 'Cliente', 'CL01', false);

CREATE TABLE tbl_page(
  p_id_page VARCHAR(36) NOT NULL PRIMARY KEY,
  p_code VARCHAR(20) NOT NULL,
  p_description VARCHAR(100) NOT NULL
);

INSERT INTO tbl_page (p_id_page, p_code, p_description)
VALUES (uuid(), 'profile', 'Ingreso al perfil de usuario'),
(uuid(), 'rolePrivileges', 'Acceso a Roles y a otorgar Privilegios en el sistema'),
(uuid(), 'geography', 'Acceso Geografia'),
(uuid(), 'users', 'Acceso a Usuarios');

CREATE TABLE tbl_privilege(
  i_fk_role VARCHAR(36) NOT NULL,
  i_fk_page VARCHAR(36) NOT NULL,
  CONSTRAINT tbl_privilege_fk1 FOREIGN KEY(i_fk_role) REFERENCES tbl_role(r_id_role),
  CONSTRAINT tbl_privilege_fk2 FOREIGN KEY(i_fk_page) REFERENCES tbl_page(p_id_page)
);

CREATE OR REPLACE VIEW vta_privilege AS
SELECT tr.r_name, tp.*, tp2.p_description, tp2.p_code FROM tbl_privilege tp 
JOIN tbl_page tp2 ON tp.i_fk_page = tp2.p_id_page
JOIN tbl_role tr ON tp.i_fk_role = tr.r_id_role;

INSERT INTO tbl_privilege 
VALUES ((SELECT r_id_role FROM tbl_role WHERE r_name='Administrador'), (SELECT p_id_page FROM tbl_page WHERE p_code='profile')),
((SELECT r_id_role FROM tbl_role WHERE r_name='Administrador'), (SELECT p_id_page FROM tbl_page WHERE p_code='rolePrivileges'));

CREATE TABLE tbl_user(
  e_id_user VARCHAR(36) PRIMARY KEY,
  e_type_dni VARCHAR(2) NOT NULL,
  e_dni VARCHAR(50) NOT NULL UNIQUE KEY,
  e_complete_name VARCHAR(250) NOT NULL,
  e_username VARCHAR(15) NOT NULL,
  e_gender VARCHAR(1) NOT NULL DEFAULT 'm',
  e_email VARCHAR(100) NULL,
  e_pass VARCHAR(100) NOT NULL,
  e_phone VARCHAR(50) NULL,
  e_address VARCHAR(500) NULL,
  e_fk_role VARCHAR(36) NOT NULL,
  e_fk_geography INT NOT NULL,
  e_status BOOL DEFAULT true,
  e_date_register TIMESTAMP DEFAULT now(),
  e_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_user_fk1 FOREIGN KEY(e_fk_role) REFERENCES tbl_role(r_id_role),
  CONSTRAINT tbl_user_fk2 FOREIGN KEY(e_fk_geography) REFERENCES tbl_geography(g_id_geography)
);

INSERT INTO tbl_user (e_id_user, e_type_dni, e_dni, e_complete_name, e_username, e_pass, e_fk_role, e_fk_geography)
VALUES (uuid(), 'P', '99999999', 'Administrador', 'admin', '+DOUT+du/SWoaJHlnE4N3g==', (SELECT r_id_role FROM tbl_role WHERE r_name='Administrador'), (SELECT g_id_geography FROM tbl_geography WHERE g_code='593'));

CREATE OR REPLACE VIEW vta_user AS
SELECT tu.*, tr.r_name, vg.g_name, vg.g_belong FROM tbl_user tu
JOIN tbl_role tr ON tu.e_fk_role = tr.r_id_role
JOIN vta_geography vg ON vg.g_id_geography = tu.e_fk_geography;

/*IspControl*/

INSERT INTO tbl_page (p_id_page, p_code, p_description)
VALUES 
(uuid(), 'client', 'Administración de Clientes'),
(uuid(), 'permanenceBenefits', 'Resumen acerca de los Beneficios de Permanencia'),
(uuid(), 'branch', 'Administracion de Sucursales'),
(uuid(), 'internetPlans', 'Administracion de Tipos y Planes de Internet'),
(uuid(), 'internetNodes', 'Acceso a Nodos y Antenas por Sucursal'),
(uuid(), 'supportType', 'Tipos de Trabajos para Soporte'),
(uuid(), 'logs', 'Acceso a Visualizar todos los registros de eventos en el Sistema'),
(uuid(), 'roadmap', 'Acceso a Ordenes de Trabajo'),
(uuid(), 'admRoadmap', 'Control de Hojas de Rutas'),
(uuid(), 'myRoadmap', 'Ver Hojas de Rutas Asignadas'),
(uuid(), 'admInvoice', 'Ver el historial de Facturacion y cobro mensual de Instalaciones'),
(uuid(), 'invoice', 'Cobro de Facturas pendientes'),
(uuid(), 'backDoc', 'Ingreso de Documentos bancarios por transferencias'),
(uuid(), 'accountBook', 'Visualizar Libro diario'),
(uuid(), 'bank', 'Administracion de Bancos'),
(uuid(), 'quiz', 'Administracion de Preguntas solicitadas para la Arcotel'),
(uuid(), 'reportQuiz', 'Reportes de las Encuestas solicitadas por la Arcotel');

CREATE TABLE tbl_company (
  c_social_reason VARCHAR(300) NOT NULL,
  c_commercial_name VARCHAR(500) NOT NULL,
  c_ruc VARCHAR(15) NOT NULL,
  c_email VARCHAR(30) NOT NULL,
  c_province VARCHAR(30) NOT NULL,
  c_canton VARCHAR(30) NOT NULL,
  c_city VARCHAR(30) NOT NULL,
  c_parish VARCHAR(30) NOT NULL COMMENT 'parroquia',
  c_address TEXT NOT NULL,
  c_phone VARCHAR(15) NOT NULL,
  c_website VARCHAR(50) NOT NULL,
  c_electronic_invoice_url TEXT DEFAULT NULL,
  c_electronic_invoice_pass VARCHAR(100) DEFAULT NULL,
  c_date_register TIMESTAMP DEFAULT now(),
  c_date_modify TIMESTAMP ON UPDATE now()
);

INSERT INTO tbl_company (c_social_reason, c_commercial_name, c_ruc, c_email, c_province, c_canton, c_city, c_parish, c_address, c_phone, c_website)
VALUES ("BENITEZ GUEVARA SILVIO RICARDO", 'INTERPLUS S.A.S.', '1391932196001', '---', 'MANABI', 'CHONE', 'CHONE', 'CHONE', 'AV. MARCOS ARAY DUEÑAS', '0999999999', '---');

CREATE TABLE tbl_client (
  l_id_client VARCHAR(36) NOT NULL PRIMARY KEY,
  l_dni VARCHAR(15) NOT NULL UNIQUE KEY,
  l_type_dni VARCHAR(2) NOT NULL DEFAULT 'c',
  l_social_reason VARCHAR(300) DEFAULT NULL,
  l_gender VARCHAR(2) DEFAULT 'm',
  l_birth_date TIMESTAMP DEFAULT now(),
  l_phone VARCHAR(50) DEFAULT NULL,
  l_address TEXT DEFAULT NULL,
  l_email VARCHAR(50) DEFAULT NULL,
  l_coorx VARCHAR(100) DEFAULT NULL,
  l_coory VARCHAR(100) DEFAULT NULL,
  l_pass VARCHAR(100) DEFAULT NULL,
  l_senior_citizens BOOL DEFAULT false COMMENT '3era edad',
  l_handicapped BOOL DEFAULT FALSE COMMENT 'discapacitado',
  l_fk_geography VARCHAR(36) NOT NULL,
  l_status BOOL DEFAULT true,
  l_date_register TIMESTAMP DEFAULT now(),
  l_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_client_fk1 FOREIGN KEY (l_fk_geography) REFERENCES tbl_geography (g_id_geography)
);

CREATE OR REPLACE VIEW vta_client as
SELECT tc.*, vg.g_belong FROM tbl_client tc 
LEFT JOIN vta_geography vg on vg.g_id_geography = tc.l_fk_geography;

CREATE TABLE tbl_contract (
  b_id_contract VARCHAR(36) NOT NULL PRIMARY KEY,
  b_name TEXT NOT NULL,
  b_description TEXT NOT NULL,
  b_type VARCHAR(2) NOT NULL COMMENT 'pr: prepago, ps: postpago',
  b_contract_duration INT(2) NOT NULL COMMENT 'duracion de contrato',
  b_minimum_permanence INT(2) NOT NULL, 
  b_installation_value DOUBLE(16,4) NOT NULL,
  b_status BOOL DEFAULT true,
  b_date_register TIMESTAMP DEFAULT now(),
  b_date_modify TIMESTAMP ON UPDATE now()
);

CREATE TABLE tbl_plan_internet (
  a_id_plan_internet VARCHAR(36) NOT NULL PRIMARY KEY,
  a_name VARCHAR(30) NOT NULL,
  a_sharing_level VARCHAR(5) NOT NULL COMMENT 'nivel de comparticion',
  a_red_access VARCHAR(5),
  a_status BOOL DEFAULT true,
  a_date_register TIMESTAMP DEFAULT now(),
  a_date_modify TIMESTAMP ON UPDATE now()
);

/*
CB= Velocidad Comercial de bajada
CS= Velocidad Comercial de Subida
MEB= Minima efectiva de Bajada
MES= Minima Efectiva de Subida
*/

CREATE TABLE tbl_plan (
  n_id_plan VARCHAR(36) NOT NULL PRIMARY KEY,
  n_name VARCHAR(30) NOT NULL,
  n_value DOUBLE(16,4) NOT NULL,
  n_velocity_CB VARCHAR(30) NOT NULL,
  n_velocity_CS VARCHAR(30) NOT NULL,
  n_velocity_MEB VARCHAR(30) NOT NULL,
  n_velocity_MES VARCHAR(30) NOT NULL,
  n_fk_plan_internet VARCHAR(36) NOT NULL,
  n_status BOOL DEFAULT true,
  n_date_register TIMESTAMP DEFAULT now(),
  n_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_plan_fk1 FOREIGN KEY (n_fk_plan_internet) REFERENCES tbl_plan_internet (a_id_plan_internet)
);

CREATE TABLE tbl_node(
  o_id_node VARCHAR(36) NOT NULL PRIMARY KEY,
  o_name VARCHAR(50) NOT NULL,
  o_coorx VARCHAR(100) NOT NULL,
  o_coory VARCHAR(100) NOT NULL,
  o_status BOOL DEFAULT true,
  o_date_register TIMESTAMP DEFAULT now(),
  o_date_modify TIMESTAMP ON UPDATE now()
);

CREATE TABLE tbl_antenna(
  an_id_antenna VARCHAR(36) NOT NULL PRIMARY KEY,
  an_name VARCHAR(50) NOT NULL,
  an_type TEXT NOT NULL,
  an_ssid TEXT NULL,
  an_ip VARCHAR(50) NULL,
  an_mac TEXT NULL,
  an_fk_node VARCHAR(36) NOT NULL,
  an_status BOOL DEFAULT true,
  an_date_register TIMESTAMP DEFAULT now(),
  an_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_antenna_fk1 FOREIGN KEY (an_fk_node) REFERENCES tbl_node (o_id_node) 
);

CREATE TABLE tbl_type_job(
  t_id_type_job VARCHAR(36) NOT NULL PRIMARY KEY,
  t_name VARCHAR(25) NOT NULL,
  t_code VARCHAR(5) NOT NULL,
  t_value DOUBLE(16,4) NOT NULL,
  t_priority INT(11) NOT NULL, 
  t_editable BOOL DEFAULT true,
  t_status BOOL DEFAULT true,
  t_date_register TIMESTAMP DEFAULT now(),
  t_date_modify TIMESTAMP ON UPDATE now()
);

INSERT INTO tbl_type_job (t_id_type_job, t_name, t_code, t_value, t_priority, t_editable) 
VALUES (uuid(), 'INSTALACION', 'INS01', 0, 1, false),
(uuid(), 'REVISIÓN TECNICA', 'RTE01',0, 2, true),
(uuid(), 'REVISION DE ANTENA', 'RAN01', 0, 2, true),
(uuid(), 'RETIRO DE EQUIPOS', 'REQ01', 0, 1, false),
(uuid(), 'CAMBIO DE DOMICILIO', 'CDO01', 0, 2, true),
(uuid(), 'MIGRACIÓN', 'MIG01', 0, 2, true);

CREATE TABLE tbl_installation(
  i_id_installation VARCHAR(36) NOT NULL PRIMARY KEY,
  i_submit_mediation BOOL NOT NULL DEFAULT true COMMENT 'someter_mediacion',
  i_automatic_renewal BOOL NOT NULL DEFAULT true COMMENT 'renovacion_automatica',
  i_perform_invoice BOOL NOT NULL DEFAULT true COMMENT 'realizar_factura',
  i_address TEXT NOT NULL,
  i_reference TEXT NOT NULL,
  i_date_petition DATETIME NOT NULL COMMENT 'fecha peticion',
  i_date_installation TIMESTAMP DEFAULT NULL,
  i_ip VARCHAR(20) DEFAULT NULL,
  i_phone VARCHAR(50) NOT NULL,
  i_status_code VARCHAR(2) DEFAULT 'i',
  i_coorx varchar(100) DEFAULT '0',
  i_coory varchar(100) DEFAULT '0',
  i_snm varchar(30) DEFAULT '',
  i_base_top varchar(100) DEFAULT '',
  i_fk_client VARCHAR(36) NOT NULL,
  i_fk_contract VARCHAR(36) NOT NULL,
  i_fk_plan VARCHAR(36) NOT NULL,
  i_fk_antenna VARCHAR(36) DEFAULT NULL,
  i_status BOOL DEFAULT true,
  i_date_register TIMESTAMP DEFAULT now(),
  i_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_installation_fk1 foreign key (i_fk_client) references tbl_client (l_id_client),
  CONSTRAINT tbl_installation_fk2 foreign key (i_fk_contract) references tbl_contract (b_id_contract),
  CONSTRAINT tbl_installation_fk3 foreign key (i_fk_plan) references tbl_plan (n_id_plan),
  CONSTRAINT tbl_installation_fk4 foreign key (i_fk_antenna) references tbl_antenna (an_id_antenna)
);

CREATE OR REPLACE VIEW vta_instalacion AS
SELECT ti.*,
  tc.b_name, tc.b_description, tc.b_type, tc.b_contract_duration, tc.b_minimum_permanence, tc.b_installation_value,
  tp.n_name, tp.n_value, tp.n_fk_plan_internet, tp.n_velocity_CB, tp.n_velocity_CS, tp.n_velocity_MEB, tp.n_velocity_MES,
  tpi.a_name, tpi.a_sharing_level, tpi.a_red_access,
  ta.an_name, ta.an_type, ta.an_ssid, ta.an_fk_node,
  vc.l_type_dni, vc.l_dni, vc.l_social_reason, vc.l_phone, vc.l_address, vc.l_email, vc.l_fk_geography, vc.g_belong,
  vc.l_senior_citizens, vc.l_handicapped, vc.l_gender
FROM tbl_installation ti
JOIN tbl_contract tc on tc.b_id_contract = ti.i_fk_contract
JOIN tbl_plan tp on tp.n_id_plan = ti.i_fk_plan 
JOIN tbl_plan_internet tpi on tpi.a_id_plan_internet = tp.n_fk_plan_internet
JOIN tbl_antenna ta on ta.an_id_antenna = ti.i_fk_antenna 
JOIN vta_client vc on vc.l_id_client = ti.i_fk_client;

CREATE TABLE tbl_suspension_temporary(
	s_id_temporary_suspension VARCHAR(36) NOT NULL PRIMARY KEY,
	s_date_start date NOT NULL,
	s_date_end date NOT NULL,
	s_reason text NOT NULL,
	s_user VARCHAR(15) NOT NULL,
	s_fk_installation VARCHAR(36) NOT NULL,
	s_status BOOL DEFAULT true,
  	s_date_register TIMESTAMP DEFAULT now(),
  	s_date_modify TIMESTAMP ON UPDATE now(),
	CONSTRAINT tbl_temporary_suspension_fk1 foreign key (s_fk_installation) references tbl_installation (i_id_installation)
);

CREATE TABLE tbl_suspension_definitive(
	v_id_suspension_definitive VARCHAR(36) NOT NULL PRIMARY KEY,
	v_date_suspension date NOT NULL,
	v_reason text NOT NULL,
	v_user VARCHAR(15) NOT NULL,
	v_fk_installation VARCHAR(36) NOT NULL,
	v_status BOOL DEFAULT true,
  	v_date_register TIMESTAMP DEFAULT now(),
  	v_date_modify TIMESTAMP ON UPDATE now(),
	CONSTRAINT tbl_suspension_definitive_fk1 foreign key (v_fk_installation) references tbl_installation (i_id_installation)
);

CREATE TABLE tbl_installation_plan_history(
	h_id_installation_plan_history VARCHAR(36) NOT NULL PRIMARY KEY,
	h_user VARCHAR(15) NOT NULL,
	h_fk_installation VARCHAR(36) NOT NULL,
	h_fk_plan VARCHAR(36) NOT NULL,
	h_status BOOL DEFAULT true,
	h_date_register TIMESTAMP DEFAULT now(),
	h_date_modify TIMESTAMP ON UPDATE now(),
	CONSTRAINT tbl_plan_history_fk1 FOREIGN KEY (h_fk_installation) REFERENCES tbl_installation (i_id_installation),
	CONSTRAINT tbl_plan_history_fk2 FOREIGN KEY (h_fk_plan) REFERENCES tbl_plan (n_id_plan)
);

CREATE OR REPLACE VIEW vta_installation_plan_history AS
SELECT vi.l_type_dni, vi.l_social_reason, vi.i_ip, tiph.*, tp.n_name, tp.n_value 
FROM tbl_plan tp
JOIN tbl_installation_plan_history tiph on tiph.h_fk_plan = tp.n_id_plan
JOIN vta_instalacion vi on vi.i_id_installation = tiph.h_fk_installation;

CREATE TABLE tbl_installation_change_client_history(
  y_id_installation_change_client_history VARCHAR(36) NOT NULL PRIMARY KEY,
  y_fk_client_set VARCHAR(36) NOT NULL,
  y_fk_client_get VARCHAR(36) NOT NULL,
  y_fk_installation VARCHAR(36) NOT NULL,
  y_user varchar(15) NOT NULL,
  y_date_register TIMESTAMP DEFAULT now(),
  CONSTRAINT tbl_installation_change_client_history_fk1 FOREIGN KEY (y_fk_client_set) REFERENCES tbl_client (l_id_client),
  CONSTRAINT tbl_installation_change_client_history_fk2 FOREIGN KEY (y_fk_client_get) REFERENCES tbl_client (l_id_client),
  CONSTRAINT tbl_installation_change_client_history_fk3 FOREIGN KEY (y_fk_installation) REFERENCES tbl_installation (i_id_installation)
);

CREATE OR REPLACE VIEW vta_installation_change_client_history AS
SELECT ticch.*, 
tc.l_dni as dni_set, tc.l_social_reason as social_reason_set,
tc2.l_dni as dni_get, tc2.l_social_reason as social_reason_get,
ti.i_address, ti.i_ip 
FROM tbl_installation_change_client_history ticch 
JOIN tbl_client tc on tc.l_id_client = ticch.y_fk_client_set 
JOIN tbl_client tc2 on tc2.l_id_client = ticch.y_fk_client_get 
JOIN tbl_installation ti ON ti.i_id_installation = ticch.y_fk_installation;


CREATE TABLE tbl_roadmap(
  d_id_roadmap VARCHAR(36) NOT NULL PRIMARY KEY,
  d_observation_request TEXT NOT NULL COMMENT 'observacion solicitud',
  d_observacion_solution TEXT DEFAULT NULL,
  d_user_creation VARCHAR(15)NOT NULL,
  d_user_assignment VARCHAR(15) DEFAULT NULL,
  d_date_petition DATETIME NOT NULL,
  d_date_done TIMESTAMP DEFAULT NULL,
  d_date_assignment TIMESTAMP DEFAULT NULL,
  d_time_entry TIME DEFAULT NULL COMMENT 'hora de entrada',
  d_time_departure TIME DEFAULT NULL COMMENT 'hora de salida',
  d_value DOUBLE(16,4) NOT NULL,
  d_status_code VARCHAR(2) DEFAULT 's',
  d_fk_installation VARCHAR(36) NOT NULL,
  d_fk_type_job VARCHAR(36) NOT NULL,
  d_fk_client VARCHAR(36) DEFAULT NULL,
  d_status BOOL DEFAULT true,
  d_date_register TIMESTAMP DEFAULT now(),
  d_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_roadmap_fk1 foreign key (d_fk_installation) references tbl_installation (i_id_installation),
  CONSTRAINT tbl_roadmap_fk2 foreign key (d_fk_type_job) references tbl_type_job (t_id_type_job),
  CONSTRAINT tbl_roadmap_fk3 FOREIGN KEY (d_fk_client) REFERENCES tbl_client (l_id_client)
);

CREATE OR REPLACE VIEW vta_ordenes_trabajo AS

SELECT tr.*, ttj.t_name, ttj.t_priority 
FROM tbl_roadmap tr 
JOIN tbl_type_job ttj 

    `tbl_ciudadano`.`razon_social` as `tecnico`,
    `tbl_ciudadano`.`telefonos` as `tecnico_telefonos`,
    `vta_instalacion`.`id_sucursal` as `id_sucursal`,
    `vta_instalacion`.`razon_social` as `razon_social`,
    `vta_instalacion`.`cedula` as `cedula`,
    `vta_instalacion`.`tipo_identificacion` as `tipo_identificacion`,
    `vta_instalacion`.`email` as `email`,
    `vta_instalacion`.`provincia` as `provincia`,
    `vta_instalacion`.`canton` as `canton`,
    `vta_instalacion`.`parroquia` as `parroquia`,
    `vta_instalacion`.`direccion_instalacion` as `direccion_instalacion`,
    `vta_instalacion`.`referencia` as `referencia`,
    `vta_instalacion`.`coordenadax` as `coordenadax`,
    `vta_instalacion`.`coordenaday` as `coordenaday`,
    `vta_instalacion`.`costo_instalacion` as `costo_instalacion`,
    `vta_instalacion`.`telefonos` as `telefonos`,
    `vta_instalacion`.`telefonos_instalacion` as `telefonos_instalacion`,
    `vta_instalacion`.`fecha_instalacion` as `fecha_instalacion`,
    `vta_instalacion`.`id_nodo` as `id_nodo`,
    `vta_instalacion`.`id_antena` as `id_antena`,
    `vta_instalacion`.`nivel_comparticion` as `nivel_comparticion`,
    `vta_instalacion`.`ip` as `ip`,
    `vta_instalacion`.`plan` as `plan`,
    `vta_instalacion`.`velocidad_CB` as `velocidad_CB`,
    `vta_instalacion`.`velocidad_CS` as `velocidad_CS`,
    `vta_instalacion`.`velocidad_MEB` as `velocidad_MEB`,
    `vta_instalacion`.`velocidad_MES` as `velocidad_MES`,
    `vta_instalacion`.`snm` as `snm`,
    `vta_instalacion`.`base_cima` as `base_cima`,
    `vta_instalacion`.`realizar_factura` as `realizar_factura`
from
    (((`tbl_tipo_trabajo`
join `tbl_orden_trabajo` on
    (`tbl_tipo_trabajo`.`id_tipo_trabajo` = `tbl_orden_trabajo`.`id_tipo_trabajo`))
left join `tbl_ciudadano` on
    (`tbl_orden_trabajo`.`id_ciudadano` = `tbl_ciudadano`.`id_ciudadano`))
join `vta_instalacion` on
    (`tbl_orden_trabajo`.`id_instalacion` = `vta_instalacion`.`id_instalacion`));


CREATE TABLE tbl_invoice(
  v_id_invoice VARCHAR(36) NOT NULL PRIMARY KEY,
  v_number INT(11) NOT NULL AUTO_INCREMENT,
  v_type varchar(2) DEFAULT NULL,
  v_date_payment DATETIME DEFAULT NULL COMMENT 'fecha de cobro',
  v_payment_method varchar(2) NOT NULL,
  v_document_number varchar(15) DEFAULT NULL,
  v_subtotal DOUBLE(16,4) NOT NULL,
  v_iva_cero DOUBLE(16,4) NOT NULL,
  v_iva_doce DOUBLE(16,4) NOT NULL,
  v_total DOUBLE(16,4) NOT NULL,
  v_user_payment VARCHAR(50) DEFAULT NULL,
  v_status_code VARCHAR(2) DEFAULT 'e',
  v_fk_installation VARCHAR(36) NOT NULL,
  v_status BOOL DEFAULT true,
  v_date_register TIMESTAMP DEFAULT now(),
  v_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_invoice_fk1 foreign key (v_fk_installation) references tbl_installation (i_id_installation)
);

CREATE TABLE tbl_invoice_detail(
  id_id_invoice_detail VARCHAR(36) NOT NULL PRIMARY KEY,
  id_cod_principal VARCHAR(15) NOT NULL,
  id_quantity INT(11) NOT NULL,
  id_description text NOT NULL,
  id_unit_price DOUBLE(16,4) NOT NULL DEFAULT 0,
  id_unit_price_iva DOUBLE(16,4) NOT NULL,
  id_discount DOUBLE(16,4) NOT NULL DEFAULT 0,
  id_reason_discount DOUBLE(16,4) NOT NULL DEFAULT 0,
  id_total DOUBLE(16,4) NOT NULL,
  id_fk_invoice VARCHAR(36) NOT NULL PRIMARY KEY,
  id_status BOOL DEFAULT true,
  id_date_register TIMESTAMP DEFAULT now(),
  id_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_invoice_detail_fk1 foreign key (id_fk_invoice) references tbl_invoice (v_id_invoice)
);

CREATE TABLE tbl_invoice_extra(
  x_id_invoice_extra VARCHAR(36) NOT NULL PRIMARY KEY,
  x_number INT(11) NOT NULL AUTO_INCREMENT,
  x_type varchar(2) DEFAULT NULL,
  x_date_payment DATETIME DEFAULT NULL COMMENT 'fecha de cobro',
  x_payment_method varchar(2) NOT NULL,
  x_document_number varchar(15) DEFAULT NULL,
  x_subtotal DOUBLE(16,4) NOT NULL,
  x_iva_cero DOUBLE(16,4) NOT NULL,
  x_iva_doce DOUBLE(16,4) NOT NULL,
  x_total DOUBLE(16,4) NOT NULL,
  x_user_payment VARCHAR(50) DEFAULT NULL,
  x_status_code VARCHAR(2) DEFAULT 'e',
  x_fk_client VARCHAR(36) NOT NULL,
  x_status BOOL DEFAULT true,
  x_date_register TIMESTAMP DEFAULT now(),
  x_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_invoice_fk1 foreign key (v_fk_client) references tbl_client (l_id_client)
);

CREATE TABLE tbl_invoice_extra_detail(
  ex_id_invoice_detail VARCHAR(36) NOT NULL PRIMARY KEY,
  ex_cod_principal VARCHAR(15) NOT NULL,
  ex_cod_aux VARCHAR(15) NOT NULL,
  ex_quantity INT(11) NOT NULL,
  ex_description text NOT NULL,
  ex_unit_price DOUBLE(16,4) NOT NULL DEFAULT 0,
  ex_unit_price_iva DOUBLE(16,4) NOT NULL,
  ex_discount DOUBLE(16,4) NOT NULL DEFAULT 0,
  ex_reason_discount DOUBLE(16,4) NOT NULL DEFAULT 0,
  ex_total DOUBLE(16,4) NOT NULL,
  ex_fk_invoice_extra VARCHAR(36) NOT NULL PRIMARY KEY,
  ex_status BOOL DEFAULT true,
  ex_date_register TIMESTAMP DEFAULT now(),
  ex_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_invoice_extra_detail_fk1 foreign key (ex_fk_invoice_extra) references tbl_invoice_extra (x_id_invoice_extra)
);

CREATE TABLE tbl_bank(
  b_id_bank VARCHAR(36) NOT NULL PRIMARY KEY,
  b_code VARCHAR(5) NOT NULL,
  b_name VARCHAR(250) NOT NULL,
  b_detail TEXT DEFAULT NULL,
  b_account_number VARCHAR(150) NOT NULL,
  b_status BOOL DEFAULT true,
  b_date_register TIMESTAMP DEFAULT now(),
  b_date_modify TIMESTAMP ON UPDATE now(),
);

CREATE TABLE tbl_document(
  m_id_document VARCHAR(36) NOT NULL PRIMARY KEY,
  m_document varchar(25) NOT NULL UNIQUE KEY,
  m_deposit_date date NOT NULL,
  m_ammount DOUBLE(16,4) NOT NULL DEFAULT 0 COMMENT 'monto',
  m_balance DOUBLE(16,4) NOT NULL DEFAULT 0 COMMENT 'saldo',
  m_payer_name text NOT NULL COMMENT 'nombre ordenante',
  m_user VARCHAR(15) NOT NULL,
  m_fk_bank VARCHAR(36) NOT NULL,
  m_status BOOL DEFAULT true,
  m_date_register TIMESTAMP DEFAULT now(),
  m_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_document_fk1 foreign key (m_fk_bank) references tbl_bank (b_id_bank)
);

CREATE TABLE tbl_journal(
  j_id_journal VARCHAR(36) NOT NULL PRIMARY KEY,
  j_detail text NOT NULL,
  j_income DOUBLE (16,4) DEFAULT 0 COMMNENT 'ingreso',
  j_expense DOUBLE (16,4) DEFAULT 0 COMMNENT 'egreso',
  j_user VARCHAR(15) NOT NULL,
  j_date_register TIMESTAMP DEFAULT now(),
);

CREATE TABLE tbl_journal_personal(
  jp_id_journal_personal VARCHAR(36) NOT NULL PRIMARY KEY,
  jp_detail text NOT NULL,
  jp_income DOUBLE (16,4) DEFAULT 0 COMMNENT 'ingreso',
  jp_expense DOUBLE (16,4) DEFAULT 0 COMMNENT 'egreso',
  jp_balance DOUBLE (16,4) DEFAULT 0 COMMNENT 'saldo',
  jp_fk_user VARCHAR(36) NOT NULL,
  jp_status BOOL DEFAULT true,
  jp_date_register TIMESTAMP DEFAULT now(),
  jp_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_journal_personal_fk1 FOREIGN KEY(jp_fk_user) REFERENCES tbl_user(e_id_user)
);

CREATE TABLE tbl_installation_plan_history(
  iph_id_installation_plan_history VARCHAR(36) NOT NULL PRIMARY KEY,
  iph_user VARCHAR(15) NOT NULL,
  iph_fk_installation VARCHAR(36) NOT NULL,
  iph_fk_plan VARCHAR(36) NOT NULL,
  iph_date_register TIMESTAMP DEFAULT now(),
  iph_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_installation_plan_history_fk1 FOREIGN KEY(iph_fk_installation) REFERENCES tbl_installation(i_id_installation),
  CONSTRAINT tbl_installation_plan_history_fk2 FOREIGN KEY(iph_fk_plan) REFERENCES tbl_plan(n_id_plan)
);

CREATE OR REPLACE VIEW vta_installation_plan_history AS
SELECT vi.l_dni, vi.l_social_reason, vi.ip, tiph.*, tp.n_name, tp.n_value
FROM tbl_plan tp
JOIN tbl_installation_plan_history tiph ON tiph.iph_fk_plan = tp.id_plan
JOIN vta_instalacion vi ON vi.i_id_installation=tiph.iph_fk_installation;

CREATE TABLE tbl_installation_change_social_reason(
  icsr_id_installation_change_social_reason VARCHAR(36) NOT NULL PRIMARY KEY,
  icsr_user VARCHAR(15) NOT NULL,
  icsr_fk_client_transfer VARCHAR(36) NOT NULL,
  icsr_fk_client_accept VARCHAR(36) NOT NULL,
  icsr_fk_installation VARCHAR(36) NOT NULL,
  icsr_date_register TIMESTAMP DEFAULT now(),
  icsr_date_modify TIMESTAMP ON UPDATE now(),
  CONSTRAINT tbl_installation_change_social_reason_fk1 FOREIGN KEY(icsr_fk_client_transfer) REFERENCES tbl_client(l_id_client),
  CONSTRAINT tbl_installation_change_social_reason_fk2 FOREIGN KEY(icsr_fk_client_accept) REFERENCES tbl_client(l_id_client)
  CONSTRAINT tbl_installation_change_social_reason_fk3 FOREIGN KEY(icsr_fk_installation) REFERENCES tbl_installation(i_id_installation)
);

CREATE OR REPLACE VIEW vta_installation_change_social_reason AS
SELECT ticsr.*, tc.l_dni AS dni_client_transfer, tc.l_social_reason AS social_reason_client_transfer,
	tc.l_dni AS dni_client_accept, tc.l_social_reason AS social_reason_client_accept,
	vi.i_address, vi.i_ip
FROM tbl_installation_change_social_reason ticsr
JOIN tbl_client tc ON tc.l_id_client = ticsr.icsr_fk_client_transfer
JOIN vta_instalacion vi ON vi.i_id_installation=ticsr.icsr_fk_installation
LEFT JOIN tbl_client tc ON tc.l_id_client = ticsr.icsr_fk_client_accept;


/* f k q w x
 * id ex*/

/* ARCOTEL */
create table tbl_pregunta(
	id_pregunta int(11) not null auto_increment,
	pregunta text not null,
	orden int(11) not null,
	fecha datetime default CURRENT_TIMESTAMP,
	estado varchar(2) not null default 'a',
	PRIMARY KEY (id_pregunta)
); 

create table tbl_encuesta(
	id_encuesta int(11) not null auto_increment,
	fecha datetime default CURRENT_TIMESTAMP,
	id_ciudadano int(11) not null,	
	CONSTRAINT `tbl_encuesta_fk1` foreign key (`id_ciudadano`) references `tbl_ciudadano` (`id_ciudadano`),
	PRIMARY KEY (id_encuesta)
);

create table tbl_encuesta_detalle(
	id_encuesta_detalle int(11) not null auto_increment,
	calificacion int(11) not null,
	comentario text,
	id_pregunta int(11) not null,
	id_encuesta int(11) not null,
	CONSTRAINT `tbl_encuesta_detalle_fk1` foreign key (`id_pregunta`) references `tbl_pregunta` (`id_pregunta`),
	CONSTRAINT `tbl_encuesta_detalle_fk2` foreign key (`id_encuesta`) references `tbl_encuesta` (`id_encuesta`),
	PRIMARY KEY (id_encuesta_detalle)
);

create or replace view vta_encuesta as 
select te.*, tc.cedula, tc.razon_social from tbl_encuesta te
join tbl_ciudadano tc on te.id_ciudadano = tc.id_ciudadano;

create or replace view vta_encuesta_detalle as 
select ted.*, tp.pregunta, tp.orden from tbl_encuesta_detalle ted 
join tbl_pregunta tp on ted.id_pregunta = tp.id_pregunta;

create or replace view vta_encuesta_arcotel as
SELECT ve.*, 
(SELECT (SUM(calificacion)/2) from vta_encuesta_detalle ved where id_pregunta in (1,2) and  id_encuesta = ve.id_encuesta) as amabilidad,
(SELECT (SUM(calificacion)/2) from vta_encuesta_detalle ved where id_pregunta in (3,4) and  id_encuesta = ve.id_encuesta) as disponibilidad,
(SELECT calificacion from vta_encuesta_detalle ved where id_pregunta = 5 and  id_encuesta = ve.id_encuesta) as rapidez
FROM vta_encuesta ve;


SELECT COUNT(id_ciudadano) as total FROM vta_ciudadano 
WHERE id_rol!='2' and (cedula LIKE '%101%' or razon_social LIKE '%101%' or email LIKE '%101%' or telefonos LIKE '%101%')