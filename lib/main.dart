import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:http/http.dart' as http;
import 'loader.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MaterialApp(
      home: new MyApp(),
      debugShowCheckedModeBanner: false,
    ));
  });
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      navigateAfterSeconds: new Covid19(),
      title: new Text('Covid-19 India'.toUpperCase(),
      style: new TextStyle(   
        fontSize: 30.0,
        color: Colors.black
      ),),
      image: new Image.asset('images/coronavirus.png'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 150.0,
      loaderColor: Colors.red
    );
  }
}


class Covid19 extends StatefulWidget{
  @override 
  Covid19State createState() => new Covid19State();
}


class Covid19State extends State<Covid19>{
  bool isLoading = false;
  Map data;
  List stateData;
  Map totalData;
  String lastUpdated;
  String confirmed;
  String active;
  String recovered;
  String deaths;
  String sourceText = '(API source https://www.covid19india.org)';
  String stateHeading = 'State / UT wise data';
  String helpText = '(Click on each state to see district wise data)';
  Map districtData;

  getTotalData(stateDataList){
    for(var i=0; i<stateDataList.length - 1; i+=1){
      if (stateDataList[i]['state']== 'Total'){
        return stateDataList[i];
      }
    }
  }

  Future<String> getData() async{

    this.setState(() {
      isLoading = true;
    });

    var stateResponse = await http.get(
      Uri.encodeFull("https://api.covid19india.org/data.json"),
      headers: {"Accept": "application/json"}
    );

    var districtResponse = await http.get(
      Uri.encodeFull("https://api.covid19india.org/state_district_wise.json"),
      headers: {"Accept": "application/json"}
    );

    this.setState(() {
      // State wise Data
      data = json.decode(utf8.decode(stateResponse.bodyBytes));
      stateData = data['statewise'];
      totalData = getTotalData(stateData);
      lastUpdated = totalData['lastupdatedtime'];
      confirmed = totalData['confirmed'];
      active = totalData['active'];
      recovered = totalData['recovered'];
      deaths = totalData['deaths'];
      isLoading = false;

      // State District Wise data
      districtData = json.decode(utf8.decode(districtResponse.bodyBytes));
    });
    
    return "Success";
  }

  @override
  void initState() {
    this.getData();
    super.initState();
  }

  @override 
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Covid-19 India'.toUpperCase()),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: (){
              getData();
            },
          ),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            padding: new EdgeInsets.all(10),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.only(bottom: 10),
                  child: data == null ? new Text('') : new Title(title: '${lastUpdated ?? ''}', align: TextAlign.center, size: 20,)
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: data == null ? new Text('') :  new MyCard(title: "Confirmed".toUpperCase(), value: '${confirmed ?? ''}', colour: Colors.red)
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(left: 5, right: 5),
                    ),
                    new Expanded(
                      child: data == null ? new Text('') :  new MyCard(title: "Active".toUpperCase(), value: '${active ?? ''}', colour: Colors.deepPurpleAccent)
                    ),
                  ],
                ),
                new Padding(
                  padding: new EdgeInsets.only(bottom: 10),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: data == null ? new Text('') :  new MyCard(title: "Recovered".toUpperCase(), value: '${recovered ?? ''}', colour: Colors.green)
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(left: 5, right: 5),
                    ),
                    new Expanded(
                      child: data == null ? new Text('') :  new MyCard(title: "Deaths".toUpperCase(), value: '${deaths ?? ''}', colour: Colors.blueGrey)
                    ),
                  ],
                ),
                new Padding(
                  padding: new EdgeInsets.only(bottom: 0, top: 20),
                  child: data == null ? new Text('') : new Title(title: stateHeading, align: TextAlign.center, size: 18)
                ),
                data == null ? new Text('') : new Text(
                  helpText.toUpperCase(), 
                  textAlign: TextAlign.center, 
                  style: new TextStyle(fontSize:10, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                ),
                new Expanded(child: new MyTable(colour: Colors.white ,item:  data == null ? [] : stateData, districtItem:districtData == null ? {} : districtData)),
              ],
            ),
          ),
          new Loader(isLoading),
        ],
      ),
      bottomNavigationBar: new BottomAppBar(
        child: new Text(
          sourceText.toUpperCase(), 
          textAlign: TextAlign.center, 
          style: new TextStyle(fontSize:10, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
        )
      ),
    );
  }
}


