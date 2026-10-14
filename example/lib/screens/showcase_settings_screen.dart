import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

// =============================================================================
// Shared state
// =============================================================================

class _Device {
  const _Device(this.name, this.subtitle, this.icon);
  final String name;
  final String subtitle;
  final IconData icon;
}

class _Settings extends ChangeNotifier {
  // Profile
  String name = 'Ada Lovelace';
  String email = 'ada@example.com';

  // Network
  bool airplane = false;
  bool wifi = true;
  String? wifiNetwork = 'Home-5G';
  bool mobileData = true;
  bool hotspot = false;

  // Devices
  bool bluetooth = true;
  final List<_Device> devices = [
    const _Device(
      'Pixel Buds Pro',
      'Connected \u2022 80% battery',
      Symbols.headphones,
    ),
    const _Device('Car stereo', 'Paired', Symbols.directions_car),
    const _Device('Smartwatch', 'Paired', Symbols.watch),
  ];

  // Display
  double brightness = 0.6;
  bool adaptiveBrightness = true;
  bool darkTheme = false;
  String timeout = '1m';
  String refreshRate = 'auto';
  double fontScale = 1.0;

  // Sound
  double media = 0.7;
  double ring = 0.5;
  double alarm = 0.8;
  bool dnd = false;
  bool vibrate = true;
  String ringtone = 'Pixel Sounds';

  // Notifications
  final Map<String, bool> appNotifications = {
    'Messages': true,
    'Gmail': true,
    'Calendar': true,
    'Maps': false,
    'Photos': false,
  };
  bool lockConversations = true;
  bool lockSilent = false;

  // Battery
  bool batterySaver = false;
  bool adaptiveBattery = true;

  // Privacy
  bool location = true;
  bool biometric = true;

  // System
  String language = 'en';
  bool autoTime = true;
  bool backup = true;

  // About / developer
  bool developer = false;
  bool usbDebugging = false;
  bool layoutBounds = false;

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }
}

// =============================================================================
// Helpers
// =============================================================================

Widget _live(_Settings s, Widget Function(BuildContext) builder) =>
    ListenableBuilder(listenable: s, builder: (context, _) => builder(context));

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

// Widget _badge(IconData icon, HColorRole role) => Container(
//   width: 40,
//   height: 40,
//   decoration: BoxDecoration(color: role.soft, shape: BoxShape.circle),
//   child: Icon(icon, size: 22, color: role.onSoft),
// );
Widget _badge(IconData icon, HColorRole role) => HAvatar(
  // width: 40,
  // height: 40,
  // decoration: BoxDecoration(color: role.soft, shape: BoxShape.circle),
  backgroundColor: role.soft,
  radius: HAvatarRadius.rounded,
  child: Icon(icon, size: 22, color: role.onSoft),
);

HListTile _tile(
  BuildContext context, {
  required IconData icon,
  required HColorRole role,
  required String title,
  String? subtitle,
  Widget? suffix,
  VoidCallback? onTap,
}) {
  return HListTile(
    leading: _badge(icon, role),
    title: Text(title),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle,
            style: TextStyle(color: context.hColors.mutedForeground),
          ),
    suffix: suffix,
    onTap: onTap,
  );
}

HListTile _switchTile(
  BuildContext context, {
  required IconData icon,
  required HColorRole role,
  required String title,
  String? subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return _tile(
    context,
    icon: icon,
    role: role,
    title: title,
    subtitle: subtitle,
    suffix: HSwitch(value: value, onChanged: onChanged),
    onTap: () => onChanged(!value),
  );
}

Widget _group(List<HListTile> items) =>
    HListView(padding: EdgeInsets.zero, items: items);

Widget _label(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(left: 4),
  child: Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: context.hColors.primary.base),
  ),
);

Future<void> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
  VoidCallback? onConfirm,
}) async {
  // useRootNavigator: false keeps the dialog inside the phone frame.
  final ok = await showHDialog<bool>(
    context,
    useRootNavigator: false,
    builder: (ctx) => HDialog(
      title: Text(title),
      content: [Text(message)],
      actions: [
        HButton(
          color: .primary,
          onPressed: () => Navigator.pop(ctx, true),
          label: Text(confirm),
        ),
        HButton(
          variant: .flat,
          onPressed: () => Navigator.pop(ctx, false),
          label: const Text('Cancel'),
        ),
      ],
    ),
  );
  if (ok == true) onConfirm?.call();
}

