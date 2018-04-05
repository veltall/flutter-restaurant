import 'dart:async';
import 'package:flutter/material.dart';
import './places.dart';

const lat = 47.706406;
const long = -122.207548;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  static Map<Place, bool> _favList = new Map<Place, bool>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Polymer Demo',
        theme: new ThemeData(
          primarySwatch: Colors.red,
        ),
        // home: new MyHomePage(title: 'Polymer Demo'),
        home: new HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Place> _places = <Place>[];

  @override
  initState() {
    super.initState();
    listenForPlaces();
  }

  void listenForPlaces() async {
    var stream = await getPlaces(lat, long);
    stream.listen((place) =>
        // _places.add(place);
        setState(() => _places.add(place)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Home'),
      ),
      body: new ListView(
        children: _places.map((place) => new PlaceWidget(place)).toList(),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.favorite, color: Colors.white),
        // onPressed: _navigateToFav(context),
        onPressed: () {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new SecondScreen()),
          );
        },
        // backgroundColor: Colors.green,
      ),
    );
  }
}

class PlaceWidget extends StatefulWidget {
  @override
  _PlaceWidgetState createState() {
    return new _PlaceWidgetState(place);
  }

  final Place place;

  PlaceWidget(this.place, {Key key}) : super(key: key);
}

class _PlaceWidgetState extends State<PlaceWidget> {
  final Place _place;
  bool favorited;

  _PlaceWidgetState(this._place);

  @override
  Widget build(BuildContext context) {
    // checks favorite state
    favorited =
        (MyApp._favList[_place] != null) ? MyApp._favList[_place] : false;

    return new ListTile(
      key: new PageStorageKey(_PlaceWidgetState),
      title: new Text(_place.name),
      subtitle:
          new Text(_place.address, style: Theme.of(context).textTheme.caption),
      leading: new CircleAvatar(
        child: new Text(_place.rating.toString()),
        backgroundColor:
            favorited ? Colors.green : Theme.of(context).primaryColor,
      ),
      trailing: new GestureDetector(
        onTap: () {
          final snackBar =
              new SnackBar(content: new Text("Tapped on " + _place.name));
          Scaffold.of(context).showSnackBar(snackBar);
          setState(() {
            favorited = !favorited;
          });
          MyApp._favList[_place] = favorited; // adding
        },
        child: favorited
            ? new Icon(Icons.favorite, color: Colors.red)
            : new Icon(Icons.favorite_border),
      ),
    );
  }
}

// @TODO: convert Second Screen to a stateful widget
class SecondScreen extends StatelessWidget {
  List<Place> _favPlaces = <Place>[];

  @override
  Widget build(BuildContext context) {
    for (var _place in MyApp._favList.keys) {
      if (MyApp._favList[_place] == true) {
        _favPlaces.add(_place);
      }
    }
    return new Scaffold(
        appBar: new AppBar(title: new Text('Supplementary Screen')),
        body: new ListView(
          children: _favPlaces.map((place) => new PlaceWidget(place)).toList(),
        ));
  }
}
