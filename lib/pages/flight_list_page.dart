import 'package:flight_system_admin/pages/add_seat_page.dart';
import 'package:flight_system_admin/utils/numbers.dart';
import 'package:flight_system_admin/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../connection/api_data_source.dart';
import '../model/flight_model.dart';
import '../utils/colors.dart';
import '../utils/date.dart';
import '../widgets/texts.dart';
import 'edit_flight_page.dart';
import 'edit_seat_page.dart';

class FlightListPage extends StatefulWidget {
  const FlightListPage({super.key});

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  List<Flights> flightList = [];
  List<bool> stateIndex = [];
  String title = '';
  late DateTime parsedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  @override
  Widget build(BuildContext context) {
    return _flightDisplay();
  }

  Widget _flightDisplay() {
    return flightList.isNotEmpty
        ? ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if (index == flightList.length + 1) {
                return const SizedBox(height: 60);
              } else if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      listTitleText('Flights')
                    ],
                  ),
                );
              }
              return _flightItem(index - 1);
            },
            itemCount: flightList.length + 2,
          )
        : Center(
            child: _isLoading
                ? CircularProgressIndicator(color: blackColor)
                : const Text('No flight is available.'));
  }

  Widget _flightItem(int index) {
    int cheapestPrice = 0;
    if (flightList[index].seats!.isNotEmpty) {
      cheapestPrice = flightList[index].seats![0].price!;
      for (var seat in flightList[index].seats!) {
        if (seat.price! < cheapestPrice) {
          cheapestPrice = seat.price!;
        }
      }
    }
    double topMargin = index == 0 ? 15 : 7.5;
    double bottomMargin = index == flightList.length - 1 ? 15 : 7.5;
    Map<String, String> duration = flightDuration(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      flightList[index].departureTime!,
      flightList[index].originAirport!.timezone!,
      flightList[index].arrivalTime!,
      flightList[index].destinationAirport!.timezone!,
      true,
    );
    return InkWell(
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return EditFlightPage(flight: flightList[index]);
          }),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: topMargin,
          bottom: bottomMargin,
          left: 15,
          right: 15,
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: lightGreyColor),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: listTitleText(
                      '${flightList[index].airline!} (${flightList[index].flightNumber})'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    smallerSubText('Available from', TextAlign.right),
                    boldDefaultText(formatNumber(cheapestPrice, 'IDR', true),
                        TextAlign.right)
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Symbols.my_location,
                            fill: 0,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 85,
                            child: boldSmallText(
                              duration['departure_time']!,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: smallerSubText(
                            '${flightList[index].originAirport!.name!} (${flightList[index].originAirport!.code!})',
                            TextAlign.left),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const SizedBox(width: 30),
                smallerSubText('${duration['duration']} ${duration['note']}',
                    TextAlign.left)
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Symbols.location_on,
                            fill: 0,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 85,
                            child: boldSmallText(
                              duration['arrival_time']!,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: smallerSubText(
                            '${flightList[index].destinationAirport!.name!} (${flightList[index].destinationAirport!.code!})',
                            TextAlign.left),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    setState(() {
                      stateIndex[index] = !stateIndex[index];
                    });
                  },
                  icon: Icon(
                    stateIndex[index]
                        ? Symbols.keyboard_arrow_down
                        : Symbols.keyboard_arrow_right,
                    fill: 0,
                  ),
                  iconSize: 24,
                  splashRadius: 24,
                  constraints:
                      const BoxConstraints.tightFor(height: 24, width: 24),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            _flightDetail(index)
          ],
        ),
      ),
    );
  }

  Widget _flightDetail(int index) {
    return stateIndex[index] && flightList[index].seats!.isNotEmpty
        ? Column(
            children: [
              ...flightList[index].seats!.asMap().entries.map((item) {
                double topMargin = item.key == 0 ? 15 : 7.5;
                double bottomMargin =
                    item.key == flightList[index].seats!.length - 1 ? 0 : 7.5;
                return InkWell(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return EditSeatPage(
                          flightId: flightList[index].id!,
                          seat: item.value,
                        );
                      }),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(top: topMargin, bottom: bottomMargin),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: lightGreyColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              boldDefaultText(item.value.type!, TextAlign.left),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            disableSubText('Price', TextAlign.end),
                            boldSmallText(
                                formatNumber(item.value.price!, 'IDR', true),
                                TextAlign.right),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 15),
              blackButton(context, 'Add Seat', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddSeatPage(flightId: flightList[index].id!);
                }));
              }),
            ],
          )
        : stateIndex[index] && flightList[index].seats!.isEmpty
            ? Column(
                children: [
                  const SizedBox(height: 15),
                  blackButton(context, 'Add Seat', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddSeatPage(flightId: flightList[index].id!);
                    }));
                  }),
                ],
              )
            : Container();
  }

  void _loadFlights() {
    ApiDataSource.getFlights().then((data) {
      setState(() {
        flightList = FlightListModel.fromJson(data).flights!;
        stateIndex = List.filled(flightList.length, false);
      });
    }).catchError((error) {
      setState(() {
        flightList = [];
        stateIndex = [];
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
