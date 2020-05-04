import 'dart:convert';

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'package:share/share.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offset = 0;
  final _textController = TextEditingController();

  Future<Map>_getGifs() async{
    http.Response response;
    if(_search == null){
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=PO8tpmjvilenpFmuRoEpB1GIHG5H3N1C&limit=20&rating=G");
    }else{
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=PO8tpmjvilenpFmuRoEpB1GIHG5H3N1C&q=$_search&limit=19&offset=$_offset&rating=G&lang=pt");
    } 

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif")
      ),
      backgroundColor: Colors.black,
      body:Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              controller: _textController,
              onSubmitted: (text){
                if(text != ""){
                  _updateFutureBuilder(text, 0);
                }
              },
            ),
          ),
          _search != null ? Padding(
            padding: EdgeInsets.symmetric(horizontal:10.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlineButton(
                key: Key("trending"),
                highlightColor: Colors.white,
                borderSide: BorderSide(color: Colors.white),
                child: Text(
                  "Voltar para os GIF's em alta",
                  style: TextStyle(fontSize: 12.0, color: Colors.white)
                ),
                onPressed: (){
                  _textController.text = "";
                  _updateFutureBuilder(null, 0);
                },
              ),
            )
          ) : Container(),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 10.0,
                      )
                    ); 
                    break;
                  default:
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot); 
                }
              },
            )
          )
        ],
      )
    );
  }

  int _getCount(List data){
    if(_search == null){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index){
        if(_search == null || index < snapshot.data["data"].length){
          return GestureDetector(
            child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
              );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        }else{
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text("Carregar outros", style: TextStyle(color:Colors.white, fontSize: 22.0),)
                ],
              ),
              onTap: (){
                _updateFutureBuilder(_search, _offset += 20);
              },
            ),
          );
        }
      },
    );
  }
  void _updateFutureBuilder( dynamic search, int offset){
    setState(() {
      _search = search;
      _offset = offset;
    });
  }
}