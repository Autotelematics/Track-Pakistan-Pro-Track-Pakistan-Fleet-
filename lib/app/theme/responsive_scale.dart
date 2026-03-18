import 'package:flutter/widgets.dart';

enum ScaleProfile {
  dashboard,
  vehicleList,
  tracking,
  analytics,
  notifications,
  reportType,
}

double appTextScale(BuildContext context, ScaleProfile profile) {
  final width = MediaQuery.sizeOf(context).width;
  switch (profile) {
    case ScaleProfile.dashboard:
      if (width >= 430) return 1.18;
      if (width >= 402) return 1.13;
      if (width >= 390) return 1.10;
      return 1.0;
    case ScaleProfile.vehicleList:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.09;
      return 1.0;
    case ScaleProfile.tracking:
      if (width >= 430) return 1.14;
      if (width >= 402) return 1.10;
      if (width >= 390) return 1.07;
      return 1.0;
    case ScaleProfile.analytics:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.08;
      return 1.0;
    case ScaleProfile.notifications:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.08;
      return 1.0;
    case ScaleProfile.reportType:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.08;
      return 1.0;
  }
}

double appIconScale(BuildContext context, ScaleProfile profile) {
  final width = MediaQuery.sizeOf(context).width;
  switch (profile) {
    case ScaleProfile.dashboard:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.08;
      return 1.0;
    case ScaleProfile.vehicleList:
      if (width >= 430) return 1.14;
      if (width >= 402) return 1.10;
      if (width >= 390) return 1.07;
      return 1.0;
    case ScaleProfile.tracking:
      if (width >= 430) return 1.16;
      if (width >= 402) return 1.12;
      if (width >= 390) return 1.08;
      return 1.0;
    case ScaleProfile.analytics:
      if (width >= 430) return 1.14;
      if (width >= 402) return 1.10;
      if (width >= 390) return 1.07;
      return 1.0;
    case ScaleProfile.notifications:
      if (width >= 430) return 1.14;
      if (width >= 402) return 1.10;
      if (width >= 390) return 1.07;
      return 1.0;
    case ScaleProfile.reportType:
      if (width >= 430) return 1.14;
      if (width >= 402) return 1.10;
      if (width >= 390) return 1.07;
      return 1.0;
  }
}
