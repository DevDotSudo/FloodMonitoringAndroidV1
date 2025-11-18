import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherData {
  final String cityName;
  final DateTime dateTime;
  final double temperatureCelsius;
  final String weatherConditionText;
  final String weatherConditionCode;
  final double chanceOfRain;
  final double windSpeedKmh;
  final double feelsLikeCelsius;
  final int humidityPercent;
  final List<ForecastItem> forecast;  

  WeatherData({
    required this.cityName,
    required this.dateTime,
    required this.temperatureCelsius,
    required this.weatherConditionText,
    required this.weatherConditionCode,
    required this.chanceOfRain,
    required this.windSpeedKmh,
    required this.feelsLikeCelsius,
    required this.humidityPercent,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecastDay = json['forecast']['forecastday'][0];
    final hourly = forecastDay['hour'] as List;

    if (location == null || current == null || forecastDay == null || hourly.isEmpty) {
      throw Exception('Invalid weather data format from WeatherAPI.com: Missing essential fields.');
    }

    final cityName = location['name'] as String;
    final dateTime = DateTime.parse(current['last_updated'] as String);
    final temperatureCelsius = (current['temp_c'] as num).toDouble();
    final weatherConditionText = current['condition']['text'] as String;
    final weatherConditionCode = (current['condition']['code'] as num).toString();
    final humidityPercent = (current['humidity'] as num).toInt();
    final windSpeedKmh = (current['wind_kph'] as num).toDouble();
    final feelsLikeCelsius = (current['feelslike_c'] as num).toDouble();

    double calculatedChanceOfRain = 0.0;
    if (dateTime.hour < hourly.length && hourly[dateTime.hour].containsKey('chance_of_rain')) {
      calculatedChanceOfRain = (hourly[dateTime.hour]['chance_of_rain'] as num).toDouble();
    }

    final List<ForecastItem> parsedForecast = [];
    final int currentHour = dateTime.hour;

    for (int i = 0; i < 3; i++) {
      final int forecastHourIndex = (currentHour + 1 + i) % 24;
      if (forecastHourIndex < hourly.length) {
        final Map<String, dynamic> item = hourly[forecastHourIndex] as Map<String, dynamic>;
        final DateTime forecastTime = DateTime.parse(item['time'] as String);
        final double forecastTemp = (item['temp_c'] as num).toDouble();
        final double forecastChanceOfRain = (item['chance_of_rain'] as num).toDouble();
        final String forecastConditionCode = (item['condition']['code'] as num).toString();
        final bool isDay = (item['is_day'] as int) == 1;

        final IconData icon = getWeatherIconFromCode(forecastConditionCode, isDay);
        String detail;

        if (forecastChanceOfRain > 10) {
          detail = '${forecastChanceOfRain.toInt()}%';
        } else {
          detail = '${forecastTemp.toInt()}°C';
        }

        parsedForecast.add(
          ForecastItem(
            timeOrTemp: DateFormat('h a').format(forecastTime),
            icon: icon,
            detail: detail,
          ),
        );
      }
    }

    return WeatherData(
      cityName: cityName,
      dateTime: dateTime,
      temperatureCelsius: temperatureCelsius,
      weatherConditionText: weatherConditionText,
      weatherConditionCode: weatherConditionCode,
      chanceOfRain: calculatedChanceOfRain,
      windSpeedKmh: windSpeedKmh,
      feelsLikeCelsius: feelsLikeCelsius,
      humidityPercent: humidityPercent,
      forecast: parsedForecast,
    );
  }
}

class ForecastItem {
  final String timeOrTemp;
  final IconData icon;
  final String detail;

  ForecastItem({
    required this.timeOrTemp,
    required this.icon,
    required this.detail,
  });
}

class WeatherApiService {
  final String _apiKey = '612844a545b644a5a6331159250207';
  final String _baseUrl = 'http://api.weatherapi.com/v1';

  Future<WeatherData> fetchWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl/forecast.json?key=$_apiKey&q=$latitude,$longitude&days=1&aqi=no&alerts=no');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(data);
      } else {
        throw Exception(
            "Can't load weather data");
      }
    } catch (e) {
      throw Exception('Failed to connect to weather API: $e');
    }
  }
}

IconData getWeatherIconFromCode(String code, bool isDay) {
  switch (code) {
    case '1000':
      return isDay ? Icons.wb_sunny_rounded : Icons.mode_night_rounded;
    case '1003':
      return isDay ? Icons.cloud_queue_rounded : Icons.wb_cloudy_rounded;
    case '1006':
    case '1009':
      return Icons.cloud_rounded;
    case '1030':
    case '1135':
    case '1147':
      return Icons.foggy;
    case '1063':
    case '1150':
    case '1153':
    case '1180':
    case '1183':
    case '1186':
    case '1189':
    case '1192':
    case '1195':
    case '1240':
    case '1243':
    case '1246':
    case '1249':
    case '1252':
      return Icons.cloudy_snowing;
    case '1066':
    case '1069':
    case '1072':
    case '1114':
    case '1117':
    case '1210':
    case '1213':
    case '1216':
    case '1219':
    case '1222':
    case '1225':
    case '1255':
    case '1258':
      return Icons.ac_unit_rounded;
    case '1087':
    case '1273':
    case '1276':
    case '1279':
    case '1282':
      return Icons.thunderstorm_rounded;
    case '1198':
    case '1201':
      return Icons.ac_unit;
    case '1204':
    case '1207':
      return Icons.grain_rounded;
    case '1237':
      return Icons.bubble_chart_rounded;
    default:
      return Icons.wb_sunny_rounded;
  }
}
