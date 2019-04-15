import 'package:flutter/material.dart';
//import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());



class Post {
  String title;
  int price;
  String description;

//   constructor
   Post (String title, int price, String description ) {
     this.title = title;
     this.price = price;
     this.description = description;
   }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final wordPair = new WordPair.random(); deleted
    return new MaterialApp(
      title: 'Hyper Garage Sale',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: BrowsePost(),
    );
  }
}

class BrowsePost extends StatefulWidget {
  @override
  _BrowsePostState createState() => _BrowsePostState();
}

class _BrowsePostState extends State<BrowsePost> {

  Choice _selectedChoice = choices[0]; // The app's "state".
   List<Post> _suggestions = new List<Post>();

  final Set<Post> _saved = new Set<Post>();
  final TextStyle _biggerFont = const TextStyle(fontSize:18.0);

  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Hyper Garage Sale',
              textAlign: TextAlign.right,
            ),
            actions: <Widget>[
              //action buttons:
//              browse:
              IconButton(
                icon: Icon(choices[0].icon),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BrowsePost()),
                  );
                },
              ),
//                  Post:
              IconButton(
                icon: Icon(choices[1].icon),
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewPost()),
                    );
                },
              ),
              PopupMenuButton<Choice>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return choices.skip(2).map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: _buildSuggestions(),
        )
    );
  }
  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          Post dummy1 = new Post('bike', 100, 'brand new');
          Post dummy2 = new Post('Drone', 500, 'good condition');
          Post dummy3 = new Post('boat', 2000, 'regular used');
          
          _suggestions.add(dummy1);
          _suggestions.add(dummy2);
          _suggestions.add(dummy3);

          print(_suggestions.length);

          final int index = i ~/ (1);

          return _buildRow(_suggestions[i]);

        }
    );
  }

  Widget _buildRow(Post pair) {
    final bool alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        pair.title,
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite: Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          }else {
            _saved.add(pair);
          }
        });
      },
    );
  }
}




//==========new post page=============
class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {

  Choice _selectedChoice = choices[0]; // The app's "state".

  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'What is in your garage? ' ,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              //action buttons:
              IconButton(
                icon: Icon(choices[4].icon),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BrowsePost()),
                    );
                  },
              ),
            ],
          ),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter title of the item'),
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter price'),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter details',
                    contentPadding: const EdgeInsets.only(top: 10.0, bottom: 400.0),
                  ),
                ),
                // button at the end;
                Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 12),
                    child: Container(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SnackBarPage(),
                        )))
              ],
            ),
          ),
        )
    );

  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Browse', icon: Icons.explore),
  const Choice(title: 'Post', icon: Icons.launch),
  const Choice(title: 'Home', icon: Icons.home),
  const Choice(title: 'Setting', icon: Icons.settings),
  const Choice(title: 'Cancel', icon: Icons.clear),
];



class SnackBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: RaisedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: Text('Submitted!'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Some code to undo the change!
              },
            ),
          );

          // Find the Scaffold in the Widget tree and use it to show a SnackBar!
          Scaffold.of(context).showSnackBar(snackBar);
        },
        textColor: Colors.white,
        color: Colors.blue,
        child: Text('POST'),
      ),
    );
  }
}
