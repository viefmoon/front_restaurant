class IdentifierState {
  final int id;
  final String? error;

  const IdentifierState({required this.id, this.error});

  IdentifierState copyWith({int? id, String? error}) {
    return IdentifierState(id: id ?? this.id, error: error ?? this.error);
  }
}
