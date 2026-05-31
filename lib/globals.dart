import 'package:flutter/material.dart';

const String baseUrl = 'https://api.zync-app.net'; 

final ValueNotifier<int> unreadNotisCount = ValueNotifier<int>(0);
final ValueNotifier<int> unreadMessagesCount = ValueNotifier<int>(0);