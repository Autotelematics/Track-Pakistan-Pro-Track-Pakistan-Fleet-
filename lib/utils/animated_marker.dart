import 'dart:async';
import 'package:flutter/foundation.dart';
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
    this.animateRotation = true,
    this.debugLogKey,
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
  final bool animateRotation;
  final String? debugLogKey;
  final Map<MarkerId, Marker> staticMarkersMap;
  final Map<MarkerId, Marker> animatedMarkersMap;
  @override
  State<AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker> {
  static const double _deferredHandoffProgress = 0.78;
  late final StreamController<Set<Marker>> _markersStreamController;
  late final Map<MarkerId, Marker> _transitioningMarkers;
  Timer? _tickerTimer;
  bool _hasDeferredWidgetUpdate = false;
  void _animLog(String message) {
    final key = widget.debugLogKey;
    if (!kDebugMode || key == null || key.isEmpty) return;
    debugPrint('[$key] $message');
  }

  @override
  void initState() {
    super.initState();

    // Set initial state for markers and animation configurations.
    _transitioningMarkers = widget.animatedMarkersMap;
    _markersStreamController = StreamController<Set<Marker>>.broadcast();

    // Add initial markers to the stream.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialMarkers =
      widget.staticMarkers.followedBy(widget.animatedMarkers).toSet();
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
    if (_tickerTimer?.isActive ?? false) {
      _hasDeferredWidgetUpdate = true;
      _animLog('defer widget update until current animation completes');
      return;
    }

    _syncAnimatedMarkers(fallbackOldMarkers: oldWidget.animatedMarkersMap);
  }

  void _syncAnimatedMarkers({Map<MarkerId, Marker>? fallbackOldMarkers}) {
    _tickerTimer?.cancel();

    final Map<MarkerId, Marker> sameAnimatedMarkers = {};
    final Map<MarkerId, ({Marker oldMarker, Marker newMarker})>
        updatedMarkerPairs = {};

    // Compare current markers with previous markers to find updated positions.
    for (final marker in widget.animatedMarkers) {
      final oldMarker = _transitioningMarkers[marker.markerId] ??
          fallbackOldMarkers?[marker.markerId];
      if (oldMarker != null && oldMarker != marker) {
        updatedMarkerPairs[marker.markerId] =
            (oldMarker: oldMarker, newMarker: marker);
      } else {
        if (oldMarker == null) _transitioningMarkers[marker.markerId] = marker;
        sameAnimatedMarkers[marker.markerId] = marker;
      }
    }

    // Combine static markers and unchanged animated markers.
    final Set<Marker> allStaticMarkers =
    widget.staticMarkers.followedBy(sameAnimatedMarkers.values).toSet();

    // If there are no marker changes, update the stream with static markers only.
    if (updatedMarkerPairs.isEmpty) {
      _animLog('no animated marker delta; emit stable markers only');
      _markersStreamController.add(allStaticMarkers);
      return;
    }

    // Emit a stable pre-animation frame to avoid boundary flicker.
    final preAnimationMarkers =
        allStaticMarkers.followedBy(_transitioningMarkers.values).toSet();
    _markersStreamController.add(preAnimationMarkers);

    final double animationSteps =
        (widget.fps * widget.duration.inMilliseconds / 1000)
            .clamp(1, 100000)
            .toDouble();
    final Duration animationInterval = widget.duration ~/ animationSteps.round();
    _animLog(
      'start durationMs=${widget.duration.inMilliseconds} fps=${widget.fps} '
      'steps=${animationSteps.round()} intervalMs=${animationInterval.inMilliseconds} '
      'animateRotation=${widget.animateRotation} markers=${updatedMarkerPairs.length}',
    );
    for (final markerPair in updatedMarkerPairs.entries) {
      final oldMarker = markerPair.value.oldMarker;
      final newMarker = markerPair.value.newMarker;
      _animLog(
        'marker=${markerPair.key.value} '
        'from=(${oldMarker.position.latitude.toStringAsFixed(6)},${oldMarker.position.longitude.toStringAsFixed(6)}) '
        'to=(${newMarker.position.latitude.toStringAsFixed(6)},${newMarker.position.longitude.toStringAsFixed(6)}) '
        'fromRot=${oldMarker.rotation.toStringAsFixed(1)} '
        'toRot=${newMarker.rotation.toStringAsFixed(1)}',
      );
    }

    // Start a timer to interpolate marker positions over the specified duration.
    _tickerTimer = Timer.periodic(animationInterval, (timer) {
      final double fraction = (timer.tick / animationSteps).clamp(0, 1);

      if (_hasDeferredWidgetUpdate && fraction >= _deferredHandoffProgress) {
        _hasDeferredWidgetUpdate = false;
        _animLog(
          'handoff deferred update atProgress=${fraction.toStringAsFixed(2)}',
        );
        timer.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _syncAnimatedMarkers();
        });
        return;
      }

      if (timer.tick >= animationSteps) {
        // Animation complete: Update with final positions and cancel the timer.
        for (final pair in updatedMarkerPairs.entries) {
          _transitioningMarkers[pair.key] = pair.value.newMarker;
        }
        final allMarkers =
            allStaticMarkers.followedBy(_transitioningMarkers.values).toSet();
        _markersStreamController.add(allMarkers);
        _animLog('complete ticks=${timer.tick}');
        timer.cancel();
        if (_hasDeferredWidgetUpdate && mounted) {
          _hasDeferredWidgetUpdate = false;
          _animLog('run deferred widget update after animation completion');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _syncAnimatedMarkers();
          });
        }
        return;
      }
      final curveFraction = widget.curve.transform(fraction);

      // Calculate interpolated positions for each updated marker.
      for (final markerPair in updatedMarkerPairs.entries) {
        final oldMarker = markerPair.value.oldMarker;
        final newMarker = markerPair.value.newMarker;

        final oldPosition = oldMarker.position;
        final newPosition = newMarker.position;

        // Interpolates position and angle based on the animation curve.
        final newLatLng = oldPosition.lerp(newPosition, step: curveFraction);
        final newRotation = widget.animateRotation
            ? oldMarker.rotation.lerp(newMarker.rotation, step: curveFraction)
            : newMarker.rotation;

        // Create a new marker at the interpolated position.
        final newMarkerCopy = newMarker.copyWith(
          positionParam: newLatLng,
          rotationParam: newRotation,
        );
        _transitioningMarkers[markerPair.key] = newMarkerCopy;
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
                widget.staticMarkers
                    .followedBy(_transitioningMarkers.values)
                    .toSet());
          }

          final allMarkers = snapshot.data!;
          return widget.builder(context, allMarkers);
        });
  }
}
