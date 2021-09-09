class SgxClientError extends Error {
  final String? message;

  SgxClientError([this.message]);

  @override
  String toString() {
    if (message != null) {
      return "Sgx verify failed: ${Error.safeToString(message)}";
    }
    return "Sgx server failed";
  }
}