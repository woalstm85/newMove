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

        // 미리 포맷팅 처리
        final List<TextSpan> formatted = _formatTerms(content, i);

        setState(() {
          _contents[i] = content;
          _formattedContents[i] = formatted;
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

  // 파일 유형에 따라 다른 포맷팅 적용
  List<TextSpan> _formatTerms(String text, int fileIndex) {
    // 개인정보처리방침인 경우 (index = 1)
    if (fileIndex == 1) {
      return _formatPrivacyPolicy(text);
    }
    // 다른 형식의 문서인 경우
    else {
      return _formatTraditionalTerms(text);
    }
  }

  // 기존 "제X장", "제X조" 형식의 문서 처리
  List<TextSpan> _formatTraditionalTerms(String text) {
    final List<TextSpan> spans = [];

    // 제목 패턴 (제X장, 제X조 등)
    final titleRegex = RegExp(r"(제\s*\d+\s*[장조])");

    // 섹션 구분자 패턴 (예: "제 1 장 총칙" 같은 전체 라인)
    final sectionRegex = RegExp(r"^.*제\s*\d+\s*장.*$", multiLine: true);

    int lastMatchEnd = 0;

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
                  color: Color(0xFF333333), // 검정색으로 변경
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

  // 개인정보처리방침 형식 처리
  List<TextSpan> _formatPrivacyPolicy(String text) {
    final List<TextSpan> spans = [];

    // 메인 타이틀 패턴: 줄 시작에 숫자와 점이 있고 그 뒤에 텍스트가 오는 경우
    final RegExp mainTitleRegex = RegExp(r"^\s*(\d+)\.\s+([^\n]+)", multiLine: true);

    int lastIndex = 0;

    // 메인 타이틀 찾기
    final Iterable<RegExpMatch> matches = mainTitleRegex.allMatches(text);
    for (final match in matches) {
      // 매치 이전 텍스트 추가
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF333333),
          ),
        ));
      }

      // 타이틀 전체를 볼드 처리 (검정색으로 변경)
      final fullTitle = match.group(0)!;
      spans.add(TextSpan(
        text: fullTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.8,
          color: Color(0xFF333333), // 검정색으로 변경
        ),
      ));

      lastIndex = match.end;
    }

    // 마지막 매치 이후 텍스트 추가
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
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
            // 각 탭마다 별도의 스크롤 컨트롤러 사용
            controller: _scrollControllers[tabIndex],
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
                    heroTag: 'scrollUpButton${tabIndex}',  // 각 탭마다 고유한 heroTag 사용
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
                    child: Icon(Icons.arrow_upward, size: 20, color : Colors.white,),
                  ),
                ),
              FloatingActionButton(
                heroTag: 'copyButton${tabIndex}',  // 각 탭마다 고유한 heroTag 사용
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