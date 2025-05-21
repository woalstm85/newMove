import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/services/api_service.dart';
import 'partner_detail_intro.dart';
import 'partner_detail_review.dart';
import 'partner_detail_busi.dart';
import 'API/partner_api_service.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class PartnerDetailScreen extends StatefulWidget {
  final String partnerId;

  const PartnerDetailScreen({
    Key? key,
    required this.partnerId,
  }) : super(key: key);

  @override
  _PartnerDetailScreenState createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _partnerData = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPartnerDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _generatePartnerSpecificReviews(String partnerId) {
    debugPrint('_generatePartnerSpecificReviews 함수에 전달된 파트너 ID: $partnerId');
    switch (partnerId) {
      case 'C0001': // 대형 이사 전문 파트너
        return [
          {
            'userName': '김** 고객님',
            'rating': 5.0,
            'date': '2024.01.15',
            'content': '대형 사무실 이사를 진행했는데 정말 전문적이었어요. 복잡한 IT 장비와 대형 가구들을 세심하게 옮겨주셨고, 모든 작업이 매우 체계적으로 진행되었습니다.',
            'serviceType': '사무실 대형 이사',
            'verified': true,
          },
          {
            'userName': '박** 고객님',
            'rating': 4.5,
            'date': '2023.12.22',
            'content': '회사 이전으로 많은 장비와 가구를 옮겨야 했는데, 모든 과정이 놀라울 정도로 효율적이었어요. 특히 중요한 장비들의 포장과 운반에 확실한 전문성을 보여주셨습니다.',
            'serviceType': '사무실 대형 이사',
            'verified': true,
          },
          {
            'userName': '이** 고객님',
            'rating': 4.0,
            'date': '2023.11.05',
            'content': '대규모 이사였지만 예상보다 빠르게 마무리되었어요. 다만 일부 사무용 의자에 작은 긁힘이 생겨 아쉬웠습니다. 전반적으로 전문적인 서비스였습니다.',
            'serviceType': '사무실 대형 이사',
            'verified': true,
          },
          {
            'userName': '최** 고객님',
            'rating': 5.0,
            'date': '2024.02.03',
            'content': '여러 층의 사무실을 한 번에 이사했는데 정말 놀라운 팀워크를 보여주셨어요. 모든 장비와 문서를 완벽하게 정리해주셔서 감사합니다.',
            'serviceType': '다층 사무실 이사',
            'verified': true,
          },
          {
            'userName': '정** 고객님',
            'rating': 4.5,
            'date': '2023.10.17',
            'content': '대형 서버실 이전 작업을 맡겼는데 데이터 센터 이사치고는 놀랍도록 부드럽게 진행되었습니다. 장비 하나도 손상 없이 완벽하게 이전했어요.',
            'serviceType': '데이터 센터 이사',
            'verified': true,
          },
        ];

      case 'C0002': // 소형 이사 전문 파트너
        return [
          {
            'userName': '이** 고객님',
            'rating': 5.0,
            'date': '2024.02.10',
            'content': '원룸 이사를 도와주셨는데 정말 꼼꼼하고 친절하셨어요. 좁은 공간에서도 매우 세심하게 짐을 포장하고 운반해주셨습니다.',
            'serviceType': '원룸 이사',
            'verified': true,
          },
          {
            'userName': '최** 고객님',
            'rating': 4.5,
            'date': '2023.11.30',
            'content': '학생 이사라 예산이 빠듯했는데, 합리적인 가격에 퀄리티 높은 서비스를 제공해주셨어요. 짐 정리까지 도와주셔서 너무 감사했습니다.',
            'serviceType': '소형 이사',
            'verified': true,
          },
          {
            'userName': '박** 고객님',
            'rating': 4.0,
            'date': '2024.01.22',
            'content': '비교적 간단한 이사였지만 세심하게 일해주셨어요. 다만 계단이 많은 건물이라 약간의 시간이 더 걸렸습니다.',
            'serviceType': '투룸 이사',
            'verified': true,
          },
          {
            'userName': '김** 고객님',
            'rating': 5.0,
            'date': '2023.12.15',
            'content': '짐이 생각보다 많았는데도 불구하고 너무 빠르고 효율적으로 이사를 마쳤어요. 포장부터 운반까지 모든 과정이 전문적이었습니다.',
            'serviceType': '원룸 이사',
            'verified': true,
          },
          {
            'userName': '윤** 고객님',
            'rating': 4.5,
            'date': '2024.03.01',
            'content': '좁은 공간에서의 이사치고는 정말 깔끔하게 진행해주셨어요. 특히 가구 배치와 정리까지 도와주셔서 감사했습니다.',
            'serviceType': '소형 이사',
            'verified': true,
          },
          // 대체로 긍정적이지만 약간의 아쉬움이 있는 리뷰
          {
            'userName': '김** 고객님',
            'rating': 4.0,
            'date': '2023.09.22',
            'content': '전반적으로 만족스러운 서비스였습니다. 이사 과정이 꽤 빠르고 전문적이었어요. 다만, 일부 가구에 작은 긁힘이 있어 아쉬웠습니다. 고객 응대는 매우 친절했고, 문제 발생 시 즉각적으로 대응해주셨어요.',
            'serviceType': '가정이사',
            'verified': true,
          },
          // 보통의 평가 (중립적)
          {
            'userName': '이** 고객님',
            'rating': 3.5,
            'date': '2023.10.05',
            'content': '기대했던 것만큼 완벽하지는 않았지만, 나쁘지 않은 서비스였어요. 시간을 꽤 잘 지켜주었고, 기본적인 이사 서비스는 문제없이 진행되었습니다. 추가 요청사항에 대한 대응은 조금 아쉬웠어요.',
            'serviceType': '소형이사',
            'verified': true,
          },
          // 부정적인 리뷰 (낮은 평점)
          {
            'userName': '박** 고객님',
            'rating': 2.0,
            'date': '2023.11.12',
            'content': '기대와는 너무 달랐습니다. 약속된 시간보다 한참 늦게 도착했고, 이사 과정에서 물건 하나가 파손되었어요. 고객 응대도 형식적이었고, 보상 과정도 매우 불친절했습니다. 다시는 이용하고 싶지 않습니다.',
            'serviceType': '가정이사',
            'verified': false,
          },
        ];

      case 'C0003': // 장거리 이사 전문 파트너
        return [
          {
            'userName': '정** 고객님',
            'rating': 5.0,
            'date': '2024.03.05',
            'content': '지방으로 장거리 이사를 하게 되어 걱정했는데, 모든 과정이 매우 원활하고 전문적이었어요. 장거리 운송 중 물건 관리가 정말 뛰어났습니다.',
            'serviceType': '장거리 이사',
            'verified': true,
          },
          {
            'userName': '윤** 고객님',
            'rating': 4.5,
            'date': '2023.10.18',
            'content': '도서산간 지역으로 이사하는 것이 쉽지 않았는데, 이 파트너님의 전문성 덕분에 안전하고 신속하게 이사를 마쳤습니다.',
            'serviceType': '도서산간 이사',
            'verified': true,
          },
          {
            'userName': '박** 고객님',
            'rating': 4.0,
            'date': '2024.01.07',
            'content': '서울에서 부산으로 이사하면서 걱정했는데 예상보다 순조롭게 진행되었어요. 다만 도착 시간이 조금 늦어져 아쉬웠습니다.',
            'serviceType': '장거리 이사',
            'verified': true,
          },
          {
            'userName': '김** 고객님',
            'rating': 5.0,
            'date': '2023.11.25',
            'content': '제주도로 이사하는 특수한 상황이었는데 모든 과정이 완벽했어요. 섬까지의 운송을 포함해 놀라울 정도로 전문적이었습니다.',
            'serviceType': '도서 이사',
            'verified': true,
          },
          {
            'userName': '최** 고객님',
            'rating': 4.5,
            'date': '2024.02.14',
            'content': '대전에서 광주로 이사하면서 많은 짐을 운반했는데 단 하나의 물건도 손상 없이 안전하게 도착했습니다.',
            'serviceType': '장거리 이사',
            'verified': true,
          },
        ];

      case 'C0004': // 특수 화물 이사 전문 파트너
        return [
          {
            'userName': '강** 고객님',
            'rating': 5.0,
            'date': '2024.02.25',
            'content': '피아노와 고가의 미술품 이사를 맡겼는데, 최고의 전문성을 보여주셨어요. 각 물품에 맞는 특수 포장과 운반 방법으로 신뢰감을 주셨습니다.',
            'serviceType': '특수 화물 이사',
            'verified': true,
          },
          {
            'userName': '서** 고객님',
            'rating': 4.5,
            'date': '2023.09.12',
            'content': '연주용 첼로와 고가의 음향 장비 이사를 맡겼는데, 세심함과 전문성이 정말 인상적이었습니다. 모든 기자재가 완벽하게 보호되었어요.',
            'serviceType': '악기 및 특수 장비 이사',
            'verified': true,
          },
          {
            'userName': '이** 고객님',
            'rating': 4.0,
            'date': '2024.01.30',
            'content': '대형 조각상과 예술 작품을 운반해야 해서 걱정했는데 예상 이상으로 안전하게 이동시켜 주셨어요. 다만 비용이 조금 높았습니다.',
            'serviceType': '예술품 운송',
            'verified': true,
          },
          {
            'userName': '박** 고객님',
            'rating': 5.0,
            'date': '2023.12.05',
            'content': '실험실 장비 이사로 정밀 기기들을 옮겨야 했는데 놀라울 정도로 꼼꼼하고 전문적이었어요. 모든 장비가 완벽한 상태로 도착했습니다.',
            'serviceType': '연구 장비 이사',
            'verified': true,
          },
          {
            'userName': '최** 고객님',
            'rating': 4.5,
            'date': '2024.02.18',
            'content': '고가의 와인 컬렉션을 운반해야 해서 걱정했는데 온도 관리부터 진동 방지까지 완벽했어요. 프로페셔널한 서비스에 감동받았습니다.',
            'serviceType': '특수 화물 운송',
            'verified': true,
          },
        ];
      default:
        return [
          {
            'userName': '기본** 고객님',
            'rating': 4.0,
            'date': '2024.01.01',
            'content': '일반적인 이사 서비스를 이용했습니다. 기본적인 서비스 수준은 만족스러웠습니다.',
            'serviceType': '일반 이사',
            'verified': true,
          }
        ];
    }
  }

