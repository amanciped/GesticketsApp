import 'package:flutter/material.dart';
import 'screens/ticket_list_screen.dart';

void main() => runApp(GesTicketsApp());

class GesTicketsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GesTickets',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TicketListScreen(),
    );
  }
}