import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final int _index = 0;
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Card'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 16.0,
              children: [
                HCard(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with an outline.'),
                    ],
                  ),
                ),
                HElevatedCard(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HElevatedCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with elevation.'),
                    ],
                  ),
                ),
                HFilledCard(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HFilledCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with elevation.'),
                    ],
                  ),
                ),
                HGradientCard(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HGradientCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with elevation.'),
                    ],
                  ),
                ),
                HStatusCard(
                  status: HStatus.success,
                  fullWidth: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HStatusCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with system status.'),
                    ],
                  ),
                ),
                HStatusCard(
                  status: HStatus.info,
                  fullWidth: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HStatusCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with system status.'),
                    ],
                  ),
                ),
                HStatusCard(
                  status: HStatus.warning,
                  fullWidth: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HStatusCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with system status.'),
                    ],
                  ),
                ),
                HStatusCard(
                  status: HStatus.error,
                  fullWidth: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'HStatusCard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This is a simple card with system status.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
