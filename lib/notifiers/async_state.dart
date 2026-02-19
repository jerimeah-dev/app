enum AsyncStatus { initial, loading, success, error }

class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final String? error;

  const AsyncState._({required this.status, this.data, this.error});

  // =====================================================
  // FACTORIES
  // =====================================================

  const AsyncState.initial() : this._(status: AsyncStatus.initial);

  const AsyncState.loading({T? previousData})
    : this._(status: AsyncStatus.loading, data: previousData);

  const AsyncState.success(T data)
    : this._(status: AsyncStatus.success, data: data);

  const AsyncState.error(String error, {T? previousData})
    : this._(status: AsyncStatus.error, error: error, data: previousData);

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isInitial => status == AsyncStatus.initial;
  bool get isLoading => status == AsyncStatus.loading;
  bool get isSuccess => status == AsyncStatus.success;
  bool get isError => status == AsyncStatus.error;

  bool get hasData => data != null;
  bool get hasError => error != null;
}
