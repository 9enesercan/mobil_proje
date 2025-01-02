import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.ortak-harcama-takip.com/expenses";

  // GET: Tüm harcamaları listeleme
  static Future<List<dynamic>> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        // Sunucudan dönen veriyi JSON olarak çöz
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Veriler alınırken hata oluştu. Durum Kodu: ${response.statusCode}, Mesaj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Veriler alınırken bir hata oluştu: $e");
    }
  }

  // POST: Yeni harcama ekleme
  static Future<void> createExpense(Map<String, dynamic> expense) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(expense),
      );
      if (response.statusCode != 201) {
        throw Exception(
            "Harcama eklenirken hata oluştu. Durum Kodu: ${response.statusCode}, Mesaj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Harcama eklenirken bir hata oluştu: $e");
    }
  }

  // PUT: Mevcut harcamayı güncelleme
  static Future<void> updateExpense(
      String id, Map<String, dynamic> updatedExpense) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedExpense),
      );
      if (response.statusCode != 200) {
        throw Exception(
            "Harcama güncellenirken hata oluştu. Durum Kodu: ${response.statusCode}, Mesaj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Harcama güncellenirken bir hata oluştu: $e");
    }
  }

  // DELETE: Harcama silme
  static Future<void> deleteExpense(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode != 200) {
        throw Exception(
            "Harcama silinirken hata oluştu. Durum Kodu: ${response.statusCode}, Mesaj: ${response.body}");
      }
    } catch (e) {
      throw Exception("Harcama silinirken bir hata oluştu: $e");
    }
  }
}
