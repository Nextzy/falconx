import 'package:falconx/lib.dart';

abstract class FalconWidgetStateEventSafeBloc<EVENT, DATA>
    extends FalconEventBloc<EVENT, WidgetStateEvent<DATA>> {
  FalconWidgetStateEventSafeBloc(
    DATA data, {
    EventTransformer<BlocEvent<EVENT>>? transformer,
  }) : super(
          WidgetStateEvent(FullWidgetState.initial, data: data),
          transformer: transformer,
        );

  DATA get data => state.data;

  void _assertEmitter() {
    assert(
      _emitter != null,
      '''
emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
Please make sure to await all asynchronous operations with event handlers
and use emit.isDone after asynchronous operations before calling emit() to
ensure the event handler has not completed.

  **❌BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emitSuccess(...));
  });

  **✅GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emitSuccess(...));
  });
''',
    );
  }

  void _emit(WidgetStateEvent<DATA> state) {
    _assertEmitter();
    _emitter?.call(state);
  }

  void emitEvent<T>(Object event, [T? data]) =>
      _emit(state.addEvent(event, data));

  void emitInitial([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.initial, data: data ?? state.data));

  void emitLoading([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.loading, data: data ?? state.data));

  void emitFail([DATA? data]) =>
      _emit(WidgetStateEvent(FullWidgetState.fail, data: data ?? state.data));

  void emitWarning([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.warning, data: data ?? state.data));

  void emitSuccess([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.success, data: data ?? state.data));

  void emitCancel([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.cancel, data: data ?? state.data));

  Future<void> callStream<A>({
    required Stream<WidgetStateEvent<A?>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      Failure failure,
    )? onFailure,
  }) {
    _assertEmitter();
    return _emitter!.onEach(
      call,
      onData: (WidgetStateEvent<A?> state) {
        onData(_emitter!, state);
      },
      onError: (error, stackTrace) {
        if (error is Failure) {
          onFailure?.call(_emitter!, error);
        } else {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
          ));
        }
      },
    );
  }

  Future<void> callEitherFuture<A>({
    required Object key,
    required Future<Either<Failure, A>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      Failure failure,
    )? onFailure,
    bool debounceFetch = true,
  }) =>
      callStream<A>(
        call: fetchEitherFuture<A>(
          key: key,
          call: call,
          debounceFetch: debounceFetch,
        ),
        onData: onData,
        onFailure: onFailure,
      );

  Future<void> callEitherStream<A>({
    required Object key,
    required Stream<Either<Failure, A>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA>> emitter,
      Failure failure,
    )? onFailure,
    bool debounceFetch = true,
  }) =>
      callStream<A>(
        call: fetchEitherStream<A>(
          key: key,
          call: call,
          debounceFetch: debounceFetch,
          // defaultData: state.data,
        ),
        onData: onData,
        onFailure: onFailure,
      );
}