Future<T?> _pick<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
}) {
  return showHDialog<T>(
    context,
    useRootNavigator: false,
    builder: (ctx) => HDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          HListHeader(title: title, padding: .zero),
          HListView.builder(
            padding: .zero,
            itemCount: options.length,
            itemBuilder: (index) => HListTile(
              title: Text(options[index].$2),
              onTap: () => Navigator.pop(ctx, options[index].$1),
            ),
          ),
          HButton(
            variant: .flat,
            fullWidth: true,
            onPressed: () => Navigator.pop(ctx),
            label: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}

/// Standard sub-page: app bar plus a padded, scrollable column.
class _Page extends StatelessWidget {
  const _Page({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return HScaffold(
      appBar: HAppBar(title: Text(title)),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min, max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.hColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: c.primary.base,
            inactiveTrackColor: c.content3,
            thumbColor: c.primary.base,
            overlayColor: c.primary.base.withValues(alpha: 0.12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: c.mutedForeground),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Home page
// =============================================================================

class _Entry {
  const _Entry(this.icon, this.role, this.title, this.subtitle, this.page);
  final IconData icon;
  final HColorRole role;
  final String title;
  final String subtitle;
  final Widget Function() page;
}

class _HomePage extends StatefulWidget {
  const _HomePage(this.s);
  final _Settings s;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return _live(s, (context) {
      final c = context.hColors;

      final groups = <List<_Entry>>[
        [
          _Entry(
            Symbols.wifi,
            c.primary,
            'Network & internet',
            s.airplane
                ? 'Airplane mode'
                : s.wifi
                ? '${s.wifiNetwork ?? 'Wi\u2011Fi on'} \u2022 Mobile data'
                : 'Wi\u2011Fi off',
            () => _NetworkPage(s),
          ),
          _Entry(
            Symbols.bluetooth,
            c.primary,
            'Connected devices',
            s.bluetooth
                ? '${s.devices.length} paired devices'
                : 'Bluetooth off',
            () => _DevicesPage(s),
          ),
        ],
        [
          _Entry(
            Symbols.notifications,
            c.warning,
            'Notifications',
            'Notification history, app notifications',
            () => _NotificationsPage(s),
          ),
          _Entry(
            Symbols.volume_up,
            c.danger,
            'Sound & vibration',
            s.dnd ? 'Do Not Disturb is on' : 'Volume, haptics, ringtone',
            () => _SoundPage(s),
          ),
          _Entry(
            Symbols.brightness_6,
            c.warning,
            'Display',
            s.darkTheme ? 'Dark theme, font size' : 'Light theme, font size',
            () => _DisplayPage(s),
          ),
        ],
        [
          _Entry(
            Symbols.battery_android_full,
            c.success,
            'Battery',
            s.batterySaver ? 'Battery Saver on' : '84% \u2022 About 1 day left',
            () => _BatteryPage(s),
          ),
          _Entry(
            Symbols.storage,
            c.tertiary,
            'Storage',
            '70% used \u2022 39 GB free',
            () => _StoragePage(s),
          ),
        ],
        [
          _Entry(
            Symbols.security,
            c.success,
            'Security & privacy',
            'Location, biometrics, permissions',
            () => _PrivacyPage(s),
          ),
          _Entry(
            Symbols.settings,
            c.secondary,
            'System',
            'Languages, time, backup, reset',
            () => _SystemPage(s),
          ),
          _Entry(
            Symbols.info,
            c.primary,
            'About phone',
            'Pixel 9 Pro',
            () => _AboutPage(s),
          ),
        ],
      ];

      final q = _query.trim().toLowerCase();
      final matches = [
        for (final e in groups.expand((g) => g))
          if (e.title.toLowerCase().contains(q) ||
              e.subtitle.toLowerCase().contains(q))
            e,
      ];

      HListTile toTile(_Entry e) => _tile(
        context,
        icon: e.icon,
        role: e.role,
        title: e.title,
        subtitle: e.subtitle,
        onTap: () => _push(context, e.page()),
      );

      return _Page(
        title: 'Settings',
        children: [
          HTextField(
            hintText: 'Search settings',
            startContent: Icon(
              Symbols.search,
              size: 20,
              color: c.mutedForeground,
            ),
            isClearable: true,
            onChanged: (v) => setState(() => _query = v),
          ),
          if (q.isEmpty) ...[
            GestureDetector(
              onTap: () => _push(context, _ProfilePage(s)),
              child: HFilledCard(
                child: Row(
                  children: [
                    HAvatar(size: HAvatarSize.lg, name: s.name),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            s.email,
                            style: TextStyle(color: c.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    Icon(Symbols.chevron_right, color: c.mutedForeground),
                  ],
                ),
              ),
            ),
            for (final g in groups) _group([for (final e in g) toTile(e)]),
          ] else if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No settings found',
                  style: TextStyle(color: c.mutedForeground),
                ),
              ),
            )
          else
            _group([for (final e in matches) toTile(e)]),
        ],
      );
    });
  }
}

// =============================================================================
// Profile
// =============================================================================

class _ProfilePage extends StatefulWidget {
  const _ProfilePage(this.s);
  final _Settings s;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  late final _name = TextEditingController(text: widget.s.name);
  late final _email = TextEditingController(text: widget.s.email);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hColors;
    return _Page(
      title: 'Device Account',
      children: [
        HAvatar(size: HAvatarSize.lg, name: widget.s.name),
        _label(context, 'Name'),
        HTextField(controller: _name, hintText: 'Full name'),
        _label(context, 'Email'),
        HTextField(
          controller: _email,
          hintText: 'Email address',
          startContent: Icon(Symbols.mail, size: 18, color: c.mutedForeground),
        ),
        HButton(
          label: const Text('Save changes'),
          onPressed: () {
            widget.s.update(() {
              widget.s.name = _name.text.trim().isEmpty
                  ? widget.s.name
                  : _name.text.trim();
              widget.s.email = _email.text.trim().isEmpty
                  ? widget.s.email
                  : _email.text.trim();
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Network & internet  ->  Wi-Fi
// =============================================================================

class _NetworkPage extends StatelessWidget {
  const _NetworkPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Network & internet',
      children: [
        _group([
          _switchTile(
            context,
            icon: Symbols.flight,
            role: c.warning,
            title: 'Airplane mode',
            value: s.airplane,
            onChanged: (v) => s.update(() {
              s.airplane = v;
              if (v) {
                s.wifi = false;
                s.bluetooth = false;
                s.hotspot = false;
              }
            }),
          ),
        ]),
        _group([
          _tile(
            context,
            icon: Symbols.wifi,
            role: c.primary,
            title: 'Wi\u2011Fi',
            subtitle: s.wifi ? (s.wifiNetwork ?? 'Not connected') : 'Off',
            suffix: HSwitch(
              value: s.wifi,
              onChanged: (v) => s.update(() => s.wifi = v),
            ),
            onTap: () => _push(context, _WifiPage(s)),
          ),
          _switchTile(
            context,
            icon: Symbols.signal_cellular_alt,
            role: c.success,
            title: 'Mobile data',
            subtitle: s.mobileData ? 'Connected' : 'Off',
            value: s.mobileData,
            onChanged: (v) => s.update(() => s.mobileData = v),
          ),
          _switchTile(
            context,
            icon: Symbols.wifi_tethering,
            role: c.tertiary,
            title: 'Hotspot & tethering',
            subtitle: s.hotspot ? 'Hotspot is on' : 'Off',
            value: s.hotspot,
            onChanged: (v) => s.update(() => s.hotspot = v),
          ),
        ]),
        HButton(
          variant: .light,
          color: .secondary,
          label: const Text('Reset network settings'),
          onPressed: () => _confirm(
            context,
            title: 'Reset network settings?',
            message:
                'This resets Wi\u2011Fi, mobile data and Bluetooth settings.',
            confirm: 'Reset',
            onConfirm: () => s.update(() {
              s.wifi = true;
              s.wifiNetwork = null;
              s.mobileData = true;
              s.hotspot = false;
              s.airplane = false;
            }),
          ),
        ),
      ],
    );
  });
}

class _Net {
  const _Net(this.name, this.secured, this.icon);
  final String name;
  final bool secured;
  final IconData icon;
}

final _networks = [
  _Net('Home-5G', true, Symbols.wifi),
  _Net('Caf\u00e9 Guest', false, Symbols.wifi_2_bar),
  _Net('Office', true, Symbols.wifi),
  _Net('AndroidAP', true, Symbols.wifi_1_bar),
];

class _WifiPage extends StatelessWidget {
  const _WifiPage(this.s);
  final _Settings s;

  Future<void> _askPassword(BuildContext context, _Net n) async {
    final ctrl = TextEditingController();
    final ok = await showHDialog<bool>(
      context,
      useRootNavigator: false,
      builder: (ctx) => HDialog(
        title: Text(n.name),
        content: [
          HTextField(
            controller: ctrl,
            label: 'Password',
            hintText: 'Enter Wi\u2011Fi password',
            startContent: Icon(
              Symbols.lock,
              size: 18,
              color: ctx.hColors.mutedForeground,
            ),
          ),
        ],
        actions: [
          HButton(
            color: .primary,
            onPressed: () => Navigator.pop(ctx, true),
            label: const Text('Connect'),
          ),
          HButton(
            onPressed: () => Navigator.pop(ctx, false),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (ok == true) s.update(() => s.wifiNetwork = n.name);
  }

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Wi\u2011Fi',
      children: [
        HFilledCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Use Wi\u2011Fi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              HSwitch(
                value: s.wifi,
                onChanged: (v) => s.update(() {
                  s.wifi = v;
                  if (v) s.airplane = false;
                }),
              ),
            ],
          ),
        ),
        if (s.wifi) ...[
          _label(context, 'Available networks'),
          _group([
            for (final n in _networks)
              _tile(
                context,
                icon: n.icon,
                role: s.wifiNetwork == n.name ? c.primary : c.secondary,
                title: n.name,
                subtitle: s.wifiNetwork == n.name
                    ? 'Connected'
                    : (n.secured ? 'Secured' : 'Open'),
                suffix: n.secured
                    ? Icon(Symbols.lock, size: 18, color: c.mutedForeground)
                    : null,
                onTap: s.wifiNetwork == n.name
                    ? null
                    : () => n.secured
                          ? _askPassword(context, n)
                          : s.update(() => s.wifiNetwork = n.name),
              ),
          ]),
        ],
      ],
    );
  });
}

// =============================================================================
// Connected devices
// =============================================================================

class _DevicesPage extends StatelessWidget {
  const _DevicesPage(this.s);
  final _Settings s;

  void _deviceSheet(BuildContext context, _Device d) {
    showHDialog<void>(
      context,
      useRootNavigator: false,
      builder: (ctx) => HDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            HListHeader(title: d.name, icon: d.icon),
            HListView(
              padding: .zero,
              items: [
                HListTile(
                  leading: const Icon(Symbols.edit),
                  title: const Text('Rename'),
                  onTap: () => Navigator.pop(ctx),
                ),
                HListTile(
                  leading: Icon(Symbols.delete, color: ctx.hColors.danger.base),
                  title: Text(
                    'Forget device',
                    style: TextStyle(color: ctx.hColors.danger.base),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    s.update(() => s.devices.remove(d));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Connected devices',
      children: [
        _group([
          _switchTile(
            context,
            icon: Symbols.bluetooth,
            role: c.primary,
            title: 'Bluetooth',
            subtitle: s.bluetooth ? 'On' : 'Off',
            value: s.bluetooth,
            onChanged: (v) => s.update(() {
              s.bluetooth = v;
              if (v) s.airplane = false;
            }),
          ),
        ]),
        if (s.bluetooth) ...[
          _label(context, 'Paired devices'),
          if (s.devices.isEmpty)
            HFilledCard(
              child: Text(
                'No paired devices',
                style: TextStyle(color: c.mutedForeground),
              ),
            )
          else
            _group([
              for (final d in s.devices)
                _tile(
                  context,
                  icon: d.icon,
                  role: c.secondary,
                  title: d.name,
                  subtitle: d.subtitle,
                  suffix: Icon(Symbols.settings, color: c.mutedForeground),
                  onTap: () => _deviceSheet(context, d),
                ),
            ]),
        ],
        _label(context, 'Connection preferences'),
        _group([
          _tile(
            context,
            icon: Symbols.cast,
            role: c.tertiary,
            title: 'Cast',
            subtitle: 'Not connected',
          ),
          _tile(
            context,
            icon: Symbols.nearby,
            role: c.tertiary,
            title: 'Quick Share',
            subtitle: 'Contacts only',
          ),
        ]),
      ],
    );
  });
}

// =============================================================================
// Notifications
// =============================================================================

final _appIcons = <String, IconData>{
  'Messages': Symbols.chat,
  'Gmail': Symbols.mail,
  'Calendar': Symbols.calendar_month,
  'Maps': Symbols.map,
  'Photos': Symbols.photo_library,
};

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Notifications',
      children: [
        _label(context, 'App notifications'),
        _group([
          for (final e in s.appNotifications.entries)
            _switchTile(
              context,
              icon: _appIcons[e.key] ?? Symbols.apps,
              role: c.secondary,
              title: e.key,
              subtitle: e.value ? 'On' : 'Off',
              value: e.value,
              onChanged: (v) => s.update(() => s.appNotifications[e.key] = v),
            ),
        ]),
        _label(context, 'On the lock screen'),
        _group([
          HListTile(
            title: const Text('Show conversations'),
            suffix: HCheckBox(
              value: s.lockConversations,
              onChanged: (v) =>
                  s.update(() => s.lockConversations = v ?? false),
            ),
            onTap: () =>
                s.update(() => s.lockConversations = !s.lockConversations),
          ),
          HListTile(
            title: const Text('Show silent notifications'),
            suffix: HCheckBox(
              value: s.lockSilent,
              onChanged: (v) => s.update(() => s.lockSilent = v ?? false),
            ),
            onTap: () => s.update(() => s.lockSilent = !s.lockSilent),
          ),
        ]),
      ],
    );
  });
}

// =============================================================================
// Sound & vibration
// =============================================================================

class _SoundPage extends StatelessWidget {
  const _SoundPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Sound & vibration',
      children: [
        HFilledCard(
          child: Column(
            spacing: 8,
            children: [
              _SliderRow(
                icon: Symbols.music_note,
                label: 'Media volume',
                value: s.media,
                onChanged: (v) => s.update(() => s.media = v),
              ),
              _SliderRow(
                icon: Symbols.ring_volume,
                label: 'Call & ring volume',
                value: s.ring,
                onChanged: (v) => s.update(() => s.ring = v),
              ),
              _SliderRow(
                icon: Symbols.alarm,
                label: 'Alarm volume',
                value: s.alarm,
                onChanged: (v) => s.update(() => s.alarm = v),
              ),
            ],
          ),
        ),
        _group([
          _switchTile(
            context,
            icon: Symbols.do_not_disturb_on,
            role: c.danger,
            title: 'Do Not Disturb',
            subtitle: s.dnd ? 'On' : 'Off',
            value: s.dnd,
            onChanged: (v) => s.update(() => s.dnd = v),
          ),
          _switchTile(
            context,
            icon: Symbols.vibration,
            role: c.tertiary,
            title: 'Vibration & haptics',
            subtitle: s.vibrate ? 'On' : 'Off',
            value: s.vibrate,
            onChanged: (v) => s.update(() => s.vibrate = v),
          ),
          _tile(
            context,
            icon: Symbols.music_note,
            role: c.secondary,
            title: 'Phone ringtone',
            subtitle: s.ringtone,
            onTap: () async {
              final r = await _pick<String>(
                context,
                title: 'Phone ringtone',
                selected: s.ringtone,
                options: const [
                  ('Pixel Sounds', 'Pixel Sounds'),
                  ('Flutter', 'Flutter'),
                  ('Chimes', 'Chimes'),
                  ('Old Phone', 'Old Phone'),
                ],
              );
              if (r != null) s.update(() => s.ringtone = r);
            },
          ),
        ]),
      ],
    );
  });
}

// =============================================================================
// Display
// =============================================================================

class _DisplayPage extends StatelessWidget {
  const _DisplayPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Display',
      children: [
        HFilledCard(
          child: _SliderRow(
            icon: Symbols.brightness_medium,
            label: 'Brightness level',
            value: s.brightness,
            onChanged: (v) => s.update(() => s.brightness = v),
          ),
        ),
        _group([
          _switchTile(
            context,
            icon: Symbols.brightness_auto,
            role: c.warning,
            title: 'Adaptive brightness',
            subtitle: s.adaptiveBrightness ? 'On' : 'Off',
            value: s.adaptiveBrightness,
            onChanged: (v) => s.update(() => s.adaptiveBrightness = v),
          ),
          _switchTile(
            context,
            icon: Symbols.dark_mode,
            role: c.secondary,
            title: 'Dark theme',
            subtitle: s.darkTheme ? 'On' : 'Off',
            value: s.darkTheme,
            onChanged: (v) => s.update(() => s.darkTheme = v),
          ),
        ]),
        HSelect<String>(
          label: 'Screen timeout',
          value: s.timeout,
          onChanged: (v) => s.update(() => s.timeout = v ?? s.timeout),
          items: const [
            HSelectItem(value: '15s', label: '15 seconds'),
            HSelectItem(value: '30s', label: '30 seconds'),
            HSelectItem(value: '1m', label: '1 minute'),
            HSelectItem(value: '5m', label: '5 minutes'),
          ],
        ),
        _label(context, 'Smooth display'),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: '60', label: Text('60 Hz')),
            ButtonSegment(value: 'auto', label: Text('Auto')),
            ButtonSegment(value: '120', label: Text('120 Hz')),
          ],
          selected: {s.refreshRate},
          onSelectionChanged: (v) => s.update(() => s.refreshRate = v.first),
        ),
        HFilledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _SliderRow(
                icon: Symbols.format_size,
                label: 'Font size',
                value: s.fontScale,
                min: 0.85,
                max: 1.3,
                divisions: 3,
                onChanged: (v) => s.update(() => s.fontScale = v),
              ),
              Text(
                'The quick brown fox jumps over the lazy dog.',
                textScaler: TextScaler.linear(s.fontScale),
              ),
            ],
          ),
        ),
      ],
    );
  });
}

