import 'package:flutter/widgets.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';

double dashboardTextScale(BuildContext context) =>
    appTextScale(context, ScaleProfile.dashboard);

double dashboardIconScale(BuildContext context) =>
    appIconScale(context, ScaleProfile.dashboard);
