import 'package:books_data_source/books_data_source.dart';

/// In-memory implementation for managing Books data source interface.
class BooksDataSource {
  /// List of all the books
  final _data = <Book>[];

  /// Initialises the Function once so that it preserves access to
  /// the variables of the outer function of `_autoIncrementId()`, 
  /// even after the outer function has finished executing.
  final generateId = _autoIncrementId();

  /// Creates and returns the newly created [Book].
  Future<Book> createBook(Book book) async {
    final id = generateId();

    final createdBook = book.copyWith(id: id);
    _data.add(createdBook);

    return createdBook;
  }

  /// Returns all the [Book]s stored.
  Future<List<Book>> readAll() async => _data;

  /// Returns a [Book] with the specified `id` if exists.
  Future<Book?> read(int id) async =>
      _data.firstWhere((element) => element.id == id);

  /// Updates the [Book] with the provided `id` and returns the updated [Book].
  Future<Book> update(int id, Book book) async {
    final bookToBeUpdated = _data.firstWhere((element) => element.id == id);
    final indexToBeUpdated = _data.indexOf(bookToBeUpdated);
    final updatedBook = book.copyWith(id: bookToBeUpdated.id);

    _data
      ..remove(bookToBeUpdated)
      ..insert(indexToBeUpdated, updatedBook);

    return updatedBook;
  }

  /// Delete a [Book] record with the provided `id`.
  Future<bool> delete(int id) async {
    final bookToBeDeleted = _data.firstWhere((element) => element.id == id);
    return _data.remove(bookToBeDeleted);
  }
}

/// A Closure function that easily generates auto incremented id.
///
/// ```dart
/// final generateId = _autoIncrementId();
/// final id1 = generateId(); // 0
/// final id2 = generateId(); // 1
/// ```
int Function() _autoIncrementId() {
  var _count = 0;
  int increment() => _count++;
  return increment;
}
