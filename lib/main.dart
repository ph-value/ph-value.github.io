import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sando_diary/markdownpage.dart';

import 'firebase_options.dart';

Future<void> main() async {

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
        '/markdownpage': (context) => MarkdownPage(),
      },
      home: CustomAppBarScreenTest(),
    );
  }
}

final List<int> _items = List<int>.generate(51, (int index) => index);

Widget testBody() {
  return GridView.builder(
    itemCount: _items.length,
    padding: const EdgeInsets.all(8.0),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 2.0,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
    ),
    itemBuilder: (BuildContext context, int index) {
      if (index == 0) {
        return Center(
          child: Text(
            'Scroll to see the Appbar in effect.',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
        );
      }
      return Container(
        alignment: Alignment.center,
        // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.teal,
        ),
        child: Text('Item $index'),
      );
    },
  );
}

class CustomAppBarScreenTest extends StatefulWidget {
  @override
  _CustomAppBarScreenState createState() => _CustomAppBarScreenState();
}

class _CustomAppBarScreenState extends State<CustomAppBarScreenTest> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
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

              // Positioned(
              //   // To take AppBar Size only
              //   top: 80.0,
              //   left: 20.0,
              //   right: 20.0,
              //   child: AppBar(
              //     backgroundColor: Colors.white,
              //     shadowColor: Colors.white30,
              //     scrolledUnderElevation: 0,
              //     primary: false,
              //   ),
              // ),

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
                          child: Center(child: Text("aaaa")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(1),
                        child: Container(
                          color: Colors.orange,
                          width: 80,
                          height: _selectedIndex == 1 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("aaaa")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: Container(
                          color: Colors.yellow,
                          width: 80,
                          height: _selectedIndex == 2 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("aaaa")),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: Container(
                          color: Colors.green,
                          width: 80,
                          height: _selectedIndex == 3 ? height + 40 : (height / 2) + 40,
                          child: Center(child: Text("aaaa")),
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
    return MarkdownPage();
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
