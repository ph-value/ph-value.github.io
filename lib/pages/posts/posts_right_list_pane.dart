import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sando_diary/model/docs_repo.dart';
import 'package:sando_diary/model/post_meta.dart';

class PostsRightListPane extends StatelessWidget {
  const PostsRightListPane({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final seg = uri.pathSegments;

    String? category;
    String? tag;

    if (seg.length >= 2 && seg[0] == 'category') {
      category = Uri.decodeComponent(seg[1]);
    } else if (seg.length >= 2 && seg[0] == 'tag') {
      tag = Uri.decodeComponent(seg[1]);
    } else if (seg.isNotEmpty && seg[0] == 'posts') {
      category = 'All';
    }

    return FutureBuilder<List<MdDoc>>(
      future: DocsRepo.instance.load(context),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('로드 실패: ${snap.error}'));
        }
        var docs = snap.data ?? [];

        // 현재 URL에 따라 필터
        if (tag != null && tag!.isNotEmpty) {
          docs = docs.where((d) => d.meta.tags.contains(tag)).toList();
        } else if (category != null && category != 'All') {
          docs = docs.where((d) => d.meta.category == category).toList();
        }

        if (docs.isEmpty) {
          return const Center(child: Text('문서가 없습니다.'));
        }

        return ListView.separated(
          key: const PageStorageKey('posts-list'),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = docs[i];
            return ListTile(
              title: Text(d.meta.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(d.meta.category +
                  (d.meta.tags.isNotEmpty ? ' · ${d.meta.tags.join(', ')}' : '')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Uri(
                pathSegments: ['', 'posts', d.meta.slug],
                queryParameters: {
                  if (category != null) 'category': category!,
                  if (tag != null) 'tag': tag!,
                },
              ).toString()),
            );
          },
        );
      },
    );
  }
}
