import 'hornbill_platform_interface.dart';

export 'src/theme.dart';
export 'src/widgets/data/cards.dart';
export 'src/widgets/data/codeblock.dart';
export 'src/widgets/data/data_table.dart';
export 'src/widgets/data/page_navigation.dart';
export 'src/widgets/feedback/chip.dart';
export 'src/widgets/feedback/progressindicator.dart';
export 'src/widgets/inputfield/buttons.dart';
export 'src/widgets/inputfield/checkbox.dart';
export 'src/widgets/inputfield/dropdown_input_field.dart';
export 'src/widgets/inputfield/iconbuttons.dart';
export 'src/widgets/inputfield/switch.dart';
export 'src/widgets/inputfield/text_input_field.dart';
export 'src/widgets/layout/scaffold.dart';
export 'src/widgets/list_widgets.dart';
export 'src/widgets/navigation/appbar.dart';
export 'src/widgets/navigation/breadcrumbs.dart';
export 'src/widgets/navigation/navigation_bar.dart';
export 'src/widgets/navigation/sidebar.dart';
export 'src/widgets/navigation/tab.dart';
export 'src/widgets/overlay/dialog.dart';
export 'src/widgets/overlay/toast.dart';

class Hornbill {
  Future<String?> getPlatformVersion() {
    return HornbillPlatform.instance.getPlatformVersion();
  }
}
