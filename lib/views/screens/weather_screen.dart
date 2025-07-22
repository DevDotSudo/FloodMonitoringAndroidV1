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
      print("Error fetching weather: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load weather data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            border: Border.all(
                color: Colors.blue.shade200) // Light pastel blue background
            ),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF5DADE2),
            // Soft sky blue
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: MediaQuery.of(context).padding.top + 5,
      ),
      children: [
        _locationHeader(),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _weatherIcon(),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _currentTemperature(),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        _extraWeatherInfo(),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
      ],
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "Loading Location...",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
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
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFDFF1FE),
              border: Border.all(
                  color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Image.network(
              iconUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _weather?.weatherDescription?.toUpperCase() ?? "Loading...",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentTemperature() {
    return Column(
      children: [
        Text(
          "${_weather?.temperature?.celsius?.toStringAsFixed(0) ?? 'N/A'}°C",
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (_weather?.tempFeelsLike?.celsius != null)
          Text(
            "Feels like: ${_weather!.tempFeelsLike!.celsius!.toStringAsFixed(0)}°C",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _extraWeatherInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.90,
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.9),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                "Max Temp",
                "${_weather?.tempMax?.celsius?.toStringAsFixed(0) ?? 'N/A'}°C",
                Icons.arrow_upward,
              ),
              _infoTile(
                "Min Temp",
                "${_weather?.tempMin?.celsius?.toStringAsFixed(0) ?? 'N/A'}°C",
                Icons.arrow_downward,
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, thickness: 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                "Wind",
                "${_weather?.windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s",
                Icons.wind_power,
              ),
              _infoTile(
                "Humidity",
                "${_weather?.humidity?.toStringAsFixed(0) ?? 'N/A'}%",
                Icons.water_drop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon,
            color: Color.fromARGB(255, 150, 213, 255), size: 20), // Sky blue
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}