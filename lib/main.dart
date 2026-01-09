import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/station_repository.dart';
import 'viewmodels/station_list_view_model.dart';
import 'views/station_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StationRepository>(create: (_) => StationRepositoryImpl()),
        ChangeNotifierProvider<StationListViewmodel>(
          create: (ctx) => StationListViewmodel(repository: ctx.read<StationRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'BiciCoruña Alt',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const StationListScreen(),
        debugShowCheckedModeBanner: false,
      
      ),
    );
  }
}