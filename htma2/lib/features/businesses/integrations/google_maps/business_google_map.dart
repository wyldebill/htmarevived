import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/business.dart';

class BusinessGoogleMap extends StatefulWidget {
  const BusinessGoogleMap({
    required this.businesses,
    required this.onBusinessSelected,
    this.initialCameraPosition,
    this.onCameraMoved,
    super.key,
  });

  final List<Business> businesses;
  final ValueChanged<Business> onBusinessSelected;
  final CameraPosition? initialCameraPosition;
  final ValueChanged<CameraPosition>? onCameraMoved;

  @override
  State<BusinessGoogleMap> createState() => _BusinessGoogleMapState();
}

class _BusinessGoogleMapState extends State<BusinessGoogleMap> {
  static const _googleplex = LatLng(37.4219983, -122.084);
  BitmapDescriptor? _businessMarkerIcon;
  GoogleMapController? _mapController;
  bool _myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    _syncLocationLayerPermission();
  }

  Future<void> _loadMarkerIcon() async {
    final markerIcon = await _buildBusinessMarkerIcon();
    if (!mounted) {
      return;
    }
    setState(() {
      _businessMarkerIcon = markerIcon;
    });
  }

  Future<BitmapDescriptor> _buildBusinessMarkerIcon() async {
    const markerSize = 84.0;
    const iconSize = 46.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(markerSize / 2, markerSize / 2);
    final outerPaint = Paint()..color = const Color(0xFF1E5A7A);
    final innerPaint = Paint()..color = const Color(0xFF2C7AA1);

    canvas.drawCircle(center, markerSize / 2, outerPaint);
    canvas.drawCircle(center, markerSize / 2 - 3, innerPaint);

    final iconText = String.fromCharCode(Icons.storefront.codePoint);
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: iconText,
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: Icons.storefront.fontFamily,
          package: Icons.storefront.fontPackage,
          color: Colors.white,
        ),
      ),
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        (markerSize - iconPainter.width) / 2,
        (markerSize - iconPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      markerSize.toInt(),
      markerSize.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final byteData = bytes?.buffer.asUint8List() ?? Uint8List(0);
    final devicePixelRatio = ui.PlatformDispatcher.instance.views.isEmpty
        ? 1.0
        : ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return BitmapDescriptor.bytes(byteData, imagePixelRatio: devicePixelRatio);
  }

  Future<void> _syncLocationLayerPermission() async {
    final permission = await Geolocator.checkPermission();
    final enabled = _isPermissionGranted(permission);
    if (!mounted) {
      return;
    }
    setState(() {
      _myLocationEnabled = enabled;
    });
  }

  bool _isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _centerOnUser() async {
    if (_mapController == null) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('Location services are off. Turn them on and try again.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final granted = _isPermissionGranted(permission);
    if (!granted) {
      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied in system settings.',
        );
      } else {
        _showMessage('Location permission denied. Map position was unchanged.');
      }
      return;
    }

    if (!_myLocationEnabled && mounted) {
      setState(() {
        _myLocationEnabled = true;
      });
    }

    try {
      final position = await _getReliableCurrentPosition();
      await _animateTo(position.latitude, position.longitude);
      return;
    } on StateError catch (error) {
      _showMessage(error.message);
    } on TimeoutException {
      _showMessage('Could not get your location in time. Try again.');
    } catch (_) {
      _showMessage('Could not get an accurate location right now.');
    }
  }

  LocationSettings _locationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        timeLimit: Duration(seconds: 8),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: false,
        timeLimit: Duration(seconds: 8),
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      timeLimit: Duration(seconds: 8),
    );
  }

  Future<Position> _getReliableCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings(),
    );
    final invalidReason = _invalidPositionReason(position);
    if (invalidReason != null) {
      throw StateError(invalidReason);
    }
    return position;
  }

  String? _invalidPositionReason(Position position) {
    if (position.isMocked) {
      return 'Your device is reporting a mock location. Turn off mock location to center accurately.';
    }

    if (_isGoogleplexDefault(position)) {
      return 'Device location is still set to a simulator default. Set a real device location and try again.';
    }

    if (position.accuracy > 100) {
      return 'Location is still settling. Try Find Me again in a moment.';
    }

    return null;
  }

  bool _isGoogleplexDefault(Position position) {
    final metersFromGoogleplex = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _googleplex.latitude,
      _googleplex.longitude,
    );
    return metersFromGoogleplex <= 150;
  }

  Future<void> _animateTo(double latitude, double longitude) async {
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 15.5),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.businesses
        .map(
          (business) => Marker(
            markerId: MarkerId(business.id),
            position: LatLng(business.latitude, business.longitude),
            icon: _businessMarkerIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: business.name,
              snippet: business.address,
              onTap: () => widget.onBusinessSelected(business),
            ),
          ),
        )
        .toSet();

    final fallbackCenter = widget.businesses.isEmpty
        ? const LatLng(45.1719, -93.8747)
        : LatLng(
            widget.businesses.first.latitude,
            widget.businesses.first.longitude,
          );
    final startingCamera =
        widget.initialCameraPosition ??
        CameraPosition(target: fallbackCenter, zoom: 12);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: startingCamera,
          markers: markers,
          onMapCreated: (controller) => _mapController = controller,
          onCameraMove: widget.onCameraMoved,
          myLocationButtonEnabled: false,
          myLocationEnabled: _myLocationEnabled,
          mapToolbarEnabled: false,
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: 'map-my-location-btn',
            onPressed: _centerOnUser,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
