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
///  * [MListHeader] — a small section header (title, optional subtitle,
///    icon, and trailing widget) to place above a grouped list.
///  * [MListView] — a grouped list of arbitrary rows. Construct eagerly
///    with [MListView.new] and a `List<MListItemData>`, or lazily with
///    [MListView.builder] and an `itemCount` + item builder callback.
///  * [MRadioListView] — a grouped, single-select radio list. Also
///    supports both [MRadioListView.new] and [MRadioListView.builder].
///  * [MCheckboxListView] — a grouped, multi-select checkbox list. Also
///    supports both [MCheckboxListView.new] and [MCheckboxListView.builder].
///
/// ## Example
///
/// ```dart
/// MListView(
///   items: [
///     MListItemData(title: 'Wi-Fi', subtitle: 'Connected', onTap: () {}),
///     MListItemData(title: 'Bluetooth', onTap: () {}),
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
