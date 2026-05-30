import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_app_bar.dart';

class CallCenterScreen extends StatelessWidget {
  const CallCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA);
    final surface = isDark ? const Color(0xFF171B26) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: background,
      appBar: CustomAppBar(
        title: 'Call Center',
        showBackButton: true,
        showThemeToggle: true,
        showNotification: true,
        backgroundColor: const Color(0xFF005C45),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _AccordionSection(
            title: 'AAWSA',
            subtitle: 'Addis Ababa Water & Sewerage Authority',
            surface: surface,
            entries: const [
              _BranchEntry(
                serial: '1',
                office: 'Head Office',
                phones: ['0116674036', '0116673982', '0116674063', '0116673983', '0116674064'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '2',
                office: 'Megnegna Branch',
                phones: ['0116674035', '0116674051', '0116673996'],
                subCities: ['Bole Sub City', 'Yeka Sub City', 'Kirkos Sub City'],
              ),
              _BranchEntry(
                serial: '3',
                office: 'Gurd Shola Branch',
                phones: ['0116675508', '0116675519', '0116675459'],
                subCities: ['Bole Sub City', 'Yeka Sub City'],
              ),
              _BranchEntry(
                serial: '4',
                office: 'Arada Branch',
                phones: ['0111260810', '0111260835', '0111260824'],
                subCities: ['Arada Sub City', 'Gulele Sub City', 'Addis Ketema Sub City', 'Kirkos Sub City', 'Yeka Sub City'],
              ),
              _BranchEntry(
                serial: '5',
                office: 'Akaki Branch',
                phones: ['0114716362', '0114716326', '0114716335'],
                subCities: ['Akaki Sub City'],
              ),
              _BranchEntry(
                serial: '6',
                office: 'Addis Ketema Branch',
                phones: ['0112736004', '0112736035', '0112787478'],
                subCities: ['Addis Ketema Sub City', 'Kolfe Sub City', 'Gulele Sub City', 'Ledeta Sub City'],
              ),
              _BranchEntry(
                serial: '7',
                office: 'Nefas Silk Branch',
                phones: ['0114700920', '0114700932', '0114700925'],
                subCities: ['Nefas Silk Lafto Sub City', 'Kirkos Sub City', 'Akaki Sub City'],
              ),
              _BranchEntry(
                serial: '8',
                office: 'Gulele Branch',
                phones: ['0111260742', '0111260745', '0111260831'],
                subCities: ['Gulele Sub City', 'Yeka Sub City', 'Arada Sub City'],
              ),
              _BranchEntry(
                serial: '9',
                office: 'Mekanisa Branch',
                phones: ['0113691338', '0113691387', '0113691384'],
                subCities: ['Kolfe Sub City', 'Nefas Silk Lafto Sub City', 'Ledeta Sub City', 'Kirkos Sub City'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AccordionSection(
            title: 'EEP',
            subtitle: 'Ethiopian Electric Utility',
            surface: surface,
            entries: const [
              _BranchEntry(
                serial: '1',
                office: 'Chief Executive Office',
                phones: ['011-5-58-06-07'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '2',
                office: 'Assistant Administrative Office',
                phones: ['011-5-58-08-05'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '3',
                office: 'Human Resources Office',
                phones: ['011-5-58-06-03'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '4',
                office: 'Corporate Communication Office',
                phones: ['011-5-58-05-98'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '5',
                office: 'Vigilian Office',
                phones: ['011-5-58-05-91'],
                subCities: ['--'],
              ),
              _BranchEntry(
                serial: '6',
                office: 'Marketing & Business Bureau Office',
                phones: ['011-5-58-03-37'],
                subCities: ['--'],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.title,
    required this.subtitle,
    required this.surface,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final Color surface;
  final List<_BranchEntry> entries;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: const Color(0xFF005C45),
          collapsedIconColor: onSurface.withValues(alpha: 0.58),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: onSurface.withValues(alpha: 0.62),
            ),
          ),
          children: [
            _TableHeader(onSurface: onSurface),
            const SizedBox(height: 10),
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BranchCard(entry: entry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.onSurface});

  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          child: Text(
            'S.No',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Branch Office & Phone Number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Covers Sub City',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.entry});

  final _BranchEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              entry.serial,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF005C45),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _DetailColumn(
              title: entry.office,
              lines: entry.phones,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _DetailColumn(
              title: entry.subCities.join('\n'),
              lines: const [],
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
    required this.title,
    required this.lines,
    this.compact = false,
  });

  final String title;
  final List<String> lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: onSurface,
          ),
        ),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: 6),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: onSurface.withValues(alpha: 0.74),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BranchEntry {
  const _BranchEntry({
    required this.serial,
    required this.office,
    required this.phones,
    required this.subCities,
  });

  final String serial;
  final String office;
  final List<String> phones;
  final List<String> subCities;
}