// posts_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/services.dart';

import 'package:sando_diary/model/post_meta.dart';
import '../model/docs_repo.dart';

/// /posts (목록) 과 /posts/:slug (상세)를 동시에 처리
class PostsScreen extends StatefulWidget {
  final String? slug; // null이면 목록, 있으면 해당 slug 상세
  const PostsScreen({super.key, this.slug});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with AutomaticKeepAliveClientMixin {
  late final DateFormat df = DateFormat('yyyy-MM-dd');
  @override
  bool get wantKeepAlive => true; // 목록 스크롤 유지

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<MdDoc>>(
      future: DocsRepo.instance.load(context), // 동일 Future 재사용
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('로드 실패: ${snap.error}'));
        }
        final docs = snap.data ?? [];

        // slug가 있으면 상세
        if (widget.slug != null && widget.slug!.isNotEmpty) {
          final slug = Uri.decodeComponent(widget.slug!);
          final doc = DocsRepo.instance.getBySlug(slug);
          if (doc == null) {
            return const Center(child: Text('문서를 찾을 수 없습니다.'));
          }
          return _DetailView(
            doc: doc,
            onBack: () => context.go('/posts'),
          );
        }

        // 없으면 목록
        return _ListWithFilters(
          docs: docs,
          df: df,
          categories: DocsRepo.instance.categories,
          tags: DocsRepo.instance.tags,
          onTapDoc: (d) =>
              context.go('/posts/${Uri.encodeComponent(d.meta.slug)}'),
        );
      },
    );
  }
}

/// 좌측 카테고리/태그 + 우측 리스트(반응형)
class _ListWithFilters extends StatefulWidget {
  final List<MdDoc> docs;
  final DateFormat df;
  final List<String> categories;
  final List<String> tags;
  final void Function(MdDoc doc) onTapDoc;

  const _ListWithFilters({
    required this.docs,
    required this.df,
    required this.categories,
    required this.tags,
    required this.onTapDoc,
  });

  @override
  State<_ListWithFilters> createState() => _ListWithFiltersState();
}

class _ListWithFiltersState extends State<_ListWithFilters> {
  String? _selectedCategory = 'All';
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    // 필터 적용
    var filtered = widget.docs;
    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      filtered = filtered.where((d) => d.meta.tag == _selectedTag).toList();
    } else if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered =
          filtered.where((d) => d.meta.category == _selectedCategory).toList();
    }

    Widget buildCategories() {
      final data = ['All', ...widget.categories];
      return ExpansionPanelList.radio(
        children: data.map((value) {
          return ExpansionPanelRadio(
            value: value,
            headerBuilder: (context, isExpanded) =>
                ListTile(title: Text('Post Categories')),
            body: Column(
              children: data.map((v) {
                final selected = v == _selectedCategory;
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
            ),
          );
        }).toList(),
      );
    }

    Widget buildTags() {
      if (widget.tags.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Wrap(
          spacing: 8,
          children: widget.tags.map((t) {
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
              d.meta.date != null ? widget.df.format(d.meta.date!) : '날짜 정보 없음';
          return ListTile(
            title: Text(d.meta.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              d.meta.tag.isNotEmpty
                  ? '${d.meta.category} · ${d.meta.tag} · $dateStr'
                  : '${d.meta.category} · $dateStr',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onTapDoc(d),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width > 600) {
          return Row(
            children: [
              SizedBox(
                width: width * 0.3,
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
              ExpansionTile(
                  title: const Text('Post Categories'),
                  children: [buildCategories()]),
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
  }
}

class _DetailView extends StatelessWidget {
  final MdDoc doc;
  final VoidCallback onBack;
  const _DetailView({required this.doc, required this.onBack});

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
    );
  }
}
