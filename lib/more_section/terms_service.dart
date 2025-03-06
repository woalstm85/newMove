import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../theme/theme_constants.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final int initialIndex;

  const TermsOfServiceScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showScrollUpButton = false;

  final List<String> _tabTitles = ["이용약관", "개인정보 처리방침", "리뷰 중단 정책"];
  final List<String> _filePaths = [
    'assets/terms_of_service.txt',
    'assets/privacy_policy.txt',
    'assets/review_policy.txt'
  ];

  final List<String> _contents = ['', '', ''];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _tabTitles.length,
        vsync: this,
        initialIndex: widget.initialIndex
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadContents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showScrollUpButton) {
      setState(() {
        _showScrollUpButton = true;
      });
    } else if (_scrollController.offset <= 300 && _showScrollUpButton) {
      setState(() {
        _showScrollUpButton = false;
      });
    }
  }

  Future<void> _loadContents() async {
    try {
      for (int i = 0; i < _filePaths.length; i++) {
        final String content = await rootBundle.loadString(_filePaths[i]);
        setState(() {
          _contents[i] = content;
        });
      }
    } catch (e) {
      print('Error loading terms: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TextSpan> _formatTerms(String text) {
    final List<TextSpan> spans = [];

    // 제목 패턴 (제X장, 제X조 등)
    final titleRegex = RegExp(r"(제\s*\d+\s*[장조])");

    // 섹션 구분자 패턴 (예: "제 1 장 총칙" 같은 전체 라인)
    final sectionRegex = RegExp(r"^.*제\s*\d+\s*장.*$", multiLine: true);

    int lastMatchEnd = 0;
    bool inSection = false;

    // 섹션 제목 먼저 찾기
    final sectionMatches = sectionRegex.allMatches(text);
    final Set<String> sectionTitles = {};
    for (final match in sectionMatches) {
      sectionTitles.add(match.group(0)!);
    }

    // 일반 제목 패턴 찾기
    final matches = titleRegex.allMatches(text);

    for (final match in matches) {
      final matchText = text.substring(match.start, match.end);

      // 매치 이전 텍스트 추가
      if (match.start > lastMatchEnd) {
        final beforeText = text.substring(lastMatchEnd, match.start);
        // 섹션 제목인지 확인
        if (sectionTitles.any((title) => beforeText.contains(title))) {
          for (final sectionTitle in sectionTitles) {
            if (beforeText.contains(sectionTitle)) {
              final int titleStart = beforeText.indexOf(sectionTitle);

              // 섹션 제목 이전 텍스트
              if (titleStart > 0) {
                spans.add(TextSpan(
                  text: beforeText.substring(0, titleStart),
                  style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333)
                  ),
                ));
              }

              // 섹션 제목
              spans.add(TextSpan(
                text: sectionTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                  color: AppTheme.primaryColor,
                ),
              ));

              // 섹션 제목 이후 텍스트
              if (titleStart + sectionTitle.length < beforeText.length) {
                spans.add(TextSpan(
                  text: beforeText.substring(titleStart + sectionTitle.length),
                  style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333)
                  ),
                ));
              }
              break;
            }
          }
        } else {
          spans.add(TextSpan(
            text: beforeText,
            style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF333333)
            ),
          ));
        }
      }

      // 현재 매치 추가 (제X조 등)
      spans.add(TextSpan(
        text: matchText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
        ),
      ));

      lastMatchEnd = match.end;
    }

    // 마지막 매치 이후 텍스트 추가
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF333333)
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: SafeArea(
          child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        )
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
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 문서 위에 마지막 수정일 표시
                Container(
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
                ),
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: _formatTerms(content),
                  ),
                ),
                // 문서 끝에 여백 추가
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
        // 플로팅 버튼
        Positioned(
          bottom: 24,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showScrollUpButton)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton(
                    heroTag: 'scrollUpButton',
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    backgroundColor: AppTheme.primaryColor,
                    elevation: 4,
                    mini: true,
                    child: Icon(Icons.arrow_upward, size: 20, color : Colors.white,),
                  ),
                ),
              FloatingActionButton(
                heroTag: 'copyButton',
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
        ),
      ],
    );
  }
}