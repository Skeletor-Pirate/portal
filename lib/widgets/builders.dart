import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

// ── SECTION LABEL ──────────────────────────────
Widget secLabel(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 7),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5, fontWeight: FontWeight.w700,
          letterSpacing: 1.8, color: AppColors.text4,
        ),
      ),
    );

// ── PAGE TITLE ─────────────────────────────────
Widget pageTitle(String title, {String subtitle = ''}) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
          ),
      ]),
    );

// ── CARD ───────────────────────────────────────
Widget appCard(Widget child, {EdgeInsets? padding}) => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rLg),
        child: padding != null ? Padding(padding: padding, child: child) : child,
      ),
    );

// ── STAT GRID (FIXED FOR OVERFLOW) ──────────────
class StatItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String val;
  final String label;
  final int? delta;
  const StatItem({
    required this.icon,
    this.iconBg = AppColors.blueLight,
    this.iconColor = AppColors.blue,
    required this.val,
    required this.label,
    this.delta,
  });
}

// ── STAT GRID ──────────────────────────────────
Widget statGrid(List<StatItem> items) => Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        // LOWER childAspectRatio (e.g., 1.15) gives the cards more vertical room
        // to accommodate wrapped text without triggering an overflow error.
        childAspectRatio: 1.15, 
        children: items.map((i) => _StatCard(item: i)).toList(),
      ),
    );

class _StatCard extends StatelessWidget {
  final StatItem item;
  const _StatCard({required this.item});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(rLg),
          boxShadow: shadowSm,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Changed to 'start' to ensure content doesn't jump if lines wrap
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(rSm),
              ),
              child: Center(child: Icon(item.icon, size: 16, color: item.iconColor)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(item.val,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: AppColors.text1)),
            ),
            const SizedBox(height: 2),
            // REMOVED maxLines: 1 and TextOverflow.ellipsis to allow wrapping
            Text(
              item.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, 
                color: AppColors.text3, 
                fontWeight: FontWeight.w500,
                height: 1.2, // Tighter line height for wrapped text
              ),
            ),
            const Spacer(), // Pushes the delta row to the absolute bottom of the card
            if (item.delta != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  Icon(
                    item.delta! > 0 ? Icons.trending_up_rounded
                        : item.delta! < 0 ? Icons.trending_down_rounded
                        : Icons.remove_rounded,
                    size: 10,
                    color: item.delta! > 0 ? AppColors.green
                        : item.delta! < 0 ? AppColors.red
                        : AppColors.text3,
                  ),
                  const SizedBox(width: 2),
                  Text('${item.delta!.abs()}%',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: item.delta! > 0 ? AppColors.green
                              : item.delta! < 0 ? AppColors.red
                              : AppColors.text3)),
                ]),
              ),
          ],
        ),
      );
}
// ── ACTION GRID ────────────────────────────────
class ActionItem {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  const ActionItem({
    required this.icon,
    required this.label,
    required this.bg,
    this.iconColor = AppColors.navy,
  });
}

Widget actionGrid(List<ActionItem> items) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
        children: items.map((i) => _ActionBtn(item: i)).toList(),
      ),
    );

class _ActionBtn extends StatelessWidget {
  final ActionItem item;
  const _ActionBtn({required this.item});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(rLg),
            boxShadow: shadowSm,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: item.bg,
                borderRadius: BorderRadius.circular(rMd),
              ),
              child: Center(child: Icon(item.icon, size: 18, color: item.iconColor)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text2)),
            ),
          ]),
        ),
      );
}

// ── LIST ITEM ROW ──────────────────────────────
Widget listItem({
  required IconData avIcon,
  required Color avBg,
  required Color avColor,
  String? avInitials,
  required String name,
  required String sub,
  required String badgeText,
  required Color badgeBg,
  required Color badgeColor,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: avBg, borderRadius: BorderRadius.circular(rMd)),
          child: avInitials != null
              ? Center(child: Text(avInitials,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: avColor)))
              : Center(child: Icon(avIcon, size: 18, color: avColor)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
          Text(sub,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        ])),
        appBadge(badgeText, bg: badgeBg, color: badgeColor),
      ]),
    );

