import 'dart:async';
import 'dart:io';

import 'package:books_data_source/books_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  final dataSource = context.read<BooksDataSource>();
  Book? book;
  try {
    book = await dataSource.read(int.parse(id));

    if (book == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Not found',
      );
    }
  } catch (_) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'Not found',
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _getMethod(context, book);
    case HttpMethod.put:
      return _putMethod(context, int.parse(id));
    case HttpMethod.delete:
      return _deleteMethod(context, int.parse(id));
    case HttpMethod.post:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _getMethod(RequestContext context, Book book) async {
  return Response.json(body: book);
}

FutureOr<Response> _putMethod(RequestContext context, int id) async {
  final dataSource = context.read<BooksDataSource>();
  final book = Book.fromJson(
    await context.request.json() as Map<String, dynamic>,
  );

  final updatedBook = await dataSource.update(id, book);
  return Response.json(body: updatedBook);
}

FutureOr<Response> _deleteMethod(RequestContext context, int id) async {
  final dataSource = context.read<BooksDataSource>();
  await dataSource.delete(id);

  return Response.json(statusCode: HttpStatus.noContent);
}
