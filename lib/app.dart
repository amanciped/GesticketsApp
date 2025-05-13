import 'package:flutter/material.dart';
import 'screens/create_ticket_screen.dart';
import 'screens/ticket_list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GesTickets',
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: const CreateTicketScreen(),
      home: const TicketListScreen(),
    );
  }
}