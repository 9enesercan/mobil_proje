import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form alanları için controller
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Seçilen dosyayı saklamak için değişken
  File? _selectedFile;
  String? _downloadUrl; // Storage'a yükledikten sonra alacağımız dosya URL'si

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fatura Ekle")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tutar bilgisi
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Tutar"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Lütfen fatura tutarını giriniz.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Açıklama alanı
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Açıklama"),
                    ),
                    const SizedBox(height: 16),

                    // Dosya seçme butonu
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Dosya Seç (PDF/Resim)"),
                    ),
                    const SizedBox(height: 8),

                    // Seçilen dosya var mı?
                    if (_selectedFile != null)
                      Text(
                        "Seçilen dosya: ${_selectedFile!.path.split('/').last}",
                        style: const TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 24),

                    // Kaydet butonu
                    ElevatedButton(
                      onPressed: _saveInvoice,
                      child: const Text("Kaydet"),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  /// PDF veya resim dosyası seçmek için
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // PDF veya resim uzantılarını sınırlayabilirsiniz
      // type: FileType.custom,
      // allowedExtensions: ['pdf', 'png', 'jpg']
      type: FileType.any, // Her türlü dosya için
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          _selectedFile = File(path);
        });
      }
    }
  }

  /// Form validasyonundan sonra verileri Firestore'a kaydeden fonksiyon
  /// Eğer dosya seçildiyse önce Firebase Storage'a yükleyip URL'sini alır.
  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? fileUrl;
      // Eğer dosya seçilmişse Storage'a yükleyip URL'sini al
      if (_selectedFile != null) {
        fileUrl = await _uploadFileToStorage(_selectedFile!);
      }

      // Firestore koleksiyonuna kaydet
      await _addInvoiceData(
        amount: _amountController.text.trim(),
        description: _descriptionController.text.trim(),
        invoiceUrl: fileUrl,
      );

      // İşlem başarılı olunca kullanıcıya bilgi verebilir veya sayfayı kapatabilirsiniz
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fatura başarıyla kaydedildi")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Firebase Storage'a dosya yükleyen fonksiyon
  /// Başarılı olursa dosyanın downloadUrl'sini döndürür.
  Future<String> _uploadFileToStorage(File file) async {
    final fileName = file.path.split('/').last; // Örnek dosya adı elde etme
    final storageRef =
        FirebaseStorage.instance.ref().child('invoices/$fileName');
    final uploadTask = storageRef.putFile(file);

    // Yükleme işleminin tamamlanmasını bekliyoruz
    final snapshot = await uploadTask.whenComplete(() => null);

    // Yükleme tamamlanınca downloadUrl alın
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Firestore veritabanına fatura bilgilerini kaydeden fonksiyon
  Future<void> _addInvoiceData({
    required String amount,
    required String description,
    required String? invoiceUrl,
  }) async {
    final docRef =
        FirebaseFirestore.instance.collection("invoices").doc(); // key oluştur
    await docRef.set({
      "invoiceId": docRef.id,
      "amount": amount,
      "description": description,
      "invoiceUrl": invoiceUrl, // Dosya URL'si (null da olabilir)
      "createdAt": FieldValue.serverTimestamp(),
      // Eğer özel bir groupId, userId, veya expenseId ile ilişkilendirecekseniz ekleyin.
      // "groupId": "xxx",
      // "userId": "xxx",
    });
  }
}
