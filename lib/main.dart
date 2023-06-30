import 'dart:ui';
import 'package:besenur_project/model/current_city_data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<CurrentCityDataModel> currentWeather;
  var cityName = 'tehran';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWeather = sendRequestCurrentWeather(cityName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          backgroundColor: Colors.blue[300],
          elevation: 0,
          title: const Text('Weather Application'),
          actions: <Widget>[
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return {'Setting', 'Logout'}.map((String choice) {
                  return PopupMenuItem(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: FutureBuilder<CurrentCityDataModel>(
          future: currentWeather,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              CurrentCityDataModel? cityDataModel = snapshot.data;

              /// change DateTime Sun rise Sun set
              final formatter = DateFormat.jm();
              var sunrise = formatter.format(
                DateTime.fromMillisecondsSinceEpoch(
                    cityDataModel!.sunRise * 1000,
                    isUtc: true),
              );
              var sunset = formatter.format(
                DateTime.fromMillisecondsSinceEpoch(
                  cityDataModel.sunSet * 1000,
                  isUtc: true,
                ),
              );

              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/picBG.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text("Find"),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Entry Your City',
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          cityDataModel.cityName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          cityDataModel.description,
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: 100,
                            child: setIconForMain(
                          cityDataModel,
                        )),
                      ),
                      Text(
                        '${cityDataModel.temp}\u00B0',
                        style: const TextStyle(
                            fontSize: 60, color: Colors.black54),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Max',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                cityDataModel.tempMax.toString(),
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                width: 1, height: 40, color: Colors.white),
                          ),
                          Column(
                            children: [
                              const Text(
                                'Min',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                // ignore: prefer_interpolation_to_compose_strings
                                '${cityDataModel.tempMin}\u00B0',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                          color: Colors.grey[800],
                          height: 1,
                          width: double.infinity),
                      SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            itemBuilder: (context, pos) {
                              return const SizedBox(
                                width: 60,
                                child: Card(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                        ),
                                        child: Text(
                                          'Fri , 8pm',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.cloud,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '16' '\u00B0',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.grey[800],
                        height: 1,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Wind Speed',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${cityDataModel.windSpeed}m/s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  width: 1, height: 40, color: Colors.white),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Sunrise',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  sunrise,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  width: 1, height: 40, color: Colors.white),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Sunset',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  sunset,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  width: 1, height: 40, color: Colors.white),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Humidity',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${cityDataModel.humidity}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            } //
            return Center(
              child: Lottie.network(
                  'https://assets4.lottiefiles.com/datafiles/bEYvzB8QfV3EM9a/data.json'),
            );
          },
        ),
      ),
    );
  }

  Future<CurrentCityDataModel> sendRequestCurrentWeather(
      String cityName) async {
    var apiKey = '72be12eaa64bc339aadc4027ae95d68a';

    var response = await Dio().get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {'q': cityName, 'appid': apiKey, 'units': 'metric'},
    );
    // print(response.data);
    // print(response.statusCode);

    var dataModel = CurrentCityDataModel(
      response.data['name'],
      response.data["coord"]["lon"],
      response.data['coord']['lat'],
      response.data['weather'][0]['main'],
      response.data['weather'][0]['description'],
      response.data['main']['temp'],
      response.data['main']['temp_min'],
      response.data['main']['temp_max'],
      response.data['main']['pressure'],
      response.data['main']['humidity'],
      response.data['wind']['speed'],
      response.data['dt'],
      response.data['sys']['country'],
      response.data['sys']['sunrise'],
      response.data['sys']['sunset'],
    );
    return dataModel;
  }

  Image setIconForMain(model) {
    String description = model.description;
    if (description == "clear sky") {
      return const Image(
        image: AssetImage('assets/images/sun.png'),
      );
    } else if (description == "few clouds") {
      return const Image(
        image: AssetImage('assets/images/cloud.png'),
      );
    } else if (description == 'overcast clouds') {
      return const Image(
        image: AssetImage('assets/images/clouds.png'),
      );
    } else if (description == 'thunderstorm') {
      return const Image(
        image: AssetImage('assets/images/storm.png'),
      );
    } else if (description == 'drizzle') {
      return const Image(
        image: AssetImage('assets/images/rain.png'),
      );
    } else if (description == 'snow') {
      return const Image(
        image: AssetImage('assets/images/snowfall.png'),
      );
    }
    return const Image(
      image: AssetImage('assets/images/sun.png'),
    );
  }
}
