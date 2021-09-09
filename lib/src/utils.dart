extension ArrayExtension<T> on List<T> {
  List split(T value) {
    final result = [];
    var index = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] == value || i == length - 1) {
        result.add(sublist(index, i == length - 1 ? length : i));
        index = i + 1;
      }
    }
    return result;
  }
}
