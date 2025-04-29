import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/terms/widgets/terms_format.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final int initialIndex;

  const TermsOfServiceScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 각 탭마다 별도의 스크롤 컨트롤러 사용
  final List<ScrollController> _scrollControllers = [];
  bool _showScrollUpButton = false;

  final List<String> _tabTitles = ["이용약관", "개인정보 처리방침", "리뷰 중단 정책"];
  final List<String> _filePaths = [
    'assets/terms_of_service.txt',
    'assets/privacy_policy.txt',
    'assets/review_policy.txt'
  ];

  final List<String> _contents = ['', '', ''];
  final List<List<TextSpan>> _formattedContents = [[], [], []];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 탭 수만큼 스크롤 컨트롤러 생성
    for (int i = 0; i < _tabTitles.length; i++) {
      _scrollControllers.add(ScrollController()..addListener(() => _scrollListener(i)));
    }

    _tabController = TabController(
        length: _tabTitles.length,
        vsync: this,
        initialIndex: widget.initialIndex
    );

    _loadContents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 모든 스크롤 컨트롤러 해제
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 현재 활성화된 탭의 스크롤 위치에 따라 버튼 표시 여부 결정
  void _scrollListener(int index) {
    if (index == _tabController.index) {
      final controller = _scrollControllers[index];
      if (controller.offset > 300 && !_showScrollUpButton) {
        setState(() {
          _showScrollUpButton = true;
        });
      } else if (controller.offset <= 300 && _showScrollUpButton) {
        setState(() {
          _showScrollUpButton = false;
        });
      }
    }
  }

  Future<void> _loadContents() async {
    try {
      for (int i = 0; i < _filePaths.length; i++) {
        final String content = await rootBundle.loadString(_filePaths[i]);

        // 미리 포맷팅 처리 - 별도 클래스로 분리된 포맷팅 기능 사용
        final List<TextSpan> formatted = TermsFormat.formatTerms(content, i);

        setState(() {
          _contents[i] = content;
          _formattedContents[i] = formatted;
        });
      }
    } catch (e) {
      debugPrint('Error loading terms: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingIndicator()
            : TabBarView(
          controller: _tabController,
          children: List.generate(
            _contents.length,
                (index) => _buildContentView(_contents[index], index),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        '약관 및 정책',
        style: TextStyle(
          color: AppTheme.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.secondaryText,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: _tabTitles.map((title) {
              // 개인정보 처리방침 탭만 줄바꿈 적용
              if (title == "개인정보 처리방침") {
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("개인정보"),
                      const Text("처리방침"),
                    ],
                  ),
                );
              }
              return Tab(text: title);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildContentView(String content, int tabIndex) {
    if (content.isEmpty) {
      return Center(
        child: Text(
          "내용을 불러올 수 없습니다.",
          style: TextStyle(color: AppTheme.secondaryText),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            controller: _scrollControllers[tabIndex],
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLastModifiedInfo(),
                SizedBox(height: 16),
                // 미리 포맷팅된 내용 사용
                RichText(
                  text: TextSpan(
                    children: _formattedContents[tabIndex],
                  ),
                ),
                // 문서 끝에 여백 추가
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
        // 플로팅 버튼
        _buildFloatingButtons(tabIndex, content),
      ],
    );
  }

  Widget _buildLastModifiedInfo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.secondaryText,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "최종 수정일: 2024년 6월 1일",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(int tabIndex, String content) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showScrollUpButton)
            Container(
              margin: EdgeInsets.only(bottom: 12),
              child: FloatingActionButton(
                heroTag: 'scrollUpButton$tabIndex',  // 각 탭마다 고유한 heroTag 사용
                onPressed: () {
                  _scrollControllers[tabIndex].animateTo(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                backgroundColor: AppTheme.primaryColor,
                elevation: 4,
                mini: true,
                child: Icon(Icons.arrow_upward, size: 20, color: Colors.white),
              ),
            ),
          FloatingActionButton(
            heroTag: 'copyButton$tabIndex',  // 각 탭마다 고유한 heroTag 사용
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('내용이 클립보드에 복사되었습니다.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            backgroundColor: Colors.white,
            elevation: 4,
            mini: true,
            child: Icon(
              Icons.content_copy,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}