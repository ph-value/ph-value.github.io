// post_list_page.dart (핵심만 — 그대로 교체 권장)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:sando_diary/model/docs_repo.dart';

import 'package:sando_diary/model/post_meta.dart';

class PostListPage extends StatefulWidget {
  final String? slug; // ← 추가: 상세일 때 전달됨
  const PostListPage({super.key, this.slug});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class PostDetailPane extends StatelessWidget {
  final MdDoc doc;
  const PostDetailPane({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            doc.meta.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'category: ${doc.meta.category}'
              '${doc.meta.date != null ? ' · ${DateFormat('yyyy-MM-dd').format(doc.meta.date!)}' : ' · 날짜 정보 없음'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(height: 24),
          MarkdownWidget(
            data: doc.body,
            config: MarkdownConfig(configs: [
              LinkConfig(
                style: const TextStyle(decoration: TextDecoration.underline),
                onTap: (url) {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크를 클립보드에 복사했습니다.')),
                  );
                },
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final MdDoc doc;
  const PostDetailPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc.meta.title),
        leading: BackButton(onPressed: () => context.go('/posts')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final uri = GoRouterState.of(context).uri;
              final abs = Uri.base
                  .replace(
                    path: uri.path,
                    queryParameters: uri.queryParameters.isEmpty
                        ? null
                        : uri.queryParameters,
                    fragment: null,
                  )
                  .toString();
              Clipboard.setData(ClipboardData(text: abs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied!')),
              );
            },
          ),
        ],
      ),
      body: PostDetailPane(doc: doc), // 본문은 Pane 재사용
    );
  }
}

class _PostListPageState extends State<PostListPage>
    with AutomaticKeepAliveClientMixin {
  late final DateFormat df = DateFormat('yyyy-MM-dd');
  String? _selectedCategory = 'All';
  String? _selectedTag;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<MdDoc>>(
      future: DocsRepo.instance.load(context), // 캐시된 Future 재사용
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('로드 실패: ${snap.error}'));
        }
        final docs = snap.data ?? [];

        // ───── 상세: slug가 있으면 상세 화면 ─────
        if (widget.slug != null && widget.slug!.isNotEmpty) {
          final slug = Uri.decodeComponent(widget.slug!);
          final doc = DocsRepo.instance.getBySlug(slug);
          if (doc == null) return const Center(child: Text('문서를 찾을 수 없습니다.'));
          return _DetailView(
              doc: doc, df: df, onBack: () => context.go('/posts'));
        }

        // ───── 목록: 필터 적용 후 목록 표시 ─────
        var filtered = docs;
        if (_selectedTag != null && _selectedTag!.isNotEmpty) {
          filtered = filtered.where((d) => d.meta.tag == _selectedTag).toList();
        } else if (_selectedCategory != null && _selectedCategory != 'All') {
          filtered = filtered
              .where((d) => d.meta.category == _selectedCategory)
              .toList();
        }

        Widget buildCategories() {
          final items = ['All', ...DocsRepo.instance.categories];
          return ExpansionTile(
            title: const Text('Post Categories'),
            children: items.map((v) {
              final selected = v == _selectedCategory ||
                  (v == 'All' && _selectedCategory == 'All');
              return ListTile(
                title: Text(v),
                selected: selected,
                onTap: () {
                  setState(() {
                    _selectedCategory = v;
                    _selectedTag = null;
                  });
                  if (v == 'All') {
                    context.go('/posts');
                  } else {
                    context.go('/category/${Uri.encodeComponent(v)}');
                  }
                },
                trailing: selected
                    ? const Icon(Icons.check)
                    : const Icon(Icons.chevron_right),
              );
            }).toList(),
          );
        }

