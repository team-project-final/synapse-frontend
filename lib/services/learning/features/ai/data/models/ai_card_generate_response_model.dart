class GeneratedCardModel {
  GeneratedCardModel.fromJson(Map<String, dynamic> json)
      : front = json['front'] as String,
        back = json['back'] as String;
  final String front;
  final String back;
}

class AiCardGenerateResponseModel {
  AiCardGenerateResponseModel.fromJson(Map<String, dynamic> json)
      : cards = (json['cards'] as List<dynamic>)
            .map((c) => GeneratedCardModel.fromJson(c as Map<String, dynamic>))
            .toList(),
        model = json['model'] as String;
  final List<GeneratedCardModel> cards;
  final String model;
}
