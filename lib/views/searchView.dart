import 'package:flutter/material.dart';
import 'package:meteo/controllers/BDController.dart';
import 'package:meteo/controllers/weatherController.dart';
import 'citiesView.dart';
import 'package:meteo/controllers/BDController.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:meteo/models/city.dart';

class SearchView extends StatefulWidget {
  SearchView({this.locationWeather});

  final locationWeather;

  @override
  SearchViewState createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  //cargo el controlador con la lógica relacionadacon el clima
  Weather weather = Weather();
  BDController bd = BDController();
  List? arrayCities;
  late int temperature;
  late String weatherIcon;
  late String cityName;
  late String weatherMessage;

  final textBoxContoller = TextEditingController();
  final textBoxFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    //actualizo los datos de la vista con los datos de la posicion en al que me encuentro que obtengo en la loadView
    updateView(widget.locationWeather);
  }

  void updateView(dynamic weatherData) {
    setState(() {
      //si la llamada a la api da error visualizo
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = '¡Error!';
        weatherMessage = 'No disponemos de datos de ese lugar o no existe';
        cityName = '';

        return;
      } else {
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
      }
    });
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
                      //LEER BASE DE DATOS Y DESCARGO DATOS AL ARRAY LIST CITIES
                      arrayCities = await bd.readBDToList();
                      print(arrayCities);
                      if (arrayCities!.isNotEmpty) {
                        //datos deserializados de la ubicación actual
                        var weatherData = await Weather().getLocationWeather();
                        print("datos ubicacion actual");
                        print(weatherData);
                        //paso a la ventana con la lista de ciudades
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CitiesView(
                            locationWeather: weatherData,
                          );
                        }));
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) => NetworkGiffyDialog(
                                  image: Image.asset(
                                    'images/error.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text('No hay lugares favoritos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.w600)),
                                  description: Text(
                                    'Añade al menos un lugar favorito a la lista de favoritas con el boton +',
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
                    },
                    child: Icon(
                      Icons.location_city,
                      size: 50.0,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      //botón que me devuelve los datos del lugar en el que me encuentro
                      var weatherData = await weather.getLocationWeather();
                      //recarga los datos en la vista
                      updateView(weatherData);
                    },
                    child: Icon(
                      Icons.near_me,
                      size: 50.0,
                    ),
                  ),
                ],
              ),
              Container(
                  height: 75,
                  margin:
                      EdgeInsets.only(top: 30, right: 30, bottom: 0, left: 30),
                  child: TextField(
                      onSubmitted: (value) async {
                        var weatherData = await weather.getCityWeather(value);
                        //recarga los datos en la vista
                        updateView(weatherData);
                        textBoxContoller.text = "";
                      },
                      cursorColor: Colors.amber,
                      controller: textBoxContoller,
                      focusNode: textBoxFocus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                          labelText: 'Lugar',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.white)),
                          suffixIcon: IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.search),
                              onPressed: () async {
                                String nameCity = textBoxContoller.text;
                                print(nameCity);
                                //botón que me devuelve los datos del lugar de la caja de texto
                                var weatherData =
                                    await weather.getCityWeather(nameCity);
                                //recarga los datos en la vista
                                updateView(weatherData);

                                //cerrar teclado
                                final FocusScopeNode focus =
                                    FocusScope.of(context);
                                if (!focus.hasPrimaryFocus && focus.hasFocus) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }

                                textBoxContoller.text = "";
                              })))),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 30.0),
                child: Row(
                  children: <Widget>[
                    //si existe la ciudad devuelvo la temperatura
                    if (this.cityName != "")
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
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    //si existe la ciudad devuelvo el botón de agregar
                    if (this.cityName != "")
                      FlatButton(
                        onPressed: () async {
                          //botón agrega ciudad a la bd
                          City c = City(cityName);
                          bd.addCity(c); //agrego objeto tipo ciudad a la bd
                          showDialog(
                              context: context,
                              builder: (_) => NetworkGiffyDialog(
                                    image: Image.asset(
                                      'images/ok.gif',
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                        'Agregada $cityName a favoritos',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600)),
                                    entryAnimation: EntryAnimation.TOP,
                                    buttonRadius: 50,
                                    onOkButtonPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    buttonOkColor: Colors.blue,
                                    onlyOkButton: true,
                                  ));
                        },
                        child: Icon(
                          Icons.add_box,
                          size: 24.0,
                        ),
                      ),
                    Text(
                      '$cityName',
                      style: TextStyle(
                          fontFamily: 'Spartan MB',
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 15.0, top: 30.0),
                  child: Text(
                    '$weatherMessage',
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
