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
      isExpanded: true,
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
  List<String> tags = [];
  String? _selectedCategory = 'All';
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    future = loadMarkdownDocs(context);
    df = DateFormat('yyyy-MM-dd'); // 한국어 로케일이면 intl 초기화 추가 가능

    future.then((docs) {
      final cats = docs
          .map((d) =>
              (d.meta.category).isNotEmpty ? d.meta.category : 'Uncategorized')
          .toSet()
          .toList();
      final tagList = docs
          .map((d) => (d.meta.tag).isNotEmpty ? d.meta.tag : '')
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        categories = cats;
        tags = tagList;
        _data = generateItems(categories);
      });
    }).catchError((e) {
      debugPrint('load docs error: $e');
    });
  }

  void _launchURLInNewTab(String url) {
    web.window.open(url, '_blank');
  }

  void _copyCurrentPostUrlToClipboard() {
    try {
      final postPath = '/posts/${currentPost.meta.slug}';
      web.window.history.pushState(null, '', postPath);

      final postUrl = web.window.location.href;
      Clipboard.setData(ClipboardData(text: postUrl));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL copied to clipboard!')),
      );
    } catch (e, st) {
      debugPrint('URL 복사 실패: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL 복사에 실패했습니다.')),
      );
    }
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
    // 카테고리 패널
    Widget buildPanel() {
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
                      final selected = value == _selectedCategory;
                      return ListTile(
                        title: Text(value),
                        selected: selected,
                        onTap: () {
                          setState(() {
                            isShowPostDetail = false;
                            _selectedCategory = value;
                            _selectedTag = null;
                          });
                          final path = value == 'All'
                              ? '/'
                              : '/category/${Uri.encodeComponent(value)}';
                          try {
                            web.window.history.pushState(null, value, path);
                          } catch (e) {
                            debugPrint('history pushState 실패: $e');
                          }
                        },
                        trailing: selected
                            ? const Icon(Icons.check)
                            : const Icon(Icons.chevron_right),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      );
    }

    // 태그 칩
    Widget buildTagChips() {
      if (tags.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Wrap(
          spacing: 8,
          children: tags.map((t) {
            final sel = t == _selectedTag;
            return ChoiceChip(
              label: Text(t),
              selected: sel,
              onSelected: (v) {
                setState(() {
                  isShowPostDetail = false;
                  _selectedTag = v ? t : null;
                  if (v) _selectedCategory = null;
                });

                final path = v
                    ? '/tag/${Uri.encodeComponent(t)}'
                    : (_selectedCategory != null && _selectedCategory != 'All'
                        ? '/category/${Uri.encodeComponent(_selectedCategory!)}'
                        : '/');
                try {
                  web.window.history.pushState(null, _selectedTag!, path);
                } catch (e) {
                  debugPrint('history pushState 실패: $e');
                }
              },
            );
          }).toList(),
        ),
      );
    }

    // 포스트 리스트
    Widget buildPostList(String? category) {
      // category: All, Language, Platform, Dev, Life, Book_Review
      // tag: TIL, 등등...
      if (category != null && category == 'All') {
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
                  var docs = snap.data ?? [];

                  if (_selectedTag != null && _selectedTag!.isNotEmpty) {
                    docs =
                        docs.where((d) => d.meta.tag == _selectedTag).toList();
                  } else if (_selectedCategory != null &&
                      _selectedCategory != 'All') {
                    docs = docs
                        .where((d) => d.meta.category == _selectedCategory)
                        .toList();
                  }
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
                          final postPath =
                              '/posts/${Uri.encodeComponent(d.meta.slug)}';
                          // 주소 표시줄을 포스트 경로로 즉시 갱신
                          web.window.history
                              .pushState(null, d.meta.title, postPath);
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
      } else if (category != null && category == 'TIL') {
        return const Center(child: Text('TIL 카테고리 페이지는 미구현 상태입니다.'));
      } else {
        return const Center(child: Text('카테고리를 선택해주세요.'));
      }
    }

    return Scaffold(
        appBar: !isShowPostDetail
            ? AppBar(
                elevation: 0,
                title: const Text('Blog Posts'),
                shape: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              )
            : AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                forceMaterialTransparency: true,
                shape: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
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
                      buildPanel(),
                      const ListTile(
                        title: Center(child: Text('Tags')),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildTagChips()),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.grey[400], width: 3),
                Expanded(child: buildPostList('All')),
              ],
            );
          } else {
            return Column(
              children: [
                Visibility(
                  visible: !isShowPostDetail,
                  child: Column(
                    children: [
                      buildPanel(),
                      const ListTile(
                        title: Center(child: Text('Tags')),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildTagChips()),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[400], height: 3),
                SizedBox(height: 16),
                Expanded(child: buildPostList('All')),
              ],
            );
          }
        }));
  }
}
