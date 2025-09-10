import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sando_diary/widget/sticky_note.dart';
import 'package:sando_diary/theme/custom_decoration.dart';
import 'package:sando_diary/theme/interpolated_colors.dart';
import 'package:sando_diary/firestore_service.dart';

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

  // 색상을 사용자 ID에 따라 고유하게 지정
  Color getColorForUserId(String userId) {
    int hash = userId.hashCode;
    return interpolatedColors[hash % interpolatedColors.length];
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
                    labelText: '✨먼저! 이름을 설정하세요✨',
                    hintText: userName, // 현재 저장된 사용자 이름을 표시
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String newName = nameController.text.isNotEmpty
                      ? nameController.text
                      : "Anonymous";
                  setState(() {
                    userName = newName;
                  });
                  await saveUserName(newName); // Firestore에 새 이름 저장
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Remove default padding
                  shape: const StadiumBorder(), // Keep the round corner style
                ),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        border: Border.all(width: 1, color: Colors.black),
                        boxShadow: AppShadows.customBaseBoxShadow),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '이름 설정',
                        style: TextStyle(color: Colors.black),
                      ),
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
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              String? lastUserId;
              Color? lastColor;

              return ListView.builder(
                reverse: true,
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  final doc = docs[index];
                  final isMe =
                      doc['userId'] == FirebaseAuth.instance.currentUser?.uid;
                  final currentUserId = doc['userId'] ?? 'unknown';
                  Color messageColor = getColorForUserId(currentUserId);

                  // 만약 이전 메시지와 다른 사용자라면 색상이 겹치지 않도록 조정
                  if (lastUserId != null &&
                      lastUserId != currentUserId &&
                      messageColor == lastColor) {
                    // 인덱스를 조정하여 색상 변경
                    int colorIndex =
                        (interpolatedColors.indexOf(messageColor) + 1) %
                            interpolatedColors.length;
                    messageColor = interpolatedColors[colorIndex];
                  }

                  lastUserId = currentUserId;
                  lastColor = messageColor;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        StickyNote(
                          isMe: isMe,
                          color: messageColor,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['userName'] ?? 'Anonymous',
                                  // 저장된 사용자 이름 표시
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc['text'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
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
                  decoration: InputDecoration(
                    labelText: userName == "Anonymous"
                        ? '익명으로 메시지 입력 (이름 설정은 최상단에...)'
                        : '$userName의 메시지 입력',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
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
