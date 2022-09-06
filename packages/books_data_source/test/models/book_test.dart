import 'package:books_data_source/books_data_source.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Book', () {
    Book createSubject({
      int? id = 0,
      String name = 'name',
      String description = 'description',
      String author = 'author',
    }) {
      return Book(
        id: id,
        name: name,
        description: description,
        author: author,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(createSubject, returnsNormally);
      });

      test('throws AssertionError when id is negative', () {
        expect(
          () => createSubject(id: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('supports value equality', () {
        expect(createSubject(), equals(createSubject()));
      });

      test('props are correct', () {
        expect(
          createSubject().props,
          equals([0, 'name', 'description', 'author']),
        );
      });
    });
    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameters', () {
        expect(
          createSubject().copyWith(
            id: 1,
            name: 'new name',
            description: 'new description',
            author: 'new author',
          ),
          equals(
            createSubject(
              id: 1,
              name: 'new name',
              description: 'new description',
              author: 'new author',
            ),
          ),
        );
      });
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          Book.fromJson(
            <String, dynamic>{
              'id': 0,
              'name': 'name',
              'description': 'description',
              'author': 'author',
            },
          ),
          equals(createSubject()),
        );
      });
    });

    group('toJson', () {
      test('works correctly', () {
        expect(
          createSubject().toJson(),
          equals(
            <String, dynamic>{
              'id': 0,
              'name': 'name',
              'description': 'description',
              'author': 'author',
            },
          ),
        );
      });
    });
  });
}
