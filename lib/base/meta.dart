const proto = _JsonProto();

class _JsonProto {
  const _JsonProto();
}

class JsonAnalyzeException implements Exception {
  final String message;

  JsonAnalyzeException(this.message);

  @override
  String toString() {
    return message;
  }
}
