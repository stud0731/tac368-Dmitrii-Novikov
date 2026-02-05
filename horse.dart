class Horse {
  String name;
  int age;
  String sex;
  int wins;
  int secondPlaces;
  double rating;

  Horse(this.name, this.age, this.sex, this.wins, this.secondPlaces)
      : rating = (age == 1)
            ? 0
            : (wins * 2 + secondPlaces) / (age - 1);
}

void main() {
  Horse h1 = Horse("Bob", 4, "m", 5, 7);
  Horse h2 = Horse("Jane", 3, "f", 6, 2);

  print(h1.rating);
  print(h2.rating);
}
