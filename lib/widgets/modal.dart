import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../utils/token.dart';

class ModalFit extends StatefulWidget {
  const ModalFit({super.key});

  @override
  State<ModalFit> createState() => _ModalFitState();
}

class _ModalFitState extends State<ModalFit> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 15),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout_outlined),
            onTap: () {
              deleteToken();
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return const LoginPage();
                },
              ));
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    ));
  }
}
