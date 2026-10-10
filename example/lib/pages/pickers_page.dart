import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class PickersPage extends StatefulWidget {
  const PickersPage({super.key});

  @override
  State<PickersPage> createState() => _PickersPageState();
}

class _PickersPageState extends State<PickersPage> {
  final DateTime _first = DateTime(DateTime.now().year - 1);
  final DateTime _last = DateTime(DateTime.now().year + 2, 12, 31);
  DateTime? _inline;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 30);
  String _result = '—';

  void _show(Object? value) =>
      setState(() => _result = value?.toString() ?? 'Cancelled');

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Dialogs',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DemoWrap(
                children: [
                  NeoButton(
                    label: 'Date',
                    icon: Icons.event,
                    onPressed: () async => _show(
                      await showNeoDatePicker(
                        context: context,
                        firstDate: _first,
                        lastDate: _last,
                      ),
                    ),
                  ),
                  NeoButton(
                    label: 'Time',
                    icon: Icons.schedule,
                    color: theme.colors.blue,
                    onPressed: () async => _show(
                      await showNeoTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ),
                    ),
                  ),
                  NeoButton(
                    label: 'Date & time',
                    icon: Icons.event_available,
                    color: theme.colors.green,
                    onPressed: () async => _show(
                      await showNeoDateTimePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: _last,
                        minuteInterval: 5,
                      ),
                    ),
                  ),
                  NeoButton(
                    label: 'Range',
                    icon: Icons.date_range,
                    color: theme.colors.pink,
                    onPressed: () async => _show(
                      await showNeoDateRangePicker(
                        context: context,
                        firstDate: _first,
                        lastDate: _last,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              Text(
                'Result: $_result',
                style: theme.typography.bodyStrong.copyWith(
                  color: theme.colors.ink,
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Inline calendar',
          child: NeoCard(
            child: NeoCalendar(
              firstDate: _first,
              lastDate: _last,
              selectedDate: _inline,
              selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
              onDateSelected: (d) => setState(() => _inline = d),
            ),
          ),
        ),
        CatalogSection(
          title: 'Range calendar',
          child: NeoCard(
            child: NeoCalendar.range(
              firstDate: _first,
              lastDate: _last,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
              color: theme.colors.teal,
              onRangeChanged: (s, e) => setState(() {
                _rangeStart = s;
                _rangeEnd = e;
              }),
            ),
          ),
        ),
        CatalogSection(
          title: 'Time selector',
          child: NeoCard(
            child: NeoTimeSelector(
              value: _time,
              minuteInterval: 5,
              onChanged: (t) => setState(() => _time = t),
            ),
          ),
        ),
      ],
    );
  }
}
