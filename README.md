# Flutter Proje README

## PR Özeti

### [PR 1: UI Pages – Giriş ve Kayıt Ekranları Tasarlandı]
- Giriş ve kayıt işlemleri için modern ve kullanıcı dostu arayüz tasarlandı.
- Form validasyonları eklendi.
- Sayfalar arasında gezinmeyi sağlayan temel navigasyon yapısı kuruldu.

### [PR 2: Firebase Bağlantısı ve Auth İşlemleri]
- Firebase entegrasyonu gerçekleştirildi.
- Kullanıcı kimlik doğrulama işlemleri (kayıt, giriş, şifre sıfırlama) tamamlandı.
- Firebase'den hata mesajlarını kullanıcı dostu mesajlara dönüştüren yapı eklendi.

### [PR 3: Local Database ve RESTful API Çalışmaları]
- **Local Database**: Kullanıcı verilerini saklamak için SQLite veya Room Database entegrasyonu tamamlandı.
- **RESTful API**: Uygulama, uzaktan veri senkronizasyonu için RESTful API ile bağlandı.
  - CRUD işlemleri başarıyla gerçekleştirildi.
  - Veri yönetimi ve senkronizasyon için repository pattern uygulandı.

### [PR 4: Connectivity – Bağlantı Çalışmaları]
- WiFi, Mobil Veri ve Bluetooth bağlantı durumlarını kontrol eden altyapı eklendi.
- Kullanıcının internet bağlantısını gerçek zamanlı olarak izleyen bir yapı kuruldu.
- Uygulama, bağlantı kesildiğinde kullanıcıya bilgilendirme yapar ve işlem durumunu saklar.

---

## Kurulum Adımları

### 1. Gerekli Yazılımları Kurun

#### a. Flutter SDK
- Flutter’ı kurmak için [Flutter’ın resmi web sitesi](https://flutter.dev) adresinden uygun sürümü indirin ve kurun.
- Sisteminizde Flutter’ın doğru kurulduğunu kontrol etmek için terminalde şu komutu çalıştırın:
  ```bash
  flutter doctor
  ```
- Eksik gereksinimleri tamamlayın (örneğin, Android Studio, Xcode veya gerekli lisanslar).

#### b. Android Studio (Android için)
- Android uygulamalarını derlemek ve çalıştırmak için Android Studio'yu kurun.
- Android Studio içinde, **SDK Tools** sekmesinden Android SDK ve Virtual Device Manager'ı yükleyin.

#### c. Xcode (iOS için)
- MacOS kullanıyorsanız, iOS uygulamaları için Xcode’u yükleyin.
- Terminalde şu komutu çalıştırarak Xcode bileşenlerini kurun:
  ```bash
  sudo xcode-select --install
  ```

#### d. Visual Studio Code veya Android Studio
- Kodlama için bir IDE seçin. **Visual Studio Code** veya **Android Studio** önerilir.
- IDE’ye **Flutter** ve **Dart** eklentilerini yükleyin.

---

### 2. Gerekli Ortam Değişkenlerini Ayarlayın

#### a. Flutter SDK’nın Yolunu Ekleyin
- **PATH** değişkenine Flutter SDK'nın `bin` klasörünü ekleyin.
  - Örnek (MacOS ve Linux):
    ```bash
    export PATH="$PATH:/flutter/kurulu/yolu/bin"
    ```
  - Örnek (Windows): Sistem özelliklerinden **Environment Variables** altında **PATH** değişkenine Flutter SDK’nın yolunu ekleyin.

---

### 3. Bağımlılıkları Kurun
- Projenin bağımlılıklarını yüklemek için terminalde şu komutu çalıştırın:
  ```bash
  flutter pub get
  ```

---

### 4. Emülatör veya Gerçek Cihaz Ayarlayın

#### a. Android Emulator
- Android Studio’da bir emülatör oluşturun (**AVD Manager** ile).
- Emülatörü başlatın.

#### b. Gerçek Android Cihaz
- Geliştirici seçeneklerini etkinleştirin ve **USB hata ayıklama (USB Debugging)** özelliğini açın.
- Cihazı USB ile bilgisayara bağlayın.

#### c. iOS Simulator
- Terminalde şu komutu çalıştırarak bir iOS simülatörü başlatın:
  ```bash
  open -a Simulator
  ```

#### d. Gerçek iOS Cihaz
- Xcode üzerinden cihazınızı bağlayın ve ayarları yapın.

---

### 5. Uygulamayı Çalıştırın

- Projeyi çalıştırmak için terminalden şu komutu kullanın:
  ```bash
  flutter run
  ```
- Eğer birden fazla cihaz bağlıysa cihaz listesini görmek için:
  ```bash
  flutter devices
  ```
- Belirli bir cihazda çalıştırmak için:
  ```bash
  flutter run -d <cihaz_id>
  
