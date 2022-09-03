import 'package:books_data_source/books_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

final _dataSource = BooksDataSource();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<BooksDataSource>((_) => _dataSource));
}
