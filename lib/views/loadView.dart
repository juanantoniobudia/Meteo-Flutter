import 'package:flutter/material.dart';
import 'package:meteo/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meteo/controllers/weatherController.dart';
import 'package:meteo/views/searchView.dart';

class LoadView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadViewState();
  }
}

class LoadViewState extends State<LoadView> {
  @override
  void initState() {
    super.initState();
    //localizo los datos de la ubicacion actual y paso a la ventana principal
    getLocationData();
  }

  void getLocationData() async {
    //datos deserializados de la ubicación actual
    var weatherData = await Weather().getLocationWeather();
    print("datos ubicacion actual");
    print(weatherData);
    //paso a la ventana principal

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchView(
        locationWeather: weatherData,
      );
    }));
  }
  //visualizo un spinner en el centro hasta que me devuelva los datos del clima de la ubicación actual
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SpinKitDoubleBounce(
          color: Colors.amber,
          size: 100.0,
        ),
      ),
    );
  }
}