class City {
  String city = "";

  City(String city) {
    this.city = city;
  }

  Map<String, dynamic> toMap() {
    return {'cityname': city};
  }
}
