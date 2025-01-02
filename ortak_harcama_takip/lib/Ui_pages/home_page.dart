import 'package:flutter/material.dart';
import 'add_expense_page.dart';
import '../auth/auth_f.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  // Dinamik harcama listesi
  final List<Map<String, String>> _expenses = [
    {"title": "Harcama 1", "category": "Yemek", "amount": "₺50"},
    {"title": "Harcama 2", "category": "Ulaşım", "amount": "₺30"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ortak Harcamalar'),
        centerTitle: true,
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
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Column(
        children: [
          // Toplam harcama özet bölümü
          _buildTotalExpenseSummary(),
          Expanded(
            // Harcama listesi
            child: _expenses.isEmpty
                ? Center(
              child: Text(
                'Henüz harcama eklenmedi.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return _buildExpenseCard(expense, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpensePage(context),
        child: Icon(Icons.add),
        tooltip: 'Harcama Ekle',
      ),
    );
  }

  // Toplam harcama özet bölümü
  Widget _buildTotalExpenseSummary() {
    return Container(
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
    );
  }

  // Harcama kartı oluşturma
  Widget _buildExpenseCard(Map<String, String> expense, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(
          Icons.category,
          color: _getCategoryColor(expense["category"] ?? ""),
        ),
        title: Text(expense["title"] ?? ""),
        subtitle: Text('Kategori: ${expense["category"]}'),
        trailing: Text(
          expense["amount"] ?? "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onLongPress: () => _deleteExpense(index),
      ),
    );
  }

  // Harcama ekleme sayfasına yönlendirme
  void _navigateToAddExpensePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpensePage(
          onAddExpense: (newExpense) {
            setState(() {
              _expenses.add(newExpense);
            });
          },
        ),
      ),
    );
  }

  // Harcama silme işlemi
  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Harcama Sil'),
          content: Text('Bu harcamayı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _expenses.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  // Harcama kategorisine göre renk seçimi
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

  // Toplam harcamayı hesaplama
  double _calculateTotal() {
    return _expenses.fold(0, (sum, expense) {
      final amount =
          double.tryParse(expense["amount"]?.replaceAll('₺', '') ?? "0") ?? 0;
      return sum + amount;
    });
  }
}
