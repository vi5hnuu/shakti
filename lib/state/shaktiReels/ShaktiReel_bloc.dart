import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/models/Aarti.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/models/Reel.dart';
import 'package:shakti/services/AartiApi.dart';
import 'package:shakti/services/ShaktiReelApi.dart';
import '../../models/HttpState.dart';
import '../WithHttpState.dart';
import '../httpStates.dart';

part 'ShaktiReel_event.dart';
part 'ShaktiReel_state.dart';

class ShaktiReelBloc extends Bloc<ShaktiReelEvent, ShaktiReelState> {
  ShaktiReelBloc({required ShaktiReelApi shaktiReelApi}) : super(ShaktiReelState.initial()) {
    on<FetchShaktiReelsEvent>((event, emit) async {
      if(!state.canLoadPage(pageNo: event.pageNo)) return emit(state.copyWith());
      emit(state.copyWith(httpStates: state.httpStates.clone()
        ..put(HttpStates.ALL_REEL, const HttpState.loading())));
      try {
        ApiResponse<Pageable<Reel>> res = await shaktiReelApi.getPaginatedReels(
            pageNo: event.pageNo,
            pageSize: ShaktiReelState.PAGE_SIZE,
            cancelToken: event.cancelToken);
        emit(state.copyWith(reels: state.reels.clone()..put(event.pageNo, res.data!.data),
            totalItems: res.data!.totalItems,
            httpStates: state.httpStates.clone()
              ..put(HttpStates.ALL_REEL, HttpState.done())));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()
          ..put(HttpStates.ALL_REEL, HttpState.error(
              error: e.response?.data?['error'] ??
                  e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()
          ..put(HttpStates.ALL_REEL, HttpState.error(error: e.toString()))));
      }
    });
  }
}
