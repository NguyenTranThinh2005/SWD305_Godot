UPDATE users SET password_hash = '$2b$12$PL3Wj9ePS4OHy2mXoatk8uw8SVyg3WJRZDlIEfuhrbCeLCp6L9lJe' WHERE email = 'admin@vneg.vn';
UPDATE users SET password_hash = '$2b$12$a5kpVx4SP5gLnQPiGLwvwOrEcB672ll8pbL0sUZaXP91qmtgsCzee' WHERE email = 'staff01@vneg.vn';
UPDATE users SET password_hash = '$2b$12$nb2qR26NLJGDI.zFHlRR1Oe8WG6ycilX30AcssEzvhQj1EOpP6cTG' WHERE email = 'superadmin@vneg.vn';
GO
SELECT id, email, role, is_active, LEN(password_hash) as hash_len FROM users WHERE role IN ('admin','staff') ORDER BY id;
GO
