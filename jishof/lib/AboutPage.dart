import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        body: new ListView(
      children: <Widget>[
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            child: new Text(
              "Credits",
              style: new TextStyle(color: Colors.black87),
              textScaleFactor: 3.0,
            )),
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
            child: new Text(
                "Made using the Jisho.org API and Jim Brrend's RADKFILE and KANJIDIC2",
                style: new TextStyle(color: Colors.black54),textScaleFactor: 1.25)),
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            child: new Text(
              "To Report Bugs",
              style: new TextStyle(color: Colors.black87),
              textScaleFactor: 3.0,
            )),
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
            child: new Text(
                "To report bugs or other concerns, send an email to phikid0@gmail.com",
                style: new TextStyle(color: Colors.black54),textScaleFactor: 1.25,)),
    new Padding(
    padding: new EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),child: new Text(
          "Developers",
          style: new TextStyle(color: Colors.black87),
          textScaleFactor: 3.0,
        )),
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
            child: new Text(
                "Developed with love by Abhimanyu Singhal and Tim Toombs, 2018",
                style: new TextStyle(color: Colors.black54),textScaleFactor: 1.25)),
      ],
    ));
  }
}
