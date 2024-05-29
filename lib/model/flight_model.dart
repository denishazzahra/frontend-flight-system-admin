class FlightListModel {
  String? status;
  String? message;
  List<Flights>? flights;

  FlightListModel({this.status, this.message, this.flights});

  FlightListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['flights'] != null) {
      flights = <Flights>[];
      json['flights'].forEach((v) {
        flights!.add(Flights.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (flights != null) {
      data['flights'] = flights!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Flights {
  int? id;
  String? airline;
  String? flightNumber;
  String? departureTime;
  String? arrivalTime;
  OriginAirport? originAirport;
  OriginAirport? destinationAirport;
  List<Seats>? seats;

  Flights(
      {this.id,
      this.airline,
      this.flightNumber,
      this.departureTime,
      this.arrivalTime,
      this.originAirport,
      this.destinationAirport,
      this.seats});

  Flights.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    airline = json['airline'];
    flightNumber = json['flightNumber'];
    departureTime = json['departure_time'];
    arrivalTime = json['arrival_time'];
    originAirport = json['origin_airport'] != null
        ? OriginAirport.fromJson(json['origin_airport'])
        : null;
    destinationAirport = json['destination_airport'] != null
        ? OriginAirport.fromJson(json['destination_airport'])
        : null;
    if (json['seats'] != null) {
      seats = <Seats>[];
      json['seats'].forEach((v) {
        seats!.add(Seats.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['airline'] = airline;
    data['flightNumber'] = flightNumber;
    data['departure_time'] = departureTime;
    data['arrival_time'] = arrivalTime;
    if (originAirport != null) {
      data['origin_airport'] = originAirport!.toJson();
    }
    if (destinationAirport != null) {
      data['destination_airport'] = destinationAirport!.toJson();
    }
    if (seats != null) {
      data['seats'] = seats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OriginAirport {
  String? name;
  String? code;
  String? city;
  String? province;
  String? timezone;

  OriginAirport(
      {this.name, this.code, this.city, this.province, this.timezone});

  OriginAirport.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    city = json['city'];
    province = json['province'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['city'] = city;
    data['province'] = province;
    data['timezone'] = timezone;
    return data;
  }
}

class Seats {
  int? id;
  String? type;
  int? capacity;
  int? price;

  Seats({this.id, this.type, this.capacity, this.price});

  Seats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    capacity = json['capacity'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['capacity'] = capacity;
    data['price'] = price;
    return data;
  }
}
