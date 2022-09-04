import 'dart:io';

import 'package:books_data_source/books_data_source.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/books/[id].dart' as route;

class MockRequestContext extends Mock implements RequestContext {}

class MockRequest extends Mock implements Request {}

class MockBooksDataSource extends Mock implements BooksDataSource {}

class MockUri extends Mock implements Uri {}

void main() {
  late RequestContext context;
  late Request request;
  late BooksDataSource dataSource;
  late Uri uri;

  const id = 0;
  final book = Book(
    id: id,
    name: 'name',
    description: 'description',
    author: 'author',
  );

  setUpAll(() => registerFallbackValue(book));

  setUp(() {
    context = MockRequestContext();
    request = MockRequest();
    dataSource = MockBooksDataSource();
    uri = MockUri();

    when(() => context.read<BooksDataSource>()).thenReturn(dataSource);
    when(() => context.request).thenReturn(request);
    when(() => request.uri).thenReturn(uri);

    when(() => uri.resolve(any())).thenAnswer(
      (_) => Uri.parse('http://localhost/books${_.positionalArguments.first}'),
    );
    when(() => uri.queryParameters).thenReturn({});
  });

  group('Responds with 405', () {
    setUp(() {
      when(() => dataSource.read(any())).thenAnswer((_) async => book);
    });

    test('when the method is HEAD', () async {
      when(() => request.method).thenReturn(HttpMethod.head);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is OPTIONS', () async {
      when(() => request.method).thenReturn(HttpMethod.options);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is PATCH', () async {
      when(() => request.method).thenReturn(HttpMethod.patch);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is POST', () async {
      when(() => request.method).thenReturn(HttpMethod.post);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });

  group('Responds with 404', () {
    test('if no book is found', () async {
      when(() => dataSource.read(any())).thenAnswer((_) async => null);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.notFound));
      expect(response.body(), completion(equals('Not found')));

      verify(() => dataSource.read(any(that: equals(id)))).called(1);
    });

    test('if the id cannot be parsed to int', () async {
      when(() => dataSource.read(any())).thenAnswer((_) async => null);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context, 'hello');

      expect(response.statusCode, equals(HttpStatus.notFound));
      expect(response.body(), completion(equals('Not found')));

      verifyNever(() => dataSource.read(any()));
    });
  });

  group('GET /books/[id]', () {
    test('responds with a 200 and the book', () async {
      when(() => dataSource.read(any())).thenAnswer((_) async => book);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(equals(book.toJson())));

      verify(() => dataSource.read(any(that: equals(id)))).called(1);
    });
  });

  group('PUT /books/[id]', () {
    test('responds with a 200 and the updated book', () async {
      final updatedBook = book.copyWith(name: 'New name');

      when(() => dataSource.read(any())).thenAnswer((_) async => book);
      when(() => dataSource.update(any(), any()))
          .thenAnswer((_) async => updatedBook);

      when(() => request.method).thenReturn(HttpMethod.put);
      when(() => request.json()).thenAnswer((_) async => updatedBook.toJson());

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(equals(updatedBook.toJson())));

      verify(() => dataSource.read(any(that: equals(id)))).called(1);
      verify(
        () => dataSource.update(
          any(that: equals(id)),
          any(that: equals(updatedBook)),
        ),
      ).called(1);
    });
  });

  group('DELETE /books/[id]', () {
    test('responds with a 204 and deletes the book', () async {
      when(() => dataSource.read(any())).thenAnswer((_) async => book);
      when(() => dataSource.delete(any())).thenAnswer((_) async => true);
      when(() => request.method).thenReturn(HttpMethod.delete);

      final response = await route.onRequest(context, id.toString());

      expect(response.statusCode, equals(HttpStatus.noContent));
      expect(response.json(), completion(isEmpty));

      verify(() => dataSource.read(any(that: equals(id)))).called(1);
      verify(() => dataSource.delete(any(that: equals(id)))).called(1);
    });
  });
}
