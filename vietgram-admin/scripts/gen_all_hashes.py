import bcrypt

accounts = [
    ('admin@vneg.vn', 'Admin@123'),
    ('staff01@vneg.vn', 'Staff@123'),
    ('superadmin@vneg.vn', 'Superadmin@123'),
]

print("=== Generated BCrypt Hashes (cost=12) ===\n")
sql_lines = []
for email, pwd in accounts:
    salt = bcrypt.gensalt(rounds=12)
    h = bcrypt.hashpw(pwd.encode(), salt).decode()
    print(f"Email   : {email}")
    print(f"Password: {pwd}")
    print(f"Hash    : {h}")
    print()
    sql_lines.append(f"UPDATE users SET password_hash = '{h}' WHERE email = '{email}';")

with open('scripts/update_all_passwords.sql', 'w') as f:
    for line in sql_lines:
        f.write(line + '\n')
    f.write("GO\n")
    f.write("SELECT id, email, role, is_active, LEN(password_hash) as hash_len FROM users WHERE role IN ('admin','staff') ORDER BY id;\n")
    f.write("GO\n")

print("=== SQL saved to scripts/update_all_passwords.sql ===")
