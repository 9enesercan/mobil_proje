import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ortak_harcama_takip/auth/auth_f.dart';
import 'package:ortak_harcama_takip/Ui_pages/login_page.dart';
import 'package:ortak_harcama_takip/Ui_pages/group_expenses_page.dart'; // Add this line

import 'add_group_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  User? _currentUser;
  List<Map<String, dynamic>> _groups = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: _currentUser?.uid)
          .get();

      setState(() {
        _groups = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                  'members': List<String>.from(doc['members']),
                })
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gruplar yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _joinGroup(String groupJoinId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupJoinId', isEqualTo: groupJoinId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentReference groupRef = snapshot.docs.first.reference;
        await groupRef.update({
          'members': FieldValue.arrayUnion([_currentUser?.uid])
        });
        _loadGroups();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gruba başarıyla katıldınız')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grup bulunamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gruba katılırken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController groupJoinIdController = TextEditingController();

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
          Expanded(
            child: _groups.isEmpty
                ? Center(child: Text('Grup bulunamadı'))
                : ListView.builder(
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text(group["name"] ?? ""),
                          subtitle: Text(
                              'Üyeler: ${group["members"].length}\nGrup ID: ${group["id"]}\nGrup Kayıt ID: ${group["groupJoinId"]}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupExpensesPage(
                                  groupId: group["id"],
                                  groupName: group["name"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: groupJoinIdController,
                    decoration: InputDecoration(
                      labelText: 'Grup Kayıt ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _joinGroup(groupJoinIdController.text);
                  },
                  child: Text('Gruba Katıl'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupPage(
                onAddGroup: (newGroup) async {
                  await _addGroup(newGroup);
                },
                currentUser: _currentUser,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Grup Ekle',
      ),
    );
  }

  Future<void> _addGroup(Map<String, dynamic> newGroup) async {
    try {
      newGroup['createdBy'] = _currentUser?.uid ?? '';
      newGroup['members'] = [_currentUser?.uid ?? ''];
      newGroup['groupJoinId'] = (100000 +
              (999999 - 100000) *
                  (DateTime.now().millisecondsSinceEpoch % 1000000))
          .toString();
      _loadGroups();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grup eklenirken hata oluştu: $e')),
      );
    }
  }
}