// =============================================================================
// Battery
// =============================================================================

class _BatteryPage extends StatelessWidget {
  const _BatteryPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    const usage = [
      ('Screen', 42, Symbols.smartphone),
      ('Maps', 18, Symbols.map),
      ('Messages', 11, Symbols.chat),
    ];
    return _Page(
      title: 'Battery',
      children: [
        HFilledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('84%', style: Theme.of(context).textTheme.displaySmall),
              Text(
                s.batterySaver
                    ? 'Battery Saver is on'
                    : 'About 1 day left \u2022 Not charging',
                style: TextStyle(color: c.mutedForeground),
              ),
              HProgressIndicator(
                value: 0.84,
                height: 12,
                progressColor: s.batterySaver ? c.warning.base : c.success.base,
              ),
            ],
          ),
        ),
        _group([
          _switchTile(
            context,
            icon: Symbols.battery_saver,
            role: c.warning,
            title: 'Battery Saver',
            subtitle: s.batterySaver ? 'On' : 'Off',
            value: s.batterySaver,
            onChanged: (v) => s.update(() => s.batterySaver = v),
          ),
          _switchTile(
            context,
            icon: Symbols.bolt,
            role: c.success,
            title: 'Adaptive Battery',
            subtitle: 'Limit battery use for rarely used apps',
            value: s.adaptiveBattery,
            onChanged: (v) => s.update(() => s.adaptiveBattery = v),
          ),
        ]),
        _label(context, 'Battery usage since last full charge'),
        _group([
          for (final u in usage)
            _tile(
              context,
              icon: u.$3,
              role: c.secondary,
              title: u.$1,
              suffix: Text(
                '${u.$2}%',
                style: TextStyle(color: c.mutedForeground),
              ),
            ),
        ]),
      ],
    );
  });
}

