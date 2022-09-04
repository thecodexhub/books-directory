import 'dart:io';

import 'package:books_data_source/books_data_source.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/books/index.dart' as route;

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
    test('when the method is DELETE', () async {
      when(() => request.method).thenReturn(HttpMethod.delete);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is HEAD', () async {
      when(() => request.method).thenReturn(HttpMethod.head);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is OPTIONS', () async {
      when(() => request.method).thenReturn(HttpMethod.options);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is PATCH', () async {
      when(() => request.method).thenReturn(HttpMethod.patch);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('when the method is PUT', () async {
      when(() => request.method).thenReturn(HttpMethod.put);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });

  group('GET /books', () {
    test('responds with a 200 and an empty list', () async {
      when(() => dataSource.readAll()).thenAnswer((_) async => []);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(isEmpty));

      verify(() => dataSource.readAll()).called(1);
    });

    test('responds with a 200 and a populated list of books', () async {
      when(() => dataSource.readAll()).thenAnswer((_) async => [book]);
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(equals([book.toJson()])));

      verify(() => dataSource.readAll()).called(1);
    });
  });

  group('POST /books', () {
    test('returns a 201 and the newly created book', () async {
      when(() => dataSource.createBook(any())).thenAnswer((_) async => book);
      when(() => request.method).thenReturn(HttpMethod.post);

      when(() => request.json()).thenAnswer(
        (_) async => <String, dynamic>{
          'name': 'name',
          'description': 'description',
          'author': 'author',
        },
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.created));
      expect(response.json(), completion(equals(book.toJson())));

      verify(() => dataSource.createBook(any())).called(1);
    });
  });
}