abstract class FalconWidgetStateEventBloc<EVENT, DATA>
    extends FalconEventBloc<EVENT, WidgetStateEvent<DATA?>> {
  FalconWidgetStateEventBloc({
    DATA? data,
    EventTransformer<BlocEvent<EVENT>>? transformer,
  }) : super(WidgetStateEvent(FullWidgetState.initial, data: data),
            transformer: transformer);

  DATA? get data => state.data;

  void _emit(WidgetStateEvent<DATA?> state) {
    assertEmitter();
    _emitter?.call(state);
  }

  void emitEvent<T>(Object event, [T? data]) =>
      _emit(state.addEvent(event, data));

  void emitInitial([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.initial, data: data ?? state.data));

  void emitLoading([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.loading, data: data ?? state.data));

  void emitFail([DATA? data]) =>
      _emit(WidgetStateEvent(FullWidgetState.fail, data: data ?? state.data));

  void emitWarning([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.warning, data: data ?? state.data));

  void emitSuccess([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.success, data: data ?? state.data));

  void emitCancel([DATA? data]) => _emit(
      WidgetStateEvent(FullWidgetState.cancel, data: data ?? state.data));

  Future<void> callStream<A>({
    required Stream<WidgetStateEvent<A?>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      Failure failure,
    )? onFailure,
  }) {
    assertEmitter();
    return _emitter!.onEach(
      call,
      onData: (WidgetStateEvent<A?> state) {
        onData(_emitter!, state);
      },
      onError: (error, stackTrace) {
        if (error is Failure) {
          onFailure?.call(_emitter!, error);
        } else {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
          ));
        }
      },
    );
  }

  Future<void> callEitherFuture<A>({
    required Object key,
    required Future<Either<Failure, A>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      Failure failure,
    )? onFailure,
    bool debounceFetch = true,
  }) =>
      callStream<A>(
        call: fetchEitherFuture<A>(
          key: key,
          call: call,
          debounceFetch: debounceFetch,
        ),
        onData: onData,
        onFailure: onFailure,
      );

  Future<void> callEitherStream<A>({
    required Object key,
    required Stream<Either<Failure, A>> call,
    required Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      WidgetStateEvent<A?> state,
    ) onData,
    Function(
      Emitter<WidgetStateEvent<DATA?>> emitter,
      Failure failure,
    )? onFailure,
    bool debounceFetch = true,
  }) =>
      callStream<A>(
        call: fetchEitherStream<A>(
          key: key,
          call: call,
          debounceFetch: debounceFetch,
        ),
        onData: onData,
        onFailure: onFailure,
      );
}

abstract class FalconEventBloc<EVENT, STATE>
    extends FalconBloc<BlocEvent<EVENT>, STATE> {
  FalconEventBloc(
    super.initialState, {
    EventTransformer<BlocEvent<EVENT>>? transformer,
  }) {
    on<BlocEvent<EVENT>>(
        (BlocEvent<EVENT> event, Emitter<STATE> emitter) async {
      _emitter = emitter;
      await onBlocEvent(event);
      _emitter = null;
    }, transformer: transformer);
  }

  Emitter<STATE> get emitter {
    assertEmitter();
    return _emitter!;
  }

  Emitter<STATE>? _emitter;

  Future<void> onBlocEvent(BlocEvent<EVENT> event);

  void assertEmitter() {
    assert(
      _emitter != null,
      '''
emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
Please make sure to await all asynchronous operations with event handlers
and use emit.isDone after asynchronous operations before calling emit() to
ensure the event handler has not completed.

  **❌BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emitSuccess(...));
  });

  **✅GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emitSuccess(...));
  });
''',
    );
  }

  void addEvent<T>(EVENT event, {T? data}) {
    add(BlocEvent(event, data: data));
  }

  @override
  Future<void> close() async {
    _emitter = null;
    return super.close();
  }
}

abstract class FalconBloc<EVENT, STATE> extends Bloc<EVENT, STATE> {
  FalconBloc(
    super.initialState, {
    EventTransformer<EVENT>? transformer,
  }) : _fetcher = EitherStreamFetcherList();

  final EitherStreamFetcherList _fetcher;

  Stream<WidgetStateEvent<T?>> fetchEitherStream<T>({
    required Object key,
    required Stream<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) =>
      _fetcher.fetchStream(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      );

  Stream<WidgetStateEvent<T>> fetchEitherStreamSafe<T>({
    required Object key,
    required Stream<Either<Failure, T>> call,
    required T defaultData,
    bool debounceFetch = true,
  }) =>
      fetchEitherStream(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      ).map(
        (WidgetStateEvent<T?> event) => event.mapData(
          (T? a) => a ?? defaultData,
        ),
      );

  Stream<WidgetStateEvent<T?>> fetchEitherFuture<T>({
    required Object key,
    required Future<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) =>
      _fetcher.fetchFuture(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      );

  Stream<WidgetStateEvent<T>> fetchEitherFutureSafe<T>({
    required Object key,
    required Future<Either<Failure, T>> call,
    required T defaultData,
    bool debounceFetch = true,
  }) =>
      fetchEitherFuture(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      ).map(
        (WidgetStateEvent<T?> event) => event.mapData(
          (T? a) => a ?? defaultData,
        ),
      );

  @override
  Future<void> close() async {
    await _fetcher.closeAsync();
    return super.close();
  }
}