// ── BADGE ──────────────────────────────────────
Widget appBadge(String text, {Color? bg, Color? color}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? AppColors.blueMid,
        borderRadius: BorderRadius.circular(rFull),
      ),
      child: Text(text,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.3, color: color ?? AppColors.blue)),
    );

// ── PROGRESS BAR ───────────────────────────────
class ProgressBar extends StatefulWidget {
  final String label;
  final int value;
  final Gradient gradient;
  const ProgressBar({super.key, required this.label, required this.value, required this.gradient});
  @override
  State<ProgressBar> createState() => _ProgressBarState();
}
class _ProgressBarState extends State<ProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 80), () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.label,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            Text('${widget.value}%',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text1)),
          ]),
          const SizedBox(height: 5),
          SizedBox(
            height: 7,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(rFull),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_anim.value * widget.value / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(rFull),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
}

Gradient blueGrad()  => const LinearGradient(colors: [Color(0xFF2D1B8E), Color(0xFF4361EE)]);
Gradient greenGrad() => const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF22C55E)]);
Gradient amberGrad() => const LinearGradient(colors: [Color(0xFFB45309), Color(0xFFF59E0B)]);
Gradient tealGrad()  => const LinearGradient(colors: [Color(0xFF0D7490), Color(0xFF06B6D4)]);

// ── CHIP ROW ───────────────────────────────────
class ChipRow extends StatefulWidget {
  final List<String> chips;
  final int active;
  const ChipRow({super.key, required this.chips, this.active = 0});
  @override
  State<ChipRow> createState() => _ChipRowState();
}
class _ChipRowState extends State<ChipRow> {
  late int _active;
  @override
  void initState() { super.initState(); _active = widget.active; }
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Row(
          children: List.generate(widget.chips.length, (i) {
            final active = i == _active;
            return GestureDetector(
              onTap: () => setState(() => _active = i),
              child: Container(
                margin: const EdgeInsets.only(right: 7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: active ? blueGrad() : null,
                  color: active ? null : AppColors.surface,
                  border: Border.all(
                      color: active ? Colors.transparent : AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(rFull),
                  boxShadow: active ? shadowSm : null,
                ),
                child: Text(widget.chips[i],
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.text2)),
              ),
            );
          }),
        ),
      );
}

// ── SEARCH BAR ─────────────────────────────────
Widget searchBar({String placeholder = 'Search...'}) => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowSm,
      ),
      child: Row(children: [
        const Icon(Icons.search_rounded, size: 16, color: AppColors.text4),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
              border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );

// ── TIMELINE ───────────────────────────────────
class TlItem {
  final String title, sub, time;
  final Color color;
  const TlItem({required this.title, required this.sub, required this.time, required this.color});
}

Widget timeline(List<TlItem> items) => Column(
      children: List.generate(items.length, (i) {
        final e = items[i];
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 30,
              child: Column(children: [
                Container(
                  width: 9, height: 9,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: e.color, width: 2),
                  ),
                ),
                if (i < items.length - 1)
                  Expanded(child: Container(
                    width: 1, color: AppColors.border,
                    margin: const EdgeInsets.only(top: 3),
                  )),
              ]),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.title, style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text(e.sub, style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.text3)),
                Text(e.time, style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.text4)),
              ]),
            )),
          ]),
        );
      }),
    );

// ── TIMETABLE ROW ──────────────────────────────
class TtItem {
  final String time, subject, room, status;
  final Color barColor, badgeBg, badgeColor;
  const TtItem({
    required this.time, required this.subject, required this.room,
    required this.status, required this.barColor,
    required this.badgeBg, required this.badgeColor,
  });
}

