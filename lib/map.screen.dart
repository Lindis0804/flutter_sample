import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample/get_env.dart';
import 'package:flutter_sample/utils.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late MapOptions _navigationOption;

  final _vietmapNavigationPlugin = VietMapNavigationPlugin();

  List<LatLng> waypoints = const [
    LatLng(10.759091, 106.675817),
    LatLng(10.762528, 106.653099)
  ];

  LatLng myHomeCoordinate = LatLng(21.0037581, 105.7809310);

  /// Display the guide instruction image to the next turn
  Widget instructionImage = const SizedBox.shrink();

  Widget recenterButton = const SizedBox.shrink();

  /// RouteProgressEvent contains the route information, current location, next turn, distance, duration,...
  /// This variable is update real time when the navigation is started
  RouteProgressEvent? routeProgressEvent;

  /// The controller to control the navigation, such as start, stop, recenter, overview,...
  MapNavigationViewController? _navigationController;

  Future<void> initialize() async {
    if (!mounted) {
      return;
    }
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();

    /// set the simulate route to true to test the navigation without the real location
    _navigationOption.simulateRoute = false;

    String vietmapApiKey = EnvVariable().vietmapApiKey;
    _navigationOption.apiKey = vietmapApiKey;
    _navigationOption.mapStyle =
        "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=$vietmapApiKey";

    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    _setInstructionImage(String? modifier, String? type) {
      if (modifier != null && type != null) {
        List<String> data = [
          type.replaceAll(' ', '_'),
          modifier.replaceAll(' ', '_')
        ];
        String path = 'assets/navigation_symbol/${data.join('_')}.svg';
        setState(() {
          instructionImage = SvgPicture.asset(path, color: Colors.white);
        });
      }
    }

    return Scaffold(
      body: NavigationView(
        mapOptions: _navigationOption,
        onMapCreated: (controller) {
          _navigationController = controller;
        },
        onMapLongClick: (LatLng? latLng, Point? point) {
          if (latLng == null) {
            return;
          }

          _navigationController?.buildRoute(
              waypoints: [myHomeCoordinate, latLng],
              profile: DrivingProfile.drivingTraffic);
        },
        onRouteProgressChange: (RouteProgressEvent routeProgressEvent) {
          logging(
              'current location: ${routeProgressEvent.currentLocation}, snapped location: ${routeProgressEvent.snappedLocation}');
          setState(() {
            this.routeProgressEvent = routeProgressEvent;
          });
          _setInstructionImage(routeProgressEvent.currentModifier,
              routeProgressEvent.currentModifierType);
        },
        onRouteBuilt: (DirectionRoute route) {},
        onNewRouteSelected: (DirectionRoute route) {},
      ),
    );
  }
}
