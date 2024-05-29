class AirportResponseModel {
  String? status;
  String? message;
  Airport? airport;

  AirportResponseModel({this.status, this.message, this.airport});

  AirportResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    airport =
        json['airport'] != null ? Airport.fromJson(json['airport']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (airport != null) {
      data['airport'] = airport!.toJson();
    }
    return data;
  }
}

class Airport {
  int? id;
  String? name;
  String? city;
  String? province;
  String? code;
  String? timezone;

  Airport(
      {this.id, this.name, this.city, this.province, this.code, this.timezone});

  Airport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    city = json['city'];
    province = json['province'];
    code = json['code'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['city'] = city;
    data['province'] = province;
    data['code'] = code;
    data['timezone'] = timezone;
    return data;
  }
}