Widget ttRows(List<TtItem> items) => Column(
      children: items.map((c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          SizedBox(
            width: 60,
            child: Text(c.time, style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppColors.text4)),
          ),
          Container(width: 3, height: 44,
              decoration: BoxDecoration(
                color: c.barColor,
                borderRadius: BorderRadius.circular(rFull),
              )),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.subject, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            Text(c.room, style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.text3)),
          ])),
          appBadge(c.status, bg: c.badgeBg, color: c.badgeColor),
        ]),
      )).toList(),
    );

// ── ASSIGNMENT CARD ────────────────────────────
class AsgItem {
  final String sub, title, due;
  final Color barColor;
  final String? badge;
  final Color? badgeBg, badgeColor;
  const AsgItem({
    required this.sub, required this.title, required this.due, required this.barColor,
    this.badge, this.badgeBg, this.badgeColor,
  });
}

Widget asgnCards(List<AsgItem> items) => Column(
      children: items.map((a) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 3, height: 64,
              decoration: BoxDecoration(
                color: a.barColor,
                borderRadius: BorderRadius.circular(rFull),
              )),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.sub, style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700,
                letterSpacing: 1.0, color: a.barColor)),
            const SizedBox(height: 3),
            Text(a.title, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.text4),
              const SizedBox(width: 4),
              Text(a.due, style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3)),
            ]),
            if (a.badge != null) ...[
              const SizedBox(height: 6),
              appBadge(a.badge!, bg: a.badgeBg, color: a.badgeColor),
            ],
          ])),
        ]),
      )).toList(),
    );

// ── GRADE BARS ─────────────────────────────────
class GradeItem {
  final String subject;
  final int value;
  final Color color;
  const GradeItem({required this.subject, required this.value, required this.color});
}

class GradeBars extends StatefulWidget {
  final List<GradeItem> items;
  const GradeBars({super.key, required this.items});
  @override
  State<GradeBars> createState() => _GradeBarsState();
}
class _GradeBarsState extends State<GradeBars> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 80), () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: widget.items.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 92, child: Text(g.subject,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text2))),
              Expanded(child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(rFull),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rFull),
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _anim.value * g.value / 100,
                      child: Container(color: g.color),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              SizedBox(width: 38, child: Text('${g.value}%',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: g.color))),
            ]),
          )).toList(),
        ),
      );
}

// ── FINANCE BANNER ─────────────────────────────
Widget finBanner(String label, String amount, String sub) => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC],
        ),
        borderRadius: BorderRadius.circular(rXl),
        boxShadow: shadowMd,
      ),
      child: Stack(children: [
        Positioned(top: -30, right: -30, child: Container(
          width: 150, height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
          ),
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.currency_rupee_rounded, size: 12, color: Colors.white.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(
                fontSize: 10, letterSpacing: 1.5, color: Colors.white.withOpacity(0.65))),
          ]),
          const SizedBox(height: 8),
          RichText(text: TextSpan(children: [
            TextSpan(text: '₹', style: GoogleFonts.dmSerifDisplay(
                fontSize: 16, color: Colors.white.withOpacity(0.7))),
            TextSpan(text: amount, style: GoogleFonts.dmSerifDisplay(
                fontSize: 34, color: Colors.white)),
          ])),
          const SizedBox(height: 8),
          Text(sub, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.white.withOpacity(0.65))),
        ]),
      ]),
    );

// ── INVOICE ROW ────────────────────────────────
class InvItem {
  final String id, name, type, amount, status;
  final Color badgeBg, badgeColor;
  const InvItem({
    required this.id, required this.name, required this.type,
    required this.amount, required this.status,
    required this.badgeBg, required this.badgeColor,
  });
}

Widget invRows(List<InvItem> items) => Column(
      children: items.map((i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(rMd),
            ),
            child: const Center(child: Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.blue)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(i.id, style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text4)),
            Text(i.name, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            Text(i.type, style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.text3)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(i.amount, style: GoogleFonts.dmSerifDisplay(
                fontSize: 15, color: AppColors.text1)),
            const SizedBox(height: 4),
            appBadge(i.status, bg: i.badgeBg, color: i.badgeColor),
          ]),
        ]),
      )).toList(),
    );

