import 'package:flutter/material.dart';
import 'package:sando_diary/customDecoration.dart';

class Projectpage extends StatefulWidget {
  const Projectpage({super.key});

  @override
  State<Projectpage> createState() => _ProjectpageState();
}

class _ProjectpageState extends State<Projectpage> {
  bool isShowDetail = false;
  List<bool> _isHovering = [];

  final List<CardData> cardList = [
    CardData(
      title: 'Card 1',
      description: 'This is the first card description.',
      tags: ['Language', 'Platform'],
    ),
    CardData(
      title: 'Card 2',
      description: 'This is the second card description.',
      tags: ['Flutter', 'Dart', 'Platform'],
    ),
    CardData(
      title: 'Card 3',
      description: 'This is the third card description.',
      tags: ['Java', 'Android'],
    ),
    CardData(
      title: 'Card 3',
      description: 'This is the third card description.',
      tags: ['iOS', 'Android'],
    ),
    CardData(
      title: 'Card 3',
      description: 'This is the third card description.',
      tags: ['Web', 'iOS'],
    )
  ];

  final Map<String, Color> tagColors = {
    'Flutter': Color(0xFF027DFD),
    'Android': Color(0xFF3DDC84),
    'iOS': Color(0xFF555555),
    'Web' : Colors.white,
  };

  @override
  void initState() {
    super.initState();
    // 카드 개수만큼 hover 상태 리스트 초기화
    _isHovering = List.generate(cardList.length, (index) => false);
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
              title: Text("title"),
              leading: BackButton(
                onPressed: () => setState(() {
                  isShowDetail = false;
                }),
              ),
            ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

          double width = constraints.maxWidth;

          if (width > 700) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
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
                              border: Border.all(width: 1, color: Colors.black),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
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
                                              cardData.tags.length, (tagIndex) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets.only(right: 8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF75F8AE),
                                                  borderRadius:
                                                  BorderRadius.circular(15),
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
                                                  child:
                                                  Text(cardData.tags[tagIndex]),
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
          }else{
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
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
                              border: Border.all(width: 1, color: Colors.black),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          cardData.title,
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        SizedBox(height: 8,),
                                        Row(
                                          children: List.generate(cardData.tags.length, (tagIndex) {
                                            String tag = cardData.tags[tagIndex];
                                            Color tagColor = tagColors[tag] ?? Colors.grey;

                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: tagColor,
                                                  borderRadius: BorderRadius.circular(15),
                                                  border: Border.all(width: 1, color: Colors.black),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 8,
                                                  ),
                                                  child: Text(tag,
                                                  style: TextStyle(
                                                    color: tag == "iOS" ? Colors.white : Colors.black
                                                  ),),
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

        }
      ),
    );
  }
}

class CardData {
  final String title;
  final String description;
  final List<String> tags;

  CardData({
    required this.title,
    required this.description,
    required this.tags,
  });
}
