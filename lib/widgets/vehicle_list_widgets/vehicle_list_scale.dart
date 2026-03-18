import 'package:flutter/widgets.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';

double vehicleListTextScale(BuildContext context) =>
    appTextScale(context, ScaleProfile.vehicleList);

double vehicleListIconScale(BuildContext context) =>
    appIconScale(context, ScaleProfile.vehicleList);
