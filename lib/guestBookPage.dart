import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sando_diary/customDecoration.dart';
import 'package:sando_diary/services.dart';

class GuestBook extends StatefulWidget {
  @override
  _GuestBookState createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String userName = "Anonymous"; // 기본 사용자 이름

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Firestore에서 저장된 사용자 이름 불러오기
  }

  // Firestore에서 사용자 이름 불러오기
  Future<void> _loadUserName() async {
    String savedName = await loadUserName();
    setState(() {
      userName = savedName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이름 설정 부분
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '이름을 설정하세요',
                    hintText: userName, // 현재 저장된 사용자 이름을 표시
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  String newName = nameController.text.isNotEmpty
                      ? nameController.text
                      : "Anonymous";
                  setState(() {
                    userName = newName;
                  });
                  await saveUserName(newName); // Firestore에 새 이름 저장
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.black)
                        )
                    ),

                ),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        border: Border.all(width: 1, color: Colors.black),
                        boxShadow: AppShadows.customBaseBoxShadow),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('이름 설정'),
                    )),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: getMessages(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  final doc = docs[index];
                  final isMe =
                      doc['userId'] == FirebaseAuth.instance.currentUser?.uid;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['userName'] ?? 'Anonymous', // 저장된 사용자 이름 표시
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                doc['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: '메시지 입력'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(messageController.text,
                      userName); // Firestore에 저장된 이름으로 메시지 전송
                  messageController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Firestore에서 메시지 가져오기
  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Firestore에 메시지 추가
  Future<void> sendMessage(String message, String userName) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('messages').add({
      'text': message,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user?.uid,
      'userName': userName, // 사용자 이름 저장
    });
  }
}
