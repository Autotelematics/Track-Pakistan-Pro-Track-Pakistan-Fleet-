import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/admin_user_list_model.dart';
import 'package:trackerapp/data/repositories/admin_user_list_repository.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final AdminUserListRepository _repo = AdminUserListRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AdminUserItem> _items = const [];
  String _title = "User List";
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  int _lastPage = 1;

  final Map<int, bool> _localToggles = {};
  final Set<int> _updatingUserIds = <int>{};
  final Set<int> _loggingInAsUserIds = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUsers(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers({String? email, bool reset = false}) async {
    if (!reset && (_isLoading || _isLoadingMore)) return;
    if (!reset && _currentPage >= _lastPage) return;

    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _lastPage = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final targetPage = reset ? 1 : _currentPage + 1;
    final token = MySharedPreferences.getString(authTokenKey).trim();
    final model = await _repo.getAdminUserList(
      token: token,
      email: email ?? _searchController.text,
      page: targetPage,
    );
    if (!mounted) return;

    final existing =
        reset ? <AdminUserItem>[] : List<AdminUserItem>.from(_items);
    final seenIds = existing.map((e) => e.userId).toSet();
    final incoming = model?.items ?? const <AdminUserItem>[];

    for (final item in incoming) {
      if (!seenIds.contains(item.userId)) {
        existing.add(item);
        seenIds.add(item.userId);
      }
      _localToggles[item.userId] = item.isActive;
    }

    setState(() {
      if (reset) {
        _localToggles.removeWhere((userId, _) => !seenIds.contains(userId));
      }
      _items = existing;
      if (model != null) {
        _title = model.title.trim().isEmpty ? "User List" : model.title;
        _currentPage = model.pagination.currentPage;
        _lastPage =
            model.pagination.lastPage <= 0 ? 1 : model.pagination.lastPage;
      } else if (reset) {
        _title = "User List";
        _currentPage = 1;
        _lastPage = 1;
      }
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  Widget _field(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: .45.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  AppStyles.lightTextStyle(context).copyWith(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(BuildContext context, AdminUserItem item) {
    final theme = Theme.of(context);
    final isActive = _localToggles[item.userId] ?? item.isActive;
    final statusColor = isActive ? Colors.green : Colors.red;
    final isUpdating = _updatingUserIds.contains(item.userId);
    final isLoggingInAs = _loggingInAsUserIds.contains(item.userId);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.2.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.userEmail,
                style: AppStyles.semiboldTextStyle(context)
                    .copyWith(fontSize: 14.sp),
              ),
              Row(
                children: [
                  Text(
                    isActive ? "Active" : "Inactive",
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(width: 1.6.w),
                  Switch(
                    value: isActive,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.red.withValues(alpha: .65),
                    onChanged: isUpdating
                        ? null
                        : (value) async {
                            final previous =
                                _localToggles[item.userId] ?? item.isActive;
                            final messenger =
                                ScaffoldMessenger.of(this.context);
                            setState(() {
                              _localToggles[item.userId] = value;
                              _updatingUserIds.add(item.userId);
                            });

                            final token =
                                MySharedPreferences.getString(authTokenKey)
                                    .trim();
                            final result = await _repo.setAdminUserStatus(
                              token: token,
                              userId: item.userId,
                              status: value ? 1 : 0,
                            );

                            if (!mounted) return;
                            setState(() {
                              if (result.success) {
                                if (result.activeStatus != null) {
                                  _localToggles[item.userId] =
                                      result.activeStatus == 1;
                                }
                              } else {
                                _localToggles[item.userId] = previous;
                              }
                              _updatingUserIds.remove(item.userId);
                            });

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: .5.h),
          _field(context, "User Type", item.userType),
          _field(context, "Manager", item.manager),
          _field(context, "Total Devices", item.totalDevices.toString()),
          _field(
              context, "Devices Limit", item.devicesLimit?.toString() ?? "-"),
          _field(context, "Expiration Date", item.expirationDate),
          _field(context, "Last Login", item.lastLogin),
          SizedBox(height: .5.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: isLoggingInAs
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      setState(() {
                        _loggingInAsUserIds.add(item.userId);
                      });

                      final token =
                          MySharedPreferences.getString(authTokenKey).trim();
                      final result = await _repo.loginAsUser(
                        token: token,
                        userId: item.userId,
                      );

                      if (!mounted) return;
                      setState(() {
                        _loggingInAsUserIds.remove(item.userId);
                      });

                      if (!result.success) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final isAlreadyImpersonating =
                          MySharedPreferences.getBool(isImpersonatingAsUserKey);
                      if (!isAlreadyImpersonating) {
                        await MySharedPreferences.setString(
                          adminOriginalAuthTokenKey,
                          MySharedPreferences.getString(authTokenKey),
                        );
                        await MySharedPreferences.setInt(
                          adminOriginalUserIdKey,
                          MySharedPreferences.getInt(userIdKey),
                        );
                        await MySharedPreferences.setString(
                          adminOriginalUserEmailKey,
                          MySharedPreferences.getString(userEmailKey),
                        );
                        await MySharedPreferences.setString(
                          adminOriginalUserTypeKey,
                          MySharedPreferences.getString(userTypeKey),
                        );
                      }

                      await MySharedPreferences.setBool(
                          isImpersonatingAsUserKey, true);
                      await MySharedPreferences.setString(
                          authTokenKey, result.userApiHash);
                      await MySharedPreferences.setInt(
                          userIdKey, result.userId);
                      await MySharedPreferences.setString(
                          userEmailKey, result.userEmail);
                      await MySharedPreferences.setString(
                          userTypeKey, result.userType);
                      try {
                        await FcmTokenRepository()
                            .syncCurrentDeviceToken(force: true);
                      } catch (_) {}

                      if (!mounted) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MotionBottomNavigationBar(
                            showBackToAdminAction: true,
                          ),
                        ),
                      );
                    },
              child: Text(
                isLoggingInAs ? "Logging in..." : "Login as user",
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, .8.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadUsers(reset: true),
                    decoration: InputDecoration(
                      hintText: "Search by email...",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.2.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () => _loadUsers(reset: true),
                  icon: const Icon(Icons.search),
                  tooltip: "Search",
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_items.isEmpty)
                    ? Center(
                        child: Text(
                          "No users found.",
                          style: AppStyles.regularTextStyle(context),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadUsers(reset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(4.w, .4.h, 4.w, 1.6.h),
                          itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _items.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _userCard(context, _items[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
