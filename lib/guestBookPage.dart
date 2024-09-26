import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sando_diary/StickyNote.dart';
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

  // Generated 'Interpolated Colors' palette in Flutter
// Full Extended 'Interpolated Colors' palette in Flutter
  final List<Color> interpolatedColors = [
    const Color(0xFF9581F5),
    const Color(0xFF9483F4),
    const Color(0xFF9486F2),
    const Color(0xFF9388F1),
    const Color(0xFF928BEF),
    const Color(0xFF928DEE),
    const Color(0xFF9190EC),
    const Color(0xFF9092EB),
    const Color(0xFF9094E9),
    const Color(0xFF8F97E8),
    const Color(0xFF8E99E7),
    const Color(0xFF8E9CE5),
    const Color(0xFF8D9EE4),
    const Color(0xFF8DA1E2),
    const Color(0xFF8CA3E1),
    const Color(0xFF8BA5DF),
    const Color(0xFF8BA8DE),
    const Color(0xFF8AAADC),
    const Color(0xFF89ADDB),
    const Color(0xFF89AFD9),
    const Color(0xFF88B2D8),
    const Color(0xFF87B4D7),
    const Color(0xFF87B6D5),
    const Color(0xFF86B9D4),
    const Color(0xFF85BBD2),
    const Color(0xFF85BED1),
    const Color(0xFF84C0CF),
    const Color(0xFF83C3CE),
    const Color(0xFF83C5CC),
    const Color(0xFF82C7CB),
    const Color(0xFF81CACA),
    const Color(0xFF81CCC8),
    const Color(0xFF80CFC7),
    const Color(0xFF7FD1C5),
    const Color(0xFF7FD4C4),
    const Color(0xFF7ED6C2),
    const Color(0xFF7DD8C1),
    const Color(0xFF7DDBBF),
    const Color(0xFF7CDDBE),
    const Color(0xFF7CE0BC),
    const Color(0xFF7BE2BB),
    const Color(0xFF7AE5BA),
    const Color(0xFF7AE7B8),
    const Color(0xFF79E9B7),
    const Color(0xFF78ECB5),
    const Color(0xFF78EEB4),
    const Color(0xFF77F1B2),
    const Color(0xFF76F3B1),
    const Color(0xFF76F6AF),
    const Color(0xFF75F8AE),
    const Color(0xFF75F8AE),
    const Color(0xFF77F8AD),
    const Color(0xFF79F8AB),
    const Color(0xFF7CF8AA),
    const Color(0xFF7EF8A9),
    const Color(0xFF80F8A8),
    const Color(0xFF82F8A6),
    const Color(0xFF84F8A5),
    const Color(0xFF87F8A4),
    const Color(0xFF89F8A3),
    const Color(0xFF8BF8A1),
    const Color(0xFF8DF8A0),
    const Color(0xFF8FF89F),
    const Color(0xFF92F89E),
    const Color(0xFF94F89C),
    const Color(0xFF96F89B),
    const Color(0xFF98F89A),
    const Color(0xFF9AF898),
    const Color(0xFF9DF897),
    const Color(0xFF9FF896),
    const Color(0xFFA1F895),
    const Color(0xFFA3F893),
    const Color(0xFFA5F892),
    const Color(0xFFA8F891),
    const Color(0xFFAAF890),
    const Color(0xFFACF98E),
    const Color(0xFFAEF98D),
    const Color(0xFFB1F98C),
    const Color(0xFFB3F98B),
    const Color(0xFFB5F989),
    const Color(0xFFB7F988),
    const Color(0xFFB9F987),
    const Color(0xFFBCF986),
    const Color(0xFFBEF984),
    const Color(0xFFC0F983),
    const Color(0xFFC2F982),
    const Color(0xFFC4F980),
    const Color(0xFFC7F97F),
    const Color(0xFFC9F97E),
    const Color(0xFFCCF97D),
    const Color(0xFFcdf97b),
    const Color(0xFFCFF97A),
    const Color(0xFFD2F979),
    const Color(0xFFD4F978),
    const Color(0xFFD6F976),
    const Color(0xFFD8F975),
    const Color(0xFFDAF974),
    const Color(0xFFDDF973),
    const Color(0xFFDFF971),
    const Color(0xFFE1F970),
    const Color(0xFFE1F970),
    const Color(0xFFE0F873),
    const Color(0xFFDEF876),
    const Color(0xFFDDF778),
    const Color(0xFFDBF67B),
    const Color(0xFFDAF57E),
    const Color(0xFFD8F581),
    const Color(0xFFD7F484),
    const Color(0xFFD5F386),
    const Color(0xFFD4F389),
    const Color(0xFFD2F28C),
    const Color(0xFFD1F18F),
    const Color(0xFFCFF092),
    const Color(0xFFCEF094),
    const Color(0xFFCCEF97),
    const Color(0xFFCBEE9A),
    const Color(0xFFC9EE9D),
    const Color(0xFFC8EDA0),
    const Color(0xFFC7ECA2),
    const Color(0xFFC5EBA5),
    const Color(0xFFC4EBA8),
    const Color(0xFFC2EAAB),
    const Color(0xFFC1E9AE),
    const Color(0xFFBFE9B0),
    const Color(0xFFBEE8B3),
    const Color(0xFFBCE7B6),
    const Color(0xFFBBE6B9),
    const Color(0xFFB9E6BB),
    const Color(0xFFB8E5BE),
    const Color(0xFFB6E4C1),
    const Color(0xFFB5E4C4),
    const Color(0xFFB3E3C7),
    const Color(0xFFB2E2C9),
    const Color(0xFFB1E1CC),
    const Color(0xFFAFE1CF),
    const Color(0xFFAEE0D2),
    const Color(0xFFACDFD5),
    const Color(0xFFABDFD7),
    const Color(0xFFA9DEDA),
    const Color(0xFFA8DDDD),
    const Color(0xFFA6DCE0),
    const Color(0xFFA5DCE3),
    const Color(0xFFA3DBE5),
    const Color(0xFFA2DAE8),
    const Color(0xFFA0DAEB),
    const Color(0xFF9FD8EE),
    const Color(0xFF9CD7F3),
    const Color(0xFF9AD7F6),
    const Color(0xFF99D6F9)
  ];

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
                return Center(child: CircularProgressIndicator());
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc['text'],
                                  style: TextStyle(fontSize: 16),
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
