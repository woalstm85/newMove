import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../api_service.dart';

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
  bool _isFavorite = false;

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

  Future<void> _fetchPartnerDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dynamic response = await ApiService.fetchPartnerDetail(widget.partnerId);

      // 응답이 리스트인 경우 처리
      if (response is List && response.isNotEmpty) {
        // partnerId와 일치하는 파트너 찾기
        final partnerData = response.firstWhere(
              (partner) => partner['compCd'] == widget.partnerId,
          orElse: () => response[0], // 일치하는 것이 없으면 첫 번째 항목 사용
        );

        setState(() {
          _partnerData = partnerData;
          _isLoading = false;
        });

        print('파트너 상세 정보 로드 성공: ${_partnerData['compName']}');
      } else if (response is Map<String, dynamic>) {
        // 응답이 Map인 경우 (API가 단일 객체를 반환하는 경우)
        setState(() {
          _partnerData = response;
          _isLoading = false;
        });
      } else {
        print('예상치 못한 응답 형식: $response');
        setState(() {
          _partnerData = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('파트너 정보 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            '파트너 정보를 불러오는 중입니다...',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
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
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppTheme.primaryText,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite ? '찜 목록에 추가되었습니다.' : '찜 목록에서 제거되었습니다.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share, color: AppTheme.primaryText, size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '공유 기능은 준비 중입니다.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
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
                _buildIntroductionTab(),
                _buildReviewTab(),
                _buildBusinessInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab() {
    // 파트너 기본 정보
    final String bossName = _partnerData['bossName'] ?? '정보 없음';
    final String introduction = _partnerData['introduction'] ??
        '안녕하세요, ${_partnerData['compName'] ?? '파트너'} 입니다.\n'
            '오랜 경험과 노하우로 고객님의 소중한 물품을 안전하게 이사해 드립니다.\n'
            '빠르고 정확한 서비스로 고객님의 만족을 최우선으로 생각합니다.\n'
            '언제든지 문의주시면 친절하게 상담해 드리겠습니다.';

    final String experience = _partnerData['experience'] ?? '5년';
    final List<dynamic> regions = _partnerData['regions'] ?? ['서울', '경기', '인천'];
    final List<dynamic> services = _partnerData['serviceData'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 통계 및 정보 카드
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '파트너 정보',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      icon: Icons.access_time,
                      title: '경력',
                      value: experience,
                      color: AppTheme.primaryColor,
                    ),
                    _buildInfoItem(
                      icon: Icons.check_circle,
                      title: '인증상태',
                      value: '인증완료',
                      color: AppTheme.success,
                    ),
                    _buildInfoItem(
                      icon: Icons.local_shipping,
                      title: '보유차량',
                      value: '1.5톤 탑차',
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 소개글 섹션
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '파트너 소개',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  introduction,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 제공 서비스 섹션
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.handyman,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '제공 서비스',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var service in services.isNotEmpty ? services : [{'serviceNm': '소형이사'}, {'serviceNm': '가정이사'}])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              service['serviceNm'] ?? '서비스',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '기본 제공 서비스 외 현장의 서비스는 현장에 따라 금액, 수행여부 등이 변경될 수 있습니다. 반드시 업체와 상담해 주세요.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 서비스 지역 섹션
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '서비스 지역',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var region in regions)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.secondaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.secondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              region.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 견적 상담 조건 섹션
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gavel,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '견적 상담 조건',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildConditionItem(
                  icon: Icons.restaurant_menu,
                  text: '식대 요구 없음',
                  description: '별도의 식대를 요구하지 않습니다.',
                ),
                const SizedBox(height: 16),
                _buildConditionItem(
                  icon: Icons.smoke_free,
                  text: '작업 중 흡연 금지',
                  description: '고객님의 건강과 쾌적한 환경을 위해 작업 중 흡연을 하지 않습니다.',
                ),
                const SizedBox(height: 16),
                _buildConditionItem(
                  icon: Icons.local_police,
                  text: '고객 물품 안전 보장',
                  description: '파손 발생 시 즉시 보상해 드립니다.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 자격증 및 수상 이력 섹션
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.card_membership,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '자격증 및 수상 이력',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이달의 파트너',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2023년 1월',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '우수 파트너 인증',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2023년 상반기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    // 파트너 이름 가져오기
    final String partnerName = _partnerData['compName'] ?? '파트너';
    final List<String> serviceTypes = [];

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

    // 임의의 리뷰 데이터 - 실제 파트너 이름 반영
    final List<Map<String, dynamic>> reviews = [
      {
        'userName': '김** 고객님',
        'rating': 5.0,
        'date': '2023.12.15',
        'content': '정말 깔끔하게 이사를 도와주셨습니다. $partnerName 파트너님이 포장도 꼼꼼하게 해주시고 운반 과정에서도 물건이 전혀 파손되지 않았어요. 직원분들도 친절하셔서 다음에도 이용하고 싶습니다.',
        'serviceType': serviceTypes.isNotEmpty ? serviceTypes[0] : '가정이사',
        'verified': true,
      },
      {
        'userName': '이** 고객님',
        'rating': 4.5,
        'date': '2023.11.28',
        'content': '전반적으로 만족스러웠습니다. $partnerName 파트너님이 시간도 잘 지켜주시고 일처리도 빨랐어요. 다만 일부 가구에 작은 스크래치가 생긴 점이 아쉬웠습니다. 하지만 바로 확인해주시고 적절한 보상을 해주셔서 감사했습니다.',
        'serviceType': serviceTypes.length > 1 ? serviceTypes[1] : (serviceTypes.isNotEmpty ? serviceTypes[0] : '포장이사'),
        'verified': true,
      },
      {
        'userName': '박** 고객님',
        'rating': 5.0,
        'date': '2023.10.05',
        'content': '이사 과정에서 가장 걱정했던 피아노 운반을 $partnerName 파트너님이 아주 안전하게 해주셨어요. 전문가의 손길이 느껴졌습니다. 가격도 합리적이고 서비스도 좋아서 주변에 많이 추천했어요.',
        'serviceType': serviceTypes.isNotEmpty ? serviceTypes[0] : '가정이사',
        'verified': true,
      },
      {
        'userName': '최** 고객님',
        'rating': 4.0,
        'date': '2023.09.22',
        'content': '약속 시간보다 조금 늦게 오셨지만, 그 이후로는 $partnerName 파트너님이 아주 빠르게 진행해주셨어요. 진행 과정을 잘 설명해주시고 고객의 요구사항을 잘 들어주셔서 좋았습니다.',
        'serviceType': serviceTypes.length > 1 ? serviceTypes[1] : (serviceTypes.isNotEmpty ? serviceTypes[0] : '소형이사'),
        'verified': true,
      },
      {
        'userName': '정** 고객님',
        'rating': 5.0,
        'date': '2023.08.17',
        'content': '세 번째 이용인데 역시 $partnerName 파트너님은 실망시키지 않네요. 항상 친절하고 꼼꼼하게 작업해주셔서 감사합니다. 특히 중량물 처리가 정말 전문적이에요.',
        'serviceType': serviceTypes.isNotEmpty ? serviceTypes[0] : '사무실이사',
        'verified': true,
      },
    ];

    // 별점 통계 계산
    double averageRating = reviews.fold(0.0, (sum, review) => sum + (review['rating'] as double)) / reviews.length;
    Map<double, int> ratingCounts = {
      5.0: 0,
      4.5: 0,
      4.0: 0,
      3.5: 0,
      3.0: 0,
    };
    for (var review in reviews) {
      double rating = review['rating'] as double;
      ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 통계 카드
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전체 리뷰',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // 평균 평점
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.floor() ? Icons.star :
                              (index == averageRating.floor() && averageRating % 1 > 0) ? Icons.star_half : Icons.star_border,
                              color: AppTheme.warning,
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reviews.length}개의 리뷰',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // 별점 분포
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar(5.0, ratingCounts[5.0] ?? 0, reviews.length),
                          const SizedBox(height: 8),
                          _buildRatingBar(4.5, ratingCounts[4.5] ?? 0, reviews.length),
                          const SizedBox(height: 8),
                          _buildRatingBar(4.0, ratingCounts[4.0] ?? 0, reviews.length),
                          const SizedBox(height: 8),
                          _buildRatingBar(3.5, ratingCounts[3.5] ?? 0, reviews.length),
                          const SizedBox(height: 8),
                          _buildRatingBar(3.0, ratingCounts[3.0] ?? 0, reviews.length),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 리뷰 필터 섹션
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 18,
                  color: AppTheme.secondaryText,
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: '최신순',
                  underline: Container(),
                  icon: Icon(Icons.arrow_drop_down, color: AppTheme.secondaryText),
                  items: <String>['최신순', '평점 높은순', '평점 낮은순']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // 필터 변경 로직
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '리뷰 작성하기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 리뷰 목록
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewCard(review);
            },
          ),

          const SizedBox(height: 16),

          // 더보기 버튼
          Center(
            child: TextButton(
              onPressed: () {
                // 더 많은 리뷰 보기 로직
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '리뷰 더보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRatingBar(double rating, int count, int total) {
    final double percentage = total > 0 ? count / total : 0;

    return Row(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // 배경 바
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.subtleText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 채워진 바
              Container(
                height: 8,
                width: percentage * MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 헤더
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  review['userName'].substring(0, 1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        review['serviceType'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppTheme.subtleText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (review['verified'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '인증됨',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 별점
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review['rating'].floor() ? Icons.star :
                (index == review['rating'].floor() && review['rating'] % 1 > 0) ? Icons.star_half : Icons.star_border,
                color: AppTheme.warning,
                size: 16,
              );
            }),
          ),

          const SizedBox(height: 12),

          // 리뷰 내용
          Text(
            review['content'],
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.primaryText,
            ),
          ),

          const SizedBox(height: 12),

          // 하단 액션
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                '도움됨',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.report_outlined,
                size: 16,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                '신고',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoTab() {
    // API에서 값이 비어있는 경우 기본값 제공
    final String bussNo = _partnerData['bussNo']?.isNotEmpty == true ? _partnerData['bussNo'] : '123-45-67890';
    final String tel = _partnerData['tel1']?.isNotEmpty == true ? _partnerData['tel1'] : '010-1234-5678';
    final String email = _partnerData['eMail']?.isNotEmpty == true ? _partnerData['eMail'] : 'partner@example.com';
    final String bossName = _partnerData['bossName'] ?? '정보 없음';
    final bool businessVerified = _partnerData['businessVerified'] ?? true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사업자 정보 카드
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '기본 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const Spacer(),
                    if (businessVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 12,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '인증완료',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow('상호명', _partnerData['compName'] ?? '파트너'),
                const Divider(height: 24),
                _buildInfoRow('대표자', bossName),
                const Divider(height: 24),
                _buildInfoRow('사업자등록번호', bussNo),
                const Divider(height: 24),
                _buildInfoRow('연락처', tel),
                const Divider(height: 24),
                _buildInfoRow('이메일', email),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 사업장 위치 정보
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '사업장 위치',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.subtleText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 40,
                          color: AppTheme.subtleText,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '서울특별시 강남구 테헤란로 123',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '디딤돌타워 8층',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 사업자등록증 정보
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '인증 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사업자 인증 완료',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '해당 파트너는 디딤돌에서 사업자 정보를 인증받은 파트너입니다. 안심하고 이용하세요.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield,
                          color: AppTheme.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '신뢰 파트너 인증',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '고객 만족도, 작업 품질, 응답률 등의 기준을 충족한 파트너입니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionItem({
    required IconData icon,
    required String text,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '전화 연결 기능은 준비 중입니다.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      duration: Duration(seconds: 1),
                    ),
                  );
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '견적 상담 요청이 전송되었습니다.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
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