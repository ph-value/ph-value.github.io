import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore에 사용자 이름 저장 함수
Future<void> saveUserName(String name) async {
  final user = FirebaseAuth.instance.currentUser;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user?.uid);

  await userDoc.update({
    'userName': name,
  });
}

// Firestore에서 사용자 이름 가져오기
Future<String> loadUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user?.uid);

  final docSnapshot = await userDoc.get();

  // 만약 이름이 저장되지 않았다면 기본값 'Anonymous' 사용
  if (docSnapshot.exists && docSnapshot.data()!.containsKey('userName')) {
    return docSnapshot['userName'];
  } else {
    return 'Anonymous';
  }
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
    'userName': userName,  // 사용자 이름 저장
  });
}