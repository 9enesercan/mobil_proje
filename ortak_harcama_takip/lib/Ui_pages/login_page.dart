import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ortak_harcama_takip/Ui_pages/signup_page.dart';
import 'home_page.dart';
import '../auth/auth_f.dart'; // Import the AuthService
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final AuthService _auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ortak Harcama Takip',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Kullanıcı Adı TextField
              CustomTextField(
                labelText: 'Kullanıcı Adı',
                controller: emailController,
              ),
              SizedBox(height: 16),
              // Şifre TextField
              CustomTextField(
                labelText: 'Şifre',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 24),
              // Giriş Yap Butonu
              CustomButton(
                text: 'Giriş Yap',
                onPressed: () async {
                  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
                    );
                    return;
                  }

                  try {
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
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: ${e.toString()}')),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              // Şifremi Unuttum Butonu
              TextButton(
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Şifre sıfırlama için lütfen e-posta adresinizi girin.')),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Şifremi Unuttum'),
              ),
              SizedBox(height: 16),
              // Kayıt Ol Butonu
              TextButton(
                onPressed: () {
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
      ),
    );
  }
}
