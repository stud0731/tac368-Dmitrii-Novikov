import "dart:io";

void main()
{
  print("ThreeX sequence values for different starting numbers:");
  for (int i = 1; i <= 100; i++)
  {
    ThreeX t = ThreeX(i);
    print("start=$i  max=${t.maxValue}  length=${t.length}");
  }
}

class ThreeX
{
  final int start;
  final List<int> sequence;
  final int maxValue;
  final int length;

  ThreeX(this.start)
      : sequence = returnSequence(start),
        maxValue = getMax(returnSequence(start)),
        length = getLength(returnSequence(start));

  // build the sequence
  static List<int> returnSequence(int x)
  {
    List<int> list = [];

    while (x != 1)
    {
      list.add(x);

      if (x % 2 == 0)
      {
        x = x ~/ 2;
      }
      else
      {
        x = 3 * x + 1;
      }
    }

    list.add(1);
    return list;
  }

  // return the maximum value in a list
  static int getMax(List<int> list)
  {
    int m = list[0];

    for (int v in list)
    {
      if (v > m)
      {
        m = v;
      }
    }

    return m;
  }

  // return the length of a list
  static int getLength(List<int> list)
  {
    return list.length;
  }
}