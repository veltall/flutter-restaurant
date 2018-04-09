import 'dart:async';
import 'package:flutter/material.dart';
import './places.dart';
import 'package:location/location.dart';

const String _kAsset0 = 'shrine/vendors/zach.jpg';
const String _kAsset1 = 'shrine/vendors/16c477b.jpg';
const String _kAsset2 = 'shrine/vendors/sandra-adams.jpg';
const String _kGalleryAssetsPackage = 'flutter_gallery_assets';
var _lat = 47.706406;
var _lng = -122.207548;

// TODO: refactor code into multiple files
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

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({this.title});

  @override
  _HomeScreenState createState() => new _HomeScreenState(title: title);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final String title;
  static const List<String> _drawerContents = const <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;
  bool _showDrawerContents = true;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _HomeScreenState({Key key, this.title});

  // refresh app
  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 3), () {
      completer.complete(null);
    });

    return completer.future.then((_) {
      // _scaffoldKey.currentState?.showSnackBar(new SnackBar(    // optional snackbar report
      //     content: const Text('Refresh complete'),
      //     action: new SnackBarAction(
      //         label: 'RETRY',
      //         onPressed: () {
      //           _refreshIndicatorKey.currentState.show();
      //         })));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(title),
      ),
      drawer: new Drawer(
          child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: const Text('Zach Widget'),
            accountEmail: const Text('zach.widget@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: const AssetImage(
                _kAsset0,
                package: _kGalleryAssetsPackage,
              ),
            ),
            otherAccountsPictures: <Widget>[
              new GestureDetector(
                onTap: () {
                  _onOtherAccountsTap(context);
                },
                child: new Semantics(
                  label: 'Switch to Account B',
                  child: const CircleAvatar(
                    backgroundImage: const AssetImage(
                      _kAsset1,
                      package: _kGalleryAssetsPackage,
                    ),
                  ),
                ),
              ),
              new GestureDetector(
                onTap: () {
                  _onOtherAccountsTap(context);
                },
                child: new Semantics(
                  label: 'Switch to Account C',
                  child: const CircleAvatar(
                    backgroundImage: const AssetImage(
                      _kAsset2,
                      package: _kGalleryAssetsPackage,
                    ),
                  ),
                ),
              ),
            ],
            margin: EdgeInsets.zero,
            onDetailsPressed: () {
              _showDrawerContents = !_showDrawerContents;
              if (_showDrawerContents)
                _controller.reverse();
              else
                _controller.forward();
            },
          ),
          new MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: new Expanded(
              child: new ListView(
                padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      // The initial contents of the drawer.
                      new FadeTransition(
                        opacity: _drawerContentsOpacity,
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _drawerContents.map((String id) {
                            return new ListTile(
                              leading: new CircleAvatar(
                                child: new Text(id),
                              ),
                              title: (id == 'A')
                                  ? new Text('Nearby Restaurants')
                                  : new Text('Nearby Establishment Type $id'),
                              onTap: null,
                            );
                          }).toList(),
                        ),
                      ),
                      // The drawer's "details" view.
                      new SlideTransition(
                        position: _drawerDetailsPosition,
                        child: new FadeTransition(
                          opacity: new ReverseAnimation(_drawerContentsOpacity),
                          child: new Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              new ListTile(
                                leading: const Icon(Icons.add),
                                title: const Text('Add account'),
                                onTap: null,
                              ),
                              new ListTile(
                                leading: const Icon(Icons.settings),
                                title: const Text('Manage accounts'),
                                onTap: null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
      body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: new MainList()),
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
      ),
    );
  }

  void _onOtherAccountsTap(BuildContext context) {
    showDialog<Null>(
      context: context,
      child: new AlertDialog(
        title: const Text('Account switching not implemented.'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// TODO: this is a todo
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
    var currentLocation = <String, double>{};
    var location = new Location();

    try {
      currentLocation = await location.getLocation;
    } on Exception catch (e) {
      currentLocation = null;
      print('location error: ' + e.toString());
    }

    if (currentLocation != null) {
      _lat = currentLocation["latitude"];
      _lng = currentLocation["longitude"];
    }

    var stream = await getPlaces(_lat, _lng);
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
    return new _PlaceWidgetState();
  }

  final Place place;
  PlaceWidget(this.place, {Key key}) : super(key: key);
}

class _PlaceWidgetState extends State<PlaceWidget> {
  RestaurantType restaurantType;

  @override
  Widget build(BuildContext context) {
    // checks favorite state
    final favInheritedWidget = FavInheritedWidget.of(context);
    Map<Place, RestaurantType> _favList = favInheritedWidget._favList;
    RestaurantType dialogRes;
    final Place _place = widget.place;

    return new ListTile(
      title: new Text(_place.name),
      subtitle:
          new Text(_place.address, style: Theme.of(context).textTheme.caption),
      leading: new CircleAvatar(
        child: new Text(_place.rating.toString()),
        backgroundColor: (_favList[_place] != null)
            ? Theme.of(context).highlightColor
            : Theme.of(context).primaryColor,
      ),
      onTap: () async {
        switch (await showDialog<RestaurantType>(
            context: context,
            child: new SimpleDialog(
                title: new Text('Save to...',
                    style: Theme.of(context).textTheme.headline),
                children: <Widget>[
                  new ListTile(
                      onTap: () {
                        Navigator.pop(context, RestaurantType.CHEAP);
                      },
                      leading:
                          new Icon(ListScreen.getIcon(RestaurantType.CHEAP)),
                      title: const Text('Affordable')),
                  new ListTile(
                      onTap: () {
                        Navigator.pop(context, RestaurantType.FAMILY);
                      },
                      leading:
                          new Icon(ListScreen.getIcon(RestaurantType.FAMILY)),
                      title: const Text('Family-friendly')),
                  new ListTile(
                      onTap: () {
                        Navigator.pop(context, RestaurantType.SPECIALTY);
                      },
                      leading: new Icon(
                          ListScreen.getIcon(RestaurantType.SPECIALTY)),
                      title: const Text('Specialty')),
                  new ListTile(
                      onTap: () {
                        Navigator.pop(context, RestaurantType.MISC);
                      },
                      leading:
                          new Icon(ListScreen.getIcon(RestaurantType.MISC)),
                      title: const Text('Miscellaneous')),
                  new Divider(color: Colors.black),
                  new ListTile(
                    onTap: () {
                      Navigator.pop(context, null);
                    },
                    leading: new Icon(Icons.delete),
                    title: const Text('Remove from lists'),
                  )
                ]))) {
          case RestaurantType.CHEAP:
            dialogRes = RestaurantType.CHEAP;
            break;
          case RestaurantType.FAMILY:
            dialogRes = RestaurantType.FAMILY;
            break;
          case RestaurantType.SPECIALTY:
            dialogRes = RestaurantType.SPECIALTY;
            break;
          case RestaurantType.MISC:
            dialogRes = RestaurantType.MISC;
            break;
          default:
            dialogRes = null;
        }

        setState(() {
          _favList[_place] = dialogRes;
        });
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
      list.add(
        new ListTile(
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
                      new ListScreen(rtype, ListScreen.getTitle(rtype)),
                ),
              ),
        ),
      );
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
        name = "Affordable";
        break;
      case RestaurantType.FAMILY:
        name = "Family-frienly";
        break;
      case RestaurantType.SPECIALTY:
        name = "Specialty";
        break;
      default:
        name = "Favorite";
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
      appBar: new AppBar(
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: null,
          )
        ],
        title: new Text(_listTitle),
      ),
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
