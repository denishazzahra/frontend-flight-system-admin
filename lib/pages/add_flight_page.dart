import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/api_data_source.dart';
import '../model/airport_model.dart';
import '../model/flight_response_model.dart';
import '../utils/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';
import '../widgets/texts.dart';
import 'home_page.dart';

class AddFlightPage extends StatefulWidget {
  const AddFlightPage({super.key});

  @override
  State<AddFlightPage> createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  late TextEditingController _airlineController;
  late TextEditingController _flightNumberController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  List<Airport> airportList = [];
  String token = '';
  String selectedOrigin = '', selectedDestination = '';
  bool _isLoading = false;
  final TimeOfDay _selectedDepartureTime = const TimeOfDay(hour: 0, minute: 0);
  final TimeOfDay _selectedArrivalTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadAirports();
    _airlineController = TextEditingController();
    _flightNumberController = TextEditingController();
    _departureTimeController = TextEditingController();
    _departureTimeController.text = '00:00:00';
    _arrivalTimeController = TextEditingController();
    _arrivalTimeController.text = '00:00:00';
    _originController = TextEditingController();
    _destinationController = TextEditingController();
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
          title: boldDefaultText('Add New Flight', TextAlign.center),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
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
                  _isLoading
                      ? CircularProgressIndicator(color: blackColor)
                      : blackButton(context, 'Add', _sendRequest),
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
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    });
  }

  void _sendRequest() {
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
        _isLoading = true;
      });
      Map<String, dynamic> body = {
        "airline": _airlineController.text.trim(),
        "flightNumber": _flightNumberController.text.trim(),
        "departure_time": _departureTimeController.text.trim(),
        "arrival_time": _arrivalTimeController.text.trim(),
        "originId": int.parse(selectedOrigin),
        "destinationId": int.parse(selectedDestination)
      };
      ApiDataSource.postFlight(token, body).then((data) {
        FlightResponseModel response = FlightResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Flight added successfully.';
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
          _isLoading = false;
        });
      });
    }
  }

  void _loadToken() {
    SharedPreferences.getInstance().then((storage) {
      setState(() {
        token = storage.getString('token')!;
      });
    });
  }
}
