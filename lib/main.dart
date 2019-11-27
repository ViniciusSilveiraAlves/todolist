import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];
  final _todoController = TextEditingController();

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedId;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    child: Text("Add"),
                    textColor: Colors.white,
                    onPressed: _addToDo,
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _todoList.length,
                      itemBuilder: buildItem)),
            )
          ],
        ));
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          child: Align(
              alignment: Alignment(-0.9, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ))),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
          title: Text(_todoList[index]["title"]),
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(
              _todoList[index]["ok"] ? Icons.check : Icons.error,
              color: Colors.white,
            ),
            backgroundColor:
                _todoList[index]["ok"] ? Colors.greenAccent : Colors.redAccent,
          ),
          onChanged: (c) {
            setState(() {
              _todoList[index]["ok"] = c;
              _saveData();
            });
          }),
      onDismissed: (direction) {
        print("indexxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + index.toString());
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedId = index;

          _todoList.removeAt(index);
          _saveData();

          final snackbar = SnackBar(
            content: Text("A tarefa \"${_lastRemoved["title"]}\" foi removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _todoList.insert(index, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 4),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snackbar);
        });
      },
    );
  }

  Future<void> _refresh() async{
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _todoList.sort((a,b){
          if(a["ok"] && !b["ok"]) return 1;
          else if(!a["ok"] && b["ok"]) return -1;
          else return 0;
      });

      _saveData();

    });
  }
  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      newTodo["ok"] = false;
      _todoController.text = "";
      _todoList.add(newTodo);
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/datanew.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
