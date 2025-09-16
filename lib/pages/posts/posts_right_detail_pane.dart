import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:sando_diary/model/docs_repo.dart';
import 'package:sando_diary/model/post_meta.dart';

class PostsRightDetailPane extends StatelessWidget {
  final String slug;
  const PostsRightDetailPane({super.key, required this.slug});

  MdDoc? _resolveDoc(String routeSlug) {
    // 1) 라우트에서 받은 그대로
    final s0 = routeSlug;
    // 2) 디코딩 시도
    String s1;
    try {
      s1 = Uri.decodeComponent(routeSlug);
    } catch (_) {
      s1 = routeSlug;
    }
    // 3) 인코딩 시도
    final s2 = Uri.encodeComponent(s1);

    // 여러 후보로 조회 (중복 제거)
    final tried = <String>{s0, s1, s2};
    for (final s in tried) {
      final d = DocsRepo.instance.getBySlug(s);
      if (d != null) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // final doc = DocsRepo.instance.getBySlug(Uri.decodeComponent(slug));
    // if (doc == null) return const Center(child: Text('문서를 찾을 수 없습니다.'));

    // DocsRepo를 비동기로 로드한 뒤 문서를 찾아야 함.
    return FutureBuilder(
        future: DocsRepo.instance.load(context),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('로드 실패: ${snap.error}'));
          }

          // 로드 완료 시 다양한 인코딩 후보로 문서를 조회
          final doc = _resolveDoc(slug);
          if (doc == null) {
            return const Center(child: Text('문서를 찾을 수 없습니다.'));
          }

          void copyUrl() {
            // canonical slug 사용해서 URL 생성
            final path = '/posts/${Uri.encodeComponent(doc.meta.slug)}';
            final absUrl = Uri.base.replace(path: path).toString();

            Clipboard.setData(ClipboardData(text: absUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('URL copied to clipboard!')),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => context.go('/posts'),
                      tooltip: '뒤로',
                    ),
                    Text(doc.meta.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    // 공유 버튼
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: copyUrl,
                      tooltip: '공유',
                    ),
                  ],
                ),
                // 상단 헤더 영역(고정 높이)

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'category: ${doc.meta.category}'
                    '${doc.meta.date != null ? ' · ${DateFormat('yyyy-MM-dd').format(doc.meta.date!)}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Divider(height: 24),

                // 본문은 남은 공간을 차지하고 내부에서만 스크롤
                Expanded(
                  child: MarkdownWidget(
                    data: doc.body,
                    // (필요 시) config: ...
                  ),
                ),
              ],
            ),
          );
        });
  }
}
