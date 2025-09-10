import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:sando_diary/theme/customDecoration.dart';

class Projectpage extends StatefulWidget {
  const Projectpage({super.key});

  @override
  State<Projectpage> createState() => _ProjectpageState();
}

class _ProjectpageState extends State<Projectpage> {
  bool isShowDetail = false;
  List<bool> _isHovering = [];

  late CardData currentProject;

  final List<CardData> cardList = [
    CardData(
      title: 'MindLift App',
      description: 'This is the first card description.',
      fileName: 'mindlift',
      content: '',
      tags: ['Language', 'Platform'],
    ),
    CardData(
      title: 'Iconhabit App',
      description: 'This is the first card description.',
      fileName: 'iconhabit',
      content: '',
      tags: ['Language', 'Platform'],
    ),
    CardData(
      title: 'Sando`s Diary',
      description: 'This is the second card description.',
      fileName: 'sando-diary',
      content: '',
      tags: ['Flutter', 'Dart', 'Platform'],
    ),
  ];

  final Map<String, Color> tagColors = {
    'Flutter': Color(0xFF027DFD),
    'Android': Color(0xFF3DDC84),
    'iOS': Color(0xFF555555),
    'Web': Colors.white,
  };

  @override
  void initState() {
    // 카드 개수만큼 hover 상태 리스트 초기화
    _isHovering = List.generate(cardList.length, (index) => false);

    _loadPosts();

    super.initState();
  }

  Future<void> _loadPosts() async {
    // JSON 파일 읽기
    final jsonString =
        await rootBundle.loadString('./project_info/projects.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // JSON 데이터를 맵으로 변환하여 파일명과 내용을 쉽게 찾도록 설정
    final Map<String, String> contentMap = {
      for (var item in jsonData)
        item['filename']: item['content'] // filename을 키로, content를 값으로 설정
    };

    // 기존 리스트 순서에 맞춰 file_name에 맞는 content 추가
    for (var card in cardList) {
      if (contentMap.containsKey(card.fileName)) {
        card.content =
            contentMap[card.fileName] ?? ''; // 파일명이 일치하는 경우 content 추가
      }
    }
  }

  Widget _projectDetail(CardData currentProject) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MarkdownWidget(
        data: currentProject.content,
        config: MarkdownConfig(configs: [
          LinkConfig(
            style: TextStyle(
              color: Colors.cyan,
              decoration: TextDecoration.underline,
            ),
            onTap: (url) {
              _launchURLInNewTab(url);
            },
          )
        ]),
      ),
    );
  }

  void _launchURLInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isShowDetail
          ? null
          : AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              forceMaterialTransparency: true,
              leading: BackButton(
                onPressed: () => setState(() {
                  isShowDetail = false;
                }),
              ),
            ),
      body: !isShowDetail
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
              double width = constraints.maxWidth;

              if (width > 700) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                      itemCount: cardList.length,
                      itemBuilder: (context, index) {
                        final cardData = cardList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  boxShadow: !_isHovering[index]
                                      ? AppShadows.customBaseBoxShadow
                                      : AppShadows.customHoverBoxShadow,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onHover: (hovering) {
                                    setState(() {
                                      _isHovering[index] = hovering;
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      currentProject = cardData;
                                      isShowDetail = true;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Placeholder(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 16,
                                          bottom: 16,
                                          right: 10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cardData.title,
                                              style: TextStyle(fontSize: 25),
                                            ),
                                            Expanded(
                                              child: Text(cardData.description),
                                            ),
                                            Row(
                                              children: List.generate(
                                                  cardData.tags.length,
                                                  (tagIndex) {
                                                String tag =
                                                    cardData.tags[tagIndex];
                                                Color tagColor =
                                                    tagColors[tag] ??
                                                        Colors.grey;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.black),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 4,
                                                        horizontal: 8,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(tag),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                      itemCount: cardList.length,
                      itemBuilder: (context, index) {
                        final cardData = cardList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: width - 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  boxShadow: !_isHovering[index]
                                      ? AppShadows.customBaseBoxShadow
                                      : AppShadows.customHoverBoxShadow,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onHover: (hovering) {
                                    setState(() {
                                      _isHovering[index] = hovering;
                                    });
                                  },
                                  onTap: () {
                                    debugPrint('Tapped on ${cardData.title}');
                                  },
                                  child: Column(
                                    children: [
                                      const Placeholder(
                                        fallbackHeight: 200,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 16,
                                          bottom: 16,
                                          right: 10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cardData.title,
                                              style: TextStyle(fontSize: 25),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: List.generate(
                                                  cardData.tags.length,
                                                  (tagIndex) {
                                                String tag =
                                                    cardData.tags[tagIndex];
                                                Color tagColor =
                                                    tagColors[tag] ??
                                                        Colors.grey;

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.black),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 4,
                                                        horizontal: 8,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            tag,
                                                            // style: TextStyle(
                                                            //     color: tag == "iOS"
                                                            //         ? Colors.white
                                                            //         : Colors.black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
            })
          : _projectDetail(currentProject),
    );
  }
}

class CardData {
  final String title;
  final String description;
  final String fileName;
  String content;
  final List<String> tags;

  CardData({
    required this.title,
    required this.description,
    required this.fileName,
    required this.content,
    required this.tags,
  });
}
