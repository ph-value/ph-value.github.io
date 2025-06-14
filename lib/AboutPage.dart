import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Me'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/profile.WEBP'), // 프로필 이미지 경로
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sando, ', // 이름 입력
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mobile Developer,', // 직업 또는 타이틀
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "안녕하세요! 모바일 개발자 산도입니다.\n"),
                  TextSpan(
                    text: "Android", // Android 볼드 처리 및 아이콘 추가
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  WidgetSpan(
                    child: Icon(Icons.android, size: 20, color: Colors.green),
                  ),
                  TextSpan(
                    text: " 경험을 바탕으로, ",
                  ),
                  TextSpan(
                    text: "Flutter", // Flutter 볼드 처리 및 아이콘 추가
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  WidgetSpan(
                    child:
                        Icon(Icons.flutter_dash, size: 20, color: Colors.blue),
                  ),
                  TextSpan(
                    text:
                        "로 두 개의 앱을 기획하고 출시해봤어요.\n스스로 만들어내는 즐거움과 사용자와 만나는 설렘 속에서, 개발자로서의 길을 꾸준히 걸어가고 있습니다.\n\n",
                  ),
                  TextSpan(text: "개발 외에도 "),
                  TextSpan(
                      text: "스케이트보드",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  WidgetSpan(
                    child: Icon(Icons.skateboarding,
                        size: 20, color: Colors.deepPurpleAccent),
                  ),
                  TextSpan(text: "와 "),
                  TextSpan(
                      text: "인라인 스케이트",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  WidgetSpan(
                    child:
                        Icon(Icons.roller_skating, size: 20, color: Colors.red),
                  ),
                  TextSpan(text: "를 타며 바람을 맞고, 생각을 정리하는 걸 좋아해요.\n또, "),
                  TextSpan(
                      text: "코바늘",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  WidgetSpan(
                    child: Icon(Icons.gesture, size: 20, color: Colors.pink),
                  ),
                  TextSpan(
                      text:
                          "로 인형이나 키링을 만들어보기도 하는데, 실을 엮어가며 무언가를 완성하는 기쁨이 코드 짤 때와 비슷하게 느껴져요.\n\n이 블로그는 제 여정을 담아두는 작은 기록입니다. 실도 짜고, 코드도 짜며, 저만의 속도로 성장해가는 모습을 함께 나누고 싶어요."),
                ],
              ),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}