// =============================================================================
// Storage
// =============================================================================

class _StoragePage extends StatelessWidget {
  const _StoragePage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) {
    final c = context.hColors;
    final items = [
      ('Apps', 38, Symbols.apps, c.primary),
      ('Photos', 21, Symbols.image, c.tertiary),
      ('Videos', 12, Symbols.movie, c.warning),
      ('Audio', 4, Symbols.music_note, c.success),
      ('System', 14, Symbols.memory, c.secondary),
    ];
    return _Page(
      title: 'Storage',
      children: [
        HFilledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                '89 GB used',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('of 128 GB', style: TextStyle(color: c.mutedForeground)),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    spacing: 2,
                    children: [
                      for (final i in items)
                        Expanded(
                          flex: i.$2,
                          child: ColoredBox(color: i.$4.base),
                        ),
                      Expanded(flex: 39, child: ColoredBox(color: c.content3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _group([
          for (final i in items)
            _tile(
              context,
              icon: i.$3,
              role: i.$4,
              title: i.$1,
              suffix: Text(
                '${i.$2} GB',
                style: TextStyle(color: c.mutedForeground),
              ),
            ),
        ]),
        HButton(
          variant: .light,
          icon: Symbols.delete,
          color: .secondary,
          label: const Text('Free up space'),
          onPressed: () => _confirm(
            context,
            title: 'Free up space?',
            message: 'Remove 4.2 GB of backed-up photos and cached files?',
            confirm: 'Free up',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Security & privacy
// =============================================================================

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Security & privacy',
      children: [
        _group([
          _switchTile(
            context,
            icon: Symbols.fingerprint,
            role: c.success,
            title: 'Biometric unlock',
            subtitle: s.biometric ? 'Fingerprint, Face' : 'Off',
            value: s.biometric,
            onChanged: (v) => s.update(() => s.biometric = v),
          ),
          _switchTile(
            context,
            icon: Symbols.location_on,
            role: c.tertiary,
            title: 'Location',
            subtitle: s.location ? 'On \u2022 3 apps have access' : 'Off',
            value: s.location,
            onChanged: (v) => s.update(() => s.location = v),
          ),
        ]),
        _label(context, 'Permission manager'),
        _group([
          _tile(
            context,
            icon: Symbols.photo_camera,
            role: c.secondary,
            title: 'Camera',
            subtitle: '2 of 14 apps allowed',
          ),
          _tile(
            context,
            icon: Symbols.mic,
            role: c.secondary,
            title: 'Microphone',
            subtitle: '3 of 14 apps allowed',
          ),
          _tile(
            context,
            icon: Symbols.contacts,
            role: c.secondary,
            title: 'Contacts',
            subtitle: '5 of 14 apps allowed',
          ),
        ]),
      ],
    );
  });
}

// =============================================================================
// System
// =============================================================================

class _SystemPage extends StatelessWidget {
  const _SystemPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'System',
      children: [
        HComboBox<String>(
          label: 'Language',
          placeholder: 'Search a language',
          value: s.language,
          onChanged: (v) => s.update(() => s.language = v ?? 'en'),
          isClearable: false,
          items: const [
            HSelectItem(value: 'en', label: 'English'),
            HSelectItem(value: 'hi', label: 'Hindi'),
            HSelectItem(value: 'ml', label: 'Malayalam'),
            HSelectItem(value: 'ta', label: 'Tamil'),
            HSelectItem(value: 'es', label: 'Spanish'),
            HSelectItem(value: 'fr', label: 'French'),
            HSelectItem(value: 'de', label: 'German'),
          ],
        ),
        _group([
          _switchTile(
            context,
            icon: Symbols.schedule,
            role: c.primary,
            title: 'Set time automatically',
            subtitle: s.autoTime ? 'Use network-provided time' : 'Off',
            value: s.autoTime,
            onChanged: (v) => s.update(() => s.autoTime = v),
          ),
          _switchTile(
            context,
            icon: Symbols.backup,
            role: c.success,
            title: 'Backup',
            subtitle: s.backup ? 'On \u2022 Last backup 2:10 AM' : 'Off',
            value: s.backup,
            onChanged: (v) => s.update(() => s.backup = v),
          ),
          _tile(
            context,
            icon: Symbols.restart_alt,
            role: c.danger,
            title: 'Reset options',
            subtitle: 'Reset app preferences',
            onTap: () => _confirm(
              context,
              title: 'Reset app preferences?',
              message: 'This will not delete any app data.',
              confirm: 'Reset',
              onConfirm: () => s.update(() {
                for (final k in s.appNotifications.keys.toList()) {
                  s.appNotifications[k] = true;
                }
              }),
            ),
          ),
        ]),
      ],
    );
  });
}

// =============================================================================
// About phone  ->  Developer options
// =============================================================================

class _AboutPage extends StatefulWidget {
  const _AboutPage(this.s);
  final _Settings s;

  @override
  State<_AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<_AboutPage> {
  int _taps = 0;

  void _tapBuild() {
    final s = widget.s;
    if (s.developer) return;
    setState(() => _taps++);
    if (_taps >= 5) {
      s.update(() => s.developer = true);
      showHDialog<void>(
        context,
        useRootNavigator: false,
        builder: (ctx) => HDialog(
          title: const Text('You are now a developer!'),
          content: [const Text('Developer options are now available.')],
          actions: [
            HButton(
              color: .primary,
              onPressed: () => Navigator.pop(ctx),
              label: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return _live(s, (context) {
      final c = context.hColors;
      return _Page(
        title: 'About phone',
        children: [
          _group([
            _tile(
              context,
              icon: Symbols.smartphone,
              role: c.primary,
              title: 'Device name',
              subtitle: 'Pixel 9 Pro',
            ),
            _tile(
              context,
              icon: Symbols.android,
              role: c.success,
              title: 'Android version',
              subtitle: '16',
            ),
            _tile(
              context,
              icon: Symbols.build,
              role: c.secondary,
              title: 'Build number',
              subtitle: s.developer
                  ? 'BP2A.250805.005'
                  : _taps == 0
                  ? 'BP2A.250805.005'
                  : 'Tap ${5 - _taps} more times to enable developer mode',
              onTap: _tapBuild,
            ),
            if (s.developer)
              _tile(
                context,
                icon: Symbols.code,
                role: c.tertiary,
                title: 'Developer options',
                subtitle: 'USB debugging, layout bounds',
                onTap: () => _push(context, _DeveloperPage(s)),
              ),
          ]),
        ],
      );
    });
  }
}

class _DeveloperPage extends StatelessWidget {
  const _DeveloperPage(this.s);
  final _Settings s;

  @override
  Widget build(BuildContext context) => _live(s, (context) {
    final c = context.hColors;
    return _Page(
      title: 'Developer options',
      children: [
        _group([
          _switchTile(
            context,
            icon: Symbols.usb,
            role: c.tertiary,
            title: 'USB debugging',
            subtitle: 'Debug mode when USB is connected',
            value: s.usbDebugging,
            onChanged: (v) => s.update(() => s.usbDebugging = v),
          ),
          _switchTile(
            context,
            icon: Symbols.grid_view,
            role: c.tertiary,
            title: 'Show layout bounds',
            subtitle: 'Show clip bounds, margins, etc.',
            value: s.layoutBounds,
            onChanged: (v) => s.update(() => s.layoutBounds = v),
          ),
        ]),
        HButton(
          variant: .light,
          color: .secondary,
          label: const Text('Turn off developer mode'),
          onPressed: () {
            s.update(() {
              s.developer = false;
              s.usbDebugging = false;
              s.layoutBounds = false;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  });
}

// =============================================================================
// Showcase screen: phone frame with its own nested Navigator
// =============================================================================

class ShowcaseSettingsScreen extends StatefulWidget {
  const ShowcaseSettingsScreen({super.key});

  @override
  State<ShowcaseSettingsScreen> createState() => _ShowcaseSettingsScreenState();
}

class _ShowcaseSettingsScreenState extends State<ShowcaseSettingsScreen> {
  final _settings = _Settings();
  final _navKey = GlobalKey<NavigatorState>();

  bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  static const _phoneSize = Size(400, 850);
  static const _statusBarHeight = 32.0;
  static const _navBarHeight = 24.0;

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  /// The nested navigator. Pages pushed here stay inside the phone frame.
  Widget _navigator() {
    return NavigatorPopHandler(
      onPop: () => _navKey.currentState?.pop(),
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => _HomePage(_settings)),
      ),
    );
  }

  Widget _statusBar() {
    final c = context.hColors;
    return IgnorePointer(
      child: SizedBox(
        height: _statusBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '12:30',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: c.foreground),
              ),
              const Spacer(),
              Icon(Symbols.wifi, size: 14, color: c.foreground),
              const SizedBox(width: 4),
              Icon(
                Symbols.battery_3_bar_rounded,
                size: 14,
                color: c.foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBar() {
    return IgnorePointer(
      child: SizedBox(
        height: _navBarHeight,
        child: Center(
          child: Container(
            width: 128,
            height: 4,
            decoration: BoxDecoration(
              color: context.hColors.foreground,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhone() {
    const insets = EdgeInsets.only(
      top: _statusBarHeight,
      bottom: _navBarHeight,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: _phoneSize.width,
          height: _phoneSize.height,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: context.hColors.background,
            border: Border.all(
              color: context.hColors.border,
              width: 4,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // The app fills the whole frame, behind both bars.
              Positioned.fill(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: _phoneSize,
                    padding: insets,
                    viewPadding: insets,
                  ),
                  child: _navigator(),
                ),
              ),
              Positioned(top: 0, left: 0, right: 0, child: _statusBar()),
              Positioned(bottom: 0, left: 0, right: 0, child: _navBar()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isDesktop(context)
        ? Material(
            color: context.hColors.background,
            child: Column(
              children: [
                Container(
                  color: context.hColors.tertiary.soft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'You are viewing the Android settings showcase: nested pages, dialogs and sheets built with Hornbill UI components.',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: context.hColors.tertiary.onSoft,
                                ),
                          ),
                        ),
                        HButton(
                          size: .sm,
                          variant: .light,
                          color: .secondary,
                          label: const Text('Close'),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/showcases',
                          ),
                          icon: Symbols.close,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildPhone()),
              ],
            ),
          )
        : _navigator();
  }
}
