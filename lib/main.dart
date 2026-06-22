import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:city_pulse/app/app.dart';
import 'package:city_pulse/core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  await di.init();
  runApp(const App());
}
