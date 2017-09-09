INSERT INTO done_order (name, description, photo, response, site_href, valyay_comment, ian_comment) VALUES
('Web studio','Martin studio project', 'http://www.biodiversityexplorer.org/plants/proteaceae/images/030408CPJ23ed_658w.jpg', 'Nice!', 'localhost', 'I did my best', 'I did my best too'),
('Elis','Elis type project', 'http://clipartbarn.com/wp-content/uploads/2017/01/Cat-clip-art-free-clipart-images.png', 'Good job.', 'elistype.ru', 'I didnt know about it', 'That is my best work');

INSERT INTO message (email, name, telephone, type_of_order, company_name, comment) VALUES
('my@myspace.ru', 'Harry', '89003423111', 1, 'Tables Inc.', 'I want it now!'),
('KissM3@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('mailme@mail.ru', 'Fred', '+18779943', 3, 'Ps Inc.', 'Niiiiiiiiice'),
('KillM3@mail.ru', 'Jason', '+187733443', 2, 'some inc', 'Good job'),
('MoarM3@mail.ru', 'Mary', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('FuncM3@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('Kigg@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('OpasdM3@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('lololo@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh'),
('Kiasd3@mail.ru', 'George', '+187733443', 2, 'Pills Inc.', 'Yeeeeh');

INSERT INTO admin_user (login, password_hash) VALUES
('ian', '5f4dcc3b5aa765d61d8327deb882cf99'),
('valyay', '5f4dcc3b5aa765d61d8327deb882cf99');
