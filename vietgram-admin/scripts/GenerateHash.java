import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class GenerateHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);
        String[] passwords = { "Admin@123", "Staff@123", "admin123" };
        for (String pwd : passwords) {
            System.out.println("Password: " + pwd + " => Hash: " + encoder.encode(pwd));
        }
    }
}
