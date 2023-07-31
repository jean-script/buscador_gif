import 'dart:convert';
import 'package:buscador_gif/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_share/flutter_share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offeset = 0;

  Future<Map> _getSearch() async {
    http.Response response;

    if (_search == null) {
      var url = Uri.http('api.giphy.com', '/v1/gifs/trending', {
        'api_key': 'rDoLZ8sJZ5r0uzlKdIG1JgaVEjwQxIAf',
        'limit': '19',
        'offset': '0',
        'rating': 'g',
        'bundle': 'messaging_non_clips'
      });
      response = await http.get(url);
    } else {
      var url = Uri.http('api.giphy.com', '/v1/gifs/search', {
        'api_key': 'rDoLZ8sJZ5r0uzlKdIG1JgaVEjwQxIAf',
        'q': '$_search',
        'limit': '19',
        'offset': '$_offeset',
        'rating': 'g',
        'lang': 'en',
        'bundle': 'messaging_non_clips'
      });
      response = await http.get(url);
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Pesquise aqui',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              setState(() {
                _search = text;
                _offeset = 0;
              });
            },
          ),
        ),
        Expanded(
            child: FutureBuilder(
          future: _getSearch(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 5.0,
                  ),
                );
              default:
                if (snapshot.hasError)
                  return Container(
                    child: Text('Houve erro na requisição'),
                  );
                else
                  return _createGitTable(context, snapshot);
            }
          },
        ))
      ]),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search!.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGitTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GifPage(gifData: snapshot.data['data'][index])),
              );
            },
            onLongPress: () {
              share(
                  snapshot.data["data"][index]["images"]["fixed_height"]["url"]
                      .toString(),
                  snapshot.data["data"][index]['title']);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 70),
                  Text(
                    'Carregar Mais...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offeset += 19;
                });
              },
            ),
          );
      },
    );
  }

  Future<void> share(String link, String title) async {
    await FlutterShare.share(
        title: 'Compartilhar Gif',
        text: 'Compartilhe com quem desejar essa gif...',
        linkUrl: link,
        chooserTitle: title);
  }
}
