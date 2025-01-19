SELECT uuid();

CREATE TABLE tbl_audit(
  u_id_audit INT AUTO_INCREMENT PRIMARY KEY,
  u_action TEXT,
  u_user VARCHAR(100) NULL,
  u_date_register TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pdf_files (
    p_id INT AUTO_INCREMENT PRIMARY KEY,
    p_filename VARCHAR(255) NOT NULL,
    p_file_url VARCHAR(255) NOT NULL,
    p_status bool default true,
    p_create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    p_uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    p_delete_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from pdf_files where p_status = true;