class Title extends StatelessWidget{

  Title({this.title, this.align, this.size});

  final String title;
  final TextAlign align;
  final double size;

  @override 
  Widget build(BuildContext context){
    return new Text(
      title.toUpperCase(),
      textAlign: align,
      style: new TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


class MyCard extends StatelessWidget{

  MyCard({this.title, this.value, this.colour});

  final String title;
  final String value;
  final Color colour;

  @override 
  Widget build(BuildContext context){
    return new Card(
      color: colour,
      child: new Container(
        padding: new EdgeInsets.all(10),
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5.0,
            )
          ],
          color: colour,
          borderRadius: new BorderRadius.circular(5.0),
          border: new Border.all(
            color: Colors.black.withOpacity(0.2),
            width: 0.2
          )
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(top: 5),
            ),
            new Text(title.toUpperCase(),
              style: new TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 10),
            ),
            new Text("${value ?? 0.0}",
              style: new TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MyTable extends StatelessWidget{

  MyTable({this.colour, this.item, this.districtItem});

  final Color colour;
  final List item;
  final Map districtItem;
  

  getStateDistrictData(data){
    List <Map>districtDataList = new List();
    data.forEach((k, v) {
      v['district'] = k;
      districtDataList.add(v);
    });
    return districtDataList;
  }
  

  @override 
  Widget build(BuildContext context){
    return new ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: item == null ? 0 : item.length,
      itemBuilder: (context, index){
        if (item[index]['state'] != 'Total'){
          return new GestureDetector(
            onTap: (){
              if (districtItem.containsKey(item[index]['state'])){
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => new AlertDialog(
                    title: new Text(item[index]['state'].toUpperCase()),
                    content: new Container(
                      width: 500,
                      height: 500,
                      child: new Container(
                        child: new MyDistrictTable(colour: Colors.white, item: districtItem == null ? [] : getStateDistrictData(districtItem[item[index]['state']]['districtData'])),
                      ),
                    ),
                    actions: <Widget>[
                      new OutlineButton(
                        child: new Text("Close".toUpperCase(), style: new TextStyle(color: Colors.red),),
                        highlightedBorderColor: Colors.red,
                        highlightColor: Colors.red,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ]
                  ),
                );
              }else{
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: new Text("No data found !".toUpperCase(), style: new TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w500),),
                ));

              }
            },
            child: new Container(
              margin: new EdgeInsets.all(10),
              width: double.infinity,
              height: 100.0,
              decoration: new BoxDecoration(
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                  )
                ],
                color: colour,
                borderRadius: new BorderRadius.circular(5.0),
                border: new Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 0.2
                )
              ),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new SizedBox(height: 15.0,),
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: new Text(
                      item[index]['state'].toUpperCase(),
                      style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600), 
                    ),
                  ),
                  new SizedBox(height: 14.0,),
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(item[index]['confirmed'], style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: Colors.red)),
                        new Text(item[index]['active'], style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: Colors.deepPurpleAccent)),
                        new Text(item[index]['recovered'], style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: Colors.green)),
                        new Text(item[index]['deaths'], style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ]
              ),
            ),
          );
        }
        return new Container();
      }
    );
  }
}


class MyDistrictTable extends StatelessWidget{

  MyDistrictTable({this.colour, this.item,});

  final Color colour;
  final List item;

  @override 
  Widget build(BuildContext context){
    return new ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: item == null ? 0 : item.length,
      itemBuilder: (context, index){
        return new Container(
          margin: new EdgeInsets.all(10),
          width: double.infinity,
          height: 100.0,
          decoration: new BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5.0,
              )
            ],
            color: colour,
            borderRadius: new BorderRadius.circular(5.0),
            border: new Border.all(
              color: Colors.black.withOpacity(0.5),
              width: 0.2
            )
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new SizedBox(height: 15.0,),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: new Text(
                  item[index]['district'].toUpperCase(),
                  style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600), 
                ),
              ),
              new SizedBox(height: 14.0,),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(item[index]['confirmed'].toString(), style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.red)),
                    new Text(item[index]['active'].toString(), style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.deepPurpleAccent)),
                    new Text(item[index]['recovered'].toString(), style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.green)),
                    new Text(item[index]['deaths'].toString(), style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ]
          ),
        );
      }
    );
  }
}
