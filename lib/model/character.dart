import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty/model/info.dart';

part 'character.g.dart';

@JsonSerializable()
class AllCharacterAnswer {
  AllCharacterAnswer({required this.characters, required this.info});
  Info info;
  @JsonKey(name: "results")
  List<Character> characters;

  factory AllCharacterAnswer.fromJson(Map<String, dynamic> json) =>
      _$AllCharacterAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AllCharacterAnswerToJson(this);
}

@JsonSerializable()
class Character {
  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
    required this.url,
    required this.created,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final CharacterLocation origin;
  final CharacterLocation location;
  final String image;
  final List<String> episode;
  final String url;
  final DateTime created;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}

@JsonSerializable()
class CharacterLocation {
  CharacterLocation({
    required this.name,
    required this.url,
  });

  String name;
  String url;

  factory CharacterLocation.fromJson(Map<String, dynamic> json) =>
      _$CharacterLocationFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterLocationToJson(this);
}
