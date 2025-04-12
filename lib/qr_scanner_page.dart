// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'team_info_page.dart';
//
// class QRScannerPage extends StatefulWidget {
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }
//
// class _QRScannerPageState extends State<QRScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   Map<String, dynamic>? teamData;
//   bool hasPermission = false;
//   bool isFlashOn = false;
//
//   @override
//   void initState() {
//     super.initState();
//     requestCameraPermission();
//     loadTeamData();
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   Future<void> requestCameraPermission() async {
//     var status = await Permission.camera.status;
//     if (!status.isGranted) {
//       status = await Permission.camera.request();
//     }
//     setState(() => hasPermission = status.isGranted);
//     if (!hasPermission) showPermissionDeniedDialog();
//   }
//
//   void showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text('Permission Required'),
//             content: Text('Camera permission is required to scan QR codes.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }
//
//   Future<void> loadTeamData() async {
//     String jsonString = await rootBundle.loadString('assets/team.json');
//     teamData = json.decode(jsonString);
//   }
//
//   void _onQRViewCreated(QRViewController ctrl) {
//     controller = ctrl;
//     ctrl.scannedDataStream.listen((scanData) {
//       final String? teamId = scanData.code?.trim();
//
//       if (teamId != null && teamData != null && teamData!.containsKey(teamId)) {
//         controller?.pauseCamera();
//         print('TEAM DATA = ${teamData![teamId]!}');
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (_) => TeamInfoPage(data: teamData![teamId]!, teamId: teamId),
//           ),
//         ).then((_) => controller?.resumeCamera());
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid QR or team not found!')),
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100),
//         child: AppBar(
//           backgroundColor: Colors.purple,
//           flexibleSpace: Padding(
//             padding: const EdgeInsets.only(
//               left: 20.0,
//               right: 20.0,
//               top: 20.0,
//               bottom: 5.0,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Image.asset(
//                   'assets/logo.png',
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.contain,
//                 ),
//                 Image.asset(
//                   'assets/cslogo.png',
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.contain,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//
//       body:
//           hasPermission
//               ? Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: Text(
//                       'Scan the Team QR',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Stack(
//                       children: [
//                         QRView(
//                           key: qrKey,
//                           onQRViewCreated: _onQRViewCreated,
//                           overlay: QrScannerOverlayShape(
//                             borderColor: Colors.green,
//                             borderRadius: 10,
//                             borderLength: 30,
//                             borderWidth: 10,
//                             cutOutSize: MediaQuery.of(context).size.width * 0.7,
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 20,
//                           left: 0,
//                           right: 0,
//                           child: Center(
//                             child: ElevatedButton.icon(
//                               icon: Icon(
//                                 isFlashOn ? Icons.flash_off : Icons.flash_on,
//                               ),
//                               label: Text(isFlashOn ? 'Flash Off' : 'Flash On'),
//                               onPressed: () async {
//                                 await controller?.toggleFlash();
//                                 bool? flashStatus =
//                                     await controller?.getFlashStatus();
//                                 setState(
//                                   () => isFlashOn = flashStatus ?? false,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//               : Center(child: Text('Requesting camera permission...')),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'team_info_page.dart';
import 'Rankings.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Map<String, dynamic>? teamData;
  bool hasPermission = false;
  bool isFlashOn = false;
  bool isCameraPaused = false;

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    loadTeamData();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    setState(() => hasPermission = status.isGranted);
    if (!hasPermission) showPermissionDeniedDialog();
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('Camera permission is required to scan QR codes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> loadTeamData() async {
    String jsonString = await rootBundle.loadString('assets/team.json');
    teamData = json.decode(jsonString);
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      final String? teamId = scanData.code?.trim();

      if (teamId != null && teamData != null && teamData!.containsKey(teamId)) {
        controller?.pauseCamera();
        setState(() => isCameraPaused = true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamInfoPage(data: teamData![teamId]!, teamId: teamId),
          ),
        ).then((_) async {
          await controller?.resumeCamera();
          setState(() => isCameraPaused = false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid QR or team not found!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.purple,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logo.png', height: 150, width: 150, fit: BoxFit.contain),
                Image.asset('assets/cslogo.png', height: 150, width: 150, fit: BoxFit.contain),
              ],
            ),
          ),
        ),
      ),
      body: hasPermission
          ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Scan the Team QR',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.green,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
                // Image that appears when the camera is paused
                if (isCameraPaused)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/qrlogo.png',  // Add the image you want here
                          height: MediaQuery.of(context).size.width * 0.7, // Adjust the image size to fit the QR view
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                // View Rankings Button - Centered above bottom buttons
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TeamRankingsPage()),
                        );
                      },
                      child: Text(
                        'View Rankings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // Flash and Pause buttons side-by-side at the bottom
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          isFlashOn ? Icons.flash_off : Icons.flash_on,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFlashOn ? 'Flash Off' : 'Flash On',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () async {
                          await controller?.toggleFlash();
                          bool? flashStatus = await controller?.getFlashStatus();
                          setState(() => isFlashOn = flashStatus ?? false);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(
                          isCameraPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                        ),
                        label: Text(
                          isCameraPaused ? 'Resume' : 'Pause',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () async {
                          if (isCameraPaused) {
                            await controller?.resumeCamera();
                          } else {
                            await controller?.pauseCamera();
                          }
                          setState(() => isCameraPaused = !isCameraPaused);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : Center(child: Text('Requesting camera permission...')),
    );
  }
}
