import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        // useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String getTimeFormat(Duration d) {
  int sec = d.inSeconds % 60;
  int min = d.inMinutes;
  String ssec = sec > 9 ? sec.toString() : "0$sec";
  String smin = min > 9 ? min.toString() : "0$min";
  return "$smin:$ssec";
}

class _MyHomePageState extends State<MyHomePage> {
  final _player = AudioPlayer(playerId: "001");

  bool _isplay = false;
  String _currtime = "00:00";
  String _duration = "00:00";
  String _source = "";
  String _title = "";

  Future _play() async {
    setState(() {
      _isplay = !_isplay;
    });
    if (_source == "") return;
    if (_isplay) {
      await _player.play(AssetSource(_source));
    } else {
      await _player.pause();
    }
  }

  List items = [];

  _change(int idx) async {
    debugPrint("=> ${items[idx]['link']}");
    await _player.stop();
    
    setState(() {
      _title = items[idx]['title'];
      _source = items[idx]['link'];
      _isplay = !_isplay;
    });

    _play();
  }

  Future readJson() async {
    final String response = await rootBundle.loadString('assets/song.json');
    final data = json.decode(response);
    setState(() {
      items = data;

      _title = items[0]['title'];
      _source = items[0]['link'];
    });
  }

  @override
  void initState() {
    super.initState();

    readJson();

    _player.onDurationChanged.listen((event) {
      setState(() {
        _duration = getTimeFormat(event);
      });
    });

    _player.onPositionChanged.listen((event) {
      setState(() {
        _currtime = getTimeFormat(event);
      });
    });

    _player.onPlayerComplete.listen((event) async {
      _isplay = !_isplay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(items[index]['title']),
                      onTap: () => _change(index),
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: _play,
            child: Icon(
              _isplay ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_title),
              Text("$_currtime - $_duration"),
            ],
          )
        ],
      ),
    );
  }
}
