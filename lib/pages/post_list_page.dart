import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import 'package:markdown_widget/markdown_widget.dart';
import 'package:sando_diary/model/post_meta.dart';

class Item {
  Item({
    required this.headerValue,
    this.expandedValues = const [],
    this.isExpanded = false,
  });

  String headerValue;
  List<String> expandedValues;
  bool isExpanded;

  bool get hasExpandedValues => expandedValues.isNotEmpty;
}

List<Item> generateItems(List<String> categories) {
  categories.insert(0, 'All');
  return [
    Item(
      headerValue: 'Post Categories',
      expandedValues: categories,
      isExpanded: false,
    )
  ];
}

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

  List<Item> _data = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    future = loadMarkdownDocs(context);
    df = DateFormat('yyyy-MM-dd'); // 한국어 로케일이면 intl 초기화 추가 가능

    future.then((docs) {
      final cats = docs.map((d) => d.meta.category).toSet().toList();
      setState(() {
        categories = cats;
        _data = generateItems(categories);
      });
    });
  }

  void _launchURLInNewTab(String url) {
    web.window.open(url, '_blank');
  }

  void _copyCurrentPostUrlToClipboard() {
    final postUrl =
        Uri.base.resolve('/posts/${currentPost.meta.slug}').toString();
    print('Copy URL: $postUrl');
    Clipboard.setData(ClipboardData(text: postUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard!')),
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
                style: const TextStyle(
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
    Widget _buildPanel() {
      return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _data[index].isExpanded = isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((Item item) {
          return ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(title: Text(item.headerValue));
            },
            body: item.hasExpandedValues
                ? Column(
                    children: item.expandedValues.map((value) {
                      return ListTile(
                        title: Text(value),
                        onTap: () {
                          // TODO: Implement category filtering
                          print('Tapped on $value');
                        },
                        trailing: const Icon(Icons.chevron_right),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      );
    }

    Widget _buildPostList(String? category) {
      // all 카테고리면 전체, 아니면 해당 카테고리만 필터링
      // til 카테고리는 따로 구현?

      return !isShowPostDetail
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
          : _postDetail(currentPost);
    }

    return Scaffold(
        appBar: !isShowPostDetail
            ? AppBar(
                title: const Text('Blog Posts'),
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
                    web.window.history.pushState(null, 'Posts', '/');
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
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          if (width > 600) {
            return Row(
              children: [
                SizedBox(
                  width: width * 0.3,
                  child: Column(
                    children: [
                      _buildPanel(),
                      ListTile(
                        title: const Text('TIL (Today I Learned)'),
                        onTap: () {
                          // TODO: Implement TIL navigation
                        },
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.grey[400], width: 3),
                Expanded(child: _buildPostList('All')),
              ],
            );
          } else {
            return Column(
              children: [
                Visibility(
                  visible: !isShowPostDetail,
                  child: Column(
                    children: [
                      _buildPanel(),
                      ListTile(
                        title: const Text('TIL (Today I Learned)'),
                        onTap: () {
                          // TODO: Implement TIL navigation
                        },
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[400], height: 3),
                SizedBox(height: 16),
                Text('Recent Posts',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey[700])),
                Expanded(child: _buildPostList('All')),
              ],
            );
          }
        }));
  }
}
