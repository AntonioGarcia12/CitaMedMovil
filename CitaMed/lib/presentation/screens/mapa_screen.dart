import 'dart:async';

import 'package:citamed/infrastructures/models/centro_de_salud.dart';
import 'package:citamed/presentation/widgets/bottom_navigation_bar_widget.dart';
import 'package:citamed/services/centro_de_salud_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class MapaScreen extends StatefulWidget {
  static const String name = 'MapaScreen';
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final CentroDeSaludServices _centroService = CentroDeSaludServices();
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  List<CentroDeSalud> _centros = [];
  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];

  final double _radiusKm = 5.0;
  final Distance _distance = const Distance();

  bool _isTracingRoute = false;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCentrosDeSalud());
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationTracking() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnackBar('Los servicios de ubicación están desactivados.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Permiso de ubicación denegado.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('El permiso de ubicación se ha denegado permanentemente.');
      return;
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _fetchCentrosDeSalud() async {
    try {
      final centros = await _centroService.listarCentrosDeSalud();
      setState(() => _centros = centros);
    } catch (e) {
      _showSnackBar('Error al cargar centros: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<Marker> _buildCentroMarkers() {
    if (_currentPosition == null) return [];

    return _centros
        .where(
          (centro) =>
              _distance.as(
                LengthUnit.Kilometer,
                _currentPosition!,
                LatLng(centro.latitud, centro.longitud),
              ) <=
              _radiusKm,
        )
        .map(
          (centro) => Marker(
            width: 80,
            height: 80,
            point: LatLng(centro.latitud, centro.longitud),
            child: GestureDetector(
              onTap: () => _displayCentroDetails(centro),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        )
        .toList();
  }

  void _displayCentroDetails(CentroDeSalud centro) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centro.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        centro.imagen,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      title: Text(centro.direccion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.blue),
                      title: Text(centro.telefono),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              _isTracingRoute
                                  ? null
                                  : () async {
                                    Navigator.of(context).pop();
                                    setState(() => _isTracingRoute = true);
                                    await _traceRouteToCentro(centro);
                                    setState(() => _isTracingRoute = false);
                                    _showSnackBar('Ruta trazada con éxito.');
                                  },
                          icon:
                              _isTracingRoute
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.directions),
                          label: const Text('Ir'),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _traceRouteToCentro(CentroDeSalud centro) async {
    if (_currentPosition == null) return;

    final route = await _retrieveRoute(
      start: _currentPosition!,
      end: LatLng(centro.latitud, centro.longitud),
    );

    if (route.isNotEmpty) {
      setState(() {
        _routePoints = route;
      });
      _mapController.move(route.first, 14);
    } else {
      _showSnackBar('No se pudo obtener la ruta.');
    }
  }

  Future<List<LatLng>> _retrieveRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final openRouteService = OpenRouteService(
      apiKey: '5b3ce3597851110001cf62487d06b6f8f43f4fa4bbb7550dd937dea9',
    );

    try {
      final coords = await openRouteService.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
          latitude: start.latitude,
          longitude: start.longitude,
        ),
        endCoordinate: ORSCoordinate(
          latitude: end.latitude,
          longitude: end.longitude,
        ),
        profileOverride: ORSProfile.drivingCar,
      );

      return coords.map((c) => LatLng(c.latitude, c.longitude)).toList();
    } catch (e) {
      debugPrint('Error al obtener la ruta: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _currentPosition == null || _centros.isEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(0, 0),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    markers: _buildCentroMarkers(),
                    maxClusterRadius: 120,
                    size: const Size(40, 40),
                    builder:
                        (_, markers) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                  ),
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: _currentPosition!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () =>
                _currentPosition != null
                    ? _mapController.move(_currentPosition!, 16)
                    : null,
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}
