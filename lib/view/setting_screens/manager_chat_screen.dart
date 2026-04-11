import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/models/manager_chat_model.dart';
import 'package:trackerapp/providers/manager_chat_provider.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class ManagerChatScreen extends StatelessWidget {
  final int? deviceId;
  final String? vehicleName;

  const ManagerChatScreen({
    super.key,
    this.deviceId,
    this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManagerChatProvider(
        linkedDeviceId: deviceId,
        linkedDeviceName: vehicleName,
      ),
      child: const _ManagerChatView(),
    );
  }
}

class _ManagerChatView extends StatefulWidget {
  const _ManagerChatView();

  @override
  State<_ManagerChatView> createState() => _ManagerChatViewState();
}

class _ManagerChatViewState extends State<_ManagerChatView>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  Timer? _resumeRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ManagerChatProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _resumeRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final provider = context.read<ManagerChatProvider>();
    switch (state) {
      case AppLifecycleState.resumed:
        if (provider.hasThread) {
          provider.startPolling();
          _resumeRefreshTimer?.cancel();
          _resumeRefreshTimer = Timer(const Duration(seconds: 2), () {
            if (!mounted) return;
            context.read<ManagerChatProvider>().refreshMessages(silent: true);
          });
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _resumeRefreshTimer?.cancel();
        provider.stopPolling();
        break;
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSend(BuildContext context) async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    await context.read<ManagerChatProvider>().sendMessage(text);
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  Future<void> _showSendLocationDialog(BuildContext context) async {
    final provider = context.read<ManagerChatProvider>();
    List<Item> devices;
    try {
      devices = await provider.fetchDeviceOptions();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(message: 'Unable to load devices. Please try again.');
      return;
    }

    if (!mounted) return;
    if (devices.isEmpty) {
      AppSnackBar.error(message: 'No devices available to share location.');
      return;
    }

    Item selectedDevice = devices.first;
    final preferredId = provider.linkedDeviceId;
    if (preferredId != null) {
      for (final item in devices) {
        if (item.id == preferredId) {
          selectedDevice = item;
          break;
        }
      }
    }

    bool isSubmitting = false;
    await showDialog<void>(
      context: this.context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final lat = _parseCoordinate(selectedDevice.lat);
            final lng = _parseCoordinate(selectedDevice.lng);
            final hasCoordinates = lat != null && lng != null;
            final locationPreview = hasCoordinates
                ? 'Lat: ${lat.toStringAsFixed(6)}\nLng: ${lng.toStringAsFixed(6)}'
                : 'Location is unavailable for this device.';

            return AlertDialog(
              title: Text(
                'Send Location',
                style: AppStyles.semiboldTextStyle(context),
              ),
              content: SizedBox(
                width: 86.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select vehicle',
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 12.5.sp,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    DropdownButtonFormField<int>(
                      initialValue: selectedDevice.id,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.1.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: devices
                          .where((item) => item.id != null)
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: item.id!,
                              child: Text(
                                item.name?.trim().isNotEmpty == true
                                    ? item.name!.trim()
                                    : 'Device ${item.id}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value == null) return;
                              final next = devices.firstWhere(
                                (item) => item.id == value,
                                orElse: () => selectedDevice,
                              );
                              setDialogState(() => selectedDevice = next);
                            },
                    ),
                    SizedBox(height: 1.4.h),
                    Text(
                      locationPreview,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 12.2.sp,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: (!hasCoordinates || isSubmitting)
                      ? null
                      : () async {
                          final deviceId = selectedDevice.id;
                          final deviceLat = _parseCoordinate(selectedDevice.lat);
                          final deviceLng = _parseCoordinate(selectedDevice.lng);
                          if (deviceId == null ||
                              deviceLat == null ||
                              deviceLng == null) {
                            AppSnackBar.error(
                              message: 'Selected device location is invalid.',
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final sent = await provider.sendLocationAttachment(
                            deviceId: deviceId,
                            deviceName: selectedDevice.name ?? '',
                            lat: deviceLat,
                            lng: deviceLng,
                          );
                          if (!mounted || !dialogContext.mounted) return;
                          if (!sent) {
                            setDialogState(() => isSubmitting = false);
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 15.sp,
                          height: 15.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPreAlertDialog(BuildContext context) async {
    final provider = context.read<ManagerChatProvider>();
    List<Item> devices;
    try {
      devices = await provider.fetchDeviceOptions();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(message: 'Unable to load devices. Please try again.');
      return;
    }

    if (!mounted) return;
    if (devices.isEmpty) {
      AppSnackBar.error(message: 'No devices available for pre alert.');
      return;
    }

    Item selectedDevice = devices.first;
    final preferredId = provider.linkedDeviceId;
    if (preferredId != null) {
      for (final item in devices) {
        if (item.id == preferredId) {
          selectedDevice = item;
          break;
        }
      }
    }

    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now().add(const Duration(days: 7));
    final TextEditingController noteController = TextEditingController();
    bool isSubmitting = false;
    final dateFmt = DateFormat('yyyy-MM-dd');

    await showDialog<void>(
      context: this.context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Pre Alert Info',
                style: AppStyles.semiboldTextStyle(context),
              ),
              content: SizedBox(
                width: 88.w,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select vehicle',
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      DropdownButtonFormField<int>(
                        initialValue: selectedDevice.id,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.1.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: devices
                            .where((item) => item.id != null)
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id!,
                                child: Text(
                                  item.name?.trim().isNotEmpty == true
                                      ? item.name!.trim()
                                      : 'Device ${item.id}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                if (value == null) return;
                                final next = devices.firstWhere(
                                  (item) => item.id == value,
                                  orElse: () => selectedDevice,
                                );
                                setDialogState(() => selectedDevice = next);
                              },
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        'From date',
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      InkWell(
                        onTap: isSubmitting
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: fromDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked == null || !dialogContext.mounted) {
                                  return;
                                }
                                setDialogState(() {
                                  fromDate = picked;
                                  if (toDate.isBefore(fromDate)) {
                                    toDate = fromDate;
                                  }
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.1.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(dateFmt.format(fromDate)),
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        'To date',
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      InkWell(
                        onTap: isSubmitting
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: toDate.isBefore(fromDate)
                                      ? fromDate
                                      : toDate,
                                  firstDate: fromDate,
                                  lastDate: DateTime(2100),
                                );
                                if (picked == null || !dialogContext.mounted) {
                                  return;
                                }
                                setDialogState(() => toDate = picked);
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.1.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(dateFmt.format(toDate)),
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        'Message',
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      TextField(
                        controller: noteController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write pre alert message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.2.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final deviceId = selectedDevice.id;
                          final message = noteController.text.trim();
                          if (deviceId == null) {
                            AppSnackBar.error(message: 'Please select a device.');
                            return;
                          }
                          if (message.isEmpty) {
                            AppSnackBar.error(
                              message: 'Please write a pre alert message.',
                            );
                            return;
                          }
                          if (toDate.isBefore(fromDate)) {
                            AppSnackBar.error(
                              message: 'To date must be after from date.',
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final sent = await provider.sendPreAlertAttachment(
                            deviceId: deviceId,
                            fromDate: fromDate,
                            toDate: toDate,
                            userMessage: message,
                          );
                          if (!mounted || !dialogContext.mounted) return;
                          if (!sent) {
                            setDialogState(() => isSubmitting = false);
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 15.sp,
                          height: 15.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ManagerChatProvider>(
      builder: (context, provider, _) {
        if (_lastMessageCount != provider.messages.length) {
          _lastMessageCount = provider.messages.length;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Chat',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 16.5.sp,
                  ),
                ),
                Text(
                  'Connected to your manager team',
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.hasThread
                    ? () => provider.refreshMessages()
                    : null,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        theme.scaffoldBackgroundColor,
                        theme.cardColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFFF7FFF8),
                        Color(0xFFEFFAF2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (provider.vehicleLabel.trim().isNotEmpty)
                    Container(
                      margin: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.5.w,
                        vertical: 0.9.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green
                            .withValues(alpha: isDark ? .18 : .1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_filled_rounded,
                            color: AppColors.green,
                            size: 16.sp,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              provider.vehicleLabel,
                              style:
                                  AppStyles.regularTextStyle(context).copyWith(
                                fontSize: 13.sp,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: provider.isInitializing
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () => provider.hasThread
                                ? provider.refreshMessages()
                                : provider.initialize(),
                            child: provider.hasThread
                                ? _MessageList(
                                    controller: _scrollController,
                                    messages: provider.messages,
                                    isLoadingMore: provider.isLoadingMessages &&
                                        provider.messages.isEmpty,
                                  )
                                : _EmptyChatState(
                                    isStarting: provider.isStartingChat,
                                    onStartChat: provider.startChat,
                                    hasLinkedVehicle: provider.hasLinkedVehicle,
                                    vehicleName: provider.vehicleLabel,
                                  ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, .6.h, 4.w, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FilledButton.icon(
                            onPressed: provider.isSendingPreAlert
                                ? null
                                : () => _showPreAlertDialog(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.8.w,
                                vertical: .8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            icon: provider.isSendingPreAlert
                                ? SizedBox(
                                    width: 13.sp,
                                    height: 13.sp,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.warning_amber_rounded,
                                    size: 15.sp,
                                  ),
                            label: Text(
                              'Pre Alert Info',
                              style:
                                  AppStyles.semiboldTextStyle(context).copyWith(
                                color: Colors.white,
                                fontSize: 12.4.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.7.h),
                          FilledButton.icon(
                            onPressed: provider.isSendingLocation
                                ? null
                                : () => _showSendLocationDialog(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.8.w,
                                vertical: .8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            icon: provider.isSendingLocation
                                ? SizedBox(
                                    width: 13.sp,
                                    height: 13.sp,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.near_me_rounded,
                                    size: 15.sp,
                                  ),
                            label: Text(
                              'Send Location',
                              style:
                                  AppStyles.semiboldTextStyle(context).copyWith(
                                color: Colors.white,
                                fontSize: 12.4.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _ComposerBar(
                    controller: _messageController,
                    isSending: provider.isSending,
                    onSend: () => _handleSend(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final bool isStarting;
  final VoidCallback onStartChat;
  final bool hasLinkedVehicle;
  final String? vehicleName;

  const _EmptyChatState({
    required this.isStarting,
    required this.onStartChat,
    required this.hasLinkedVehicle,
    this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 28.sp,
                  color: AppColors.green,
                ),
              ),
              SizedBox(height: 2.2.h),
              Text(
                hasLinkedVehicle
                    ? 'Report an issue about this vehicle'
                    : 'Start a conversation with your manager team',
                textAlign: TextAlign.center,
                style: AppStyles.boldTextStyle(context).copyWith(
                  fontSize: 18.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                hasLinkedVehicle
                    ? 'Your message will include the selected vehicle context so support knows which unit you are referring to.'
                    : 'Send your first message when you need help, updates, or support.',
                textAlign: TextAlign.center,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.5.sp,
                ),
              ),
              if ((vehicleName?.trim().isNotEmpty ?? false)) ...[
                SizedBox(height: 1.2.h),
                Text(
                  vehicleName!,
                  textAlign: TextAlign.center,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.sp,
                    color: AppColors.green,
                  ),
                ),
              ],
              SizedBox(height: 2.4.h),
              FilledButton.icon(
                onPressed: isStarting ? null : onStartChat,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.3.h,
                  ),
                ),
                icon: isStarting
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.chat_rounded),
                label: Text(
                  isStarting
                      ? 'Starting...'
                      : (hasLinkedVehicle
                          ? 'Start Complaint Chat'
                          : 'Start Chat'),
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  final ScrollController controller;
  final List<ManagerChatMessage> messages;
  final bool isLoadingMore;

  const _MessageList({
    required this.controller,
    required this.messages,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'No messages yet. Say hello to your manager.',
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.5.sp,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ManagerChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (message.isSystem) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.8.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: isDark ? .7 : .95),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message.message,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 11.5.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: .64),
              ),
            ),
          ),
        ),
      );
    }

    final isCustomer = message.isCustomer;
    final bubbleColor = isCustomer
        ? AppColors.green
        : (isDark ? theme.cardColor : Colors.white);
    final textColor = isCustomer ? Colors.white : theme.colorScheme.onSurface;
    final alignment =
        isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlignment =
        isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start;
    final timestamp = _formatMessageTime(message.createdAt);

    return Row(
      mainAxisAlignment: rowAlignment,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 72.w),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.6.h),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.8.w,
                    vertical: 1.25.h,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isCustomer ? 20 : 6),
                      topRight: Radius.circular(isCustomer ? 6 : 20),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? .18 : .06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      color: textColor,
                      fontSize: 13.4.sp,
                    ),
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  message.isPending ? 'Sending...' : timestamp,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 11.6.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }
}

class _ComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _ComposerBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.1.h, 4.w, 1.6.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .05),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Write a message...',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: .06)
                    : const Color(0xFFF4F7F5),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.35.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.8.w),
          InkWell(
            onTap: isSending ? null : onSend,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSending
                    ? AppColors.green.withValues(alpha: .6)
                    : AppColors.green,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: isSending
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
