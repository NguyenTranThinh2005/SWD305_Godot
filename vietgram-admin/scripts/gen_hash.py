import bcrypt

def generate_hash(password):
    # BCrypt với cost factor 12, dùng $2b$ prefix
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

passwords = {
    'admin@vneg.vn': 'Admin@123',
    'staff01@vneg.vn': 'Staff@123',
}

print("=== Generated BCrypt Hashes ===")
update_sqls = []
for email, pwd in passwords.items():
    h = generate_hash(pwd)
    print(f"Email: {email}")
    print(f"Password: {pwd}")
    print(f"Hash: {h}")
    print()
    update_sqls.append(f"UPDATE users SET password_hash = '{h}' WHERE email = '{email}';")

print("=== SQL UPDATE Statements ===")
for sql in update_sqls:
    print(sql)
