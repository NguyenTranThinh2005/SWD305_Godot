import bcrypt

# Test superadmin hash
h_super = b'$2a$12$R9h/lZ9y0U.6MvP6GsD73uQ.hF8sUv8.M9QyX.vX8.vX8.vX8.vX8'
common_passwords = ['admin123', 'Admin@123', 'superadmin', 'Superadmin@123', '123456', 'password', 'vneg@123']

print("=== Test superadmin hash ===")
found = False
for pwd in common_passwords:
    try:
        result = bcrypt.checkpw(pwd.encode(), h_super)
        if result:
            print(f"FOUND! Password is: {pwd}")
            found = True
            break
        else:
            print(f"Not: {pwd}")
    except Exception as e:
        print(f"Error with {pwd}: {e}")
        break

if not found:
    print("Password not found in common list - hash may be invalid/fake")
