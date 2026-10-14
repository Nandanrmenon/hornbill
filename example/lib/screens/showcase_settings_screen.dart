import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ShowcaseSettingsScreen extends StatefulWidget {
  const ShowcaseSettingsScreen({super.key});

  @override
  State<ShowcaseSettingsScreen> createState() => _ShowcaseSettingsScreenState();
}

class _ShowcaseSettingsScreenState extends State<ShowcaseSettingsScreen> {
  bool _emailNotifications = true;
  bool _weeklySummary = false;

  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: const HAppBar(title: Text('Account settings')),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                HCard(
                  child: Row(
                    children: [
                      const HAvatar(size: HAvatarSize.lg, child: Text('AL')),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ada Lovelace',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'ada@example.com',
                            style: TextStyle(
                              color: context.hColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(
                        'Personal information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      HTextField(
                        label: 'Display name',
                        initialValue: 'Ada Lovelace',
                      ),
                      HTextField(
                        label: 'Email address',
                        initialValue: 'ada@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: HButton(
                          icon: Symbols.save_rounded,
                          label: const Text('Save changes'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                HCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text('Email notifications')),
                          HSwitch(
                            value: _emailNotifications,
                            onChanged: (value) =>
                                setState(() => _emailNotifications = value),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text('Weekly summary')),
                          HSwitch(
                            value: _weeklySummary,
                            onChanged: (value) =>
                                setState(() => _weeklySummary = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HButton(
                  icon: Symbols.arrow_back_rounded,
                  label: const Text('Back to showcases'),
                  variant: HButtonVariant.flat,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
