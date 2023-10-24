import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart';

void main() {
  runApp(MyApp());
}

class WeatherAPI {
  static const String apiKey = '25e454cfc8fc9c5d84d886fa8966f02b';

  static Future<Map<String, dynamic>> getWeather(String cityName) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (response.statusCode == 404) {
          throw Exception('La ciudad no existe');
        } else {
          throw Exception('Fallo de conexión');
        }
      }
    } catch (e) {
      throw Exception('Fallo de conexión');
    }
  }
}

class WeatherProperties {
  String name;
  dynamic value;
  IconData icon;

  WeatherProperties(this.name, this.value, this.icon);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _cityController = TextEditingController();
  List<WeatherProperties> _weatherProperties = [];

  Future<void> getWeatherData() async {
    final cityName = _cityController.text;

    try {
      final weatherData = await WeatherAPI.getWeather(cityName);

      setState(() {
        _weatherProperties = [
          WeatherProperties('Temperatura', weatherData['main']['temp'], WeatherIcons.day_sunny),
          WeatherProperties('Humedad', weatherData['main']['humidity'], WeatherIcons.raindrop),
          WeatherProperties('Velocidad viento', weatherData['wind']['speed'], WeatherIcons.wind),
          WeatherProperties('Condiciones ambientales', weatherData['weather'][0]['description'], WeatherIcons.cloudy),
        ];
      });
    } catch (e) {
      setState(() {
        _weatherProperties = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('App del clima'),
        ),
        backgroundColor: Color.fromARGB(255, 121, 206, 235),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Color.fromARGB(255, 121, 206, 235),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network('https://cdn-icons-png.flaticon.com/512/1116/1116453.png', height: 100),
                    SizedBox(height: 20),
                    Text(
                      '¡Conoce el clima de tu ciudad favorita!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Digite la ciudad',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: getWeatherData,
                      child: Text('Enviar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: _weatherProperties.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _weatherProperties.length,
                          itemBuilder: (context, index) {
                            final weatherProperty = _weatherProperties[index];

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(weatherProperty.icon, size: 32.0),
                                    Text(weatherProperty.name),
                                    Text(weatherProperty.value.toString()),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: _cityController.text.isEmpty
                              ? Text('Digite una ciudad para obtener el clima.')
                              : Text('La ciudad no existe. Intente nuevamente.'),
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
