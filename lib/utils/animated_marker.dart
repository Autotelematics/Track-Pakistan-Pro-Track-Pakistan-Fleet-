import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/utils/extensions.dart';

class AnimatedMarker extends StatefulWidget {
  AnimatedMarker({
    super.key,
    required this.animatedMarkers,
    this.staticMarkers = const {},
    required this.builder,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.ease,
    this.fps = 30,
  })  : staticMarkersMap = {
    for (var marker in staticMarkers) marker.markerId: marker
  },
        animatedMarkersMap = {
          for (var marker in animatedMarkers) marker.markerId: marker
        };
  final Set<Marker> animatedMarkers;
  final Set<Marker> staticMarkers;
  final Widget Function(BuildContext context, Set<Marker> animatedMarkers)
  builder;
  final Duration duration;
  final Curve curve;
  final int fps;
  final Map<MarkerId, Marker> staticMarkersMap;
  final Map<MarkerId, Marker> animatedMarkersMap;
  @override
  State<AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker> {
  late final Set<Marker> _staticMarkers;
  late final StreamController<Set<Marker>> _markersStreamController;
  late final Map<MarkerId, Marker> _transitioningMarkers;

  late final double _animationSteps;
  late final Duration _animationInterval;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();

    // Set initial state for markers and animation configurations.
    _staticMarkers = widget.staticMarkers;
    _transitioningMarkers = widget.animatedMarkersMap;
    _animationSteps = widget.fps * widget.duration.inMilliseconds / 1000;
    _animationInterval = widget.duration / _animationSteps;
    _markersStreamController = StreamController<Set<Marker>>.broadcast();

    // Add initial markers to the stream.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialMarkers =
      _staticMarkers.followedBy(widget.animatedMarkers).toSet();
      _markersStreamController.add(initialMarkers);
    });
  }

  @override
  void dispose() {
    // Close the stream to avoid memory leaks.
    _tickerTimer?.cancel();
    _markersStreamController.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tickerTimer
        ?.cancel(); // Cancel any active timer before starting a new one.

    final Map<MarkerId, Marker> sameAnimatedMarkers = {};
    final Map<Marker, Marker> updatedMarkerPairs = {};

    // Compare current markers with previous markers to find updated positions.
    for (final marker in widget.animatedMarkers) {
      final oldMarker = _transitioningMarkers[marker.markerId] ??
          oldWidget.animatedMarkersMap[marker.markerId];
      if (oldMarker != null && oldMarker != marker) {
        updatedMarkerPairs[oldMarker] = marker;
      } else {
        if (oldMarker == null) _transitioningMarkers[marker.markerId] = marker;
        sameAnimatedMarkers[marker.markerId] = marker;
      }
    }

    // Combine static markers and unchanged animated markers.
    final Set<Marker> allStaticMarkers =
    _staticMarkers.followedBy(sameAnimatedMarkers.values).toSet();

    // If there are no marker changes, update the stream with static markers only.
    if (updatedMarkerPairs.isEmpty) {
      _markersStreamController.add(allStaticMarkers);
      return;
    }

    // Start a timer to interpolate marker positions over the specified duration.
    _tickerTimer = Timer.periodic(_animationInterval, (timer) {
      if (timer.tick >= _animationSteps) {
        // Animation complete: Update with final positions and cancel the timer.
        final allMarkers =
        allStaticMarkers.followedBy(_transitioningMarkers.values).toSet();
        _markersStreamController.add(allMarkers);
        timer.cancel();
        return;
      }
      final double fraction = (timer.tick / _animationSteps).clamp(0, 1);
      final curveFraction = widget.curve.transform(fraction);

      _transitioningMarkers.clear();

      // Calculate interpolated positions for each updated marker.
      for (final markerPair in updatedMarkerPairs.entries) {
        final oldMarker = markerPair.key;
        final newMarker = markerPair.value;

        final oldPosition = oldMarker.position;
        final newPosition = newMarker.position;

        // Interpolates position and angle based on the animation curve.
        final newLatLng = oldPosition.lerp(newPosition, step: curveFraction);
        final newRotation =
        oldMarker.rotation.lerp(newMarker.rotation, step: curveFraction);

        // Create a new marker at the interpolated position.
        final newMarkerCopy = newMarker.copyWith(
          positionParam: newLatLng,
          rotationParam: newRotation,
        );
        _transitioningMarkers[newMarkerCopy.markerId] = newMarkerCopy;
      }

      // Update the stream with the new marker positions.
      final allMarkers =
      allStaticMarkers.followedBy(_transitioningMarkers.values).toSet();
      _markersStreamController.add(allMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<Marker>>(
        stream: _markersStreamController.stream.distinct(),
        builder: (context, snapshot) {
          // Build GoogleMap with animated markers.
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              !snapshot.hasData) {
            return widget.builder(
                context,
                _staticMarkers
                    .followedBy(_transitioningMarkers.values)
                    .toSet());
          }

          final allMarkers = snapshot.data!;
          return widget.builder(context, allMarkers);
        });
  }
}
