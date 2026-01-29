import '../pasture_provider.dart';

abstract class PastureEvent {
  final String name;
  final String description;

  PastureEvent({required this.name, required this.description});

  // Логика воздействия на поле
  void apply(PastureNotifier notifier);
}
