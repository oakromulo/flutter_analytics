/// @nodoc
library setup_params;

/// @nodoc
class SetupParams {
  /// @nodoc
  SetupParams([this.configUrl, this.destinations, this.onFlush, this.orgId]);

  /// @nodoc
  final String configUrl;

  /// @nodoc
  final List<String> destinations;

  /// @nodoc
  final OnBatchFlush onFlush;

  /// @nodoc
  final String orgId;
}

/// Type signature alias for the optional `onFlush` event handler.
typedef OnBatchFlush = void Function(List<Map<String, dynamic>>);
