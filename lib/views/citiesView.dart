import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:meteo/controllers/BDController.dart';
import 'package:meteo/controllers/weatherController.dart';
import 'package:meteo/views/searchView.dart';
import 'searchView.dart';

class CitiesView extends StatefulWidget {
  CitiesView({this.locationWeather});

  final locationWeather;

  @override
  CitiesViewState createState() => CitiesViewState();
}

class CitiesViewState extends State<CitiesView> {
  Weather weather = Weather();
  BDController bd = BDController();

  String? selectedCity;
  Map<int, String> citiesMap = Map();
  late int temperature;
  late String weatherIcon;
  late String cityName;
  late String weatherMessage;
  bool hintContentCity = false;

  @override
  void initState() {
    super.initState();
    reloadList(context);
    //actualizo los datos de la vista con los datos de la posicion en al que me encuentro que obtengo en la loadView
    updateView(widget.locationWeather);
    bd.readBDToMap();
  }

  void updateView(dynamic weatherData) {
    setState(() {
      //si la llamada a la api da error visualizo
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = 'Error';
        weatherMessage = 'Pruebe a buscar datos';
        cityName = 'otra ciudad';
        return;
      }
      //si la llamada a la api es correcta paso los datos del objeto deserializado a las variables
      num temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      //el id condition es un valor que me va de 0 a 804 y me indica la condicicion metereorogiga
      var condition = weatherData['weather'][0]['id'];
      //weatherIcon de tipo String contiene un icono con la condicion metereológica
      weatherIcon = weather.getWeatherIcon(condition);
      //weaterMessage tiene un mensaje personalizado según la temperatura
      weatherMessage = weather.getMessage(temperature);
      cityName = weatherData['name'];
    });
  }

  Future<String> reloadList(BuildContext context) async {
    citiesMap = await bd.readBDToMap();
    return "Consulta";
  }

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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      //datos deserializados de la ubicación actual
                      var weatherData = await Weather().getLocationWeather();
                      print("datos ubicacion actual");
                      print(weatherData);
                      //paso a la ventana de busqueda
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SearchView(
                          locationWeather: weatherData,
                        );
                      }));
                    },
                    child: Icon(
                      Icons.search,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
              Container(
                  height: 75,
                  margin:
                      EdgeInsets.only(top: 30, right: 30, bottom: 0, left: 30),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              if (hintContentCity == false) {
                                print('esta borrando el hint de seleccione');
                                showDialog(
                                    context: context,
                                    builder: (_) => NetworkGiffyDialog(
                                          image: Image.asset(
                                            'images/ray.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text('Seleccione una ciudad',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600)),
                                          description: Text(
                                            'Debe seleccionar una ciudad de la lista para posteriormente borrarla de favoritos',
                                            textAlign: TextAlign.center,
                                          ),
                                          entryAnimation: EntryAnimation.TOP,
                                          buttonRadius: 50,
                                          onOkButtonPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          buttonOkColor: Colors.blue,
                                          onlyOkButton: true,
                                        ));
                              } else {
                                //if (citiesList!.length > 1) {
                                if (citiesMap.length > 1) {
                                  //borrar ciudad de la bd
                                  await bd.deleteCity(cityName);
                                  //recargo la lista de ciudades
                                  await reloadList(context);

                                  showDialog(
                                      context: context,
                                      builder: (_) => NetworkGiffyDialog(
                                            image: Image.asset(
                                              'images/delete.gif',
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(
                                                'Se ha borrado $cityName de favoritos',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 22.0,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            entryAnimation: EntryAnimation.TOP,
                                            buttonRadius: 50,
                                            onOkButtonPressed: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          super.widget));
                                            },
                                            buttonOkColor: Colors.blue,
                                            onlyOkButton: true,
                                          ));
                                  print(
                                      'borrar $cityName de la bd y actualizar items de dropdownbutton y el mapa $citiesMap');
                                } else {
                                  print(
                                      "no puede dejar la lista de favoritos vacía");
                                  showDialog(
                                      context: context,
                                      builder: (_) => NetworkGiffyDialog(
                                            image: Image.asset(
                                              'images/error.gif',
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(
                                                'Solo tiene esta ciudad en favoritos',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 22.0,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            description: Text(
                                              'Al menos debe dejar una ciudad como favorita para poder hacer la seleccion',
                                              textAlign: TextAlign.center,
                                            ),
                                            entryAnimation: EntryAnimation.TOP,
                                            buttonRadius: 50,
                                            onOkButtonPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            buttonOkColor: Colors.blue,
                                            onlyOkButton: true,
                                          ));
                                }
                              }
                            },
                            child: Icon(
                              Icons.delete,
                              size: 20.0,
                            ),
                          ),
                          FutureBuilder(
                              future: reloadList(context),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DropdownButton<String>(
                                    value: selectedCity,
                                    hint: new Text("Seleccione ciudad"),
                                    items: citiesMap.values
                                        .map((String city) =>
                                            DropdownMenuItem<String>(
                                                value: city,
                                                child: Text(
                                                  city,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    color: Colors.white,
                                                  ),
                                                )))
                                        .toList(),
                                    onChanged: (city) async {
                                      setState(() {
                                        selectedCity = city;
                                        //indico que el hint tiene el nombre de una ciudad en vez de el texto de bienvenida
                                        hintContentCity = true;
                                      });
                                      //paso a currentCity los datos de la ciudad seleccionada para que me recarge la vista
                                      String? currentCity = selectedCity;
                                      //botón que me devuelve los datos del lugar de la caja de texto
                                      var weatherData = await weather
                                          .getCityWeather(currentCity!);
                                      //recarga los datos en la vista
                                      updateView(weatherData);
                                    },
                                    elevation: 10,
                                    dropdownColor: Colors.lightBlue[100],
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.orange),
                                    ),
                                  );
                                }
                              })
                        ],
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 30.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      '$temperature°',
                      style: TextStyle(
                        fontFamily: 'Spartan MB',
                        fontSize: 100.0,
                      ),
                    ),
                    Text(
                      weatherIcon,
                      style: TextStyle(
                        fontSize: 100.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 15.0, top: 30.0),
                  child: Text(
                    '$weatherMessage en $cityName',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Spartan MB',
                      fontSize: 50.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
