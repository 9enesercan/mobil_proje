import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ortak_harcama_takip/Ui_pages/signup_page.dart';
import 'home_page.dart';
import '../auth/auth_f.dart'; // Import the AuthService

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final AuthService _auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ortak Harcama Takip',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Login işlemi
                User? user = await _auth.signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null) {
                  // Login başarılı, HomePage'e yönlendirme
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  // Login başarısız, hata mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Giriş başarısız. Tekrar deneyin.')),
                  );
                }
              },
              child: Text('Giriş Yap'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Şifreyi unuttum işlemi (henüz eklenmedi)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Şifre sıfırlama işlemi gelecek...')),
                );
              },
              child: Text('Şifremi Unuttum'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Sign-up sayfasına yönlendirme
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Hesabınız yok mu? Kayıt Olun'),
            ),
          ],
        ),
      ),
    );
  }
}
