import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_constants.dart';

class ThirdPartyConsentScreen extends StatefulWidget {
  const ThirdPartyConsentScreen({Key? key}) : super(key: key);

  @override
  _ThirdPartyConsentScreenState createState() => _ThirdPartyConsentScreenState();
}

class _ThirdPartyConsentScreenState extends State<ThirdPartyConsentScreen> {
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
      final String content = await rootBundle.loadString('assets/Third_Party_Consent.txt');
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading third party consent: $e');
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
          '제3자 정보 제공 동의',
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

  // 제3자 정보 제공 동의 텍스트 포맷팅
  Widget _buildFormattedContent(String text) {
    // 제목 패턴 (대괄호로 둘러싸인 텍스트)
    final titleRegex = RegExp(r'\*\*\[(.*?)\]\*\*');

    List<Widget> widgets = [];
    List<String> paragraphs = text.split('\n');

    for (int i = 0; i < paragraphs.length; i++) {
      String paragraph = paragraphs[i].trim();

      if (paragraph.isEmpty) continue;

      // 제목인 경우 (마크다운 볼드 형식으로 되어 있음)
      if (titleRegex.hasMatch(paragraph)) {
        // 마크다운 볼드 표시(**) 제거
        String title = paragraph.replaceAll('**', '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        );
      }
      // 숫자로 시작하는 목록 항목인 경우
      else if (RegExp(r'^\d+\.').hasMatch(paragraph)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
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
      // 하이픈으로 시작하는 목록 항목인 경우
      else if (paragraph.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}