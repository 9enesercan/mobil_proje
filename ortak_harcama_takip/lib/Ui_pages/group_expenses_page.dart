import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ortak_harcama_takip/Ui_pages/add_expense_page.dart';

class GroupExpensesPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupExpensesPage({required this.groupId, required this.groupName});

  @override
  _GroupExpensesPageState createState() => _GroupExpensesPageState();
}

class _GroupExpensesPageState extends State<GroupExpensesPage> {
  User? _currentUser;
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      setState(() {
        _expenses = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcamalar yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
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
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.category,
                            color: _getCategoryColor(expense["category"] ?? ""),
                          ),
                          title: Text(expense["description"] ?? ""),
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
                currentUser: _currentUser,
                groupId: widget.groupId,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Harcama Ekle',
      ),
    );
  }

  Future<void> _addExpense(Map<String, dynamic> newExpense) async {
    try {
      newExpense['groupId'] = widget.groupId;
      newExpense['paidBy'] = _currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('expenses').add(newExpense);
      _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama eklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcama başarıyla silindi')),
      );
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
