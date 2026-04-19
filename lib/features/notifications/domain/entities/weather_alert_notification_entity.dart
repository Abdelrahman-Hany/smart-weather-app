class WeatherAlertNotificationEntity {
  final int id;
  final String title;
  final String body;
  final String? payload;

  const WeatherAlertNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });
}
