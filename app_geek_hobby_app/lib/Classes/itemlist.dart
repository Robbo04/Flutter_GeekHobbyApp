
import 'anime.dart';
import 'game.dart';
import 'item.dart';
import 'movie.dart';
import 'show.dart';

class ItemList 
{
  String name;
  List<Item> items; // List of item IDs or names
  Set<Type> allowedTypes = {};

  ItemList({
    required this.name,
    required this.items,
  });

  void addItem(Item item) {
    if (allowedTypes.contains(item.runtimeType)) {
      // Valid type
      items.add(item);
    } else {
      throw Exception('Item type not allowed in this list');
    }   
  }

}
