import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'book.g.dart';

/// {@template book}
/// A single [Book] model.
///
/// Contains [id], [name], [description], and [author].
///
/// If the [id] is provided, it cannot be null. If no [id] is
/// provided, one will be generated.
///
/// [Book]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson].
/// {@endtemplate}
@immutable
@JsonSerializable()
class Book extends Equatable {
  /// {@macro book}
  Book({
    this.id,
    required this.name,
    this.description = '',
    required this.author,
  }) : assert(id == null || !id.isNaN, 'id cannot be null');

  /// The unique identifier of the [Book].
  ///
  /// Cannot be null.
  final int? id;

  /// The name of the [Book].
  final String name;

  /// The description of the [Book].
  ///
  /// Defaults to an empty string.
  final String description;

  /// The name of the author of the [Book].
  final String author;

  /// Returns a copy of this [Book] with the given values updated.
  ///
  /// {@macro book}
  Book copyWith({
    int? id,
    String? name,
    String? description,
    String? author,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
    );
  }

  /// Deserializes the given `Map<String, dynamic>` into a [Book].
  static Book fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  /// Converts this [Book] into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$BookToJson(this);

  @override
  List<Object?> get props => [id, name, description, author];
}
