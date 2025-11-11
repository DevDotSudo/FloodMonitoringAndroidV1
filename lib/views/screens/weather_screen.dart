import 'package:flood_monitoring_android/constants/api_key.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      Weather w = await weatherFactory.currentWeatherByLocation(11.0022, 122.8175);
      setState(() {
        _weather = w;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load weather data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // soft neutral background
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _locationHeader(),
        const SizedBox(height: 24),
        _weatherIcon(),
        const SizedBox(height: 16),
        _currentTemperature(),
        const SizedBox(height: 24),
        _extraWeatherInfo(),
      ],
    );
  }

  Widget _locationHeader() {
    return Column(
      children: [
        Text(
          _weather?.areaName ?? "Loading...",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          _weather?.country ?? "",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    final iconUrl = _weather?.weatherIcon != null
        ? "http://openweathermap.org/img/wn/${_weather!.weatherIcon}@4x.png"
        : "http://openweathermap.org/img/wn/01d@4x.png";

    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.network(
              iconUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.cloud_off,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _weather?.weatherDescription?.toUpperCase() ?? "Loading...",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _currentTemperature() {
    return Column(
      children: [
        Text(
          "${_weather?.temperature?.celsius?.toStringAsFixed(0) ?? '--'}°C",
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        if (_weather?.tempFeelsLike?.celsius != null)
          Text(
            "Feels like ${_weather!.tempFeelsLike!.celsius!.toStringAsFixed(0)}°C",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
      ],
    );
  }

  Widget _extraWeatherInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Max Temp", "${_weather?.tempMax?.celsius?.toStringAsFixed(0) ?? '--'}°C", Icons.arrow_upward),
              _infoTile("Min Temp", "${_weather?.tempMin?.celsius?.toStringAsFixed(0) ?? '--'}°C", Icons.arrow_downward),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Wind", "${_weather?.windSpeed?.toStringAsFixed(1) ?? '--'} m/s", Icons.air),
              _infoTile("Humidity", "${_weather?.humidity?.toStringAsFixed(0) ?? '--'}%", Icons.water_drop),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
