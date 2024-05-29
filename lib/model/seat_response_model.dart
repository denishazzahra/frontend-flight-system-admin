class SeatResponseModel {
  String? status;
  String? message;
  Seat? seat;

  SeatResponseModel({this.status, this.message, this.seat});

  SeatResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    seat = json['seat'] != null ? Seat.fromJson(json['seat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (seat != null) {
      data['seat'] = seat!.toJson();
    }
    return data;
  }
}

class Seat {
  int? id;
  String? type;
  int? capacity;
  int? price;
  int? flightId;

  Seat({this.id, this.type, this.capacity, this.price, this.flightId});

  Seat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    capacity = json['capacity'];
    price = json['price'];
    flightId = json['flightId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['capacity'] = capacity;
    data['price'] = price;
    data['flightId'] = flightId;
    return data;
  }
}
