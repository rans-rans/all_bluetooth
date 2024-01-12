part of "all_bluetooth.dart";

class HelperFunctions {
  static Map<String, dynamic> convertToMap(Object? object) {
    final response = <String, dynamic>{};

    final map = object as Map<Object?, Object?>;
    map.forEach((key, value) {
      response[key.toString()] = value;
    });
    return response;
  }
}
