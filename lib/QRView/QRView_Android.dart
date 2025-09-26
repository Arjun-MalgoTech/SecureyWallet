import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';
import 'package:securywallet/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:securywallet/Screens/Crypto_Transactions/SendCryptoPage.dart';
import 'package:securywallet/VaultStorageService/LocalDataServiceVM.dart';
import 'package:securywallet/WalletConnectFunctions/WalletConnectPage.dart';

class QRView extends StatefulWidget {
  QRView({Key? key, this.back}) : super(key: key);
  bool? back;
  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  TextEditingController addressController = TextEditingController();
  TextEditingController mnemonicController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Barcode? result;
  MobileScannerController controller = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isFlashOn = false;
  String? qrText;
  String _scanBarcode = 'Unknown';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  bool isValidCryptoAddress(String address) {
    if (address.contains(":")) {
      var addres = address.split(":").last;
      addres = addres.split("?").first;
      print("addres:::$addres");
      RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
      return ethereumAddressRegex.hasMatch(addres);
    } else {
      RegExp ethereumAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
      return ethereumAddressRegex.hasMatch(address);
    }
  }

  void _showManualEntryDialog() {
    TextEditingController manualEntryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Manual Entry',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          content: Container(
            width: SizeConfig.width(context, 100),
            height: SizeConfig.height(context, 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: SizeConfig.height(context, 8),
                    child: TextFormField(
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Please enter address";
                        }
                        // else if (!isValidCryptoAddress(v)) {
                        //   return "Please enter valid address";
                        // }
                        return null;
                      },
                      controller: manualEntryController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        decorationThickness: 0.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter QR Code Data',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          // Default border
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                          borderSide:
                              BorderSide(color: Colors.grey), // Border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          // Border when the field is enabled
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors
                                  .grey), // Change this to your desired color
                        ),
                        focusedBorder: OutlineInputBorder(
                          // Border when the field is focused
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2), // Change this to your desired color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppText(
                      'Cancel',
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    child: AppText(
                      'Submit',
                      color: Colors.black,
                    ),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        String enteredCode = manualEntryController.text;
                        print('////////////////////////$enteredCode');
                        if (enteredCode.isNotEmpty) {
                          Navigator.pop(context, manualEntryController.text);
                          if (widget.back == true) {
                            Navigator.pop(context, manualEntryController.text);
                          } else {
                            if (isValidCryptoAddress(enteredCode)) {
                              setState(() {
                                manualEntryController.text = enteredCode ?? '';
                              });
                              // }
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return SendCryptoPage(
                                      assetData:
                                          localStorageService.assetList[0],
                                      walletData:
                                          localStorageService.activeWalletData!,
                                      balance: localStorageService.userBalance
                                          .toString(),
                                      ethAddress: manualEntryController.text);
                                }), // Replace `YourTargetPage` with your desired page
                              );
                            } else if (isValidWalletConnectURI(enteredCode)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WalletConnectPage(
                                      selectedWalletData:
                                          localStorageService.activeWalletData!,
                                      wcURL: enteredCode),
                                ), // Replace `YourTargetPage` with your desired page
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Entered data is invalid'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid address'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          addressController.text = value;
          mnemonicController.text = value;
          print(
            " mnemonicController.text  back :::: ====11 ${mnemonicController.text}",
          );
          print(
            " addressController.text  back :::: ==== ${addressController.text}",
          );
        });
      }
    });
  }

  Future<void> pickImageFromGallery(context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final appDir = await getApplicationDocumentsDirectory();
      final imageFile = File('${appDir.path}/pickedImage.jpg');

      await imageFile.writeAsBytes(imageBytes);
      final result = await controller.analyzeImage(imageFile.path);

      // Ensure result is not null and is a list

      // Check if the list is not empty
      if (_scanBarcode.isEmpty) {
        print('........................$_scanBarcode is null');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No barcode detected in the image')),
          );
        }
      } else if (result != null && result.barcodes[0].rawValue != null) {
        setState(() {
          // Use the first element of the result list
          _scanBarcode = (result.barcodes[0].rawValue ?? 'Unknown')
              .toString(); // Assuming result is a list of barcode objects
        });

        print('........................$_scanBarcode');

        if (isValidCryptoAddress(_scanBarcode)) {
          setState(() {
            addressController.text = _scanBarcode ?? '';
          });
          // }
          if (widget.back == true) {
            Navigator.pop(context, addressController.text);
          } else {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return SendCryptoPage(
                    assetData: localStorageService.assetList[0],
                    walletData: localStorageService.activeWalletData!,
                    balance: localStorageService.userBalance.toString(),
                    ethAddress: addressController.text);
              }), // Replace `YourTargetPage` with your desired page
            );
          }
        } else if (isValidWalletConnectURI(_scanBarcode)) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletConnectPage(
                  selectedWalletData: localStorageService.activeWalletData!,
                  wcURL: _scanBarcode),
            ), // Replace `YourTargetPage` with your desired page
          );
        } else {
          setState(() {
            addressController.text = _scanBarcode ?? '';
          });
          // }
          if (widget.back == true) {
            Navigator.pop(context, addressController.text);
          }
        }
      } else {
        print('........................$_scanBarcode is null');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No barcode detected in the image')),
          );
        }
      }
    } else {
      print('........................$_scanBarcode is null');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No barcode detected in the image')),
        );
      }
    }
  }

  LocalStorageService localStorageService = LocalStorageService();
  @override
  Widget build(BuildContext context) {
    localStorageService = context.watch<LocalStorageService>();
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
        ),
        title: AppText(
          'Scan QR Code',
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              controller.toggleTorch();
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AppText(
                    'Scan a code',
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          _showManualEntryDialog();
                          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                          //   return const HomeView(dollar: '', privateKey: '');
                          // }), (route) => false);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.surfaceBright,
                          size: 15,
                        ),
                      ),
                      IconButton(
                        onPressed: () => pickImageFromGallery(context),
                        icon: Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.surfaceBright,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> processBarcode(String barcode) {
    // Check for a URL-like format with query parameters
    RegExp regExp = RegExp(r'([^?]*)\?.*=(.*)');
    Match? match = regExp.firstMatch(barcode);

    // Default values
    String barcodeValue = barcode;
    String value = '';

    if (match != null) {
      barcodeValue = match.group(1) ?? 'Unknown';
      value = match.group(2) ?? '';
    }

    // Additional check for specific prefixes like 'bsc coin:'
    if (barcodeValue.contains('bsc coin:')) {
      barcodeValue = barcodeValue.replaceFirst('bsc coin:', '').trim();
    }

    return {
      'barcode': barcodeValue,
      'value': value,
    };
  }

  bool isValidWalletConnectURI(String uri) {
    RegExp wcUriRegex = RegExp(r'^wc:[a-zA-Z0-9]+@[0-9]+\?.*$');
    return wcUriRegex.hasMatch(uri);
  }

  Widget _buildQrView(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset(0, -150)),
      width: SizeConfig.height(context, 25),
      height: SizeConfig.height(context, 25),
    );

    return Stack(
      children: [
        MobileScanner(
          fit: BoxFit.contain,
          controller: controller,
          scanWindow: scanWindow,
          overlayBuilder: (context, constraints) {
            return Padding(
                padding: const EdgeInsets.all(16.0), child: SizedBox());
          },
          onDetect: (barcode) {
            setState(() {
              String scannedValue =
                  (barcode.barcodes[0].rawValue ?? 'Unknown').toString();

              print(
                  'barcode:::::::${scannedValue == 'tb1qjfud4ws59zch35c2vqdky96r3ua58adp89spa6'}');

              // Use the helper function to process the barcode

              Map<String, String> resultData = processBarcode(scannedValue);

              print(
                  "barcode.rawValue  *************************::::::::::::::: $scannedValue");

              addressController.text = resultData['barcode'] ?? '';

              amountController.text = resultData['value'] ?? '';

              print('barcode.rawValue  :::11::::::::::$resultData');

              // Stop the scanner to prevent multiple detections

              controller.stop();

              // Check if the scanned value matches the specific address

              if (isValidWalletConnectURI(scannedValue)) {
                // Use the helper function to process the barcode

                Map<String, String> resultData = processBarcode(scannedValue);

                print("barcode.rawValue  ::::::::::::::: $scannedValue");

                //addressController.text = resultData['barcode'] ?? '';

                addressController.text = scannedValue ?? '';

                Navigator.pop(context, addressController.text);

                print(
                    "addressController.text ::::::::::>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${addressController.text}");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletConnectPage(
                        selectedWalletData:
                            localStorageService.activeWalletData!,
                        wcURL: scannedValue),
                  ),
                );
              } else if (isValidCryptoAddress(scannedValue)) {
                setState(() {
                  addressController.text = scannedValue ?? '';
                });

                // }

                if (widget.back == true) {
                  Navigator.pop(context, addressController.text);
                } else {
                  // print('ggggggggggggggggggggggggggggggggggggggggg');

                  Navigator.pop(context);

                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (context) {
                      return SendCryptoPage(
                          assetData: localStorageService.assetList[0],
                          walletData: localStorageService.activeWalletData!,
                          balance: localStorageService.userBalance.toString(),
                          ethAddress: addressController.text);
                    }), // Replace `YourTargetPage` with your desired page
                  );
                }
              } else {
                print('111$resultData');
                // If the address does not match, you can close the current dialog or screen

                Navigator.pop(context, resultData);
              }
            });
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            if (!value.isInitialized ||
                !value.isRunning ||
                value.error != null) {
              return const SizedBox();
            }

            return CustomPaint(
              painter: ScannerOverlay(scanWindow: scanWindow),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Define corner line length

    const cornerLength = 30.0;

    // Draw top-left corner

    canvas.drawLine(
      Offset(scanWindow.left + 2, scanWindow.top + cornerLength),
      Offset(scanWindow.left + 2, scanWindow.top),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top),
      Offset(scanWindow.left + cornerLength, scanWindow.top),
      cornerPaint,
    );

    // Draw top-right corner

    canvas.drawLine(
      Offset(scanWindow.right - 2, scanWindow.top + cornerLength),
      Offset(scanWindow.right - 2, scanWindow.top),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top),
      Offset(scanWindow.right - cornerLength, scanWindow.top),
      cornerPaint,
    );

    // Draw bottom-left corner

    canvas.drawLine(
      Offset(scanWindow.left + 2, scanWindow.bottom - cornerLength),
      Offset(scanWindow.left + 2, scanWindow.bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom),
      Offset(scanWindow.left + cornerLength, scanWindow.bottom),
      cornerPaint,
    );

    // Draw bottom-right corner

    canvas.drawLine(
      Offset(scanWindow.right - 2, scanWindow.bottom - cornerLength),
      Offset(scanWindow.right - 2, scanWindow.bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom),
      Offset(scanWindow.right - cornerLength, scanWindow.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}

class ScannedBarcodeLabel extends StatelessWidget {
  const ScannedBarcodeLabel({
    super.key,
    required this.barcodes,
  });

  final Stream<BarcodeCapture> barcodes;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: barcodes,
      builder: (context, snapshot) {
        final scannedBarcodes = snapshot.data?.barcodes ?? [];

        if (scannedBarcodes.isEmpty) {
          return SizedBox();
        }

        return Text(
          scannedBarcodes.first.displayValue ?? 'No display value.',
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.blue),
        );
      },
    );
  }
}