// ── QUICK STATS BAR ────────────────────────────
class QsItem {
  final String val, label;
  final Color? valColor;
  const QsItem({required this.val, required this.label, this.valColor});
}

Widget quickStatsBar(List<QsItem> items) => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowSm,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: i < items.length - 1
                    ? const Border(right: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Column(children: [
                Text(item.val, style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: item.valColor ?? AppColors.text1)),
                const SizedBox(height: 2),
                Text(item.label, style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.text4)),
              ]),
            ),
          );
        }),
      ),
    );

// ── TOGGLE ROW ─────────────────────────────────
class ToggleRow extends StatefulWidget {
  final String label, desc;
  final bool initialValue;
  const ToggleRow({super.key, required this.label, required this.desc, this.initialValue = false});
  @override
  State<ToggleRow> createState() => _ToggleRowState();
}
class _ToggleRowState extends State<ToggleRow> {
  late bool _on;
  @override
  void initState() { super.initState(); _on = widget.initialValue; }
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            Text(widget.desc, style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.text3)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _on = !_on),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 24,
              decoration: BoxDecoration(
                gradient: _on ? blueGrad() : null,
                color: _on ? null : AppColors.border2,
                borderRadius: BorderRadius.circular(rFull),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
}

// ── FIELD INPUT ────────────────────────────────
Widget fieldGroup({required String label, required Widget child}) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
        const SizedBox(height: 6),
        child,
      ]),
    );

InputDecoration fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
      filled: true, fillColor: AppColors.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
    );

// ── BUTTONS ────────────────────────────────────
Widget navyBtn(String label, {VoidCallback? onTap, bool full = true}) =>
    GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: full ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          gradient: blueGrad(),
          borderRadius: BorderRadius.circular(rMd),
          boxShadow: shadowSm,
        ),
        child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
      ),
    );

Widget outlineBtn(String label, {VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border2, width: 1.5),
          borderRadius: BorderRadius.circular(rMd),
        ),
        child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text2))),
      ),
    );

Widget dangerBtn(String label, {VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
          borderRadius: BorderRadius.circular(rMd),
        ),
        child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.red))),
      ),
    );

// ── HERO PORTRAIT ──────────────────────────────
Widget heroPortrait(String avatarAsset, String school) => Stack(
      alignment: Alignment.bottomLeft,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
              stops: [0.45, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstOut,
            child: Image.asset(
              avatarAsset,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradA, AppColors.gradB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.75),
              borderRadius: BorderRadius.circular(rFull),
            ),
            child: Text(school.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white)),
          ),
        ),
      ],
    );

Widget profileInfo(String name, String role, String idLabel) => Container(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: AppColors.text1)),
        Text(role, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
        Text(idLabel, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue)),
      ]),
    );

// ── SCHOOL CARD ────────────────────────────────
Widget schoolCard(String name, String domain, int students, int teachers, String status) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
          child: const Center(child: Icon(Icons.account_balance_rounded, size: 20, color: AppColors.blue)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
          Text(domain, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          Row(children: [
            const Icon(Icons.school_rounded, size: 10, color: AppColors.text4),
            const SizedBox(width: 3),
            Text('$students', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
            const SizedBox(width: 10),
            const Icon(Icons.menu_book_rounded, size: 10, color: AppColors.text4),
            const SizedBox(width: 3),
            Text('$teachers', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
          ]),
        ])),
        appBadge(status,
            bg: status == 'Active' ? AppColors.greenLight : AppColors.amberLight,
            color: status == 'Active' ? AppColors.green : AppColors.amber),
      ]),
    );

