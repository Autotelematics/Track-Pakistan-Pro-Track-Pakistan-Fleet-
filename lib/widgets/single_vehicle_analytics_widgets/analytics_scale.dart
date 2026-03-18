import 'package:flutter/widgets.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';

double analyticsTextScale(BuildContext context) =>
    appTextScale(context, ScaleProfile.analytics);

double analyticsIconScale(BuildContext context) =>
    appIconScale(context, ScaleProfile.analytics);
