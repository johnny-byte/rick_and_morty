import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:rick_and_morty/model/character.dart';
import 'package:rick_and_morty/model/episode.dart';

part 'api.g.dart';

@RestApi(baseUrl: "https://rickandmortyapi.com/api")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/character/{id}")
  Future<Character> getCharacter(@Path() int id);

  @GET("/character")
  Future<AllCharacterAnswer> getAllCharacters();

  @GET("/episode/{id}")
  Future<Episode> getEpisode(@Path() int id);
}
