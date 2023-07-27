class PlayerDataModel {
  final int id;
  final String name;
  final int age;
  final String nationality;
  final String club;
  final String position;
  final int? goalsScored;
  final int? assists;
  final int? cleanSheets;

  PlayerDataModel({
    required this.id,
    required this.name,
    required this.age,
    required this.nationality,
    required this.club,
    required this.position,
    this.goalsScored,
    this.assists,
    this.cleanSheets,
  });

  factory PlayerDataModel.fromJson(Map<String, dynamic> json) =>
      PlayerDataModel(
        id: json["id"],
        name: json["name"],
        age: json["age"],
        nationality: json["nationality"],
        club: json["club"],
        position: json["position"],
        goalsScored: json["goals_scored"],
        assists: json["assists"],
        cleanSheets: json["clean_sheets"],
      );
}
