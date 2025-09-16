import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color colorPrimary = const Color(0xFF0473BD);
Color colorRad = const Color(0xFFD43343);
Color colorGrey = const Color(0xFFA1A1A1);
Color colorBlack = const Color.fromARGB(255, 38, 38, 38);
// Color color1 = const Color(0xFF3B47FF);

Color colorTextPrimary = colorPrimary;
Color colorTextGrey = Colors.grey.shade400;
Color colorTextAlert = colorRad;
Color colorTextWhite = Colors.white;

BoxShadow boxShadow =
    BoxShadow(color: colorGrey, blurRadius: 6, offset: const Offset(4, 4));
BorderRadius borderRadius = BorderRadius.circular(16);
BorderRadius borderRadiusTheme = BorderRadius.circular(14);

double marginHorizontal = 16.0;

TextTheme textTheme =
    GoogleFonts.mPlusRounded1cTextTheme().apply(bodyColor: colorBlack);
