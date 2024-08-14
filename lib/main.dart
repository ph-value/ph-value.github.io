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

  static final List<Widget> _widgetOptions = <Widget>[
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
                color: Theme.of(context).primaryColor,
                height: height + 55,
                width: MediaQuery.of(context).size.width,
                // Background
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Text(
                    "Home",
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
                    color: Theme.of(context).primaryColor,
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
                        onTap: () => _onItemTapped(0),
                        child: Container(
                          color: Colors.purple,
                          width: 80,
                          height: _selectedIndex == 0 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("Posts")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(1),
                        child: Container(
                          color: Colors.orange,
                          width: 80,
                          height: _selectedIndex == 1 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("Projects")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: Container(
                          color: Colors.yellow,
                          width: 80,
                          height: _selectedIndex == 2 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("About")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: Container(
                          color: Colors.green,
                          width: 80,
                          height: _selectedIndex == 3 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("GuestBook")),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        );

    return Scaffold(
      appBar: _appBar(AppBar().preferredSize.height),
      // body: testBody(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
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
