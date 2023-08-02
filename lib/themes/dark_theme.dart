import 'package:flutter/material.dart';

class MyAppTheme {
  static final dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(19, 28, 33, 1),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primaryContainer: const Color.fromRGBO(5, 96, 98, 1),
      secondaryContainer: const Color.fromRGBO(37, 45, 49, 1),
      tertiary: Colors.white,
      outline: const Color.fromRGBO(37, 45, 50, 1),
      surface: const Color.fromRGBO(30, 36, 40, 1),
      onSurface: const Color.fromRGBO(0, 167, 131, 1),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(0, 167, 131, 1),
      foregroundColor: Colors.white,
    ),
    tabBarTheme: const TabBarTheme(
      indicatorColor: Color.fromRGBO(0, 167, 131, 1),
      labelColor: Color.fromRGBO(0, 167, 131, 1),
      unselectedLabelColor: Colors.grey,
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStatePropertyAll(Colors.black),
        backgroundColor:
            MaterialStatePropertyAll(Color.fromRGBO(0, 167, 131, 1)),
        minimumSize: MaterialStatePropertyAll(Size(
          double.infinity,
          50,
        )),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color.fromRGBO(241, 241, 242, 1),
        fontSize: 33,
        fontWeight: FontWeight.w600,
      ),
      labelLarge:
          TextStyle(color: Color.fromRGBO(241, 241, 242, 1), fontSize: 18),
      labelMedium:
          TextStyle(color: Color.fromRGBO(241, 241, 242, 1), fontSize: 15),
      labelSmall: TextStyle(color: Colors.grey, fontSize: 13),
    ),
    dividerColor: const Color.fromRGBO(37, 45, 50, 1),
    searchViewTheme: const SearchViewThemeData(
      backgroundColor: Color.fromRGBO(31, 44, 52, 1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(31, 44, 52, 1),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      foregroundColor: Colors.white,
    ),
  );
}
