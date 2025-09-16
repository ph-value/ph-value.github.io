// docs_repo.dart
import 'package:flutter/widgets.dart';
import 'package:sando_diary/model/post_meta.dart';

/// Markdown 문서 로딩을 1번만 수행하고, 파생 데이터까지 캐싱하는 레이어
class DocsRepo {
  DocsRepo._();
  static final DocsRepo instance = DocsRepo._();

  Future<List<MdDoc>>? _future; // 문서 목록 Future 캐시
  Map<String, MdDoc>? _bySlug; // slug -> 문서 캐시
  List<String>? _categories; // 카테고리 목록 캐시 (정렬됨)
  List<String>? _tags; // 태그 목록 캐시 (정렬됨)

  /// 최초 1회만 실제 로더 실행. 이후 동일 Future 재사용
  Future<List<MdDoc>> load(BuildContext context) {
    _future ??= _loadAndIndex(context);
    return _future!;
  }

  Future<List<MdDoc>> _loadAndIndex(BuildContext context) async {
    final docs = await loadMarkdownDocs(context);

    // 슬러그 인덱스 (raw slug 기준)
    _bySlug = {for (final d in docs) d.meta.slug: d};

    // 카테고리/태그 파생 데이터 계산 (중복 제거 + 정렬)
    final cats = docs
        .map((d) =>
            d.meta.category.isNotEmpty ? d.meta.category : 'Uncategorized')
        .toSet()
        .toList()
      ..sort();
    final tagList = docs
        .map((d) => d.meta.tag)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    _categories = cats;
    _tags = tagList;
    return docs;
  }

  MdDoc? getBySlug(String slug) => _bySlug?[slug];

  List<String> get categories => _categories ?? const [];
  List<String> get tags => _tags ?? const [];

  /// (선택) 핫리로드 후 강제 리셋이 필요할 때 호출
  void reset() {
    _future = null;
    _bySlug = null;
    _categories = null;
    _tags = null;
  }
}
