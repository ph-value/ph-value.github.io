import 'dart:convert';
import 'package:cosmic_frontmatter/cosmic_frontmatter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class PostMeta {
  final String title;
  final String category;
  final DateTime? date;
  final String slug;

  PostMeta(
      {required this.title,
      required this.category,
      this.date,
      required this.slug});

  factory PostMeta.fromJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] ?? '').toString().trim();
    final rawCategory = (json['category'] ?? 'Uncategorized').toString().trim();
    final rawDate = (json['date'] ?? '').toString().trim();
    DateTime? dt;
    if (rawDate.isNotEmpty) {
      // ISO8601 또는 YYYY-MM-DD 가정
      try {
        dt = DateTime.parse(rawDate);
      } catch (_) {}
    }

    final rawSlug = Uri.encodeComponent((json['slug'] ?? '')
        .toString()
        .trim()
        .replaceAll(RegExp(r'^-+|-+$'), ''));

    return PostMeta(
        title: rawTitle, category: rawCategory, date: dt, slug: rawSlug);
  }

  PostMeta withFallbacks({required String fallbackTitle}) => PostMeta(
        title: title.isNotEmpty ? title : fallbackTitle,
        category: category.isNotEmpty ? category : 'Uncategorized',
        date: date,
        slug: slug,
      );
}

class MdDoc {
  final String path;
  final PostMeta meta;
  final String body;
  MdDoc({required this.path, required this.meta, required this.body});
}

Future<List<MdDoc>> loadMarkdownDocs(BuildContext context) async {
  final manifestJson =
      await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestJson);

  final mdPaths = manifest.keys
      .where((k) => k.startsWith('post/'))
      .where((k) => k.toLowerCase().endsWith('.md'))
      .toList()
    ..sort();

  final List<MdDoc> docs = [];
  for (final path in mdPaths) {
    final raw = await rootBundle.loadString(path);
    // front matter 파싱 + 모델 매핑
    final doc = parseFrontmatter<PostMeta>(
      content: raw,
      frontmatterBuilder: (map) => PostMeta.fromJson(map),
    );
    // 제목/카테고리 폴백 처리 (없을 경우 파일명 사용)
    final filename = path.split('/').last.replaceAll('.md', '');
    final meta = doc.frontmatter
        .withFallbacks(fallbackTitle: _firstH1(doc.body) ?? filename);

    docs.add(MdDoc(path: path, meta: meta, body: doc.body));
  }

  // 날짜 내림차순 정렬(날짜 없는 글은 뒤로)
  docs.sort((a, b) {
    final da = a.meta.date;
    final db = b.meta.date;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });

  return docs;
}

String? _firstH1(String s) {
  final r = RegExp(r'^\s*#\s+(.+)$', multiLine: true);
  final m = r.firstMatch(s);
  return m?.group(1)?.trim();
}
