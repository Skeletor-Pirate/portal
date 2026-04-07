import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class GlobalPages extends StatelessWidget {
  final String page;
  const GlobalPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard': return const _Dashboard();
      case 'schools':   return const _Schools();
      case 'domains':   return const _Domains();
      case 'sysconfig': return const _SysConfig();
      default:          return defaultPage(page);
    }
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(kRoles[UserRole.global]!.avatarAsset, 'EduCore Platform'),
      profileInfo('Jordan Wells', 'Global Platform Administrator', 'Platform ID: #0001'),
      pageTitle('Dashboard', subtitle: '12 active schools · All systems operational'),
      statGrid([
        StatItem(icon: Icons.account_balance_rounded,     iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '12',    label: 'Schools Online',  delta: 8),
        StatItem(icon: Icons.group_rounded,          iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: '8.4K',  label: 'Total Users',     delta: 12),
        StatItem(icon: Icons.verified_user_rounded,    iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '94%',   label: 'Uptime SLA',      delta: 2),
        StatItem(icon: Icons.bolt_rounded,            iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '231ms', label: 'Avg Latency',     delta: -5),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.add_circle_rounded,   label: 'Setup School',  bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.language_rounded,         label: 'Domains',       bg: AppColors.tealLight,  iconColor: AppColors.teal),
        ActionItem(icon: Icons.settings_rounded,     label: 'Sys Config',    bg: AppColors.greenLight, iconColor: AppColors.green),
        ActionItem(icon: Icons.verified_user_rounded,   label: 'Access Ctrl',   bg: AppColors.amberLight, iconColor: AppColors.amber),
        ActionItem(icon: Icons.bar_chart_rounded,     label: 'Analytics',     bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.notifications_active_rounded,      label: 'Alerts',        bg: AppColors.redLight,   iconColor: AppColors.red),
      ]),
      secLabel('System Health'),
      appCard(Column(children: [
        sysRow('API Gateway',   true,  '99.98%'),
        sysRow('Auth Service',  true,  '99.95%'),
        sysRow('DB Cluster',    true,  '99.99%'),
        sysRow('Payment GW',    true,  '99.87%'),
        sysRow('Email Service', false, '97.2%'),
        sysRow('Storage CDN',   true,  '99.96%'),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Schools extends StatelessWidget {
  const _Schools();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Schools', subtitle: 'All registered tenants'),
      searchBar(placeholder: 'Search schools...'),
      appCard(Column(children: [
        schoolCard('Westfield Academy',      'westfield.educore.io',  1240, 84,  'Active'),
        schoolCard('Northgate Prep',          'northgate.educore.io',  890,  62,  'Active'),
        schoolCard('Sunrise International',   'sunrise.educore.io',    2100, 145, 'Active'),
        schoolCard('Lakeview High',           'lakeview.educore.io',   670,  48,  'Trial'),
        schoolCard('Metro Science Academy',   'metro.educore.io',      530,  41,  'Active'),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Setup New School')),
      const SizedBox(height: 16),
    ],
  );
}

class _Domains extends StatelessWidget {
  const _Domains();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Domains', subtitle: 'Custom tenant domains & SSL'),
      appCard(Column(children: [
        ...[
          ('westfield.educore.io', 'Valid',    'Dec 2025'),
          ('northgate.educore.io', 'Valid',    'Jan 2026'),
          ('app.educore.io',       'Valid',    'Mar 2026'),
          ('sunrise.educore.io',   'Renewing', 'Apr 2025'),
        ].map((d) => listItem(
          avIcon: Icons.link_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
          name: d.$1, sub: 'SSL · Expires ${d.$3}',
          badgeText: d.$2,
          badgeBg:    d.$2 == 'Valid' ? AppColors.greenLight : AppColors.amberLight,
          badgeColor: d.$2 == 'Valid' ? AppColors.green      : AppColors.amber,
        )),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Domain')),
      const SizedBox(height: 16),
    ],
  );
}

class _SysConfig extends StatelessWidget {
  const _SysConfig();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('System Config', subtitle: 'Global platform settings'),
      secLabel('Feature Flags'),
      appCard(Column(children: [
        ToggleRow(label: 'Maintenance Mode',    desc: 'Disable access for all tenants'),
        ToggleRow(label: 'Auto SSL Renewal',    desc: 'Renew certificates automatically', initialValue: true),
        ToggleRow(label: 'Payment Gateway',     desc: 'Enable online payment processing', initialValue: true),
        ToggleRow(label: 'Email Notifications', desc: 'Send system alerts via email',     initialValue: true),
        ToggleRow(label: 'Debug Logging',       desc: 'Verbose logs for all tenants'),
      ])),
      secLabel('Resource Usage'),
      appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        ProgressBar(label: 'Storage Used',   value: 67, gradient: blueGrad()),
        ProgressBar(label: 'API Rate Limit', value: 42, gradient: greenGrad()),
        ProgressBar(label: 'Email Quota',    value: 81, gradient: amberGrad()),
      ]))),
      const SizedBox(height: 16),
    ],
  );
}