        Widget buildTags() {
          final tags = DocsRepo.instance.tags;
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
                      _selectedTag = v ? t : null;
                      if (v) _selectedCategory = null;
                    });
                    if (v) {
                      context.go('/tag/${Uri.encodeComponent(t)}');
                    } else if (_selectedCategory != null &&
                        _selectedCategory != 'All') {
                      context.go(
                          '/category/${Uri.encodeComponent(_selectedCategory!)}');
                    } else {
                      context.go('/posts');
                    }
                  },
                );
              }).toList(),
            ),
          );
        }

        Widget buildList() {
          if (filtered.isEmpty) {
            return const Center(child: Text('문서가 없습니다.'));
          }
          return ListView.separated(
            key: const PageStorageKey('posts-list'),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = filtered[i];
              final dateStr =
                  d.meta.date != null ? df.format(d.meta.date!) : '날짜 정보 없음';
              return ListTile(
                title: Text(d.meta.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  d.meta.tag.isNotEmpty
                      ? '${d.meta.category} · ${d.meta.tag} · $dateStr'
                      : '${d.meta.category} · $dateStr',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.go('/posts/${Uri.encodeComponent(d.meta.slug)}'),
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            // slug가 있는 경우(상세)
            if (widget.slug != null && widget.slug!.isNotEmpty) {
              final slug = Uri.decodeComponent(widget.slug!);
              final doc = DocsRepo.instance.getBySlug(slug);
              if (doc == null)
                return const Center(child: Text('문서를 찾을 수 없습니다.'));

              if (isWide) {
                // ❶ 넓은 화면: 왼쪽 패널 고정, 오른쪽 pane에만 상세 표시 (덮지 않음)
                return Row(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.3,
                      child: Column(
                        children: [
                          buildCategories(), // ← 기존 카테고리/태그 위젯
                          const ListTile(title: Center(child: Text('Tags'))),
                          buildTags(),
                        ],
                      ),
                    ),
                    VerticalDivider(color: Colors.grey[400], width: 3),
                    const SizedBox(width: 8),
                    // 오른쪽 영역에만 상세
                    Expanded(child: PostDetailPane(doc: doc)),
                  ],
                );
              } else {
                // ❷ 좁은 화면: 전체 화면으로 상세 페이지
                return PostDetailPage(doc: doc);
              }
            }

            // slug가 없으면 목록
            // ❸ 넓은 화면: 좌측 필터 + 우측 리스트
            // ❹ 좁은 화면: 위에 필터, 아래 리스트 (기존처럼)
            if (isWide) {
              return Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.3,
                    child: Column(
                      children: [
                        buildCategories(),
                        const ListTile(title: Center(child: Text('Tags'))),
                        buildTags(),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.grey[400], width: 3),
                  Expanded(child: buildList()),
                ],
              );
            } else {
              return Column(
                children: [
                  buildCategories(),
                  const ListTile(title: Center(child: Text('Tags'))),
                  buildTags(),
                  Divider(color: Colors.grey[400], height: 3),
                  const SizedBox(height: 16),
                  Expanded(child: buildList()),
                ],
              );
            }
          },
        );
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final MdDoc doc;
  final DateFormat df;
  final VoidCallback onBack;
  const _DetailView(
      {required this.doc, required this.df, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc.meta.title),
        leading: BackButton(onPressed: onBack),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final uri = GoRouterState.of(context).uri;
              final abs = Uri.base
                  .replace(
                    path: uri.path,
                    queryParameters: uri.queryParameters.isEmpty
                        ? null
                        : uri.queryParameters,
                    fragment: null,
                  )
                  .toString();
              Clipboard.setData(ClipboardData(text: abs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MarkdownWidget(
          data: doc.body,
          config: MarkdownConfig(configs: [
            LinkConfig(
              style: const TextStyle(
                color: Colors.cyan,
                decoration: TextDecoration.underline,
              ),
              onTap: (url) {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('링크가 클립보드에 복사되었습니다.')),
                );
              },
            )
          ]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'category: ${doc.meta.category}'
          '${doc.meta.date != null ? ' · ${df.format(doc.meta.date!)}' : ' · 날짜 정보 없음'}',
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
