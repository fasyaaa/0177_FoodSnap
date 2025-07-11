import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  AdminHomeBloc() : super(AdminHomeInitial()) {
    on<AdminHomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
