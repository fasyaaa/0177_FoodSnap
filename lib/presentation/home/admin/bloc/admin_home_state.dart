part of 'admin_home_bloc.dart';

sealed class AdminHomeState extends Equatable {
  const AdminHomeState();
  
  @override
  List<Object> get props => [];
}

final class AdminHomeInitial extends AdminHomeState {}
