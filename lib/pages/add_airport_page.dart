import 'package:flight_system_admin/connection/api_data_source.dart';
import 'package:flight_system_admin/model/airport_response_model.dart';
import 'package:flight_system_admin/pages/home_page.dart';
import 'package:flight_system_admin/utils/colors.dart';
import 'package:flight_system_admin/widgets/buttons.dart';
import 'package:flight_system_admin/widgets/text_fields.dart';
import 'package:flight_system_admin/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAirportPage extends StatefulWidget {
  const AddAirportPage({super.key});

  @override
  State<AddAirportPage> createState() => _AddAirportPageState();
}

class _AddAirportPageState extends State<AddAirportPage> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _timezoneController;
  List<String> timezones = ['WIB', 'WITA', 'WIT'];
  String token = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _timezoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _timezoneController.dispose();
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
          title: boldDefaultText('Add New Airport', TextAlign.center),
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
                  listTitleText('Airport Details'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _nameController, placeholder: 'Airport Name'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _codeController, placeholder: 'Airport Code'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _cityController, placeholder: 'City'),
                  const SizedBox(height: 15),
                  textFieldWithLabel(
                      controller: _provinceController, placeholder: 'Province'),
                  const SizedBox(height: 15),
                  _timezoneDropdown('Time Zone', _timezoneController),
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

  DropdownMenu<String> _timezoneDropdown(
      String title, TextEditingController controller) {
    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 30,
      controller: controller,
      label: Text(title),
      initialSelection: 'WIB',
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
      dropdownMenuEntries: timezones.map<DropdownMenuEntry<String>>(
        (String timezone) {
          return DropdownMenuEntry<String>(
            value: timezone,
            label: timezone,
          );
        },
      ).toList(),
    );
  }

  void _sendRequest() {
    if (_nameController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _timezoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All values must not be empty!')),
      );
    } else {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> body = {
        "name": _nameController.text.trim(),
        "code": _codeController.text.trim(),
        "city": _cityController.text.trim(),
        "province": _provinceController.text.trim(),
        "timezone": _timezoneController.text
      };
      ApiDataSource.postAirport(token, body).then((data) {
        AirportResponseModel response = AirportResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Airport added successfully.';
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const HomePage(index: 0);
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
