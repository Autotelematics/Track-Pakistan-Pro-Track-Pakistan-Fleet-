import 'package:flutter/widgets.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';

double trackingTextScale(BuildContext context) =>
    appTextScale(context, ScaleProfile.tracking);

double trackingIconScale(BuildContext context) =>
    appIconScale(context, ScaleProfile.tracking);
