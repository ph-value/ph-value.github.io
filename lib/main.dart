import 'package:flutter/material.dart';
import 'package:sando_diary/BlogPostList.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print('Failed to sign in anonymously: $e');
  }
}

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await signInAnonymously();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        // '/markdownpage': (context) => MarkdownPage(data: '',),
      },
      home: CustomAppBarScreenTest(),
    );
  }
}

class CustomAppBarScreenTest extends StatefulWidget {
  @override
  _CustomAppBarScreenState createState() => _CustomAppBarScreenState();
}

class _CustomAppBarScreenState extends State<CustomAppBarScreenTest> {
  int _selectedIndex = 0;
  String _seletedMenu = "Posts";

  static final List<Widget> _widgetOptions = <Widget>[
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];

  void _onItemTapped(int index, String menu) {
    setState(() {
      _selectedIndex = index;
      _seletedMenu = menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    _appBar(height) => PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                color: const Color(0xFF30383f),
                height: height + 55,
                width: MediaQuery.of(context).size.width,
                // Background
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Text(
                    "Sando`s Diary",
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),

              Container(), // Required some widget in between to float AppBar

              Positioned(
                  top: 80.0,
                  left: 20.0,
                  right: 20.0,
                  child: Container(
                    color: const Color(0xFF30383f),
                    height: height / 2,
                  )),

              Positioned(
                  top: 40.0,
                  left: 20.0,
                  right: 20.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _onItemTapped(0, "Posts"),
                        child: Container(
                          width: 80,
                          height: _selectedIndex == 0
                              ? height + 40
                              : (height / 2) + 40,
                          child: Center(
                            child: Text("Posts"),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9581f5),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(1, "Projects"),
                        child: Container(
                          width: 80,
                          height: _selectedIndex == 1
                              ? height + 40
                              : (height / 2) + 40,
                          child: Center(child: Text("Projects")),
                          decoration: BoxDecoration(
                            color: const Color(0xFF75F8AE),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(2, "About"),
                        child: Container(
                          width: 80,
                          height: _selectedIndex == 2
                              ? height + 40
                              : (height / 2) + 40,
                          child: Center(child: Text("About")),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F970),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(3, "GuestBook"),
                        child: Container(
                          width: 80,
                          height: _selectedIndex == 3
                              ? height + 40
                              : (height / 2) + 40,
                          child: Center(child: Text("GuestBook")),
                          decoration: BoxDecoration(
                            color: const Color(0xFF99D6F9),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        );

    return Scaffold(
      // body: testBody(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 화면의 너비 정보를 가져옴
          double width = constraints.maxWidth;

          if (width > 600) {
            // 큰 화면에서는 AppBar만 사용
            return Scaffold(
              appBar: _appBar(AppBar().preferredSize.height),
              body: IndexedStack(
                index: _selectedIndex,
                children: _widgetOptions,
              ),
            );
          } else {
            // 작은 화면에서는 Drawer를 사용
            return Scaffold(
              appBar: AppBar(
                title: Text(_seletedMenu),
              ),
              endDrawer: Drawer(
                backgroundColor: Colors.transparent,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: Container(
                            color: const Color(0xFF30383f),
                          ),
                        ),
                      ],
                    ),
                    ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              '   Sando`s Diary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(0, "Posts");
                            Navigator.pop(context);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF9581f5),
                                border:
                                    Border.all(width: 1, color: Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Flexible(flex: 1, child: Icon(Icons.list)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(flex: 9, child: Text('Posts')),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(1, "Projects");
                            Navigator.pop(context);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF75F8AE),
                                border:
                                    Border.all(width: 1, color: Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        child: Icon(Icons.book_outlined)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(flex: 9, child: Text('Projects')),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(2, "About");
                            Navigator.pop(context);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1F970),
                                border:
                                    Border.all(width: 1, color: Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        child: Icon(Icons.account_box_outlined)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(flex: 9, child: Text('About')),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(3, "GuestBook");
                            Navigator.pop(context);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF99D6F9),
                                border:
                                    Border.all(width: 1, color: Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Flexible(flex: 1, child: Icon(Icons.edit_outlined)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(flex: 9, child: Text('GuestBook')),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              body: IndexedStack(
                index: _selectedIndex,
                children: _widgetOptions,
              ),
            );
          }
        },
        // body: IndexedStack(
        //   index: _selectedIndex,
        //   children: _widgetOptions,
        // ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return MarkdownPage(data: '');
    return BlogPostList();
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 2',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 3',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 4',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/markdownpage');
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                Container(
                    color: Colors.red, height: 100, width: double.infinity),
                Container(
                    color: Colors.blue, height: 100, width: double.infinity),
              ],
            );
          } else {
            return Row(
              children: [
                Container(
                    color: Colors.red,
                    height: 100,
                    width: constraints.maxWidth / 2),
                Container(
                    color: Colors.blue,
                    height: 100,
                    width: constraints.maxWidth / 2),
              ],
            );
          }
        },
      ),
    );
  }
}
