import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

class BlogPostList extends StatefulWidget {
  @override
  _BlogPostListState createState() => _BlogPostListState();
}

class _BlogPostListState extends State<BlogPostList> {
  late Future<List<Map<String, dynamic>>> futureFiles;
  bool isShowPostDetail = false;
  String currentPostContent = "";
  String currentPostTitle = "";

  @override
  void initState() {
    super.initState();
    futureFiles = _loadPosts();
  }

  Future<List<Map<String, dynamic>>> _loadPosts() async {
    // JSON 파일 읽기
    final jsonString = await rootBundle.loadString('post/files.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // 데이터를 리스트로 변환
    return jsonData.map((data) => Map<String, dynamic>.from(data)).toList();
  }

  Widget _postDetail(String data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MarkdownWidget(
        data: data,
        config: MarkdownConfig(configs: [
          LinkConfig(
            style: TextStyle(
              color: Colors.cyan,
              decoration: TextDecoration.underline,
            ),
            onTap: (url) {
              ///TODO:on tap
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isShowPostDetail
          ? AppBar(
              title: Text('Blog Posts'),
            )
          : AppBar(
              title: Text(currentPostTitle),
              leading: BackButton(
                onPressed: () => setState(() {
                  isShowPostDetail = false;
                  currentPostContent = "";
                  currentPostTitle = "";
                }),
              ),
            ),
      body: !isShowPostDetail
          ? FutureBuilder<List<Map<String, dynamic>>>(
              future: futureFiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load posts'));
                } else if (snapshot.hasData) {
                  final files = snapshot.data!;
                  return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final frontMatter =
                          files[index]['frontMatter'] as Map<String, dynamic>;
                      return ListTile(
                        title:
                            Text(frontMatter['title'] ?? files[index]['name']),
                        subtitle: Text(frontMatter['date'] ?? 'No date'),
                        onTap: () {
                          print(
                              "files[index]['content']: ${files[index]['content']}");
                          if (files[index]['content'] != null) {
                            setState(() {
                              isShowPostDetail = true;
                              currentPostContent = files[index]['content'];
                              currentPostTitle = frontMatter['title'];
                            });
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No posts available'));
                }
              },
            )
          : _postDetail(currentPostContent),
    );
  }
}
