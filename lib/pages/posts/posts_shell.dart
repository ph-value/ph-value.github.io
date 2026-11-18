import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sando_diary/model/docs_repo.dart';

import 'package:sando_diary/model/post_meta.dart';

/// 좌측 카테고리/태그 패널을 "고정"하고,
/// 우측 영역만 라우트 child로 교체하는 Shell.
/// - 좌/우 어디에도 Scaffold를 만들지 말 것(덮임 방지)
/// - 좌측은 Column + Expanded(ListView)로 높이 제약을 확실히 줄 것(스크롤 중첩 오류 방지)
class PostsShell extends StatelessWidget {
  final Widget child;
  const PostsShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 600;

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CategoriesAndTags(compact: true),
              const Divider(height: 1),
              Expanded(child: child), // 우측 child에 해당(목록/상세)
            ],
          );
        }

        // 데스크탑/태블릿: 좌측 고정 + 우측 child
        final leftWidth = (c.maxWidth * 0.30).clamp(240.0, 420.0).toDouble();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 좌/우 높이 동일
          children: [
            SizedBox(
              width: leftWidth,
              child:
                  const _CategoriesAndTags(), // 좌측 패널(여기서 ListView는 Expanded로 제한)
            ),
            const VerticalDivider(width: 3),
            Expanded(child: child), // 우측 영역만 라우트 child로 교체
          ],
        );
      },
    );
  }
}

/// 데스크톱 사이드 패널과 모바일의 간결한 필터 영역.
class _CategoriesAndTags extends StatefulWidget {
  final bool compact;

  const _CategoriesAndTags({this.compact = false});

  @override
  State<_CategoriesAndTags> createState() => _CategoriesAndTagsState();
}

class _CategoriesAndTagsState extends State<_CategoriesAndTags> {
  bool _tagsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MdDoc>>(
      future: DocsRepo.instance.load(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('로드 실패: ${snapshot.error}'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildPanel(context);
      },
    );
  }

  Widget _buildPanel(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final seg = uri.pathSegments;

    // 상세 화면에서도 글을 열기 전 목록의 필터를 유지합니다.
    final isDetail = seg.length >= 2 && seg[0] == 'posts';
    String? selectedCategory = (seg.length >= 2 && seg[0] == 'category')
        ? seg[1]
        : isDetail
            ? uri.queryParameters['category'] ??
                (uri.queryParameters.containsKey('tag') ? null : 'All')
            : (seg.isNotEmpty && seg[0] == 'posts' ? 'All' : null);
    String? selectedTag = (seg.length >= 2 && seg[0] == 'tag')
        ? seg[1]
        : (isDetail ? uri.queryParameters['tag'] : null);

    // 목록 데이터
    final cats = ['All', ...DocsRepo.instance.categories];
    final tags = DocsRepo.instance.tags;

    void selectCategory(String category) {
      context.go(category == 'All'
          ? '/posts'
          : '/category/${Uri.encodeComponent(category)}');
    }

    void selectTag(String tag, bool selected) {
      if (selected) {
        context.go('/tag/${Uri.encodeComponent(tag)}');
      } else {
        selectCategory(selectedCategory ?? 'All');
      }
    }

    if (widget.compact) {
      Widget tagChip(String tag) => ChoiceChip(
            label: Text(tag),
            selected: tag == selectedTag,
            showCheckmark: true,
            onSelected: (selected) => selectTag(tag, selected),
          );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '카테고리',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cats
                    .map((category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: category == selectedCategory,
                            onSelected: (_) => selectCategory(category),
                          ),
                        ))
                    .toList(),
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _tagsExpanded = !_tagsExpanded),
                  icon: Icon(
                      _tagsExpanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(_tagsExpanded ? '태그 접기' : '태그 열기'),
                ),
              ),
              if (!_tagsExpanded && selectedTag != null)
                Text('선택한 태그: $selectedTag'),
              const SizedBox(height: 4),
              if (_tagsExpanded)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: tags.map(tagChip).toList(),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const ListTile(
              dense: true,
              title: Text('Post Categories',
                  style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: ListView(
              children: [
                ...cats.map((v) {
                  final selected = (v == 'All' && selectedCategory == 'All') ||
                      (v == selectedCategory);
                  return ListTile(
                    title: Text(v),
                    selected: selected,
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: () => selectCategory(v),
                  );
                }),
                const Divider(height: 24),
                const ListTile(
                    dense: true,
                    title: Text('Tags',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                if (tags.isEmpty)
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text('No tags')),
                if (tags.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((t) {
                        final sel = t == selectedTag;
                        return ChoiceChip(
                          label: Text(t),
                          selected: sel,
                          onSelected: (v) => selectTag(t, v),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