// 전화 걸기 함수
  Future<void> _makePhoneCall(String phoneNumber) async {
    // 전화번호에서 하이픈, 공백 등을 제거
    final String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      // tel: 스키마 사용
      final Uri uri = Uri.parse('tel:$cleanedNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 디버깅을 위한 출력
        debugPrint('전화를 걸 수 없습니다: $cleanedNumber (원본: $phoneNumber)');
        context.showSnackBar('전화 앱을 실행할 수 없습니다.');
      }
    } catch (e) {
      debugPrint('전화 걸기 오류: $e');
      context.showSnackBar('전화 연결 중 오류가 발생했습니다.');
    }
  }

  Future<void> _fetchPartnerDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {

      final dynamic response = await PartnerService.fetchPartnerDetail(widget.partnerId);

      // 응답이 리스트인 경우 처리
      if (response is List && response.isNotEmpty) {
        // partnerId와 일치하는 파트너 찾기
        final partnerData = response.firstWhere(
              (partner) => partner['compCd'] == widget.partnerId,
          orElse: () => response[0], // 일치하는 것이 없으면 첫 번째 항목 사용
        );

        setState(() {
          _partnerData = partnerData;

          // 파트너 ID에 따른 리뷰 데이터 생성
          _partnerData['reviews'] = _generatePartnerSpecificReviews(widget.partnerId);

          _isLoading = false;
        });

        debugPrint('파트너 상세 정보 로드 성공: ${_partnerData['compName']}');
      } else if (response is Map<String, dynamic>) {
        // 응답이 Map인 경우 (API가 단일 객체를 반환하는 경우)
        setState(() {
          _partnerData = response;
          _isLoading = false;
        });
      } else {
        debugPrint('예상치 못한 응답 형식: $response');
        setState(() {
          _partnerData = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('파트너 정보 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: _isLoading ? _buildSkeletonUI() : _buildContent(),
      bottomNavigationBar: _isLoading ? _buildBottomBarSkeleton() : _buildBottomBar(),
    );
  }

  Widget _buildSkeletonUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 이미지 스켈레톤
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250,
              color: Colors.white,
            ),
          ),

          // 탭바 스켈레톤
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 48,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),

          // 콘텐츠 스켈레톤
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 카드 - 파트너 정보
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카드 제목 스켈레톤
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 100,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 정보 아이템 스켈레톤들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItemSkeleton(),
                          _buildInfoItemSkeleton(),
                          _buildInfoItemSkeleton(),
                        ],
                      ),
                    ],
                  ),
                ),

                // 두 번째 카드 - 소개
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 행 스켈레톤
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 18,
                              height: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 텍스트 라인들
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity * 0.8,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity * 0.6,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 세 번째 카드 - 제공 서비스
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 행 스켈레톤
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 18,
                              height: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 서비스 태그들 스켈레톤
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          4,
                              (index) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 정보 박스 스켈레톤
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity * 0.7,
                                      height: 12,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 네 번째 카드 - 서비스 지역
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 행 스켈레톤
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 18,
                              height: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 지역 태그들 스켈레톤
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          3,
                              (index) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 90,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 다섯 번째 카드 - 견적 상담 조건
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 행 스켈레톤
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 18,
                              height: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 120,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 조건 아이템들 스켈레톤
                      _buildConditionItemSkeleton(),
                      const SizedBox(height: 16),
                      _buildConditionItemSkeleton(),
                      const SizedBox(height: 16),
                      _buildConditionItemSkeleton(),
                    ],
                  ),
                ),

                // 여섯 번째 카드 - 자격증 및 수상 이력
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 행 스켈레톤
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 18,
                              height: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 160,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 자격증/수상 항목들 스켈레톤
                      _buildAwardItemSkeleton(),
                      const SizedBox(height: 12),
                      _buildAwardItemSkeleton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 인포 아이템 스켈레톤
  Widget _buildInfoItemSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

