import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpensePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddExpense;
  final User? currentUser;
  final String groupId;

  AddExpensePage(
      {required this.onAddExpense,
      required this.currentUser,
      required this.groupId});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isAddingExpense = false;

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
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Harcama Açıklaması',
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
              onPressed: _isAddingExpense ? null : _addExpense,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() async {
    final String description = _descriptionController.text;
    final String amount = _amountController.text;
    final String? category = _selectedCategory;

    if (description.isEmpty || amount.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    try {
      final DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (!groupSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grup bulunamadı')),
        );
        return;
      }

      final List<String> members = List<String>.from(groupSnapshot['members']);

      final Map<String, dynamic> newExpense = {
        'description': description,
        'amount': '₺$amount',
        'category': category,
        'groupId': widget.groupId,
        'paidBy': widget.currentUser?.uid ?? '',
        'splitWith': members,
      };

      setState(() {
        _isAddingExpense = true;
      });

      final QuerySnapshot existingExpenses = await FirebaseFirestore.instance
          .collection('expenses')
          .where('description', isEqualTo: description)
          .where('amount', isEqualTo: '₺$amount')
          .where('category', isEqualTo: category)
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      if (existingExpenses.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bu harcama zaten mevcut')),
        );
        setState(() {
          _isAddingExpense = false;
        });
        return;
      }

      widget.onAddExpense(newExpense);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama eklenirken hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isAddingExpense = false;
      });
    }
  }
}
