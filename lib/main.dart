import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    new MaterialApp(
      title: 'Inherited Widgets Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Inherited Widget Example'),
        ),
        body: new NamePage(),
      ),
    ),
  );
}

// "name"データを管理する遺伝ウィジェット
class NameInheritedWidget extends InheritedWidget {
  const NameInheritedWidget({
    Key key,
    this.name,
    Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final String name;

  @override
  bool updateShouldNotify(NameInheritedWidget old) {
    print('In updateShouldNotify');
    return name != old.name;
  }

  static NameInheritedWidget of(BuildContext context) {
    // １つのフィールドしかないので、ここで直接"name"データを返すことも出来る
    return context.inheritFromWidgetOfExactType(NameInheritedWidget);
  }
}

// nameデータを管理する、ステートフルウィジェット
class NamePage extends StatefulWidget {
  @override
  _NamePageState createState() => new _NamePageState();
}

// HTTPを介してnameデータをフェッチするステート
class _NamePageState extends State<NamePage> {
  String name = 'Placeholder';

  // HTTP通信で非同期に"name"を取得する
  _get() async {
    var res = await http.get('https://jsonplaceholder.typicode.com/users');
    var name = json.decode(res.body)[0]['name'];
    setState(() => this.name = name);
  }

  // ステートの初期化
  @override
  void initState() {
    super.initState();
    _get();
  }

  @override
  Widget build(BuildContext context) {
    return new NameInheritedWidget(
      name: name,
      child: const IntermediateWidget(),
    );
  }
}

// 中間Widgetがwidgetツリーの下に変更を伝搬する方法を示す
class IntermediateWidget extends StatelessWidget {
  // const付きのコンストラクタにすることで、キャッシュ可能なwidgetを作ることが出来る
  const IntermediateWidget();

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(10.0),
        child: const NameWidget(),
      ),
    );
  }
}

class NameWidget extends StatelessWidget {
  const NameWidget();

  @override
  Widget build(BuildContext context) {
    final inheritedWidget = NameInheritedWidget.of(context);
    return new Text(
      inheritedWidget.name,
      style: Theme.of(context).textTheme.display1,
    );
  }
}
