import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'gmaps_event.dart';
part 'gmaps_state.dart';

class GmapsBloc extends Bloc<GmapsEvent, GmapsState> {
  GmapsBloc() : super(GmapsInitial()) {
    on<GmapsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
