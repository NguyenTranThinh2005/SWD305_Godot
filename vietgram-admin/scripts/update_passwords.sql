UPDATE users SET password_hash = '$2b$12$YjiTymBUmJ0UNMrIdYLOyOeRfbglzn.Ne1q/QaG/3rgYl79/HZJNG' WHERE email = 'admin@vneg.vn';
UPDATE users SET password_hash = '$2b$12$aMBQQyY0RNbmezhq4IbrcudAOn/cpBU8IuokHM2DBLSdlfY9rhkoa' WHERE email = 'staff01@vneg.vn';
SELECT id, email, role, is_active, LEN(password_hash) as hash_len, password_hash FROM users WHERE role IN ('admin','staff') ORDER BY id;
GO
