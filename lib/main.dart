import 'package:flutter/material.dart';
// import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Record.dart';

void main() => runApp(MyApp());



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

  Choice _selectedChoice = choices[0]; //  The app's "state".

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
          body: _buildBody(context),
        )
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.title),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.title),
          trailing: Text('\$ ' + record.votes.toString() ),

//            onTap to be the Post page
//          onTap: () => Firestore.instance.runTransaction((transaction) async {
//            final freshSnapshot = await transaction.get(record.reference);
//            final fresh = Record.fromSnapshot(freshSnapshot);
//
//            await transaction
//                .update(record.reference, {'price': fresh.votes + 1});
//          }),
        ),
      ),
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
  const Choice(title: 'Post', icon: Icons.add),
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
