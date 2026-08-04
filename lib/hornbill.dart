import 'hornbill_platform_interface.dart';

export 'src/theme.dart';
export 'src/widgets/data/data_table.dart';
export 'src/widgets/data/page_navigation.dart';
export 'src/widgets/hornbill_button.dart';
export 'src/widgets/hornbill_card.dart';
export 'src/widgets/inputfield/dropdown_input_field.dart';
export 'src/widgets/inputfield/text_input_field.dart';
export 'src/widgets/list_widgets.dart';
export 'src/widgets/scaffold/scaffold.dart';

class Hornbill {
  Future<String?> getPlatformVersion() {
    return HornbillPlatform.instance.getPlatformVersion();
  }
}
