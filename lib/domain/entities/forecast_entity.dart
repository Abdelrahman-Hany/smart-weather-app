class ForecastEntity {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String mainCondition;
  final String icon;
  final double windSpeed;
  final int windDeg;
  final double pop; // Probability of precipitation
  final int clouds;

  const ForecastEntity({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.windSpeed,
    required this.windDeg,
    required this.pop,
    required this.clouds,
  });
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String dayIcon;
  final String nightIcon;
  final String description;
  final double pop;

  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.dayIcon,
    required this.nightIcon,
    required this.description,
    required this.pop,
  });
}
