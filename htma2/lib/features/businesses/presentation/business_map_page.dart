import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain/business.dart';
import '../integrations/google_maps/business_google_map.dart';

class BusinessMapPage extends StatelessWidget {
  const BusinessMapPage({
    required this.businesses,
    required this.googleMapsApiKey,
    required this.onBusinessSelected,
    this.initialCameraPosition,
    this.onCameraMoved,
    super.key,
  });

  final List<Business> businesses;
  final String googleMapsApiKey;
  final ValueChanged<Business> onBusinessSelected;
  final CameraPosition? initialCameraPosition;
  final ValueChanged<CameraPosition>? onCameraMoved;

  @override
  Widget build(BuildContext context) {
    if (googleMapsApiKey.trim().isEmpty) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Map is unavailable right now. Add GOOGLE_MAPS_API_KEY and restart the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BusinessGoogleMap(
              businesses: businesses,
              onBusinessSelected: onBusinessSelected,
              initialCameraPosition: initialCameraPosition,
              onCameraMoved: onCameraMoved,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
