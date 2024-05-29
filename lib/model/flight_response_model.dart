class FlightResponseModel {
  String? status;
  String? message;
  Flight? flight;

  FlightResponseModel({this.status, this.message, this.flight});

  FlightResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    flight = json['flight'] != null ? Flight.fromJson(json['flight']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (flight != null) {
      data['flight'] = flight!.toJson();
    }
    return data;
  }
}

class Flight {
  int? id;
  String? airline;
  String? flightNumber;
  String? departureTime;
  String? arrivalTime;
  int? originId;
  int? destinationId;

  Flight(
      {this.id,
      this.airline,
      this.flightNumber,
      this.departureTime,
      this.arrivalTime,
      this.originId,
      this.destinationId});

  Flight.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    airline = json['airline'];
    flightNumber = json['flightNumber'];
    departureTime = json['departure_time'];
    arrivalTime = json['arrival_time'];
    originId = json['originId'];
    destinationId = json['destinationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['airline'] = airline;
    data['flightNumber'] = flightNumber;
    data['departure_time'] = departureTime;
    data['arrival_time'] = arrivalTime;
    data['originId'] = originId;
    data['destinationId'] = destinationId;
    return data;
  }
}
