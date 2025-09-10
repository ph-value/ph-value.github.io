import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:sando_diary/model/post_meta.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});
  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late Future<List<MdDoc>> future;
  late DateFormat df;
  bool isShowPostDetail = false;
  late MdDoc currentPost;

  @override
  void initState() {
    super.initState();
    future = loadMarkdownDocs(context);
    df = DateFormat('yyyy-MM-dd'); // 한국어 로케일이면 intl 초기화 추가 가능
  }

  void _launchURLInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  void _copyCurrentPostUrlToClipboard() {
    final currentUrl = html.window.location.href; // 현재 페이지의 URL 가져오기
    Clipboard.setData(ClipboardData(text: currentUrl)); // URL을 클립보드에 복사

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL copied to clipboard!')),
    );
  }

  Widget _postDetail(MdDoc currentDoc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(currentDoc.meta.date != null
                ? DateFormat('yyyy-MM-dd').format(currentDoc.meta.date!)
                : '날짜 정보 없음'),
          ),
          MarkdownWidget(
            data: currentDoc.body,
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
              title: Text(currentPost.meta.title),
              leading: BackButton(
                onPressed: () => setState(() {
                  isShowPostDetail = false;
                  html.window.history.pushState(null, 'Posts', '/');
                }),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share this Post',
                  onPressed: _copyCurrentPostUrlToClipboard,
                ),
              ],
            ),
      body: !isShowPostDetail
          ? FutureBuilder<List<MdDoc>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('로드 실패: ${snap.error}'));
                }
                final docs = snap.data ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('문서가 없습니다.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final dateStr = d.meta.date != null
                        ? df.format(d.meta.date!)
                        : '날짜 정보 없음';
                    return ListTile(
                      title: Text(d.meta.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${d.meta.category} · $dateStr'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        setState(() {
                          isShowPostDetail = true;
                          currentPost = d;
                        });
                      },
                    );
                  },
                );
              },
            )
          : _postDetail(currentPost),
    );
  }
}
