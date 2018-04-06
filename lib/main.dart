import 'dart:async';
import 'package:flutter/material.dart';
import './places.dart';

const lat = 47.706406;
const long = -122.207548;

void main() => runApp(new MyApp());

class FavInheritedWidget extends InheritedWidget {
  final Map<Place, RestaurantType> _favList;

  FavInheritedWidget(this._favList, child) : super(child: child);

  static FavInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(FavInheritedWidget);
  }

  @override
  bool updateShouldNotify(FavInheritedWidget oldWidget) {
    return _favList != oldWidget._favList;
  }
}

class MyApp extends StatelessWidget {
  final String title = 'Local Restaurants';
  final Map<Place, RestaurantType> _favList = new Map<Place, RestaurantType>();

  @override
  Widget build(BuildContext context) {
    return new FavInheritedWidget(
      _favList,
      new MaterialApp(
        title: title,
        theme: new ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: new HomeScreen(title: title),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new MainList(),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.list, color: Colors.white),
        elevation: 9.0,
        onPressed: () {
          Navigator.push(context, new MaterialPageRoute(
            builder: (context) {
              return new TransitionScreen();
            },
          ));
        },
        // backgroundColor: Colors.green,
      ),
    );
  }
}

class MainList extends StatefulWidget {
  @override
  _MainListState createState() => new _MainListState();
}

class _MainListState extends State<MainList> {
  List<Place> _places = <Place>[];

  _MainListState();

  @override
  initState() {
    super.initState();
    this.listenForPlaces();
  }

  void listenForPlaces() async {
    var stream = await getPlaces(lat, long);
    stream.listen((place) => setState(() => _places.add(place)));
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: _places.map((place) => new PlaceWidget(place)).toList(),
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
  RestaurantType restaurantType;
  _PlaceWidgetState(this._place);

  @override
  Widget build(BuildContext context) {
    // checks favorite state
    final favInheritedWidget = FavInheritedWidget.of(context);
    Map<Place, RestaurantType> _favList = favInheritedWidget._favList;
    RestaurantType restaurantType;
    RestaurantType saveTo;

    return new ListTile(
      title: new Text(_place.name),
      subtitle:
          new Text(_place.address, style: Theme.of(context).textTheme.caption),
      leading: new CircleAvatar(
        child: new Text(_place.rating.toString()),
        backgroundColor: (restaurantType != null)
            ? Colors.green
            : Theme.of(context).primaryColor,
      ),
      onTap: () async {
        switch (await showDialog<RestaurantType>(
            context: context,
            child: new SimpleDialog(
                title: const Text('Save to...'),
                children: <Widget>[
                  new SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, RestaurantType.CHEAP);
                      },
                      child: const Text('Cheap Restaurants')),
                  new SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, RestaurantType.FAMILY);
                      },
                      child: const Text('Family-friendly Restaurants')),
                  new SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, RestaurantType.SPECIALTY);
                      },
                      child: const Text('Specialty Restaurants')),
                  new SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, RestaurantType.MISC);
                      },
                      child: const Text('Miscellaneous')),
                      new Divider(color: Colors.black),
                      new SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: const Text('Remove from lists'),
                      )
                ]))) {
          case RestaurantType.CHEAP:
            saveTo = RestaurantType.CHEAP;
            break;
          case RestaurantType.FAMILY:
            saveTo = RestaurantType.FAMILY;
            break;
          case RestaurantType.SPECIALTY:
            saveTo = RestaurantType.SPECIALTY;
            break;
          case RestaurantType.MISC:
            saveTo = RestaurantType.MISC;
            break;
          default:
            saveTo = null;
        }

        setState(() {
          restaurantType = saveTo;
          _favList[_place] = restaurantType;
        });

        final snackBar = new SnackBar(
            content: new Text("Tapped on " + _place.name));
        Scaffold.of(context).showSnackBar(snackBar);
      },
      trailing: (_favList[_place] != null)
          ? new Icon(Icons.favorite, color: Colors.red)
          : new Icon(Icons.favorite_border),
    );
  }
}

class TransitionScreen extends StatelessWidget {
  final Map<RestaurantType, int> _catalogue = new Map<RestaurantType, int>();

  TransitionScreen();

  @override
  Widget build(BuildContext context) {
    final favInheritedWidget = FavInheritedWidget.of(context);
    Map<Place, RestaurantType> _favList = favInheritedWidget._favList;
    for (var place in _favList.keys) {
      if (_favList[place] != null) {
        _catalogue[_favList[place]] == null
            ? _catalogue[_favList[place]] = 1
            : _catalogue[_favList[place]]++;
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Saved Lists'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.create),
            onPressed: null,
          )
        ],
      ),
      body: new ListView(
        children: buildList(_catalogue, context),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  List<Widget> buildList(
      Map<RestaurantType, int> catalogue, BuildContext context) {
    List<ListTile> list = new List<ListTile>();

    for (var rtype in catalogue.keys) {
      list.add(new ListTile(
        title: new Text(ListScreen.getTitle(rtype)),
        subtitle: new Text(
          catalogue[rtype].toString() + " places",
          style: Theme.of(context).textTheme.caption,
        ),
        leading: new Icon(ListScreen.getIcon(rtype)),
        onTap: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new ListScreen(rtype, ListScreen.getTitle(rtype)))),
      ));
    }
    return list;
  }
}

enum RestaurantType { CHEAP, FAMILY, SPECIALTY, MISC }

class ListScreen extends StatelessWidget {
  final List<Place> _favPlaces = <Place>[];
  final RestaurantType listType;
  final String _listTitle;

  static String getTitle(RestaurantType listType) {
    String name;
    switch (listType) {
      case RestaurantType.CHEAP:
        name = "Affordable Restaurants";
        break;
      case RestaurantType.FAMILY:
        name = "Family-friendly Restaurants";
        break;
      case RestaurantType.SPECIALTY:
        name = "Speciality Restaurants";
        break;
      default:
        name = "Favorite Restaurants";
        break;
    }
    return name;
  }

  ListScreen(this.listType, this._listTitle);

  @override
  Widget build(BuildContext context) {
    final favInheritedWidget = FavInheritedWidget.of(context);
    Map<Place, RestaurantType> _favList = favInheritedWidget._favList;

    for (var _place in _favList.keys) {
      if (_favList[_place] == listType) {
        _favPlaces.add(_place);
      }
    }
    return new Scaffold(
      appBar: new AppBar(actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.edit),
          onPressed: null,
        )
      ], title: new Text(_listTitle)),
      body: new ListView(
        children: _favPlaces.map((place) => new PlaceWidget(place)).toList(),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  static IconData getIcon(RestaurantType rtype) {
    IconData icon;
    switch (rtype) {
      case RestaurantType.CHEAP:
        icon = Icons.attach_money;
        break;
      case RestaurantType.FAMILY:
        icon = Icons.group;
        break;
      case RestaurantType.SPECIALTY:
        icon = Icons.restaurant_menu;
        break;
      default:
        icon = Icons.favorite;
        break;
    }
    return icon;
  }
}