// ── CHILD CARD ─────────────────────────────────
Widget childCard() => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC],
        ),
        borderRadius: BorderRadius.circular(rXl),
        boxShadow: shadowMd,
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rLg),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(rLg),
            child: Image.asset('assets/avatars/student.png', fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.navy2)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Arjun Mehta', style: GoogleFonts.dmSerifDisplay(fontSize: 17, color: Colors.white)),
          Text('Grade 10A · Roll #018', style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 10),
          Row(children: [
            _cmVal('88%', 'Grade'), const SizedBox(width: 16),
            _cmVal('91%', 'Attend'), const SizedBox(width: 16),
            _cmVal('2', 'Pending'),
          ]),
        ])),
      ]),
    );

Widget _cmVal(String val, String lbl) => Column(children: [
  Text(val, style: GoogleFonts.dmSerifDisplay(
      fontSize: 17, color: Colors.white.withOpacity(0.95))),
  Text(lbl, style: GoogleFonts.plusJakartaSans(
      fontSize: 9, color: Colors.white.withOpacity(0.65))),
]);

// ── SYSTEM STATUS ROW ──────────────────────────
Widget sysRow(String name, bool online, String uptime) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? AppColors.green : AppColors.amber,
              boxShadow: [BoxShadow(
                color: (online ? AppColors.green : AppColors.amber).withOpacity(0.4),
                blurRadius: 4,
              )],
            ),
          ),
          const SizedBox(width: 10),
          Text(name, style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: AppColors.text1)),
        ]),
        Text(uptime, style: GoogleFonts.plusJakartaSans(
            fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text4)),
      ]),
    );

// ── ATTENDANCE GRID ────────────────────────────
Widget attendanceGrid() {
  final headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return Column(children: [
    Row(children: headers.map((d) => Expanded(child: Center(
      child: Text(d, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.text4)),
    ))).toList()),
    const SizedBox(height: 4),
    GridView.count(
      crossAxisCount: 7, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4, crossAxisSpacing: 4,
      children: List.generate(30, (i) {
        if (i >= 28) return Container();
        final rnd = (i * 7 + 13) % 100 / 100;
        Color bg, fg;
        if (rnd > 0.95) { bg = AppColors.redLight; fg = AppColors.red; }
        else if (rnd > 0.88) { bg = AppColors.amberLight; fg = AppColors.amber; }
        else { bg = AppColors.greenLight; fg = AppColors.green; }
        return Container(
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
          child: Center(child: Text('${i + 1}', style: GoogleFonts.plusJakartaSans(
              fontSize: 9, fontWeight: FontWeight.w600, color: fg))),
        );
      }),
    ),
  ]);
}

// ── AUTH CARD ─────────────────────────────────
class AuthCardItem {
  final String name, desc, amount, via, id;
  const AuthCardItem({required this.name, required this.desc, required this.amount, required this.via, required this.id});
}

Widget authCard(AuthCardItem item) => Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowSm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
              Text('${item.desc} · ${item.amount}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3)),
              Text('${item.id} via ${item.via}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: AppColors.text4)),
            ])),
            appBadge('Pending', bg: AppColors.amberLight, color: AppColors.amber),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                  borderRadius: BorderRadius.circular(rSm),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_rounded, size: 14, color: AppColors.green),
                  const SizedBox(width: 4),
                  Text('Approve', style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green)),
                ]),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                  borderRadius: BorderRadius.circular(rSm),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.close_rounded, size: 14, color: AppColors.red),
                  const SizedBox(width: 4),
                  Text('Reject', style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red)),
                ]),
              ),
            )),
          ]),
        ),
      ]),
    );

// ── EXAM CHIPS ─────────────────────────────────
Widget examChips(List<List<String>> items) => Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Wrap(spacing: 8, runSpacing: 8,
        children: items.map((c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(rLg),
            boxShadow: shadowSm,
          ),
          constraints: const BoxConstraints(minWidth: 64),
          child: Column(children: [
            Text(c[0], style: GoogleFonts.plusJakartaSans(
                fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 1.0, color: AppColors.text4)),
            Text(c[1], style: GoogleFonts.dmSerifDisplay(
                fontSize: 20, color: AppColors.text1)),
            Text(c[2], style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green)),
          ]),
        )).toList(),
      ),
    );