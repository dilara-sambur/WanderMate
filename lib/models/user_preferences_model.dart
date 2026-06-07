class UserPreferencesModel {
  final String language;
  final String currency;
  final String travelStyle;
  final String budget;

  const UserPreferencesModel({
    required this.language,
    required this.currency,
    required this.travelStyle,
    required this.budget,
  });

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      language: map['language'] as String? ?? 'Türkçe',
      currency: map['currency'] as String? ?? 'TRY ₺',
      travelStyle: map['travelStyle'] as String? ?? 'Sakin',
      budget: map['budget'] as String? ?? 'Orta',
    );
  }

  Map<String, dynamic> toMap() => {
    'language': language,
    'currency': currency,
    'travelStyle': travelStyle,
    'budget': budget,
  };

  UserPreferencesModel copyWith({
    String? language,
    String? currency,
    String? travelStyle,
    String? budget,
  }) {
    return UserPreferencesModel(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      travelStyle: travelStyle ?? this.travelStyle,
      budget: budget ?? this.budget,
    );
  }

  static UserPreferencesModel get defaults => const UserPreferencesModel(
    language: 'Türkçe',
    currency: 'TRY ₺',
    travelStyle: 'Sakin',
    budget: 'Orta',
  );
}
