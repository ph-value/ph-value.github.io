class BlogPost {
  final String name;
  final String downloadUrl;
  final FrontMatter frontMatter;
  final String content;

  BlogPost({
    required this.name,
    required this.downloadUrl,
    required this.frontMatter,
    required this.content,
  });

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      name: json['name'],
      downloadUrl: json['download_url'],
      frontMatter: FrontMatter.fromJson(json['frontMatter']),
      content: json['content'],
    );
  }

  // Dart 객체를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'download_url': downloadUrl,
      'frontMatter': frontMatter.toJson(),
      'content': content,
    };
  }
}

class FrontMatter {
  final String title;
  final String date;
  final String category;

  FrontMatter({
    required this.title,
    required this.date,
    required this.category,
  });

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory FrontMatter.fromJson(Map<String, dynamic> json) {
    String formattedDate = json['date'].substring(0, 10);
    return FrontMatter(
      title: json['title'],
      date:formattedDate,
      category: json['category'],
    );
  }

  // Dart 객체를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'category': category,
    };
  }
}
