import 'base_network.dart';

class ApiDataSource {
  static ApiDataSource instance = ApiDataSource();

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    return BaseNetwork.post("admins/login", body);
  }

  static Future<Map<String, dynamic>> getAirports() async {
    return BaseNetwork.get("airports");
  }

  static Future<Map<String, dynamic>> getFlights() async {
    return BaseNetwork.get("flights");
  }

  static Future<Map<String, dynamic>> getUser(String token) async {
    return BaseNetwork.getWithToken("users", token);
  }

  static Future<Map<String, dynamic>> editProfile(
      String token, Map<String, dynamic> body) async {
    return BaseNetwork.putWithToken("users/edit-account", token, body);
  }

  static Future<Map<String, dynamic>> postAirport(
      String token, Map<String, dynamic> body) async {
    return BaseNetwork.postWithToken("airports/create", token, body);
  }

  static Future<Map<String, dynamic>> putAirport(
      int id, String token, Map<String, dynamic> body) async {
    return BaseNetwork.putWithToken("airports/$id", token, body);
  }

  static Future<Map<String, dynamic>> deleteAirport(
      int id, String token) async {
    return BaseNetwork.delete("airports/$id", token);
  }

  static Future<Map<String, dynamic>> postFlight(
      String token, Map<String, dynamic> body) async {
    return BaseNetwork.postWithToken("flights/create", token, body);
  }

  static Future<Map<String, dynamic>> putFlight(
      int id, String token, Map<String, dynamic> body) async {
    return BaseNetwork.putWithToken("flights/$id", token, body);
  }

  static Future<Map<String, dynamic>> deleteFlight(int id, String token) async {
    return BaseNetwork.delete("flights/$id", token);
  }

  static Future<Map<String, dynamic>> postSeat(
      String token, Map<String, dynamic> body) async {
    return BaseNetwork.postWithToken("seats/create", token, body);
  }

  static Future<Map<String, dynamic>> putSeat(
      int id, String token, Map<String, dynamic> body) async {
    return BaseNetwork.putWithToken("seats/$id", token, body);
  }

  static Future<Map<String, dynamic>> deleteSeat(int id, String token) async {
    return BaseNetwork.delete("seats/$id", token);
  }
}
