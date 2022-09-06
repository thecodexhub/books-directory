// ignore_for_file: prefer_const_constructors
import 'package:books_data_source/books_data_source.dart';
import 'package:test/test.dart';

void main() {
  group('BooksDataSource', () {
    late BooksDataSource dataSource;

    setUp(() {
      dataSource = BooksDataSource();
    });

    group('createBook', () {
      test('returns the newly created book', () async {
        final book = Book(name: 'name', author: 'author');

        final createdBook = await dataSource.createBook(book);

        expect(createdBook.id, isNotNull);
        expect(createdBook.name, equals(book.name));
        expect(createdBook.description, isEmpty);
        expect(createdBook.author, equals(book.author));
      });
    });

    group('readAll', () {
      test('returns an empty list when there is no books', () async {
        expect(dataSource.readAll(), completion(isEmpty));
      });

      test('returns a populated list when there are books', () async {
        final book = Book(name: 'name', author: 'author');

        final createdBook = await dataSource.createBook(book);

        expect(dataSource.readAll(), completion(equals([createdBook])));
      });
    });

    group('read', () {
      test('returns null when book doesnot exist', () async {
        expect(dataSource.read(0), completion(isNull));
      });

      test('returns the book when it exists', () async {
        final book = Book(name: 'name', author: 'author');

        final createdBook = await dataSource.createBook(book);

        expect(
          dataSource.read(createdBook.id!),
          completion(equals(createdBook)),
        );
      });
    });

    group('update', () {
      test('returns the updated book', () async {
        final book = Book(name: 'name', author: 'author');
        final newBook = Book(name: 'new name', author: 'new author');

        final createdBook = await dataSource.createBook(book);
        final updatedBook = await dataSource.update(createdBook.id!, newBook);

        expect(dataSource.readAll(), completion(equals([updatedBook])));
        expect(updatedBook.id, equals(createdBook.id));
        expect(updatedBook.name, equals(newBook.name));
        expect(updatedBook.description, equals(book.description));
        expect(updatedBook.author, equals(newBook.author));
      });
    });

    group('delete', () {
      test('deletes the book', () async {
        final book = Book(name: 'name', author: 'author');

        final createdBook = await dataSource.createBook(book);
        await dataSource.delete(createdBook.id!);

        expect(dataSource.readAll(), completion(isEmpty));
      });
    });
  });
}
