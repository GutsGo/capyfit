import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'hand_drawn_widgets.dart';

class FloatingCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const FloatingCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<FloatingCalendar> createState() => _FloatingCalendarState();
}

class _FloatingCalendarState extends State<FloatingCalendar> {
  bool _isExpanded = false;
  late PageController _pageController;
  late DateTime _todayStartOfWeek;
  int _currentPageIndex = 1000;

  @override
  void initState() {
    super.initState();
    _todayStartOfWeek = _getStartOfWeek(DateTime.now());
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      final newIndex =
          1000 +
          (widget.selectedDate.difference(_todayStartOfWeek).inDays / 7)
              .floor();
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(newIndex);
        }
      }
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getWeekStartForIndex(int index) {
    return _todayStartOfWeek.add(Duration(days: (index - 1000) * 7));
  }

  void _changeWeek(int offset) {
    _pageController.animateToPage(
      _currentPageIndex + offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekStart = _getWeekStartForIndex(_currentPageIndex);

    return TapRegion(
      groupId: 'calendar_region',
      onTapOutside: (event) {
        if (_isExpanded) {
          setState(() => _isExpanded = false);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Trigger
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: HandDrawnContainer(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.getCardColor(context),
              borderRadius: 20,
              borderColor: _isExpanded
                  ? AppColors.primary
                  : AppColors.getBorderColor(context),
              borderWidth: 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.calendar,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('yyyy年M月d日').format(widget.selectedDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.getTextMainColor(context),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Week View (Floating)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HandDrawnContainer(
                padding: const EdgeInsets.all(16),
                color: AppColors.getCardColor(context),
                borderRadius: 24,
                borderColor: AppColors.primary,
                borderWidth: 1.5,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, size: 20),
                          onPressed: () => _changeWeek(-1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          DateFormat('yyyy年M月').format(
                            currentWeekStart.add(const Duration(days: 3)),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMainColor(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight, size: 20),
                          onPressed: () => _changeWeek(1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPageIndex = index),
                        itemBuilder: (context, weekIndex) {
                          final weekStart = _getWeekStartForIndex(weekIndex);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (dayIndex) {
                              final date = weekStart.add(
                                Duration(days: dayIndex),
                              );
                              final isSelected = _isSameDay(
                                date,
                                widget.selectedDate,
                              );
                              final isToday = _isSameDay(date, DateTime.now());
                              final weekDays = [
                                '一',
                                '二',
                                '三',
                                '四',
                                '五',
                                '六',
                                '日',
                              ];

                              return GestureDetector(
                                onTap: () {
                                  widget.onDateSelected(date);
                                },
                                // 使用 TapRegion 包裹日期格以防点击时触发 onTapOutside
                                child: TapRegion(
                                  groupId: 'calendar_region',
                                  child: Container(
                                    width: 38,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          weekDays[dayIndex],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.8)
                                                : AppColors.getTextMutedColor(
                                                    context,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.getTextMainColor(
                                                    context,
                                                  ),
                                          ),
                                        ),
                                        if (isToday)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.accentOrange,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
