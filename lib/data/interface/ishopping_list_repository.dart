abstract class IShoppingListRepository {

  Future<int> createShoppingList(Map<String, dynamic> listInfo);
  Future<int> addItemToList(Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> getItemsForList(int listId);
  Future<List<Map<String, dynamic>>> getAllShoppingLists();
  Future<int> toggleItemChecked(int itemId, bool isChecked);
  Future<int> updateItem(Map<String, dynamic> item);
  Future<int> updateShoppingList(Map<String, dynamic> listInfo);
  Future<int> deleteShoppingList(int id);
  Future<int> deleteItemFromList(int itemId);

}