/// Rounded, grouped Material list widgets for Flutter.
///
/// This library provides drop-in replacements for [ListView] and its
/// `RadioListTile`/`CheckboxListTile` cousins that render items as a single
/// visually-grouped "card" — square-ish corners between items, rounded
/// corners at the very top and bottom — which is a common pattern in
/// settings screens and grouped forms.
///
/// ## Widgets
///
///  * [HListHeader] — a small section header (title, optional subtitle,
///    icon, and trailing widget) to place above a grouped list.
///  * [HListView] — a grouped list of arbitrary rows. Construct eagerly
///    with [HListView.new] and a `List<HListItemData>`, or lazily with
///    [HListView.builder] and an `itemCount` + item builder callback.
///  * [HRadioListView] — a grouped, single-select radio list. Also
///    supports both [HRadioListView.new] and [HRadioListView.builder].
///  * [HCheckboxListView] — a grouped, multi-select checkbox list. Also
///    supports both [HCheckboxListView.new] and [HCheckboxListView.builder].
///
/// ## Example
///
/// ```dart
/// HListView(
///   items: [
///     HListItemData(title: 'Wi-Fi', subtitle: 'Connected', onTap: () {}),
///     HListItemData(title: 'Bluetooth', onTap: () {}),
///   ],
/// )
/// ```
///
/// All three list widgets accept `enableScroll` (default `false`, since
/// they're commonly nested inside an already-scrollable parent) and
/// `shrinkWrap` (default `true`) to control how they size and scroll
/// themselves — see each widget's constructor docs for details.
library;

import 'package:flutter/material.dart';

part 'listview/checkbox_list_view.dart';
part 'listview/list_card.dart';
part 'listview/list_header.dart';
part 'listview/list_item_data.dart';
part 'listview/list_view.dart';
part 'listview/radio_list_view.dart';
