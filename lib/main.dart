import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GoogleMap CustomMarker Sample'),
      ),
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: const Offset(-400, 0), // 画面外に描画
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (_, index) => CustomMarker(index + 1),
            ),
          ),
        ],
      ),
    );
  }
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
          Image.asset(
            'assets/marker_icon.png',
            fit: BoxFit.fill,
          ),
          Align(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
