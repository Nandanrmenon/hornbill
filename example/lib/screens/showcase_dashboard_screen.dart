import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ShowcaseDashboardScreen extends StatefulWidget {
  const ShowcaseDashboardScreen({super.key});

  @override
  State<ShowcaseDashboardScreen> createState() =>
      _ShowcaseDashboardScreenState();
}

class _ShowcaseDashboardScreenState extends State<ShowcaseDashboardScreen> {
  int _selectedNavigationIndex = 0;

  bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.hColors.background,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Container(
            color: context.hColors.tertiary.soft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  Flexible(
                    child: Text(
                      'You are viewing the Finora showcase. This is a sample dashboard built with Hornbill UI components.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.hColors.tertiary.onSoft,
                      ),
                    ),
                  ),
                  // if (_isDesktop(context)) Spacer(),
                  HButton(
                    size: .sm,
                    variant: .light,
                    color: .secondary,
                    label: _isDesktop(context) ? Text('Close') : null,
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/showcases'),
                    icon: Symbols.close,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: HScaffold(
              appBar: HAppBar(title: Text('Finora'), leading: null),
              sidebar: _buildSidebar(),
              bottomNavigationBar: _isDesktop(context)
                  ? null
                  : HNavigationBar(
                      items: const [
                        HNavigationBarItem(
                          icon: Symbols.dashboard,
                          selectedIcon: Symbols.dashboard_rounded,
                          label: 'Overview',
                        ),
                        HNavigationBarItem(
                          icon: Symbols.swap_horiz_rounded,
                          label: 'Activity',
                        ),
                        HNavigationBarItem(
                          icon: Symbols.pie_chart_outline_rounded,
                          selectedIcon: Symbols.pie_chart_rounded,
                          label: 'Insights',
                        ),
                        HNavigationBarItem(
                          icon: Symbols.person_outline_rounded,
                          selectedIcon: Symbols.person_rounded,
                          label: 'Profile',
                        ),
                      ],
                      currentIndex: _selectedNavigationIndex,
                      onTap: (index) =>
                          setState(() => _selectedNavigationIndex = index),
                    ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            _Header(isDesktop: isDesktop),
                            _BalanceCard(isDesktop: isDesktop),
                            _QuickActions(),
                            _OverviewGrid(isDesktop: isDesktop),
                            _Transactions(),
                            HButton(
                              icon: Symbols.arrow_back_rounded,
                              label: const Text('Back to showcases'),
                              variant: HButtonVariant.flat,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  HSideBar _buildSidebar() {
    return HSideBar(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: const Text('Finora'),
      ),
      selectedIndex: _selectedNavigationIndex,
      onItemSelected: (index) =>
          setState(() => _selectedNavigationIndex = index),
      items: [
        HSideBarItem(
          icon: Symbols.dashboard_rounded,
          label: 'Overview',
          selected: _selectedNavigationIndex == 0,
          onTap: () => setState(() => _selectedNavigationIndex = 0),
        ),
        HSideBarItem(
          icon: Symbols.swap_horiz_rounded,
          label: 'Transactions',
          selected: _selectedNavigationIndex == 1,
          onTap: () => setState(() => _selectedNavigationIndex = 1),
        ),
        HSideBarItem(
          icon: Symbols.pie_chart_rounded,
          label: 'Insights',
          selected: _selectedNavigationIndex == 2,
          onTap: () => setState(() => _selectedNavigationIndex = 2),
        ),
        HSideBarItem(
          icon: Symbols.credit_card_rounded,
          label: 'Cards',
          selected: _selectedNavigationIndex == 3,
          onTap: () => setState(() => _selectedNavigationIndex = 3),
        ),
        HSideBarItem(
          icon: Symbols.settings_rounded,
          label: 'Settings',
          selected: _selectedNavigationIndex == 4,
          onTap: () => setState(() => _selectedNavigationIndex = 4),
        ),
      ],
      footer: HSideBarAccountTile(
        title: 'Ada Lovelace',
        subtitle: 'ada@example.com',
        onLogout: () {},
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          'Good morning, Ada',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'Tuesday, 24 September 2024',
          style: TextStyle(color: context.hColors.mutedForeground),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        HButton(
          icon: Symbols.notifications_none_rounded,
          variant: HButtonVariant.light,
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        const HAvatar(child: Text('AL')),
      ],
    );

    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [greeting, actions],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [greeting, actions],
          );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final balance = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          'Total balance',
          style: TextStyle(color: context.hColors.primary.onSoft),
        ),
        Text(
          '\$42,680.50',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: context.hColors.primary.onSoft,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '+\$2,840.20 this month',
          style: TextStyle(color: context.hColors.primary.onSoft),
        ),
      ],
    );

    final account = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symbols.account_balance_rounded,
          size: 28,
          color: context.hColors.primary.onSoft,
        ),
        const SizedBox(width: 8),
        Text(
          'Main account\n•••• 2480',
          style: TextStyle(color: context.hColors.primary.onSoft),
        ),
      ],
    );

    return HGradientCard(
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [balance, account],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [balance, account],
            ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        const HListHeader(title: 'Quick actions'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HButton(
              icon: Symbols.add_rounded,
              label: const Text('Add money'),
              onPressed: () {},
            ),
            HButton(
              icon: Symbols.swap_horiz_rounded,
              label: const Text('Transfer'),
              variant: HButtonVariant.bordered,
              onPressed: () {},
            ),
            HButton(
              icon: Symbols.receipt_long_rounded,
              label: const Text('Pay a bill'),
              variant: HButtonVariant.bordered,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _StatCard(
        title: 'Income',
        value: '\$8,420',
        detail: '+8.2% from last month',
        icon: Symbols.trending_up_rounded,
        positive: true,
      ),
      const _StatCard(
        title: 'Expenses',
        value: '\$3,248',
        detail: '-4.1% from last month',
        icon: Symbols.trending_down_rounded,
        positive: true,
      ),
    ];

    final overview = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const HListHeader(title: 'This month'),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(child: cards[0]),
              Expanded(child: cards[1]),
              const Expanded(child: _BudgetCard()),
            ],
          )
        else
          ...cards,
        if (!isDesktop) const _BudgetCard(),
      ],
    );

    return overview;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.positive,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return HFilledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: context.hColors.mutedForeground),
              ),
              Icon(icon, color: context.hColors.success.base),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            detail,
            style: TextStyle(
              color: positive
                  ? context.hColors.success.base
                  : context.hColors.danger.base,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context) {
    return HFilledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly budget',
                style: TextStyle(color: context.hColors.mutedForeground),
              ),
              const Icon(Symbols.account_balance_wallet_rounded),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$3,248 spent',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('65%'),
            ],
          ),
          HProgressIndicator(
            value: 0.65,
            progressColor: context.hColors.primary.base,
            showLabel: false,
          ),
          Text(
            '\$1,752 remaining of \$5,000',
            style: TextStyle(
              color: context.hColors.mutedForeground,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Transactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: HListHeader(title: 'Recent transactions')),
            HButton(
              label: const Text('View all'),
              variant: HButtonVariant.flat,
              onPressed: () {},
            ),
          ],
        ),
        HListView(
          padding: EdgeInsets.zero,
          items: [
            for (final transaction in _transactions)
              HListTile(
                leading: HAvatar(
                  backgroundColor: context.hColors.primary.soft,
                  foregroundColor: context.hColors.primary.onSoft,
                  child: Icon(transaction.icon, size: 20),
                ),
                title: Text(transaction.merchant),
                subtitle: Text(transaction.category),
                suffix: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction.amount,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      transaction.date,
                      style: TextStyle(
                        color: context.hColors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const HStatusCard(
          status: HStatus.info,
          fullWidth: true,
          child: Text(
            'Your next scheduled payment is Netflix for \$15.49 tomorrow.',
          ),
        ),
      ],
    );
  }
}

class _Transaction {
  const _Transaction(
    this.merchant,
    this.category,
    this.amount,
    this.date,
    this.icon,
  );

  final String merchant;
  final String category;
  final String amount;
  final String date;
  final IconData icon;
}

const _transactions = [
  _Transaction(
    'Whole Foods Market',
    'Groceries',
    '-\$86.42',
    'Today',
    Symbols.shopping_cart_rounded,
  ),
  _Transaction(
    'Acme Inc.',
    'Salary',
    '+\$4,820.00',
    'Yesterday',
    Symbols.work_rounded,
  ),
  _Transaction(
    'Netflix',
    'Entertainment',
    '-\$15.49',
    '22 Sep',
    Symbols.movie_rounded,
  ),
  _Transaction(
    'City Power & Light',
    'Utilities',
    '-\$128.30',
    '20 Sep',
    Symbols.bolt_rounded,
  ),
];
