using System.Security.Cryptography;

namespace SWD305.Security
{
    public static class PasswordHashing
    {
        private const int SaltSizeBytes = 16;
        private const int KeySizeBytes = 32;
        private const int Iterations = 100_000;

        // Format: pbkdf2$<iterations>$<base64(salt)>$<base64(key)>
        public static string HashPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                throw new ArgumentException("Password is required.", nameof(password));

            byte[] salt = RandomNumberGenerator.GetBytes(SaltSizeBytes);
            byte[] key = Rfc2898DeriveBytes.Pbkdf2(
                password,
                salt,
                Iterations,
                HashAlgorithmName.SHA256,
                KeySizeBytes);

            return $"pbkdf2${Iterations}${Convert.ToBase64String(salt)}${Convert.ToBase64String(key)}";
        }

        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(storedHash))
                return false;

            var parts = storedHash.Split('$');
            if (parts.Length != 4 || parts[0] != "pbkdf2")
                return false;

            if (!int.TryParse(parts[1], out var iterations))
                return false;

            byte[] salt;
            byte[] expectedKey;
            try
            {
                salt = Convert.FromBase64String(parts[2]);
                expectedKey = Convert.FromBase64String(parts[3]);
            }
            catch
            {
                return false;
            }

            byte[] actualKey = Rfc2898DeriveBytes.Pbkdf2(
                password,
                salt,
                iterations,
                HashAlgorithmName.SHA256,
                expectedKey.Length);

            return CryptographicOperations.FixedTimeEquals(actualKey, expectedKey);
        }
    }
}

