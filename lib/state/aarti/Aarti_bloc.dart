import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/models/Aarti.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/services/AartiApi.dart';
import '../../models/HttpState.dart';
import '../WithHttpState.dart';
import '../httpStates.dart';

part 'Aarti_event.dart';
part 'Aarti_state.dart';

class AartiBloc extends Bloc<AartiEvent, AartiState> {
  AartiBloc({required AartiApi aartiApi}) : super(AartiState.initial()) {
    on<FetchAllAartiEvent>((event, emit) async {
      if(!state.canLoadPage(pageNo: event.pageNo)) return emit(state.copyWith());
      emit(state.copyWith(httpStates: state.httpStates.clone()
        ..put(HttpStates.ALL_AARTI, const HttpState.loading())));
      try {
        ApiResponse<Pageable<Aarti>> res = await aartiApi.getPaginatedAartis(
            pageNo: event.pageNo,
            pageSize: AartiState.PAGE_SIZE,
            cancelToken: event.cancelToken);
        emit(state.copyWith(aartis: state.aartis.clone()..put(event.pageNo, res.data!.data),
            totalItems: res.data!.totalItems,
            httpStates: state.httpStates.clone()
              ..put(HttpStates.ALL_AARTI, HttpState.done())));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()
          ..put(HttpStates.ALL_AARTI, HttpState.error(
              error: e.response?.data?['error'] ??
                  e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()
          ..put(HttpStates.ALL_AARTI, HttpState.error(error: e.toString()))));
      }
    });
  }
}
