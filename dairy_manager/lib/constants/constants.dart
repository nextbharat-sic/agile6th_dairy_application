enum AnimalType { cow, buffalo }

extension AnimalTypeExtension on AnimalType {
  String get key => toString().split('.').last;
}

enum SessionType { morning, evening }

extension SessionTypeExtension on SessionType {
  String get key => toString().split('.').last;
}
