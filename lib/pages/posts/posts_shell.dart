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
          // 모바일: 좌측 패널은 상단 섹션으로, 본문은 아래 Expanded로
          return Column(
            children: [
              const _CategoriesAndTags(), // 상단(고정 높이 섹션)
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

/// 좌측 카테고리/태그 패널
/// - 절대 Scaffold를 만들지 않음
/// - 내부 스크롤은 반드시 Expanded로 감싼 ListView 하나만 사용
class _CategoriesAndTags extends StatefulWidget {
  const _CategoriesAndTags();

  @override
  State<_CategoriesAndTags> createState() => _CategoriesAndTagsState();
}

class _CategoriesAndTagsState extends State<_CategoriesAndTags> {
  String? _selectedCategory = 'All';
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final seg = uri.pathSegments;

    // 현재 선택 계산
    String? selectedCategory = (seg.length >= 2 && seg[0] == 'category')
        ? Uri.decodeComponent(seg[1])
        : (seg.isNotEmpty && seg[0] == 'posts' ? 'All' : null);
    String? selectedTag = (seg.length >= 2 && seg[0] == 'tag')
        ? Uri.decodeComponent(seg[1])
        : null;

    // 목록 데이터
    final cats = ['All', ...DocsRepo.instance.categories];
    final tags = DocsRepo.instance.tags;

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
                    onTap: () {
                      if (v == 'All') {
                        context.go('/posts');
                      } else {
                        context.go('/category/${Uri.encodeComponent(v)}');
                      }
                    },
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
                          onSelected: (v) {
                            if (v) {
                              context.go('/tag/${Uri.encodeComponent(t)}');
                            } else if (selectedCategory != null &&
                                selectedCategory != 'All') {
                              context.go(
                                  '/category/${Uri.encodeComponent(selectedCategory)}');
                            } else {
                              context.go('/posts');
                            }
                          },
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
