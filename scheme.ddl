CREATE TABLE done_order (
			 -- Internal use
			 id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			 --
			 name VARCHAR(100) NOT NULL UNIQUE,
			 description TEXT NOT NULL,
			 photo VARCHAR(200) NOT NULL, -- filepath
			 response TEXT,								-- customer's response
			 site_href VARCHAR(100) NOT NULL,
			 valyay_comment TEXT,
			 ian_comment TEXT
);

CREATE TABLE message (
			 -- Internal use
			 id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			 --
			 name VARCHAR(100),
			 company_name VARCHAR(100),
			 email VARCHAR(50),
			 telephone VARCHAR(20),	
			 type_of_order INTEGER,
			 comment TEXT
);

CREATE TABLE admin_user (
			 login VARCHAR(20) PRIMARY KEY,
			 password_hash VARCHAR(32) NOT NULL -- MD5 hash
);
