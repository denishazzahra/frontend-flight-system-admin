import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connection/api_data_source.dart';
import '../model/airport_response_model.dart';
import '../utils/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';
import '../widgets/texts.dart';
import 'home_page.dart';

class EditAirportPage extends StatefulWidget {
  final int id;
  final String name;
  final String code;
  final String city;
  final String province;
  final String timezone;
  const EditAirportPage(
      {super.key,
      required this.id,
      required this.name,
      required this.code,
      required this.city,
      required this.province,
      required this.timezone});

  @override
  State<EditAirportPage> createState() => _EditAirportPageState();
}

class _EditAirportPageState extends State<EditAirportPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  List<String> timezones = ['WIB', 'WITA', 'WIT'];
  String token = '';
  bool _isLoadingUpdate = false;
  bool _isLoadingDelete = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _nameController.text = widget.name;
    _codeController.text = widget.code;
    _cityController.text = widget.city;
    _provinceController.text = widget.province;
    _timezoneController.text = widget.timezone;
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
          title: boldDefaultText('Update Airport', TextAlign.center),
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

  DropdownMenu<String> _timezoneDropdown(
      String title, TextEditingController controller) {
    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 30,
      controller: controller,
      label: Text(title),
      initialSelection: widget.timezone,
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

  void _sendRequestUpdate() {
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
        _isLoadingUpdate = true;
      });
      Map<String, dynamic> body = {
        "name": _nameController.text.trim(),
        "code": _codeController.text.trim(),
        "city": _cityController.text.trim(),
        "province": _provinceController.text.trim(),
        "timezone": _timezoneController.text
      };
      ApiDataSource.putAirport(widget.id, token, body).then((data) {
        AirportResponseModel response = AirportResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Airport updated successfully.';
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
                const Text('Are you sure you want to delete this airport?'),
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

    ApiDataSource.deleteAirport(widget.id, token).then((data) {
      AirportResponseModel response = AirportResponseModel.fromJson(data);
      String text = '';
      if (response.status == 'Success') {
        text = 'Airport deleted successfully.';
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
