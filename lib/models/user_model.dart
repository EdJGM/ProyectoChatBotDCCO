import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1) // Define un ID único para este modelo
class UserModel {
  @HiveField(0) // Campo 0
  final String uid;

  @HiveField(1) // Campo 1
  final String name;

  @HiveField(2) // Campo 2
  final String image;

  UserModel({
    required this.uid,
    required this.name,
    required this.image,
  });
}
