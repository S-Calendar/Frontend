import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';
import '../models/notice.dart';
import '../services/notice_data.dart';
import '../widgets/notice_modal.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final int baseYear = 2024;
  late final PageController _pageController;
  late int _selectedIndex;
  late int _todayIndex;
  late List<Notice> allNotices = [];
  Set<String> _selectedCategories = {}; // ✅ 필터 선택 카테고리

  @override
  void initState() {
    super.initState();
    final DateTime today = DateTime.now();
    _todayIndex = (today.year - baseYear) * 12 + (today.month - 1);
    _selectedIndex = _todayIndex;
    _pageController = PageController(initialPage: _todayIndex);
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    final notices = await NoticeData.loadNoticesFromFirestore();
    setState(() {
      _applyCategoryFilter(notices);
    });
  }

  void _applyCategoryFilter(List<Notice> notices) {
    if (_selectedCategories.isEmpty) {
      allNotices = notices.where((n) => !n.isHidden).toList();
    } else {
      allNotices = notices.where((n) =>
          _selectedCategories.contains(_convertCategory(n.color)) &&
          !n.isHidden).toList();
    }
  }

  String _convertCategory(Color color) {
    if (color == const Color(0x83FFABAB)) return 'ai학과공지';
    if (color == const Color(0x83ABC9FF)) return '학사공지';
    if (color == const Color(0x83A5FAA5)) return '취업공지';
    return '기타';
  }

  Future<void> _navigateAndRefresh(String routeName) async {
    await Navigator.pushNamed(context, routeName);
    await _loadNotices();
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '카테고리 별로 확인하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCheckbox(setState, 'ai학과공지', '학과 공지(AI융합학부)'),
                  _buildCheckbox(setState, '학사공지', '학사 공지'),
                  _buildCheckbox(setState, '취업공지', '취업 공지'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadNotices(); // ✅ 선택 후 필터 반영
                    },
                    child: const Text('해당 공지만 확인하기'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(StateSetter setState, String category, String label) {
    return CheckboxListTile(
      value: _selectedCategories.contains(category),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int year = baseYear + (_selectedIndex ~/ 12);
    final int month = (_selectedIndex % 12) + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _navigateAndRefresh('/settings'),
                    child: Image.asset('assets/setting_icon.png', width: 32),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = _todayIndex;
                        _pageController.jumpToPage(_todayIndex);
                      });
                    },
                    child: Image.asset('assets/today_icon.png', width: 70),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$month월',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _navigateAndRefresh('/search'),
                    child: Image.asset('assets/search_icon.png', width: 30),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _showCategoryFilterDialog, // ✅ 여기를 수정
                    child: Image.asset(
                      'assets/colorfilter_icon.png',
                      width: 44,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final year = baseYear + (index ~/ 12);
                  final month = (index % 12) + 1;
                  final currentMonth = DateTime(year, month);

                  return CustomCalendar(
                    month: currentMonth,
                    notices: allNotices,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

