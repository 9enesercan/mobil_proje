import 'package:flutter/material.dart';
import 'package:ortak_harcama_takip/db/database_helper.dart';
import 'package:ortak_harcama_takip/Ui_pages/add_expense_page.dart';
import 'package:ortak_harcama_takip/auth/auth_f.dart';
import 'package:ortak_harcama_takip/Ui_pages/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      // SQLite'tan verileri çek
      final localData = await _dbHelper.getExpenses();

      // Listeyi temizle ve sadece benzersiz kayıtları ekle
      setState(() {
        _expenses = localData.toSet().toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ortak Harcamalar'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toplam harcama özet bölümü
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam Harcama:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₺${_calculateTotal()}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? Center(child: Text('Harcama bulunamadı'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.category,
                            color: _getCategoryColor(expense["category"] ?? ""),
                          ),
                          title: Text(expense["title"] ?? ""),
                          subtitle: Text('Kategori: ${expense["category"]}'),
                          trailing: Text(
                            '₺${expense["amount"]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onLongPress: () async {
                            await _deleteExpense(expense["id"]);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage(
                onAddExpense: (newExpense) async {
                  await _addExpense(newExpense);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Harcama Ekle',
      ),
    );
  }

  Future<void> _addExpense(Map<String, String> newExpense) async {
    try {
      // Sadece SQLite'a ekle
      await _dbHelper.insertExpense(newExpense);

      // Listeyi güncelle
      _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama eklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      // SQLite'tan sil
      await _dbHelper.deleteExpense(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama başarıyla silindi')),
      );

      // Listeyi güncelle
      _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama silinirken hata oluştu: $e')),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Yemek":
        return Colors.orange;
      case "Ulaşım":
        return Colors.blue;
      case "Eğlence":
        return Colors.purple;
      case "Market":
        return Colors.green;
      case "Diğer":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  double _calculateTotal() {
    return _expenses.fold(0, (sum, expense) {
      final amount = double.tryParse(expense["amount"]?.toString() ?? "0") ?? 0;
      return sum + amount;
    });
  }
}
