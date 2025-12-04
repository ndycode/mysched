import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../services/profile_cache.dart';
import '../theme/tokens.dart';
import 'brand_header.dart';
import 'layout.dart';

/// Shared scaffold that renders the MySched brand header and keeps the avatar fresh.
class BrandScaffold extends StatefulWidget {
  const BrandScaffold({
    super.key,
    required this.screenName,
    required this.builder,
    this.onRefresh,
    this.physics,
    this.padding,
    this.floatingActionButton,
    this.onAccountOpened,
    this.refreshColor,
    this.refreshBackgroundColor,
  });

  final String screenName;
  final List<Widget> Function(BuildContext context, ProfileSummary profile)
      builder;
  final Future<void> Function()? onRefresh;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final Future<void> Function()? onAccountOpened;
  final Color? refreshColor;
  final Color? refreshBackgroundColor;

  @override
  State<BrandScaffold> createState() => _BrandScaffoldState();
}

class _BrandScaffoldState extends State<BrandScaffold> {
  ProfileSummary _profile = const ProfileSummary();
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool refresh = false}) async {
    final summary = await ProfileCache.load(forceRefresh: refresh);
    if (!mounted) return;
    setState(() {
      _profile = summary;
      _loadingProfile = false;
    });
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _loadProfile(refresh: true);
    if (widget.onAccountOpened != null) {
      await widget.onAccountOpened!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final padding =
        widget.padding ?? EdgeInsets.fromLTRB(20, topInset + 24, 20, 24);
    final physics = widget.physics ??
        (Theme.of(context).platform == TargetPlatform.iOS
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const AlwaysScrollableScrollPhysics());

    final header = BrandHeader(
      name: _profile.name,
      email: _profile.email,
      avatarUrl: _profile.avatarUrl,
      onAccountTap: _openAccount,
    );

    final bodyChildren = widget.builder(context, _profile);
    final listChildren = <Widget>[
      header,
      SizedBox(height: AppTokens.spacing.lg),
      ...bodyChildren,
    ];

    Widget listView = ListView(
      padding: padding,
      physics: physics,
      children: listChildren,
    );

    final refreshCallback = widget.onRefresh;
    if (refreshCallback != null) {
      listView = RefreshIndicator(
        onRefresh: () async {
          await _loadProfile(refresh: true);
          await refreshCallback();
        },
        color: widget.refreshColor ?? Theme.of(context).colorScheme.primary,
        backgroundColor: widget.refreshBackgroundColor ?? Colors.transparent,
        child: listView,
      );
    }

    return AppScaffold(
      screenName: widget.screenName,
      safeArea: false,
      floatingActionButton: widget.floatingActionButton,
      body: AppBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _loadingProfile && _profile.avatarUrl == null
              ? const Center(child: CircularProgressIndicator())
              : listView,
        ),
      ),
    );
  }
}
