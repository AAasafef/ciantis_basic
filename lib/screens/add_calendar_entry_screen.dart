import 'package:flutter/material.dart';

import '../models/calendar_entry_model.dart';
import '../services/calendar_entry_service.dart';
import '../widgets/ciantis_side_drawer.dart';

class AddCalendarEntryScreen extends StatefulWidget {
  final DateTime initialDate;
  final String? initialType;
  final CalendarEntry? existingEntry;

  const AddCalendarEntryScreen({
    super.key,
    required this.initialDate,
    this.initialType,
    this.existingEntry,
  });

  @override
  State<AddCalendarEntryScreen> createState() => _AddCalendarEntryScreenState();
}

class _AddCalendarEntryScreenState extends State<AddCalendarEntryScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController meetingLinkController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController customReminderController =
      TextEditingController();

  String selectedType = 'Event';
  String selectedReminder = 'None';
  String selectedPriority = 'Normal';
  String selectedRecurrence = 'Does not repeat';
  String selectedRecurrenceEnd = 'Never';
  bool allDay = false;
  bool completed = false;

  late DateTime startDate;
  late TimeOfDay startTime;
  late DateTime endDate;
  late TimeOfDay endTime;

  bool get isEditing => widget.existingEntry != null;

  final List<String> entryTypes = ciantisCalendarEntryTypes;

  final List<String> reminderOptions = ciantisReminderOptions;

  final List<String> priorityOptions = const [
    'Low',
    'Normal',
    'Mild',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();

    final existing = widget.existingEntry;

    if (existing != null) {
      selectedType = existing.type;
      selectedReminder = existing.reminder;
      selectedPriority = existing.priority;
      selectedRecurrence = existing.recurrence;
      selectedRecurrenceEnd = existing.recurrenceEnd;
      allDay = existing.allDay;
      completed = existing.completed;

      titleController.text = existing.title;
      locationController.text = existing.location;
      meetingLinkController.text = existing.meetingLink;
      notesController.text = existing.notes;
      if (existing.reminders.isNotEmpty &&
          !reminderOptions.contains(existing.reminders.first)) {
        selectedReminder = 'Custom reminder';
        customReminderController.text = existing.reminders.first;
      }

      startDate = DateTime(
        existing.startDateTime.year,
        existing.startDateTime.month,
        existing.startDateTime.day,
      );

      endDate = DateTime(
        existing.endDateTime.year,
        existing.endDateTime.month,
        existing.endDateTime.day,
      );

      startTime = TimeOfDay(
        hour: existing.startDateTime.hour,
        minute: existing.startDateTime.minute,
      );

      endTime = TimeOfDay(
        hour: existing.endDateTime.hour,
        minute: existing.endDateTime.minute,
      );
    } else {
      selectedType = widget.initialType ?? 'Event';
      selectedReminder = CalendarEntryService.settings.defaultReminder;

      startDate = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
      );

      endDate = startDate;

      final now = DateTime.now();
      final roundedHour = now.minute > 30 ? now.hour + 1 : now.hour;

      startTime = TimeOfDay(hour: roundedHour.clamp(0, 23), minute: 0);

      final duration = CalendarEntryService.settings.defaultEventDuration;
      final endMinutes = (startTime.hour * 60 + startTime.minute + duration)
          .clamp(0, 23 * 60 + 59);

      endTime = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);

      if (selectedType == 'Task' || selectedType == 'Reminder') {
        allDay = selectedType == 'Task';
        endTime = startTime;
      }
    }

    locationController.addListener(() {
      if (mounted) setState(() {});
    });

    meetingLinkController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    meetingLinkController.dispose();
    notesController.dispose();
    customReminderController.dispose();
    super.dispose();
  }

  bool get hasLocation => locationController.text.trim().isNotEmpty;

  bool get hasValidMeetingLink {
    final text = meetingLinkController.text.trim().toLowerCase();

    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.contains('zoom.us') ||
        text.contains('meet.google.com') ||
        text.contains('teams.microsoft.com');
  }

  bool get isTask => selectedType == 'Task';

  bool get isReminder => selectedType == 'Reminder';

  bool get isSimpleAction => isTask || isReminder;

  DateTime get startDateTime {
    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      allDay ? 0 : startTime.hour,
      allDay ? 0 : startTime.minute,
    );
  }

  DateTime get endDateTime {
    if (isTask) {
      return DateTime(startDate.year, startDate.month, startDate.day, 23, 59);
    }

    if (isReminder) {
      return startDateTime;
    }

    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      allDay ? 23 : endTime.hour,
      allDay ? 59 : endTime.minute,
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: _datePickerTheme,
    );

    if (picked == null) return;

    setState(() {
      startDate = picked;

      if (endDate.isBefore(startDate)) {
        endDate = startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: _datePickerTheme,
    );

    if (picked == null) return;

    setState(() {
      endDate = picked;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime,
      builder: _timePickerTheme,
    );

    if (picked == null) return;

    setState(() {
      startTime = picked;

      final startTotal = startTime.hour * 60 + startTime.minute;
      final endTotal = endTime.hour * 60 + endTime.minute;

      if (endDate == startDate && endTotal <= startTotal) {
        final newEndHour = (startTime.hour + 1).clamp(0, 23);
        endTime = TimeOfDay(hour: newEndHour, minute: startTime.minute);
      }
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime,
      builder: _timePickerTheme,
    );

    if (picked == null) return;

    setState(() {
      endTime = picked;
    });
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF241D18),
          onPrimary: Color(0xFFFFF9F1),
          surface: Color(0xFFFFF9F1),
          onSurface: Color(0xFF241D18),
        ),
      ),
      child: child!,
    );
  }

  Widget _timePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF241D18),
          onPrimary: Color(0xFFFFF9F1),
          surface: Color(0xFFFFF9F1),
          onSurface: Color(0xFF241D18),
        ),
      ),
      child: child!,
    );
  }

  Future<void> _saveEntry() async {
    final title = _toTitleCase(titleController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!isSimpleAction && endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time cannot be before start time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final existing = widget.existingEntry;

    final entry = CalendarEntry(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: selectedType,
      title: title,
      notes: notesController.text.trim(),
      location: _toTitleCase(locationController.text.trim()),
      meetingLink: meetingLinkController.text.trim(),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      allDay: isTask ? true : allDay,
      reminder: selectedReminder,
      priority: selectedPriority,
      completed: completed,
      recurrence: selectedRecurrence,
      recurrenceEnd: selectedRecurrenceEnd,
      reminders: selectedReminder == 'Custom reminder'
          ? [customReminderController.text.trim()]
          : selectedReminder == 'None'
          ? const []
          : [selectedReminder],
      colorValue: _entryColor(selectedType).toARGB32(),
      source: existing?.source ?? 'manual',
      sourceId: existing?.sourceId ?? '',
      importedFromEmail: existing?.importedFromEmail ?? '',
      reservationType: existing?.reservationType ?? '',
      calendarId: existing?.calendarId ?? 'primary',
      calendarName: existing?.calendarName ?? 'CIANTIS',
      calendarOwner: existing?.calendarOwner ?? '',
      sharedWith: existing?.sharedWith ?? const [],
      visibility: existing?.visibility ?? 'Private',
      appointmentAvailability: existing?.appointmentAvailability ?? '',
      bookingPageEnabled: existing?.bookingPageEnabled ?? false,
      appointmentDuration: existing?.appointmentDuration ?? 30,
      bufferBefore: existing?.bufferBefore ?? 0,
      bufferAfter: existing?.bufferAfter ?? 0,
      attachments: existing?.attachments ?? const [],
    );

    if (existing == null) {
      await CalendarEntryService.addEntry(entry);
    } else {
      await CalendarEntryService.updateEntry(entry);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Color _entryColor(String type) {
    switch (type) {
      case 'Task':
        return const Color(0xFFD6B86A);
      case 'Reminder':
        return const Color(0xFFC7B4D8);
      case 'Birthday':
        return const Color(0xFFD8A7A7);
      case 'Appointment':
        return const Color(0xFF9FB7D5);
      case 'Meeting':
        return const Color(0xFF6F6D99);
      case 'Routine':
        return const Color(0xFFC9A978);
      case 'Deadline':
        return const Color(0xFFC98F7A);
      case 'Travel':
        return const Color(0xFFCDBB9D);
      case 'Work':
        return const Color(0xFFA7B899);
      case 'School':
        return const Color(0xFF7CA9A5);
      case 'Family':
        return const Color(0xFFC98F9D);
      case 'Salon':
        return const Color(0xFFA97F8D);
      case 'Health':
        return const Color(0xFFC98774);
      case 'Finance':
        return const Color(0xFF66876D);
      case 'Spiritual':
        return const Color(0xFF9B8A7A);
      case 'Personal':
        return const Color(0xFFD2B7A3);
      default:
        return const Color(0xFFB89B7D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = isEditing
        ? 'Edit Entry'
        : isTask
        ? 'New Task'
        : isReminder
        ? 'New Reminder'
        : 'Add Entry';

    final subtitle = isEditing
        ? 'UPDATE YOUR SAVED AGENDA ITEM'
        : isTask
        ? 'ONE-LINE TASK WITH DUE DATE'
        : isReminder
        ? 'ONE-LINE REMINDER WITH DATE & TIME'
        : 'EVENTS, TASKS, ROUTINES & REMINDERS';

    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Calendar'),
      backgroundColor: const Color(0xFFF4EFE8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 26),
              Text(
                pageTitle,
                style: const TextStyle(
                  color: Color(0xFF241D18),
                  fontSize: 46,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1.4,
                  height: .95,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8B7D72),
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 28),
              if (!isSimpleAction) ...[
                _sectionCard(
                  children: [
                    _sectionTitle('Entry type'),
                    const SizedBox(height: 14),
                    _typeChips(),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (isTask) ...[
                _taskForm(),
              ] else if (isReminder) ...[
                _reminderForm(),
              ] else ...[
                _fullForm(),
              ],
              const SizedBox(height: 24),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskForm() {
    return Column(
      children: [
        _sectionCard(
          children: [
            _sectionTitle('Task'),
            const SizedBox(height: 14),
            _textField(
              controller: titleController,
              label: 'Task name',
              hint: 'Pay car insurance...',
              icon: Icons.task_alt_rounded,
              titleCase: true,
            ),
            const SizedBox(height: 14),
            _pickerButton(
              label: 'Due date',
              value: _dateLabel(startDate),
              icon: Icons.event_available_outlined,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 14),
            _switchRow(
              title: 'Completed',
              value: completed,
              onChanged: (value) {
                setState(() {
                  completed = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recurrenceCard(),
        const SizedBox(height: 16),
        _priorityCard(),
      ],
    );
  }

  Widget _reminderForm() {
    return Column(
      children: [
        _sectionCard(
          children: [
            _sectionTitle('Reminder'),
            const SizedBox(height: 14),
            _textField(
              controller: titleController,
              label: 'Reminder',
              hint: 'Call doctor...',
              icon: Icons.notifications_none_rounded,
              titleCase: true,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _pickerButton(
                    label: 'Date',
                    value: _dateLabel(startDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerButton(
                    label: 'Time',
                    value: startTime.format(context),
                    icon: Icons.schedule_rounded,
                    onTap: _pickStartTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _dropDownField(
              value: selectedReminder,
              options: reminderOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedReminder = value;
                });
              },
            ),
            if (selectedReminder == 'Custom reminder') ...[
              const SizedBox(height: 14),
              _textField(
                controller: customReminderController,
                label: 'Custom reminder',
                hint: 'Example: 2 hours before',
                icon: Icons.alarm_add_rounded,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _recurrenceCard(),
        const SizedBox(height: 16),
        _priorityCard(),
      ],
    );
  }

  Widget _fullForm() {
    return Column(
      children: [
        _sectionCard(
          children: [
            _sectionTitle('Details'),
            const SizedBox(height: 14),
            _textField(
              controller: titleController,
              label: 'Title',
              hint: 'Client appointment, study session, reminder...',
              icon: Icons.edit_calendar_outlined,
              titleCase: true,
            ),
            const SizedBox(height: 14),
            _textField(
              controller: locationController,
              label: 'Location',
              hint: 'Type an address or place',
              icon: hasLocation
                  ? Icons.location_on_rounded
                  : Icons.location_on_outlined,
              titleCase: true,
              trailing: hasLocation
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF5DBB63),
                      size: 19,
                    )
                  : null,
            ),
            if (hasLocation) ...[
              const SizedBox(height: 8),
              const Text(
                'Location will be saved with this entry. Smart address search can be connected later.',
                style: TextStyle(
                  color: Color(0xFF8B7D72),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
            const SizedBox(height: 14),
            _textField(
              controller: meetingLinkController,
              label: 'Meeting link',
              hint: 'Zoom, Google Meet, Teams, or any link',
              icon: hasValidMeetingLink
                  ? Icons.video_call_rounded
                  : Icons.link_rounded,
              trailing: hasValidMeetingLink
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF5DBB63),
                      size: 19,
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            _textField(
              controller: notesController,
              label: 'Notes',
              hint: 'Add details, prep notes, reminders, or context',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          children: [
            _sectionTitle('Date & time'),
            const SizedBox(height: 14),
            _switchRow(
              title: 'All day',
              value: allDay,
              onChanged: (value) {
                setState(() {
                  allDay = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _pickerButton(
                    label: 'Start date',
                    value: _dateLabel(startDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerButton(
                    label: 'End date',
                    value: _dateLabel(endDate),
                    icon: Icons.event_available_outlined,
                    onTap: _pickEndDate,
                  ),
                ),
              ],
            ),
            if (!allDay) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _pickerButton(
                      label: 'Start time',
                      value: startTime.format(context),
                      icon: Icons.schedule_rounded,
                      onTap: _pickStartTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerButton(
                      label: 'End time',
                      value: endTime.format(context),
                      icon: Icons.schedule_outlined,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          children: [
            _sectionTitle('Reminder'),
            const SizedBox(height: 14),
            _dropDownField(
              value: selectedReminder,
              options: reminderOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedReminder = value;
                });
              },
            ),
            if (selectedReminder == 'Custom reminder') ...[
              const SizedBox(height: 14),
              _textField(
                controller: customReminderController,
                label: 'Custom reminder',
                hint: 'Example: 2 hours before',
                icon: Icons.alarm_add_rounded,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _recurrenceCard(),
        const SizedBox(height: 16),
        _priorityCard(),
      ],
    );
  }

  Widget _recurrenceCard() {
    return _sectionCard(
      children: [
        _sectionTitle('Repeat'),
        const SizedBox(height: 14),
        _dropDownField(
          value: selectedRecurrence,
          options: ciantisRecurrenceOptions,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedRecurrence = value;
            });
          },
        ),
        if (selectedRecurrence != 'Does not repeat') ...[
          const SizedBox(height: 14),
          _dropDownField(
            value: selectedRecurrenceEnd,
            options: ciantisRecurrenceEndOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                selectedRecurrenceEnd = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _priorityCard() {
    return _sectionCard(
      children: [
        _sectionTitle('Priority'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: priorityOptions.map((priority) {
            final selected = selectedPriority == priority;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPriority = priority;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFFCF8)
                      : const Color(0xFFF4EFE8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? _priorityColor(priority).withValues(alpha: .65)
                        : const Color(0xFFE2D8CD),
                    width: selected ? 1.2 : .7,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _priorityColor(
                              priority,
                            ).withValues(alpha: .22),
                            blurRadius: priority == 'Urgent' ? 18 : 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PriorityDot(priority: priority),
                    const SizedBox(width: 8),
                    Text(
                      priority,
                      style: const TextStyle(
                        color: Color(0xFF241D18),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFFB8A99D);
      case 'Normal':
        return const Color(0xFF8B7D72);
      case 'Mild':
        return const Color(0xFFE1C45F);
      case 'High':
        return const Color(0xFFE09A4B);
      case 'Urgent':
        return const Color(0xFFC95A4D);
      default:
        return const Color(0xFF8B7D72);
    }
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallButton(
          icon: Icons.close_rounded,
          onTap: () {
            Navigator.pop(context, false);
          },
        ),
        _smallButton(icon: Icons.check_rounded, onTap: _saveEntry),
      ],
    );
  }

  Widget _smallButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
        ),
        child: Icon(icon, color: const Color(0xFF241D18), size: 24),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF8B7D72),
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.2,
      ),
    );
  }

  Widget _typeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entryTypes.map((type) {
        final selected = selectedType == type;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedType = type;

              if (type == 'Task') {
                allDay = true;
              } else if (type == 'Reminder') {
                allDay = false;
                endTime = startTime;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF241D18)
                  : const Color(0xFFF4EFE8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? const Color(0xFF241D18)
                    : const Color(0xFFE2D8CD),
                width: .7,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFFFF9F1)
                    : const Color(0xFF6F6258),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Widget? trailing,
    int maxLines = 1,
    bool titleCase = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
            child: Icon(icon, color: const Color(0xFF8B7D72), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              textCapitalization: titleCase
                  ? TextCapitalization.words
                  : TextCapitalization.sentences,
              cursorColor: const Color(0xFF241D18),
              style: const TextStyle(
                color: Color(0xFF241D18),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: const TextStyle(
                  color: Color(0xFF8B7D72),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
                hintStyle: TextStyle(
                  color: const Color(0xFF8B7D72).withValues(alpha: .54),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: Color(0xFF8B7D72),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF241D18),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF241D18),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _pickerButton({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFE8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF8B7D72), size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B7D72),
                fontSize: 11,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF241D18),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropDownField({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFFFFF9F1),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF241D18),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  color: Color(0xFF241D18),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: _saveEntry,
      child: Container(
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF241D18),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          isEditing ? 'Save Changes' : 'Save Entry',
          style: const TextStyle(
            color: Color(0xFFFFF9F1),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: .4,
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    return '${_shortMonth(date.month)} ${date.day}, ${date.year}';
  }
}

class _PriorityDot extends StatefulWidget {
  final String priority;

  const _PriorityDot({required this.priority});

  @override
  State<_PriorityDot> createState() => _PriorityDotState();
}

class _PriorityDotState extends State<_PriorityDot>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool get pulse => widget.priority == 'Urgent' || widget.priority == 'High';

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      lowerBound: .45,
      upperBound: 1,
    );

    if (pulse) {
      controller.repeat(reverse: true);
    } else {
      controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _PriorityDot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (pulse) {
      controller.repeat(reverse: true);
    } else {
      controller.stop();
      controller.value = 1;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Color get color {
    switch (widget.priority) {
      case 'Low':
        return const Color(0xFFB8A99D);
      case 'Normal':
        return const Color(0xFF8B7D72);
      case 'Mild':
        return const Color(0xFFE1C45F);
      case 'High':
        return const Color(0xFFE09A4B);
      case 'Urgent':
        return const Color(0xFFC95A4D);
      default:
        return const Color(0xFF8B7D72);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 11,
          width: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: pulse ? controller.value : .18),
                blurRadius: pulse ? 12 : 5,
                spreadRadius: pulse ? 1.4 : .2,
              ),
            ],
          ),
        );
      },
    );
  }
}

String _toTitleCase(String text) {
  if (text.trim().isEmpty) return text;

  return text
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;

        final lower = word.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

String _shortMonth(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return names[month - 1];
}
