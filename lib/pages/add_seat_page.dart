import 'package:flight_system_admin/model/seat_response_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/api_data_source.dart';
import '../utils/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';
import '../widgets/texts.dart';
import 'home_page.dart';

class AddSeatPage extends StatefulWidget {
  final int flightId;
  const AddSeatPage({super.key, required this.flightId});

  @override
  State<AddSeatPage> createState() => _AddSeatPageState();
}

class _AddSeatPageState extends State<AddSeatPage> {
  late TextEditingController _classController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;
  String token = '';
  bool _isLoading = false;
  List<String> classes = ['Economy', 'Business'];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _classController = TextEditingController();
    _capacityController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _classController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
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
          title: boldDefaultText('Add New Seat', TextAlign.center),
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
                  listTitleText('Seat Details'),
                  const SizedBox(height: 15),
                  _classDropdown('Class', _classController),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                    controller: _capacityController,
                    placeholder: 'Capacity',
                    numOnly: true,
                  ),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                    controller: _priceController,
                    placeholder: 'Price',
                    numOnly: true,
                  ),
                  const SizedBox(height: 15),
                  _isLoading
                      ? CircularProgressIndicator(color: blackColor)
                      : blackButton(context, 'Add', _sendRequest)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendRequest() {
    if (_classController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All values must not be empty!')),
      );
    } else {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> body = {
        "type": _classController.text.trim(),
        "capacity": double.tryParse(_capacityController.text.trim()),
        "price": double.tryParse(_priceController.text.trim()),
        "flightId": widget.flightId
      };
      ApiDataSource.postSeat(token, body).then((data) {
        SeatResponseModel response = SeatResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Seat added successfully.';
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

  DropdownMenu<String> _classDropdown(
      String title, TextEditingController controller) {
    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 30,
      controller: controller,
      label: Text(title),
      initialSelection: 'Economy',
      enableSearch: false,
      enableFilter: false,
      requestFocusOnTap: false,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
      ),
      dropdownMenuEntries: classes.map<DropdownMenuEntry<String>>(
        (String timezone) {
          return DropdownMenuEntry<String>(
            value: timezone,
            label: timezone,
          );
        },
      ).toList(),
    );
  }

  void _loadToken() {
    SharedPreferences.getInstance().then((storage) {
      setState(() {
        token = storage.getString('token')!;
      });
    });
  }
}
