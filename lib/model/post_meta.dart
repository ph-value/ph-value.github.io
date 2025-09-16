import 'dart:convert';
import 'package:cosmic_frontmatter/cosmic_frontmatter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class PostMeta {
  final String title;
  final String category;
  final String tag;
  final DateTime? date;

  /// slug는 'raw 문자열'로 저장합니다(여기선 인코딩하지 않음).
  final String slug;

  const PostMeta({
    required this.title,
    required this.category,
    required this.tag,
    this.date,
    required this.slug,
  });

  // 🔹 센티널(빈 메타)
  const PostMeta._empty()
      : title = '',
        category = 'Uncategorized',
        tag = '',
        date = null,
        slug = '';

  factory PostMeta.empty() => const PostMeta._empty();

  bool get isEmpty => title.isEmpty && slug.isEmpty;

  factory PostMeta.fromJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] ?? '').toString().trim();
    final rawCategory = (json['category'] ?? 'Uncategorized').toString().trim();
    final rawTag = (json['tag'] ?? '').toString().trim();
    final rawDate = (json['date'] ?? '').toString().trim();

    DateTime? dt;
    if (rawDate.isNotEmpty) {
      try {
        dt = DateTime.parse(rawDate); // ISO8601 또는 YYYY-MM-DD 가정
      } catch (_) {
        dt = null;
      }
    }

    // ❗ 여기서 slug 인코딩하지 않습니다. (라우팅 시점에 encode)
    final rawSlug = (json['slug'] ?? '').toString().trim();

    return PostMeta(
      title: rawTitle,
      category: rawCategory.isNotEmpty ? rawCategory : 'Uncategorized',
      tag: rawTag,
      date: dt,
      slug: rawSlug,
    );
  }

  /// title/slug의 폴백 채우기
  PostMeta withFallbacks({
    required String fallbackTitle,
    required String fallbackSlug,
  }) =>
      PostMeta(
        title: title.isNotEmpty ? title : fallbackTitle,
        category: category.isNotEmpty ? category : 'Uncategorized',
        date: date,
        // raw slug가 비어 있으면 폴백 사용(파일명/제목 기반 slugify)
        slug: (slug.isNotEmpty ? slug : slugify(fallbackSlug)),
        tag: tag.isNotEmpty ? tag : '',
      );
}

class MdDoc {
  final String path;
  final PostMeta meta;
  final String body;

  const MdDoc({required this.path, required this.meta, required this.body});

  // 🔹 센티널(빈 문서)
  const MdDoc._empty()
      : path = '',
        meta = const PostMeta._empty(),
        body = '';

  factory MdDoc.empty() => const MdDoc._empty();

  bool get isEmpty => path.isEmpty && meta.isEmpty && body.isEmpty;
}

/// post/*.md를 에셋에서 읽어 front matter + 본문으로 파싱
Future<List<MdDoc>> loadMarkdownDocs(BuildContext context) async {
  // AssetManifest.json 로드
  final manifestJson =
      await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestJson);

  // post/ 아래의 .md만 수집
  final mdPaths = manifest.keys
      .where((k) => k.startsWith('post/'))
      .where((k) => k.toLowerCase().endsWith('.md'))
      .toList()
    ..sort();

  final List<MdDoc> docs = [];
  for (final path in mdPaths) {
    final raw = await rootBundle.loadString(path);

    // front matter 파싱 + 모델 매핑
    final parsed = parseFrontmatter<PostMeta>(
      content: raw,
      frontmatterBuilder: (map) => PostMeta.fromJson(map),
    );

    // 파일명(확장자 제거)
    final filename = path
        .split('/')
        .last
        .replaceAll(RegExp(r'\.md$', caseSensitive: false), '');

    // 제목 폴백: 본문 첫 H1 > 파일명
    final fallbackTitle = _firstH1(parsed.body) ?? filename;

    // slug 폴백: front matter slug 없으면 파일명/제목에서 생성
    final fallbackSlugCandidate = parsed.frontmatter.slug.isNotEmpty
        ? parsed.frontmatter.slug
        : (filename.isNotEmpty ? filename : fallbackTitle);

    final meta = parsed.frontmatter.withFallbacks(
      fallbackTitle: fallbackTitle,
      fallbackSlug: fallbackSlugCandidate,
    );

    docs.add(MdDoc(path: path, meta: meta, body: parsed.body));
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

/// 본문에서 첫 번째 H1 추출
String? _firstH1(String s) {
  final r = RegExp(r'^\s*#\s+(.+)$', multiLine: true);
  final m = r.firstMatch(s);
  return m?.group(1)?.trim();
}

/// 간단 slugify: 공백→하이픈, 특수문자 정리, 양끝 하이픈 제거.
/// (한글 유지: 정규식에 '가-힣' 포함)
String slugify(String input) {
  var s = input.trim();
  // 이미 인코딩된 경우 원복 시도(실패 시 원본 유지)
  try {
    s = Uri.decodeComponent(s);
  } catch (_) {}
  s = s.toLowerCase();
  s = s.replaceAll(RegExp(r'\s+'), '-'); // 공백류 → -
  s = s.replaceAll(RegExp(r'[^a-z0-9\-가-힣_]'), ''); // 안전 문자만
  s = s.replaceAll(RegExp(r'-{2,}'), '-'); // 연속 하이픈 합치기
  s = s.replaceAll(RegExp(r'^-+|-+$'), ''); // 양끝 하이픈 제거
  return s;
}
