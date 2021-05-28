import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/main_screen.dart';
import './screens/welcome_screen.dart';
import 'modals/networking.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: SubtitleGetter())],
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.teal,
            fontFamily: 'TitilliumWeb',
            textTheme:
                TextTheme(headline6: TextStyle(fontFamily: 'TitilliumWeb'))),
        routes: {
          '/': (context) => MoviesScreen(),
          WelcomeScreen.routeName: (context) => WelcomeScreen()
        },
        initialRoute: WelcomeScreen.routeName,
      ),
    );
  }
}