// 조건 아이템 스켈레톤
  Widget _buildConditionItemSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: double.infinity * 0.7,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


// 자격증/수상 아이템 스켈레톤
  Widget _buildAwardItemSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 하단 바 스켈레톤 UI
  Widget _buildBottomBarSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 86, // 하단 바 높이 (버튼 높이 + 패딩)
      color: Colors.white,
      child: Row(
        children: [
          // 전화 버튼 스켈레톤
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 견적 받기 버튼 스켈레톤
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final String imageUrl = _partnerData['imgData'] != null &&
        _partnerData['imgData'].isNotEmpty &&
        _partnerData['imgData'][0]['imgUrl'] != null
        ? _partnerData['imgData'][0]['imgUrl']
        : 'https://via.placeholder.com/150';

    final String partnerName = _partnerData['compName'] ?? '파트너';
    final String experience = _partnerData['experience'] ?? '0년';
    final int completedJobs = _partnerData['completedJobs'] ?? 0;
    final int reviewCount = _partnerData['reviewCount'] ?? 0;
    final double rating = _partnerData['rating'] != null
        ? (_partnerData['rating'] is int
        ? _partnerData['rating'].toDouble()
        : _partnerData['rating'])
        : 0.0;
    final String introduction = _partnerData['introduction'] ?? '';
    final List<Map<String, dynamic>> partnerReviews =
    _generatePartnerSpecificReviews(widget.partnerId);

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: AppTheme.primaryText, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: innerBoxIsScrolled ? 1.0 : 0.0,
              child: Text(
                partnerName,
                style: AppTheme.subheadingStyle.copyWith(
                  fontSize: 18,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
            centerTitle: true,
            pinned: true,
            floating: true,
            snap: false,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // 배경 이미지
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.business,
                              size: 80,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 그라데이션 오버레이
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // 파트너 정보 오버레이
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.white,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.subtleText.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppTheme.subtleText,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partnerName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppTheme.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '리뷰 $reviewCount건',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '경력 $experience',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '인증완료',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // 탭바
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.secondaryText,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: '소개'),
                Tab(text: '리뷰'),
                Tab(text: '정보'),
              ],
            ),
          ),

          // 탭바 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 소개 탭
                PartnerIntroductionTab(
                  partnerName: _partnerData['compName'] ?? '파트너',
                  bossName: _partnerData['bossName'] ?? '정보 없음',
                  introduction: _partnerData['introduction'] ?? '',
                  experience: _partnerData['experience'] ?? '5년',
                  regions: _partnerData['regions'] ?? ['서울', '경기', '인천'],
                  services: _partnerData['serviceData'] ?? [],
                ),

                // 리뷰 탭
                PartnerReviewTab(
                  partnerName: _partnerData['compName'] ?? '파트너',
                  reviews: (partnerReviews ?? []).cast<Map<String, dynamic>>(),
                  serviceTypes: _partnerData['serviceData'] != null
                      ? (_partnerData['serviceData'] as List).map((service) => service['serviceNm'] as String).toList()
                      : ['가정이사', '소형이사'],
                ),

                // 정보 탭
                PartnerBusinessInfoTab(
                  partnerData: _partnerData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 서비스 유형을 가져오는 헬퍼 메서드
  List<String> _getServiceTypes() {
    List<String> serviceTypes = [];

    // 서비스 타입 추출
    if (_partnerData['serviceData'] != null && _partnerData['serviceData'] is List) {
      for (var service in _partnerData['serviceData']) {
        if (service['serviceNm'] != null) {
          serviceTypes.add(service['serviceNm']);
        }
      }
    }

    // 서비스 타입이 없는 경우 기본값 설정
    if (serviceTypes.isEmpty) {
      serviceTypes.add('가정이사');
      serviceTypes.add('소형이사');
    }

    return serviceTypes;
  }


  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.call,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  final String phoneNumber = _partnerData['tel1']?.isNotEmpty == true
                      ? _partnerData['tel1']
                      : '010-9033-7199'; // 동일한 기본값 사용

                  debugPrint('전화 걸기 시도: $phoneNumber'); // 디버깅용
                  _makePhoneCall(phoneNumber);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 견적 의뢰 로직 추가
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          '견적 상담',
                          style: AppTheme.subheadingStyle,
                        ),
                        content: Text(
                          '${_partnerData['compName'] ?? '파트너'}와 견적 상담을 시작하시겠습니까?',
                          style: AppTheme.bodyTextStyle,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '취소',
                              style: TextStyle(color: AppTheme.secondaryText),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 실제 견적 상담 로직 구현
                              Navigator.of(context).pop();
                              context.showSnackBar('견적 상담 요청되었습니다.');
                            },
                            style: AppTheme.primaryButtonStyle,
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: AppTheme.primaryButtonStyle.copyWith(
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 54),
                  ),
                ),
                child: const Text('이 파트너에게 견적 받기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}