import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color inputFieldColor = Color(0xFFEDEDED);
const Color backgroundColor = Color(0xFFF6F6F6);
const Color textColor = Color(0xFF545D6E);
const Color authPrimaryColor = Color(0xFFF5EE50);
const Color authPrimaryTextColor = Color.fromARGB(255, 197, 189, 41);

class Themes {
  static ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: Color(0xFFEFEFEF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(
          color: textColor,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(textColor),
        ),
        fontFamily: GoogleFonts.roboto().fontFamily,
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: inputFieldColor,
          filled: true,
          hintStyle: TextStyle(
            fontSize: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          focusColor: textColor,
        ),
        textTheme: const TextTheme(
          headline5: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          bodyText2: TextStyle(
            color: textColor,
          ),
        ),
      );
}
