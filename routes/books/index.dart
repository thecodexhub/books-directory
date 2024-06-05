import 'dart:async';
import 'dart:io';

import 'package:books_data_source/books_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _getMethod(context);
  } else if (context.request.method == HttpMethod.post) {
    return _postMethod(context);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _getMethod(RequestContext context) async {
  final dataSource = context.read<BooksDataSource>();
  final books = await dataSource.readAll();
  return Response.json(body: books);
}

FutureOr<Response> _postMethod(RequestContext context) async {
  final dataSource = context.read<BooksDataSource>();
  final book = Book.fromJson(
    await context.request.json() as Map<String, dynamic>,
  );

  return Response.json(
    statusCode: HttpStatus.created,
    body: await dataSource.createBook(book),
  );
}
