import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/firestore_service.dart';
import 'screens/service_selection_screen.dart';
import 'theme/app_theme.dart';
import 'utils/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirestoreService().seedServicesIfEmpty(MockData.services);
  runApp(const ProviderScope(child: OmniBookingApp()));
}

class OmniBookingApp extends StatelessWidget {
  const OmniBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniBooking',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const ServiceSelectionScreen(),
    );
  }
}

 
