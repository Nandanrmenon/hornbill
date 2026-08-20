import 'hornbill_platform_interface.dart';

export 'src/theme.dart';
export 'src/widgets/data/codeblock.dart';
export 'src/widgets/data/data_table.dart';
export 'src/widgets/data/page_navigation.dart';
export 'src/widgets/feedback/chip.dart';
export 'src/widgets/feedback/progressindicator.dart';
export 'src/widgets/feedback/toast.dart';
export 'src/widgets/hornbill_card.dart';
export 'src/widgets/inputfield/buttons.dart';
export 'src/widgets/inputfield/dropdown_input_field.dart';
export 'src/widgets/inputfield/iconbuttons.dart';
export 'src/widgets/inputfield/switch.dart';
export 'src/widgets/inputfield/text_input_field.dart';
export 'src/widgets/list_widgets.dart';
export 'src/widgets/scaffold/appbar.dart';
export 'src/widgets/scaffold/navigation_bar.dart';
export 'src/widgets/scaffold/scaffold.dart';
export 'src/widgets/scaffold/sidebar.dart';

class Hornbill {
  Future<String?> getPlatformVersion() {
    return HornbillPlatform.instance.getPlatformVersion();
  }
}
