import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class GifPage extends StatelessWidget {
  const GifPage({super.key, required this.gifData});

  final Map gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gifData['title']),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              share();
            },
            icon: Icon(Icons.share),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Image.network(gifData['images']['fixed_height']['url'])),
    );
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Compartilhar Gif',
        text: 'Compartilhe com quem desejar essa gif...',
        linkUrl: gifData["images"]["fixed_height"]["url"],
        chooserTitle: gifData["title"]);
  }
}
