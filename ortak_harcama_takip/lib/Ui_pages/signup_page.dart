import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_f.dart';
import 'login_page.dart';
import 'home_page.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final AuthService _auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
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
                // Sign-up işlemi
                User? user = await _auth.registerWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null) {
                  // Sign-up başarılı, HomePage'e yönlendirme
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  // Sign-up başarısız, hata mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kayıt başarısız. Tekrar deneyin.')),
                  );
                }
              },
              child: Text('Kayıt Ol'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Login sayfasına yönlendirme
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Zaten hesabınız var mı? Giriş Yapın'),
            ),
          ],
        ),
      ),
    );
  }
}
