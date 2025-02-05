import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:krishak_sathi/constant.dart';
import 'package:krishak_sathi/weather_pages/secrets.dart';
import 'package:krishak_sathi/weather_pages/hourly_forecast.dart';
import 'package:krishak_sathi/weather_pages/additional_information.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentweather();
  }

  Future getCurrentweather() async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=Bhopal,IN&APPID=$APIKey'));

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'Failed to fetch weather data: ${data['message']}';
      }
      return data;
    } catch (e) {
      throw 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCurrentweather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text(snapshot.error.toString())),
          );
        }

        final data = snapshot.data!;
        final currentTemp = data['list'][0]['main']['temp'];
        final currentTempC = (currentTemp - 273.15).toStringAsFixed(1);
        final currentSky = data['list'][1]['weather'][0]['main'];
        final currentSpeed = data['list'][1]['wind']['speed'];
        final currentHumidity = data['list'][0]['main']['humidity'];
        final currentPressure = data['list'][0]['main']['pressure'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: GobalColors.PrimaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Weather App',
              style: TextStyle(),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '$currentTempC °C',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            currentSky == 'Clouds' || currentSky == 'Rain'
                                ? Icons.cloud
                                : Icons.wb_sunny,
                            size: 50,
                            color:
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? const Color.fromARGB(255, 41, 123, 199)
                                    : Colors.amberAccent,
                          ),
                          Text(
                            currentSky,
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        data['list'].length > 30 ? 30 : data['list'].length,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      return HourlyForecastItem(
                        time: DateFormat('h a').format(time),
                        temperature: (hourlyForecast['main']['temp'] - 273.15)
                            .toStringAsFixed(1),
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.wb_sunny,
                        currentSky: currentSky,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Additional information",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformation(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: "$currentHumidity%",
                    ),
                    AdditionalInformation(
                      icon: Icons.air,
                      label: "Wind speed",
                      value: "$currentSpeed m/s",
                    ),
                    AdditionalInformation(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: "$currentPressure hPa",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
