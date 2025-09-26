import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:securywallet/Crypto_Utils/Asset_Path/Asset_Path.dart';


class Utils {
  late BuildContext context;

  Utils(this.context);

  // this is where you would do your fullscreen loading
  Future<void> startLoading() async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Theme.of(context)
              .canvasColor, // can change this to your prefered color
          children: <Widget>[
            Center(
                child: Container(
                    child: Image.asset(
              assetPath.loaderGif,
              height: 100,
              width: 100,
            )))
          ],
        );
      },
    );
  }

  Future<void> stopLoading() async {
    Navigator.of(context).pop();
  }

  static snackBar(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT, // ~3.5s
    );
  }

  static snackBarErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG, // ~3.5s
    );
  }

  Future<void> showError(Object? error) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        // backgroundColor: Theme.of(context).errorColor,
        backgroundColor: Colors.red,
        content: Text(("error")),
      ),
    );
  }
}
