enum PlantType {
  tomato,
  pepper,
  basil,
  lettuce,
  strawberry;

  String get label => switch (this) {
        PlantType.tomato => 'Tomato',
        PlantType.pepper => 'Pepper',
        PlantType.basil => 'Basil',
        PlantType.lettuce => 'Lettuce',
        PlantType.strawberry => 'Strawberry',
      };
}
