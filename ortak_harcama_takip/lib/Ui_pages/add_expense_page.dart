import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  final Function(Map<String, String>) onAddExpense;

  AddExpensePage({required this.onAddExpense});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harcama Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Harcama Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Tutar',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Yemek', 'Ulaşım', 'Eğlence', 'Market']
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Kategori Seç',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() {
    // Formdaki verileri al
    final String title = _titleController.text;
    final String amount = _amountController.text;
    final String? category = _selectedCategory;

    // Verilerin eksiksiz olduğunu kontrol et
    if (title.isEmpty || amount.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    // Yeni harcamayı oluştur
    final Map<String, String> newExpense = {
      'title': title,
      'amount': '₺$amount',
      'category': category,
    };

    // Harcamayı ana sayfaya gönder
    widget.onAddExpense(newExpense);

    // Geri dön
    Navigator.pop(context);
  }
}
