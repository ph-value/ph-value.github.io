import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:sando_diary/BlogPost.dart';

class BlogPostList extends StatefulWidget {
  @override
  _BlogPostListState createState() => _BlogPostListState();
}

class _BlogPostListState extends State<BlogPostList> {
  late Future<List<BlogPost>> futureFiles;
  bool isShowPostDetail = false;
  late BlogPost currentPost;

  @override
  void initState() {
    super.initState();
    futureFiles = _loadPosts();
  }

  Future<List<BlogPost>> _loadPosts() async {
    // JSON 파일 읽기
    final jsonString = await rootBundle.loadString('post_files.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // 데이터를 리스트로 변환
    return jsonData.map((data) => BlogPost.fromJson(data)).toList();
  }

  Widget _postDetail(BlogPost currentPost) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(currentPost.frontMatter.date),
          ),
          MarkdownWidget(
            data: currentPost.content,
            config: MarkdownConfig(configs: [
              LinkConfig(
                style: TextStyle(
                  color: Colors.cyan,
                  decoration: TextDecoration.underline,
                ),
                onTap: (url) {
                  _launchURLInNewTab(url);
                },
              )
            ]),
          ),
        ],
      ),
    );
  }

  void _launchURLInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isShowPostDetail
          ? AppBar(
              title: Text('Blog Posts'),
            )
          : AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              forceMaterialTransparency: true,
              title: Text(currentPost.frontMatter.title),
              leading: BackButton(
                onPressed: () => setState(() {
                  isShowPostDetail = false;
                }),
              ),
            ),
      body: !isShowPostDetail
          ? FutureBuilder<List<BlogPost>>(
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
                      final post = files[index];
                      return ListTile(
                        title: Text(post.frontMatter.title),
                        subtitle: Text(post.frontMatter.date),
                        onTap: () {
                          setState(() {
                            isShowPostDetail = true;
                            currentPost = post;
                          });
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No posts available'));
                }
              },
            )
          : _postDetail(currentPost),
    );
  }
}
