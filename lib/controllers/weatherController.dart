import 'package:meteo/controllers/locationController.dart';
import 'package:meteo/controllers/apiWeatherController.dart';

const apiKey = 'ec46f9c2091c99b72708f63d0843ce0b';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';


class Weather {

  //devueldo los datos del tiempo de una ciudad en un objeto deserializado
  Future<dynamic> getCityWeather(String cityName) async {
    //creo el objeto api weather y paso al constructor de la clase que llama a la api web la url la llamada a la api por nombre de ciudad
    ApiWeather apiweather = ApiWeather(
        '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric');
    //hago la llamada a la api y en weatherData guardo la respuesta deserializada
    var weatherData = await apiweather.getData();
    //devueldo los datos del tiempo en la ubicación actual en un objeto deserializado
    return weatherData;
  }

  //devueldo los datos del tiempo en la ubicación actual en un objeto deserializado
  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();
    //creo el objeto api weather y paso al constructor de la clase que llama a la api web la url por la latitud y longitud de la ubicación actual
    ApiWeather apiweather = ApiWeather(
        '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');
    //hago la llamada a la api y en weatherData guardo la respuesta deserializada
    var weatherData = await apiweather.getData();
    //devueldo los datos del tiempo en la ubicación actual en un objeto deserializado
    return weatherData;
  }


  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 35) {
      return '¡Hidrataté!💦 Evita salir en las horas centrales del día';
    } else if (temp > 30) {
      return 'Refréscate con un helado 🍦‍️';
    }  else if (temp > 25) {
      return 'Ponte manga corta 👕️';
    } else if (temp > 20) {
      return 'Hace una temperatura ideal para un paseo 🚶‍️';
    } else if (temp > 15) {
      return 'Hace una temperatura ideal para salir a hacer deporte 🏃‍️';
    } else if (temp > 10) {
      return 'Lleva varias prendas por si acaso 👕️🧥 ' ;
    } else if (temp > 5) {
      return 'No olvides llevar chaqueta 🧥' ;
    } else if (temp > 0) {
      return 'Abrigate bien 🧣🧤' ;
    } else {
      return 'Ten cuidado porque puede helar 🥶';
    }
  }
}
