import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/flight_model.dart';
import '../connection/api_data_source.dart';
import '../model/seat_response_model.dart';
import '../utils/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';
import '../widgets/texts.dart';
import 'home_page.dart';

class EditSeatPage extends StatefulWidget {
  final int flightId;
  final Seats seat;
  const EditSeatPage({super.key, required this.flightId, required this.seat});

  @override
  State<EditSeatPage> createState() => _EditSeatPageState();
}

class _EditSeatPageState extends State<EditSeatPage> {
  late TextEditingController _classController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;
  String token = '';
  bool _isLoadingUpdate = false;
  bool _isLoadingDelete = false;
  List<String> classes = ['Economy', 'Business'];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _classController = TextEditingController();
    _capacityController = TextEditingController();
    _priceController = TextEditingController();
    setState(() {
      _classController.text = widget.seat.type!;
      _capacityController.text = widget.seat.capacity!.toString();
      _priceController.text = widget.seat.price!.toString();
    });
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
          title: boldDefaultText('Update Seat', TextAlign.center),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
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

  void _sendRequestUpdate() {
    if (_classController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All values must not be empty!')),
      );
    } else {
      setState(() {
        _isLoadingUpdate = true;
      });
      Map<String, dynamic> body = {
        "type": _classController.text.trim(),
        "capacity": double.tryParse(_capacityController.text.trim()),
        "price": double.tryParse(_priceController.text.trim()),
        "flightId": widget.flightId
      };
      ApiDataSource.putSeat(widget.seat.id!, token, body).then((data) {
        SeatResponseModel response = SeatResponseModel.fromJson(data);
        String text = '';
        if (response.status == 'Success') {
          text = 'Seat updated successfully.';
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

  DropdownMenu<String> _classDropdown(
      String title, TextEditingController controller) {
    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 30,
      controller: controller,
      label: Text(title),
      initialSelection: widget.seat.type!,
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
                const Text('Are you sure you want to delete this seat?'),
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

    ApiDataSource.deleteSeat(widget.seat.id!, token).then((data) {
      SeatResponseModel response = SeatResponseModel.fromJson(data);
      String text = '';
      if (response.status == 'Success') {
        text = 'Seat deleted successfully.';
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
