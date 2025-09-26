import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:securywallet/CryptoWalletApp/CryptoWalletApp_View.dart';
import 'package:securywallet/Crypto_Utils/Fetch_All_Provider/Fetch_All_Provider.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/VaultStorageService/VaultStorageService.dart';
import 'package:securywallet/firebase_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await VaultStorageService().init();
  await LocalStorageService().initializeBoxes();

  runApp(
    MultiProvider(
      providers: fetchAllProvider(),
      child: CryptoWalletApp(),
    ),
  );
}


