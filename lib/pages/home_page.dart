import 'package:flight_system_admin/connection/api_data_source.dart';
import 'package:flight_system_admin/pages/add_airport_page.dart';
import 'package:flight_system_admin/pages/add_flight_page.dart';
import 'package:flight_system_admin/pages/edit_airport_page.dart';
import 'package:flight_system_admin/pages/flight_list_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/airport_model.dart';
import 'profile_page.dart';
import '../widgets/texts.dart';
import '../utils/colors.dart';
import '../widgets/appbar.dart';

class HomePage extends StatefulWidget {
  final int index;
  const HomePage({
    super.key,
    required this.index,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String token = '';
  late int currentPageIndex = widget.index;
  List<Airport> airports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAirports();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar(context),
        bottomNavigationBar: _bottomNavbar(),
        floatingActionButton: currentPageIndex != 2
            ? FloatingActionButton(
                onPressed: () {
                  if (currentPageIndex == 0) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AddAirportPage();
                    }));
                  } else if (currentPageIndex == 1) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AddFlightPage();
                    }));
                  }
                },
                shape: const CircleBorder(),
                backgroundColor: blackColor,
                child: Icon(
                  Symbols.add,
                  fill: 0,
                  weight: 600,
                  color: whiteColor,
                ),
              )
            : null,
        body: currentPageIndex == 0
            ? _airportDisplay()
            : currentPageIndex == 1
                ? const FlightListPage()
                : const ProfilePage(),
      ),
    );
  }

  Widget _airportDisplay() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: blackColor,
        ),
      );
    } else if (airports.isNotEmpty) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              listTitleText('Airports'),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: airports.asMap().entries.map((airport) {
                  return InkWell(
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return EditAirportPage(
                            id: airport.value.id!,
                            name: airport.value.name!,
                            code: airport.value.code!,
                            city: airport.value.city!,
                            province: airport.value.province!,
                            timezone: airport.value.timezone!,
                          );
                        }),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      margin: airport.key != airports.length - 1
                          ? const EdgeInsets.only(bottom: 15)
                          : null,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: lightGreyColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          boldDefaultText(
                            '${airport.value.name!} (${airport.value.code})',
                            TextAlign.left,
                          ),
                          const SizedBox(height: 10),
                          subText(
                            '${airport.value.city}, ${airport.value.province}',
                            TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text('No airport yet.'),
      );
    }
  }

  Widget _bottomNavbar() {
    return NavigationBar(
      elevation: 0,
      backgroundColor: whiteColor,
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      indicatorColor: blackColor,
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.flightsmode,
            color: Colors.white,
            fill: 1,
          ),
          icon: Icon(
            Symbols.flightsmode,
            fill: 0,
          ),
          label: 'Airport',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Symbols.airplane_ticket,
            color: Colors.white,
            fill: 1,
          ),
          icon: Icon(
            Symbols.airplane_ticket,
            fill: 0,
          ),
          label: 'Flight',
        ),
        NavigationDestination(
          selectedIcon: Icon(Symbols.person, color: Colors.white, fill: 1),
          icon: Icon(
            Symbols.person,
            fill: 0,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  void _loadAirports() {
    ApiDataSource.getAirports().then((data) {
      setState(() {
        airports = AirportList.fromJson(data).airport!;
      });
    }).catchError((error) {
      setState(() {
        airports = [];
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _loadToken() {
    SharedPreferences.getInstance().then((storage) {
      token = storage.getString('token')!;
    });
  }
}
