import 'package:equatable/equatable.dart';

/// نمایش خطا در لایه UI/Domain (بدون وابستگی به جزئیات فنی)
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class GameLogicFailure extends Failure {
  const GameLogicFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'خطای ناشناخته رخ داد']);
}
