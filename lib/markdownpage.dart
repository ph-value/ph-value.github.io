import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/services.dart' show rootBundle;

class MarkdownPage extends StatelessWidget {
  // final String data;

  MarkdownPage();

  Future<String> getMarkdownFiletoString() async {
    return await rootBundle.loadString('./post/markdown_example.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Markdown File Reader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: getMarkdownFiletoString(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return MarkdownWidget(
                  data: snapshot.data! ?? 'No content',
                  config: MarkdownConfig(configs: [
                    LinkConfig(
                      style: TextStyle(
                        color: Colors.cyan,
                        decoration: TextDecoration.underline,
                      ),
                      onTap: (url) {
                        ///TODO:on tap
                      },
                    )
                  ]));
            } else {
              return Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }
}
