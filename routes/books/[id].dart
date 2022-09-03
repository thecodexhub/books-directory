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
      return Response(statusCode: HttpStatus.notFound, body: 'Not found');
    }
  } catch (_) {
    return Response(statusCode: HttpStatus.notFound, body: 'Not found');
  }

  if (context.request.method == HttpMethod.get) {
    return _getMethod(context, book);
  } else if (context.request.method == HttpMethod.put) {
    return _putMethod(context, int.parse(id));
  } else if (context.request.method == HttpMethod.delete) {
    return _deleteMethod(context, int.parse(id));
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _getMethod(RequestContext context, Book book) async {
  return Response.json(body: book);
}

FutureOr<Response> _putMethod(RequestContext context, int id) async {
  final dataSource = context.read<BooksDataSource>();
  final book = Book.fromJson(await context.request.json());

  final updatedBook = await dataSource.update(id, book);
  return Response.json(body: updatedBook);
}

FutureOr<Response> _deleteMethod(RequestContext context, int id) async {
  final dataSource = context.read<BooksDataSource>();
  await dataSource.delete(id);

  return Response.json(statusCode: HttpStatus.noContent);
}
