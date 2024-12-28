import 'package:flutter/material.dart';
import 'add_expense_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                  '₺${_calculateTotal()}', // Dinamik toplam harcama
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            // Harcama listesi
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
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
                onAddExpense: (newExpense) {
                  setState(() {
                    _expenses.add(newExpense);
                  });
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
      final amount = double.tryParse(expense["amount"]?.replaceAll('₺', '') ?? "0") ?? 0;
      return sum + amount;
    });
  }
}
