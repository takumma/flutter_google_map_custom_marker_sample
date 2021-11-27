import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<MarkerData> _markerData =
      List.generate(4, (index) => MarkerData(latLng: LatLng(0, 5.0 * index)));

  Future<Uint8List> _capturePng(GlobalKey iconKey) async {
    if (iconKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng(iconKey);
    }

    RenderRepaintBoundary boundary =
        iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng(iconKey);
    }

    ui.Image image = await boundary.toImage(pixelRatio: 2.5);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  void _getMarkerBitmaps() async {
    Future<void> _getMarkerBitmap(int index) async {
      final Uint8List imageData = await _capturePng(_markerData[index].iconKey);
      setState(() {
        _markerData[index].iconBitmap = BitmapDescriptor.fromBytes(imageData);
      });
    }

    final List<Future<void>> futures = [];
    for (int i = 0; i < 4; i++) {
      futures.add(_getMarkerBitmap(i));
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _getMarkerBitmaps());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GoogleMap CustomMarker Sample'),
      ),
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: const Offset(-400, 0), // 画面外に描画
            child: ListView.builder(
              itemCount: _markerData.length,
              itemBuilder: (_, index) => RepaintBoundary(
                key: _markerData[index].iconKey,
                child: CustomMarker(index + 1),
              ),
            ),
          ),
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
            ),
            markers: _markerData
                .map((markerData) => Marker(
                      markerId: MarkerId(markerData.iconKey.toString()),
                      icon: markerData.iconBitmap ??
                          BitmapDescriptor.defaultMarker,
                      position: markerData.latLng,
                    ))
                .toSet(),
          ),
        ],
      ),
    );
  }
}

class MarkerData {
  MarkerData({required this.latLng});

  final LatLng latLng;
  final GlobalKey iconKey = GlobalKey();
  BitmapDescriptor? iconBitmap;
}

class CustomMarker extends StatelessWidget {
  const CustomMarker(this.num, {Key? key}) : super(key: key);

  final int num;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.0,
      width: 72.0,
      child: Stack(
        children: [
          Align(
            child: Image.asset(
              'assets/marker_icon.png',
              fit: BoxFit.fill,
            ),
          ),
          Align(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                num.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
