// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// // import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:scan/scan.dart';
// import 'package:nvwallet/App_Export/app_export.dart';
// import 'package:nvwallet/GetStorageService/FetchLocalDataVM.dart';
// import 'package:nvwallet/Users/Transactions/SendCoin/SendCoinPage.dart';
// import 'package:nvwallet/WalletConnectFunctions/WalletConnectPage.dart';
//
// class QRViewExample extends StatefulWidget {
//   QRViewExample({Key? key, this.back}) : super(key: key);
//   bool? back;
//   @override
//   State<StatefulWidget> createState() => _QRViewExampleState();
// }
//
// class _QRViewExampleState extends State<QRViewExample> {
//   TextEditingController addressController = TextEditingController();
//   TextEditingController mnemonicController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//
//   Barcode? result;
//   ScanController controller = ScanController();
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   bool isFlashOn = false;
//   String? qrText;
//   String _scanBarcode = 'Unknown';
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     super.initState();
//   }
//
//   bool isValidCryptoAddress(String address) {
//     if (address.contains(":")) {
//       var addres = address.split(":").last;
//       addres = addres.split("?").first;
//       print("addres:::$addres");
//       RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
//       return ethereumAddressRegex.hasMatch(addres);
//     } else {
//       RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
//       return ethereumAddressRegex.hasMatch(address);
//     }
//   }
//
//   void _showManualEntryDialog() {
//     TextEditingController manualEntryController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Manual Entry',
//             style: TextStyle(
//               fontSize: 15,
//               color: Colors.black,
//             ),
//           ),
//           content: Container(
//             width: AppSize.width(context, 100),
//             height: AppSize.height(context, 10),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Container(
//                     height: AppSize.height(context, 8),
//                     child: TextFormField(
//                       validator: (v) {
//                         if (v!.isEmpty) {
//                           return "Please enter address";
//                         }
//                         // else if (!isValidCryptoAddress(v)) {
//                         //   return "Please enter valid address";
//                         // }
//                         return null;
//                       },
//                       controller: manualEntryController,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 13,
//                         decorationThickness: 0.0,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: 'Enter QR Code',
//                         hintStyle: TextStyle(fontSize: 12),
//                         border: OutlineInputBorder(
//                           // Default border
//                           borderRadius:
//                               BorderRadius.circular(8.0), // Rounded corners
//                           borderSide:
//                               BorderSide(color: Colors.grey), // Border color
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           // Border when the field is enabled
//                           borderRadius: BorderRadius.circular(8.0),
//                           borderSide: BorderSide(
//                               color: Colors
//                                   .grey), // Change this to your desired color
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           // Border when the field is focused
//                           borderRadius: BorderRadius.circular(8.0),
//                           borderSide: BorderSide(
//                               color: Colors.grey,
//                               width: 2), // Change this to your desired color
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: AppText(
//                       'Cancel',
//                       color: Colors.black,
//                     ),
//                   ),
//                   GestureDetector(
//                     child: AppText(
//                       'Submit',
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       if (_formKey.currentState!.validate()) {
//                         String enteredCode = manualEntryController.text;
//                         print('////////////////////////$enteredCode');
//                         if (enteredCode.isNotEmpty) {
//                           Navigator.pop(context, enteredCode);
//                           Navigator.pop(context, enteredCode);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Please enter a valid address')),
//                           );
//                         }
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     ).then((value) {
//       if (value != null) {
//         setState(() {
//           addressController.text = value;
//           mnemonicController.text = value;
//           print(
//             " mnemonicController.text  back :::: ====11 ${mnemonicController.text}",
//           );
//           print(
//             " addressController.text  back :::: ==== ${addressController.text}",
//           );
//         });
//       }
//     });
//   }
//
//   Future<void> pickImageFromGallery(context) async {
//     controller.pause();
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       final imageBytes = await pickedFile.readAsBytes();
//       final appDir = await getApplicationDocumentsDirectory();
//       final imageFile = File('${appDir.path}/pickedImage.jpg');
//
//       await imageFile.writeAsBytes(imageBytes);
//       final result = await Scan.parse(imageFile.path);
//
//       // Ensure result is not null and is a list
//
//       // Check if the list is not empty
//       if (result == null) {
//         controller.resume();
//         print('........................$_scanBarcode is null');
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No barcode detected in the image')),
//           );
//         }
//       } else if (result.isNotEmpty) {
//         setState(() {
//           // Use the first element of the result list
//           _scanBarcode = (result ?? 'Unknown')
//               .toString(); // Assuming result is a list of barcode objects
//         });
//
//         print('........................$_scanBarcode');
//         if (_scanBarcode.isEmpty) {
//           controller.resume();
//           print('........................$_scanBarcode is null');
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('No barcode detected in the image')),
//             );
//           }
//         } else if (!isValidCryptoAddress(_scanBarcode)) {
//           controller.resume();
//         } else if (isValidCryptoAddress(_scanBarcode)) {
//           addressController.text = _scanBarcode ?? '';
//           if (widget.back == true) {
//             Navigator.pop(context, addressController.text);
//           } else {
//             Navigator.pop(context);
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) {
//                 return SendCoinPage(
//                     coinData: fetchLocalDataVM.coinList[0],
//                     userWallet: fetchLocalDataVM.walletDataList[0],
//                     balance: fetchLocalDataVM.balanceDux.toString(),
//                     ethAddress: _scanBarcode);
//               }), // Replace `YourTargetPage` with your desired page
//             );
//           }
//         }
//       } else if (_scanBarcode.isEmpty) {
//         controller.resume();
//         print('........................$_scanBarcode is null');
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No barcode detected in the image')),
//           );
//         }
//       }
//     } else {
//       controller.resume();
//       print('........................$_scanBarcode is null');
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No barcode detected in the image')),
//         );
//       }
//     }
//   }
//
//   FetchLocalDataVM fetchLocalDataVM = FetchLocalDataVM();
//   @override
//   Widget build(BuildContext context) {
//     fetchLocalDataVM = context.watch<FetchLocalDataVM>();
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child:
//               Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
//         ),
//         title: AppText(
//           'Scan QR Code',
//           color: Theme.of(context).colorScheme.surfaceBright,
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 isFlashOn = !isFlashOn;
//               });
//               controller.toggleTorchMode();
//             },
//             icon: Icon(
//               isFlashOn ? Icons.flash_on : Icons.flash_off,
//               color: isFlashOn ? Colors.blue : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(flex: 4, child: _buildQrView(context)),
//           Expanded(
//             flex: 1,
//             child: FittedBox(
//               fit: BoxFit.contain,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   if (result != null)
//                     Text(
//                       'Barcode Type: ${result!.format}   Data: ${result!.code}',
//                       style: const TextStyle(color: Colors.orange),
//                     )
//                   else
//                     AppText(
//                       'Scan a code',
//                       color: Theme.of(context).colorScheme.surfaceBright,
//                     ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       IconButton(
//                         onPressed: () {
//                           _showManualEntryDialog();
//                           // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
//                           //   return const HomeView(dollar: '', privateKey: '');
//                           // }), (route) => false);
//                         },
//                         icon: Icon(
//                           Icons.edit,
//                           color: Theme.of(context).colorScheme.surfaceBright,
//                           size: 15,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => pickImageFromGallery(context),
//                         icon: Icon(
//                           Icons.image,
//                           color: Theme.of(context).colorScheme.surfaceBright,
//                           size: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Map<String, String> processBarcode(String barcode) {
//     // Check for a URL-like format with query parameters
//     RegExp regExp = RegExp(r'([^?]*)\?.*=(.*)');
//     Match? match = regExp.firstMatch(barcode);
//
//     // Default values
//     String barcodeValue = barcode;
//     String value = '';
//
//     if (match != null) {
//       barcodeValue = match.group(1) ?? 'Unknown';
//       value = match.group(2) ?? '';
//     }
//
//     // Additional check for specific prefixes like 'bsc coin:'
//     if (barcodeValue.contains('bsc coin:')) {
//       barcodeValue = barcodeValue.replaceFirst('bsc coin:', '').trim();
//     }
//
//     return {
//       'barcode': barcodeValue,
//       'value': value,
//     };
//   }
//
//   bool isValidWalletConnectURI(String uri) {
//     RegExp wcUriRegex = RegExp(r'^wc:[a-zA-Z0-9]+@[0-9]+\?.*$');
//     return wcUriRegex.hasMatch(uri);
//   }
//
//   Widget _buildQrView(BuildContext context) {
//     var scanArea = (MediaQuery.of(context).size.width < 400 ||
//             MediaQuery.of(context).size.height < 400)
//         ? 300.0
//         : 350.0;
//
//     return ScanView(
//       controller: controller,
//       // allowDuplicates: false,
//       onCapture: (barcode) {
//         setState(() {
//           String scannedValue = (barcode ?? 'Unknown').toString();
//
//           print(
//               'barcode:::::::${scannedValue == 'tb1qjfud4ws59zch35c2vqdky96r3ua58adp89spa6'}');
//
//           // Use the helper function to process the barcode
//           Map<String, String> resultData = processBarcode(scannedValue);
//
//           print(
//               "barcode.rawValue  *************************::::::::::::::: $scannedValue");
//
//           addressController.text = resultData['barcode'] ?? '';
//           amountController.text = resultData['value'] ?? '';
//
//           print('barcode.rawValue  :::11::::::::::$resultData');
//
//           // Stop the scanner to prevent multiple detections
//           controller.pause();
//
//           // Check if the scanned value matches the specific address
//           if (isValidWalletConnectURI(scannedValue)) {
//             // Use the helper function to process the barcode
//             Map<String, String> resultData = processBarcode(scannedValue);
//
//             print("barcode.rawValue  ::::::::::::::: $scannedValue");
//
//             //addressController.text = resultData['barcode'] ?? '';
//             addressController.text = scannedValue ?? '';
//             Navigator.pop(context, addressController.text);
//
//             print(
//                 "addressController.text ::::::::::>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${addressController.text}");
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => WalletConnectMainPage(
//                     selectedWalletData: fetchLocalDataVM.selectedWalletData!,
//                     wcURL: scannedValue),
//               ), // Replace `YourTargetPage` with your desired page
//             );
//           } else if (isValidCryptoAddress(scannedValue)) {
//             addressController.text = scannedValue ?? '';
//             if (widget.back == true) {
//               Navigator.pop(context, addressController.text);
//             } else {
//               Navigator.pop(context);
//               print('ggggggggggggggggggggggggggggggggggggggggg');
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) {
//                   return SendCoinPage(
//                       coinData: fetchLocalDataVM.coinList[0],
//                       userWallet: fetchLocalDataVM.walletDataList[0],
//                       balance: fetchLocalDataVM.balanceDux.toString(),
//                       ethAddress: scannedValue);
//                 }), // Replace `YourTargetPage` with your desired page
//               );
//             }
//           } else {
//             // If the address does not match, you can close the current dialog or screen
//             Navigator.pop(context, resultData);
//           }
//         });
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     // controller.dispose();
//     super.dispose();
//   }
// }
