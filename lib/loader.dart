import 'package:flutter/material.dart';

class Loader extends StatelessWidget{
  final bool isLoading;
  Loader(this.isLoading);
  @override 
  Widget build(BuildContext context){
    return new Positioned(
      child: isLoading ? new Container(
        child: new Center(
          child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        color: Colors.black.withOpacity(0.6),
      ) : new Container(),
    );
  }
}
