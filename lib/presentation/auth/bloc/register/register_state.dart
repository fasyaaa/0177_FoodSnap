part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  // DIUBAH: Bawa LoginResponseModel
  final RegisterResponseModel response;
  RegisterSuccess({required this.response});
}

final class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure({required this.error});
}
