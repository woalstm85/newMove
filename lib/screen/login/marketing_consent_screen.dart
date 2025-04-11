import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class MarketingConsentScreen extends StatefulWidget {
  const MarketingConsentScreen({Key? key}) : super(key: key);

  @override
  _MarketingConsentScreenState createState() => _MarketingConsentScreenState();
}

class _MarketingConsentScreenState extends State<MarketingConsentScreen> {
  bool _isLoading = true;
  String _content = '';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollUpButton = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _showScrollUpButton = _scrollController.offset > 300;
    });
  }

  Future<void> _loadContent() async {
    try {
      final String content = await rootBundle.loadString('assets/Marketing_Consent.txt');
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading marketing consent: $e');
      setState(() {
        _content = '내용을 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '마케팅 정보 수신 동의',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        )
            : Stack(
          children: [
            SingleChildScrollView(
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
                  SizedBox(height: 20),
                  _buildFormattedContent(_content),
                  SizedBox(height: 80),
                ],
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
                        child: Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                      ),
                    ),
                  FloatingActionButton(
                    heroTag: 'copyButton',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _content));
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
        ),
      ),
    );
  }

  // 마케팅 동의 텍스트 포맷팅
  Widget _buildFormattedContent(String text) {
    // 제목 패턴 (대괄호로 둘러싸인 텍스트)
    final titleRegex = RegExp(r'\[(.*?)\]');
    final emojiRegex = RegExp(r'🔄.*');

    List<Widget> widgets = [];
    List<String> paragraphs = text.split('\n');

    for (int i = 0; i < paragraphs.length; i++) {
      String paragraph = paragraphs[i].trim();

      if (paragraph.isEmpty) continue;

      // 제목인 경우 (대괄호로 시작)
      if (titleRegex.hasMatch(paragraph) && paragraph.startsWith('[')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              paragraph,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        );
      }
      // 이모지로 시작하는 경우 (마케팅 동의 철회 방법 안내)
      else if (emojiRegex.hasMatch(paragraph)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Text(
              paragraph,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        );
      }
      // 일반 텍스트인 경우
      else {
        // 들여쓰기가 있는 경우 (메뉴 경로 등)
        if (paragraph.startsWith('앱 내') || paragraph.startsWith('[앱 실행]')) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                paragraph,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          );
        }
        // 노트나 유의사항인 경우
        else if (paragraph.startsWith('유의사항:') || paragraph.startsWith('단,')) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              child: Text(
                paragraph,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          );
        }
        // 나머지 일반 텍스트
        else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Text(
                paragraph,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.primaryText,
                  height: 1.5,
                ),
              ),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}