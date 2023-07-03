import 'dart:async';
import 'dart:ui';
import 'package:besenur_project/model/current_city_data_model.dart';
import 'package:besenur_project/model/forecastdays_model.dart';
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
  late StreamController<List<ForecastDaysModel>> streamForecastDaysController;

  var cityName = 'tehran';

  var lat;

  var lon;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWeather = sendRequestCurrentWeather(cityName);
    streamForecastDaysController = StreamController<List<ForecastDaysModel>>();
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder<CurrentCityDataModel>(
            future: currentWeather,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                CurrentCityDataModel? cityDataModel = snapshot.data;

                /// Send Request 7 Days
                sendRequest7DaysForecast(lat, lon);

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
                                  onPressed: () {
                                    setState(
                                      () {
                                        currentWeather =
                                            sendRequestCurrentWeather(
                                          controller.text
                                        );
                                      },
                                    );
                                  },
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
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
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
                                  width: 1, height: 40, color: Colors.black),
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
                            child: StreamBuilder<List<ForecastDaysModel>>(
                              stream: streamForecastDaysController.stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<ForecastDaysModel>? forecastDays =
                                      snapshot.data;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 6,
                                    itemBuilder:
                                        (BuildContext context, int pos) {
                                      return listViewItems(
                                          forecastDays![pos + 1]);
                                    },
                                  );
                                } //
                                else {
                                  return Center(
                                    child: Lottie.network(
                                      'https://assets4.lottiefiles.com/datafiles/bEYvzB8QfV3EM9a/data.json',
                                    ),
                                  );
                                }
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
      ),
    );
  }

  SizedBox listViewItems(ForecastDaysModel forecastDay) {
    return SizedBox(
      width: 60,
      child: Card(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: Text(
                forecastDay.dataTime,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(child: setIconForMain(forecastDay)),
            ),
            Text(
              '${forecastDay.temp.round()}\u00B0',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image setIconForMain(model) {
    String description = model.description;
    if (description == "clear sky") {
      return const Image(
        image: AssetImage('assets/images/sun.png'),
      );
    } else if (description == "few clouds") {
      return const Image(
        image: AssetImage('assets/images/clouds.png'),
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

  Future<CurrentCityDataModel> sendRequestCurrentWeather(
      String cityName) async {
    var apiKey = '72be12eaa64bc339aadc4027ae95d68a';

    var response = await Dio().get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {'q': cityName, 'appid': apiKey, 'units': 'metric'},
    );

    // Get Lan & Lon City
    lon = response.data["coord"]["lon"];
    lat = response.data['coord']['lat'];
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

  void sendRequest7DaysForecast(lat, lon) async {
    List<ForecastDaysModel> listDays = [];
    var apiKey = '72be12eaa64bc339aadc4027ae95d68a';

    try {
      var response = await Dio().get(
        'https://api.openweathermap.org/data/3.0/onecall',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'exclude': 'minutely,hourly',
          'appid': apiKey,
          'units': 'metric'
        },
      );

      final formatter = DateFormat.MMMd();

      for (int i = 0; i < 8; i++) {
        var model = response.data['daily'][i];
        var dt = formatter.format(
          DateTime.fromMillisecondsSinceEpoch(
            model['dt'] * 100,
            isUtc: true,
          ),
        );
        ForecastDaysModel forecastDaysModel = ForecastDaysModel(
          dt,
          model['temp']['day'],
          model['weather'][0]['main'],
          model['weather'][0]['description'],
        );
        listDays.add(forecastDaysModel);
      }
      streamForecastDaysController.add(listDays);
    } on DioException catch (e) {
      print(e.response!.statusCode);
      print(e.message);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در انتقال اطلاعات'),
        ),
      );
    }
  }
}
