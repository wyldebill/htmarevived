import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/business_repository.dart';
import '../domain/business.dart';
import 'business_detail_page.dart';
import 'business_list_page.dart';
import 'business_map_page.dart';

class BusinessShellPage extends StatefulWidget {
  const BusinessShellPage({
    required this.repository,
    required this.googleMapsApiKey,
    required this.onSignOut,
    super.key,
  });

  final BusinessRepository repository;
  final String googleMapsApiKey;
  final Future<void> Function() onSignOut;

  @override
  State<BusinessShellPage> createState() => _BusinessShellPageState();
}

class _BusinessShellPageState extends State<BusinessShellPage> {
  int _selectedIndex = 0;
  late Future<List<Business>> _businessesFuture;
  CameraPosition? _lastMapCameraPosition;

  @override
  void initState() {
    super.initState();
    _businessesFuture = widget.repository.fetchBusinesses();
  }

  void _openDetail(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BusinessDetailPage(
          business: business,
          googleMapsApiKey: widget.googleMapsApiKey,
        ),
      ),
    );
  }

  void _refresh() {
    setState(() {
      _businessesFuture = widget.repository.fetchBusinesses();
    });
  }

  void _rememberMapCamera(CameraPosition cameraPosition) {
    _lastMapCameraPosition = cameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Business>>(
      future: _businessesFuture,
      builder: (context, snapshot) {
        final title = _selectedIndex == 0 ? 'Businesses' : 'Map';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
              IconButton(
                onPressed: () => widget.onSignOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBody(snapshot),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'List',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Map',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Business>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _StateMessage(
        message: _errorMessage(snapshot.error),
        actionLabel: 'Try Again',
        onAction: _refresh,
      );
    }

    final businesses = snapshot.data ?? const [];
    if (businesses.isEmpty) {
      return _StateMessage(
        message:
            'No businesses yet. Seed data in Realtime Database to continue.',
        actionLabel: 'Reload',
        onAction: _refresh,
      );
    }

    if (_selectedIndex == 0) {
      return BusinessListPage(
        businesses: businesses,
        onBusinessSelected: _openDetail,
      );
    }

    return BusinessMapPage(
      businesses: businesses,
      googleMapsApiKey: widget.googleMapsApiKey,
      onBusinessSelected: _openDetail,
      initialCameraPosition: _lastMapCameraPosition,
      onCameraMoved: _rememberMapCamera,
    );
  }

  String _errorMessage(Object? error) {
    if (error case FirebaseException(
      :final code,
    ) when code == 'permission-denied') {
      return 'Firebase denied read access to /businesses. '
          'Update Realtime Database Rules to allow this read path, '
          'or sign in with an authorized user.';
    }

    return 'Could not load businesses from Firebase Realtime Database.';
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
