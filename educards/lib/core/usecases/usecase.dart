import 'package:equatable/equatable.dart';

/// Base UseCase interface following Clean Architecture.
/// Each UseCase has exactly one public method [call].
/// [T] is the return type, [Params] is the input parameter type.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use when a UseCase requires no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
