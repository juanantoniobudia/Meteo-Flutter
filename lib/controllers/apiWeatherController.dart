import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiWeather {
  //paso la url de la llamada ya sea por ciudad o por localizacion en el constructor
  ApiWeather(this.url);

  final String url;
  //llamo a la api web
  Future getData() async {
    //llamo a la api y en response guardo la respuesta
    http.Response response = await http.get(url);
    //si el codigo de la respuesta guardo el json en data y lo devuelvo deserializado
    if (response.statusCode == 200) {
      String data = response.body;
      //devuelvo el objeto con los datos de la climatología
      return jsonDecode(data);
    } else { //si la respuesta no es correcta imprimo el error
      print(response.statusCode);
    }
  }
}
