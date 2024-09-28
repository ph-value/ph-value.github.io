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
            SizedBox(height: 10),
            Text(
              'Mobile Developer,', // 직업 또는 타이틀
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '안녕하세요! 모바일 개발자 산도입니다. '
              '\n 손 안에 들어오는 모바일 개발이 매력적이라 안드로이드 개발을 목표로 하고, \n'
              '\n iOS에도 관심이 있어 SwiftUI로 앱을 만들어보려 합니다. '
              '\n여러 강의를 수강하며 필요한 기술을 배우고 능숙하게 활용하려고 준비 중입니다.'
              '\n두 개의 모바일 생태계에서 자유롭게 활동하는 것을 목표로 Flutter 앱을 출시했습니다. '
              '\n\n 스케이트보드와 인라인 스케이트를 타며 땅을 박차고 바람을 맞으며 생각을 정리하고,'
              '\n때로는 코바늘로 인형이나 키링을 만들어가며 스트레스를 풀어요. 네, 실도 짜고, 코드도 짭니다.'
              '\n이렇게 다양한 방식으로 나를 표현하고, 또 성장해가는 중입니다. '
              '\n이 블로그는 그런 여정의 일부를 담아두는 공간입니다.',
              // 소개 글
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
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
