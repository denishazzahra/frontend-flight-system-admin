import 'package:flight_system_admin/model/airport_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/api_data_source.dart';
import '../model/flight_model.dart';
import '../model/flight_response_model.dart';
import '../utils/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';
import '../widgets/texts.dart';
import 'home_page.dart';

class EditFlightPage extends StatefulWidget {
  final Flights flight;
  const EditFlightPage({super.key, required this.flight});

  @override
  State<EditFlightPage> createState() => _EditFlightPageState();
}

class _EditFlightPageState extends State<EditFlightPage> {
  late TextEditingController _airlineController;
  late TextEditingController _flightNumberController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  List<Airport> airportList = [];
  String token = '';
  String selectedOrigin = '', selectedDestination = '';
  bool _isLoadingUpdate = false, _isLoadingDelete = false;
  late TimeOfDay _selectedDepartureTime;
  late TimeOfDay _selectedArrivalTime;
  late DateTime temp;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadAirports();
    setState(() {
      temp = DateFormat('HH:mm:ss').parse(widget.flight.departureTime!);
      _selectedDepartureTime = TimeOfDay(hour: temp.hour, minute: temp.minute);
      temp = DateFormat('HH:mm:ss').parse(widget.flight.arrivalTime!);
      _selectedArrivalTime = TimeOfDay(hour: temp.hour, minute: temp.minute);
    });
    _airlineController = TextEditingController();
    _airlineController.text = widget.flight.airline!;
    _flightNumberController = TextEditingController();
    _flightNumberController.text = widget.flight.flightNumber!;
    _departureTimeController = TextEditingController();
    _departureTimeController.text = widget.flight.departureTime!;
    _arrivalTimeController = TextEditingController();
    _arrivalTimeController.text = widget.flight.arrivalTime!;
    _originController = TextEditingController();
    _destinationController = TextEditingController();
    setState(() {
      _originController.text =
          '${widget.flight.originAirport!.name!} (${widget.flight.originAirport!.code!})';
      _destinationController.text =
          '${widget.flight.destinationAirport!.name!} (${widget.flight.destinationAirport!.code!})';
    });
  }

  @override
  void dispose() {
    _airlineController.dispose();
    _flightNumberController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: whiteColor,
          centerTitle: true,
          title: boldDefaultText('Update Flight', TextAlign.center),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  listTitleText('Flight Details'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _airlineController, placeholder: 'Airline'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _flightNumberController,
                      placeholder: 'Flight Number'),
                  const SizedBox(height: 15),
                  timePicker('Departure Time (WIB)', _departureTimeController,
                      _selectedDepartureTime),
                  const SizedBox(height: 15),
                  timePicker('Arrival Time (WIB)', _arrivalTimeController,
                      _selectedArrivalTime),
                  const SizedBox(height: 15),
                  airportDropdown('Origin', _originController),
                  const SizedBox(height: 15),
                  airportDropdown('Destination', _destinationController),
                  const SizedBox(height: 15),
                  _isLoadingUpdate
                      ? CircularProgressIndicator(color: blackColor)
                      : blackButton(context, 'Update', _sendRequestUpdate),
                  const SizedBox(height: 15),
                  _isLoadingDelete
                      ? CircularProgressIndicator(color: blackColor)
                      : outlinedButton(context, 'Delete', _sendRequestDelete),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget timePicker(
      String title, TextEditingController controller, TimeOfDay pickedTime) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () {
        _selectTime(context, controller, pickedTime);
      },
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor, width: 1.5),
        ),
        labelText: title,
      ),
    );
  }

  DropdownMenu<String> airportDropdown(
      String title, TextEditingController controller) {
    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 30,
      initialSelection:
          title == 'Origin' ? selectedOrigin : selectedDestination,
      controller: controller,
      enableFilter: true,
      requestFocusOnTap: true,
      label: Text(title),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: lightGreyColor, width: 1.5),
        ),
      ),
      onSelected: (String? airport) {
        setState(() {
          if (title == 'Origin') {
            selectedOrigin = airport!;
          } else {
            selectedDestination = airport!;
          }
        });
      },
      dropdownMenuEntries: airportList.map<DropdownMenuEntry<String>>(
        (Airport airport) {
          return DropdownMenuEntry<String>(
            value: airport.id!.toString(),
            label: '${airport.name} (${airport.code})',
          );
        },
      ).toList(),
    );
  }

  void _selectTime(BuildContext context, TextEditingController controller,
      TimeOfDay pickedTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blackColor, // Header background color
            dividerColor: whiteColor,
            // accentColor: Colors.black, // Text color of selected date
            colorScheme: ColorScheme.light(
              primary: blackColor, // Selected date color
              onPrimary: whiteColor, // Text color on selected date
              surface: whiteColor, // Background color
            ),
            dialogBackgroundColor: whiteColor, // Background color of the picker
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != pickedTime) {
      // Handle the selected date (picked)
      setState(() {
        String parsedTime = DateFormat('HH:mm:ss')
            .format(DateTime(0, 0, 0, picked.hour, picked.minute, 0));
        controller.text = parsedTime;
        pickedTime = picked;
      });
    }
  }

  void _loadAirports() {
    ApiDataSource.getAirports().then((data) {
      setState(() {
        airportList = AirportList.fromJson(data).airport!;
        selectedOrigin = airportList
            .firstWhere(
                (airport) => airport.name == widget.flight.originAirport!.name!)
            .id!
            .toString();
        selectedDestination = airportList
            .firstWhere((airport) =>
                airport.name == widget.flight.destinationAirport!.name!)
            .id!
            .toString();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    });
  }

  void _sendRequestUpdate() {
    if (_airlineController.text.trim().isEmpty ||
        _flightNumberController.text.trim().isEmpty ||
        _departureTimeController.text.trim().isEmpty ||
        _arrivalTimeController.text.trim().isEmpty ||
        selectedOrigin.isEmpty ||
        selectedDestination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All values must not be empty!')),
      );
    } else {
      setState(() {
        _isLoadingUpdate = true;
      });
      Map<String, dynamic> body = {
        "airline": _airlineController.text.trim(),
        "flightNumber": _flightNumberController.text.trim(),
        "departure_time": _departureTimeController.text.trim(),
        "arrival_time": _arrivalTimeController.text.trim(),
        "originId": int.parse(selectedOrigin),
        "destinationId": int.parse(selectedDestination)
      };
      ApiDataSource.putFlight(widget.flight.id!, token, body).then((data) {
        FlightResponseModel response = FlightResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Flight updated successfully.';
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const HomePage(index: 1);
          }));
        } else {
          text = response.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }).whenComplete(() {
        setState(() {
          _isLoadingUpdate = false;
        });
      });
    }
  }

  void _sendRequestDelete() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5),
            ),
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Confirm Deletion',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text('Are you sure you want to delete this flight?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: greyTextColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Proceed with the delete request
                        _confirmDelete();
                      },
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: dangerColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    setState(() {
      _isLoadingDelete = true;
    });

    ApiDataSource.deleteFlight(widget.flight.id!, token).then((data) {
      FlightResponseModel response = FlightResponseModel.fromJson(data);
      String text = '';
      if (response.status == 'Success') {
        text = 'Flight deleted successfully.';
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const HomePage(index: 1);
        }));
      } else {
        text = response.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }).whenComplete(() {
      setState(() {
        _isLoadingDelete = false;
      });
    });
  }

  void _loadToken() {
    SharedPreferences.getInstance().then((storage) {
      setState(() {
        token = storage.getString('token')!;
      });
    });
  }
}
