import 'package:flutter/material.dart';

class MyInheritedWidget extends InheritedWidget {
  final int accountId;
  final int scopeId;

  MyInheritedWidget(this.accountId, this.scopeId, child): super(child: child);
  
  static MyInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MyInheritedWidget);
  }

  @override
  bool updateShouldNotify(MyInheritedWidget old) =>
    accountId != old.accountId || scopeId != old.scopeId;
}

void main() => runApp(new MaterialApp(
  title: "testing InheritedWidget",
  home: new Scaffold(body: new MyPage(5,1)),
));

class MyPage extends StatelessWidget {
  final int accountId;
  final int scopeId;
  
  MyPage(this.accountId, this.scopeId);
  
  Widget build(BuildContext context) {
    return new MyInheritedWidget(
      accountId,
      scopeId,
      const MyWidget(),
     );
  }
}

class MyWidget extends StatelessWidget {

  const MyWidget();
  
  Widget build(BuildContext context) {
    // somewhere down the line
    final myInheritedWidget = MyInheritedWidget.of(context);
    int scopeId = myInheritedWidget.scopeId;
    int accountId = myInheritedWidget.accountId;
    print(scopeId);
    print(accountId);
    return new ListView(
      children: <Widget>[
        new MyOtherWidget(scopeId, accountId),
      ],
    );
  }
}

class MyOtherWidget extends StatelessWidget {
  final scopeId;
  final accountId;
  const MyOtherWidget(this.scopeId, this.accountId);
  
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(child: new Text('hi'),),
      title: new Text(scopeId.toString()),
      subtitle: new Text(accountId.toString()),
    );
  }
}