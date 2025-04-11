import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class ReviewAnalysisWidget extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final String partnerId;
  // 정적 캐시 맵 추가
  static Map<String, List<String>> _analysisCache = {};

  const ReviewAnalysisWidget({
    Key? key,
    required this.reviews,
    required this.partnerId,
  }) : super(key: key);

  @override
  _ReviewAnalysisWidgetState createState() => _ReviewAnalysisWidgetState();
}

class _ReviewAnalysisWidgetState extends State<ReviewAnalysisWidget> {
  List<String> _analysisSummary = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _cacheKey = '';

  @override
  void initState() {
    super.initState();
    if (widget.reviews.isNotEmpty) {
      // 파트너 ID를 포함한 캐시 키 생성
      _cacheKey = widget.partnerId;

      // 캐시 확인
      if (ReviewAnalysisWidget._analysisCache.containsKey(_cacheKey)) {
        setState(() {
          _analysisSummary = ReviewAnalysisWidget._analysisCache[_cacheKey]!;
        });
      } else {
        _analyzeReviews();
      }
    }
  }

  Future<void> _analyzeReviews() async {
    // 모든 리뷰 텍스트 결합 (유니코드 정규화)
    String allReviewTexts = widget.reviews
        .map((review) => _normalizeText(review['content']))
        .join('\n\n');

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _analysisSummary = [];
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'x-api-key': dotenv.env['ANTHROPIC_API_KEY']!,
          'anthropic-version': '2023-06-01'
        },
        body: utf8.encode(jsonEncode({
          'model': 'claude-3-5-sonnet-20240620',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'user',
              'content': '''
리뷰를 분석하여 다음 규칙을 엄격히 준수하세요:

규칙:
- 총 6개 이하의 명사로 제한 (장점 3-4개, 단점 2-3개)
- 각 명사 뒤에 반드시 쉼표(,) 포함
- 가장 핵심적이고 대표적인 특성만 선택
- 중복 및 유사 표현 제거
- 간결하고 명확한 단일 명사로 표현

예시 형식:
친절함, 전문성, 신속성, 
지연, 소통부족,

분석할 리뷰:
$allReviewTexts
'''
            }
          ]
        })),
      );

      if (!mounted) return;

      // UTF-8 디코딩 명시적 처리
      final responseBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(responseBody);

      String analysisText = jsonResponse['content'][0]['text'].trim();

      // 결과를 리스트로 변환
      setState(() {
        _analysisSummary = analysisText
            .split(',')
            .map((item) => item.trim())
            .where((item) =>
        item.isNotEmpty &&
            item.length > 1 &&
            !item.contains('결과') &&
            !item.contains('분석') &&
            !item.startsWith('분석') &&
            !item.contains('없음') &&
            !item.contains('기타')
        )
            .toList();
        _isLoading = false;
        // 여기에 캐시 저장 코드 추가
        ReviewAnalysisWidget._analysisCache[_cacheKey] = _analysisSummary;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        ReviewAnalysisWidget._analysisCache[_cacheKey] = _analysisSummary;
      });
    }
  }

  // 텍스트 정규화 메서드 (유니코드 문제 해결)
  String _normalizeText(String text) {
    return text.trim()
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    // 리뷰가 없거나, 오류 발생 시 아무것도 표시하지 않음
    if (widget.reviews.isEmpty || _errorMessage.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'AI 리뷰 분석',
                style: context.titleStyle(),
              ),
            ],
          ),
          SizedBox(height: context.defaultPadding),
          _isLoading
              ? _buildLoadingIndicator()
              : _buildAnalysisSummary(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Icon(
              Icons.insights,
              color: AppTheme.primaryColor.withOpacity(0.3),
              size: 20,
            ),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary() {
    // 비어있거나 의미 없는 항목 제거
    final filteredSummary = _analysisSummary
        .where((item) =>
    item.isNotEmpty &&
        item.length > 1 &&
        !item.contains('없음') &&
        !item.contains('기타')
    )
        .toList();

    // 빈 리스트인 경우 아무것도 표시하지 않음
    if (filteredSummary.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: filteredSummary.map((strength) =>
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  strength.replaceAll(',', ''), // 쉼표 제거
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
          ).toList(),
        ),
      ),
    );
  }
}