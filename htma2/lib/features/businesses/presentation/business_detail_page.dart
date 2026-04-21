import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/business.dart';

class BusinessDetailPage extends StatelessWidget {
  const BusinessDetailPage({
    required this.business,
    required this.googleMapsApiKey,
    super.key,
  });

  final Business business;
  final String googleMapsApiKey;

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${business.latitude},${business.longitude}',
    });
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(business.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Text(
            business.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            business.category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Address'),
            subtitle: Text(business.address),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 220,
              child: googleMapsApiKey.trim().isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Map preview unavailable until GOOGLE_MAPS_API_KEY is configured.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(business.latitude, business.longitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(business.id),
                          position: LatLng(
                            business.latitude,
                            business.longitude,
                          ),
                          infoWindow: InfoWindow(
                            title: business.name,
                            snippet: business.address,
                          ),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.pin_drop_outlined),
            title: const Text('Coordinates'),
            subtitle: Text(
              '${business.latitude.toStringAsFixed(6)}, ${business.longitude.toStringAsFixed(6)}',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openInGoogleMaps(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View on Google Maps'),
          ),
        ],
      ),
    );
  }
}
