class TilePlacement {
  final int row;
  final int col;
  final String letter;

  TilePlacement({
    required this.row,
    required this.col,
    required this.letter,
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'letter': letter,
    };
  }

  // from json
  factory TilePlacement.fromJson(Map<String, dynamic> json) {
    return TilePlacement(
      row: json['row'],
      col: json['col'],
      letter: json['letter'],
    );
  }
}