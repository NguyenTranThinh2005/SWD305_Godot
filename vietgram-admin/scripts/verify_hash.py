import bcrypt

h = b'$2b$12$YjiTymBUmJ0UNMrIdYLOyOeRfbglzn.Ne1q/QaG/3rgYl79/HZJNG'
print('Admin@123:', bcrypt.checkpw(b'Admin@123', h))
print('admin123:', bcrypt.checkpw(b'admin123', h))
