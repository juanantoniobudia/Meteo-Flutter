import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meteo/models/city.dart';

class BDController {
  Future<Database> openBD() async {
    // Obtiene una referencia de la base de datos
    final database = openDatabase(
      // Establecer la ruta a la base de datos. Nota: Usando la función `join` del
      // complemento `path` es la mejor práctica para asegurar que la ruta sea correctamente
      // construida para cada plataforma asi me guarda la ruta de la bd para Android e iOS
      join(await getDatabasesPath(), 'cities_database.db'),
      // Cuando la base de datos se crea por primera vez, crea una tabla para almacenar ciudades
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tableCities(cityname TEXT PRIMARY KEY)",
          //primary key permite que la clave sea nula, index no
        );
      },
      // Establece la versión. Esto ejecuta la función onCreate y proporciona una
      // ruta para realizar actualizacones y defradaciones en la base de datos.
      version: 1,
    );
    return database;
  }

  Future<void> addCity(City city) async {
    //abro bd
    final Database db = await openBD();
    // Inserta en nombre de la ciudad en la tabla correcta. También puede especificar el
    // `conflictAlgorithm` para usar en caso de que el mismo Dog se inserte dos veces.
    // En este caso, reemplaza cualquier dato anterior. El insert pide la tabla a insertar y un mapa o diccionario con los datos
    await db.insert(
      'tableCities',
      city.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, //en caso de que exista lo reemplaza
    );
  }


  Future<Map<int, String>> readBDToMap() async {
    Map<int, String> citiesMap = Map();
    //abro bd
    final Database db = await openBD();
    //meto en una lista tipo diccionario o mapa clave valor el contenido de la tabla tableCities
    final List<Map<String, dynamic>> mapCities = await db.query('tableCities');

    //devuelvo lista tipo departamento de la coleccion maps y se la paso al array de objetos tipo string
    List<String> cities = List.generate(mapCities.length, (i) {
      return mapCities[i]["cityname"];
    });
    //convierto array list en mapa
    for (var i = 0; i < cities.length; i++) {
      citiesMap[i] = cities[i];
    }
    return citiesMap;
  }

  Future<void> deleteCity(String name) async {
    // Obtiene una referencia de la base de datos
    final Database db = await openBD();

    // Elimina el Dog de la base de datos
    await db.delete(
        'tableCities',
        // Utiliza la cláusula `where` para eliminar una ciudad específica
        where: "cityname = ?", //where: "nombre = ? and apellido = ?,
        // Pasa el nombre de la ciudad a través de whereArg para prevenir SQL injection
        whereArgs: [name] // whereArgs: [id, name]
    );
  }

   Future<List<String>> readBDToList() async {
    //abro bd
    final Database db = await openBD();
    //meto en una lista tipo diccionario o mapa clave valor el contenido de la tabla tableCities
    final List<Map<String, dynamic>> mapCities = await db.query('tableCities');

    //devuelvo lista tipo departamento de la coleccion maps y se la paso al array de objetos tipo string
    List<String> cities = List.generate(mapCities.length, (i) {
      return mapCities[i]["cityname"];
    });
    return cities;

  }


}
