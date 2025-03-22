import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/theme_constants.dart';
import '../modal/partner_modal/partner_sort.dart';
import '../modal/partner_modal/partner_region.dart';
import '../modal/partner_modal/partner_service.dart';
import '../modal/partner_modal/partner_payment.dart';
import 'partner_detail_screen.dart';
import '../utils/ui_extensions.dart';

class PartnerSearchScreen extends StatefulWidget {
  const PartnerSearchScreen({super.key});

  @override
  _PartnerSearchScreenState createState() => _PartnerSearchScreenState();
}

class _PartnerSearchScreenState extends State<PartnerSearchScreen> {
  String _selectedSort = '리뷰 많은 순';
  String _selectedRegion = '지역';
  String _selectedService = '서비스';
  String _paymentMethod = '결제방식';
  int _selectedFilterCount = 0;
  bool _isLoading = true;
  List<dynamic> _partners = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  // 다른 위젯으로 이동 전에 포커스 해제
  void _unfocus() {
    _searchFocusNode.unfocus();
  }

  void _navigateToPartnerDetail(dynamic partner) {
    _unfocus(); // 화면 전환 전 포커스 해제
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerDetailScreen(
          partnerId: partner['compCd'] ?? '',
        ),
      ),
    );
  }

  Future<void> _fetchPartners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 새로운 파트너 검색 전용 API 함수 사용
      final fetchedPartners = await ApiService.fetchPartnersForSearchScreen();

      setState(() {
        _partners = fetchedPartners;
        _isLoading = false;
      });
    } catch (e) {
      print("파트너 데이터 로딩 중 오류 발생: $e");
      setState(() {
        _partners = [];
        _isLoading = false;
      });
    }
  }

  void _updateFilterState({String? region, String? service, String? paymentMethod}) {
    setState(() {
      _selectedRegion = region ?? _selectedRegion;
      _selectedService = service ?? _selectedService;
      _paymentMethod = paymentMethod ?? _paymentMethod;

      _selectedFilterCount = 0;
      if (_selectedRegion != '지역') _selectedFilterCount++;
      if (_selectedService != '서비스') _selectedFilterCount++;
      if (_paymentMethod != '결제방식') _selectedFilterCount++;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedRegion = '지역';
      _selectedService = '서비스';
      _paymentMethod = '결제방식';
      _selectedFilterCount = 0;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _selectSortOption() async {
    final selectedSort = await showSortDialog(context, initialSelection: _selectedSort);
    if (selectedSort != null) {
      setState(() {
        _selectedSort = selectedSort;
      });
      // 여기에 정렬 로직 추가
    }
  }

  void _selectRegion() async {
    // 현재 선택된 지역을 초기값으로 전달
    final selectedRegion = await showRegionDialog(
        context,
        initialSelection: _selectedRegion != '지역' ? _selectedRegion : null
    );
    if (selectedRegion != null) {
      setState(() {
        _selectedRegion = selectedRegion;
        _updateFilterState(region: selectedRegion);
      });
    }
  }

  void _selectService() async {
    final selectedService = await showServiceDialog(context);
    if (selectedService != null) {
      _updateFilterState(service: selectedService);
    }
  }

  void _selectPaymentMethod() async {
    final selectedPayment = await showPaymentDialog(context);
    if (selectedPayment != null) {
      _updateFilterState(paymentMethod: selectedPayment);
    }
  }

  List<dynamic> get _filteredPartners {
    return _partners.where((partner) {
      // 검색어 필터링
      final companyName = partner['compName'] ?? '';
      final searchMatch = _searchQuery.isEmpty ||
          companyName.toLowerCase().contains(_searchQuery.toLowerCase());

      // 지역 필터링
      final regionMatch = _selectedRegion == '지역' ||
          (partner['regionNm'] ?? '') == _selectedRegion;

      // 서비스 필터링
      bool serviceMatch = _selectedService == '서비스';
      if (_selectedService != '서비스' && partner['serviceData'] != null && partner['serviceData'] is List) {
        serviceMatch = partner['serviceData'].any((service) =>
        (service['serviceNm'] ?? '') == _selectedService);
      }

      // 결제 방식 필터링
      bool paymentMatch = _paymentMethod == '결제방식';
      if (_paymentMethod != '결제방식') {
        // 간편결제 여부 체크 (데이터 구조에 따라 수정 필요)
        final hasEasyPayment = partner['easyPayment'] == true ||
            (partner['paymentData'] != null &&
                partner['paymentData'].contains(_paymentMethod));
        paymentMatch = _paymentMethod == '간편결제' ? hasEasyPayment : !hasEasyPayment;
      }

      return searchMatch && regionMatch && serviceMatch && paymentMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // 뒤로 가기 버튼 눌렀을 때 포커스 해제
          _unfocus();
          return true; // 기본 뒤로 가기 동작 수행
        },
        child: GestureDetector(
        // 화면의 빈 공간 터치 시 포커스 해제
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          appBar: AppBar(
            title: const Text(
              '파트너 찾기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppTheme.primaryText),
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _partners.isEmpty
                    ? _buildEmptyState()
                    : _buildPartnerList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode, // 추가된 FocusNode 사용
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: '2글자 이상 입력하여 파트너 검색',
          hintStyle: TextStyle(color: AppTheme.subtleText),
          prefixIcon: Icon(Icons.search, color: AppTheme.secondaryText),
          filled: true,
          fillColor: AppTheme.scaffoldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필터 타이틀
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Text(
                  '검색 필터',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // 필터 칩 그룹
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 리뷰 많은 순 필터
                GestureDetector(
                  onTap: _selectSortOption,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedSort,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                // 초기화 필터
                if (_selectedFilterCount > 0)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.subtleText.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: AppTheme.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '초기화 $_selectedFilterCount',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 지역 필터
                GestureDetector(
                  onTap: _selectRegion,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedRegion != '지역'
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.subtleText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: _selectedRegion != '지역'
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                          : Border.all(color: AppTheme.borderSubColor)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.place,
                          size: 16,
                          color: _selectedRegion != '지역'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedRegion,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedRegion != '지역' ? FontWeight.w600 : FontWeight.w500,
                            color: _selectedRegion != '지역'
                                ? AppTheme.primaryColor
                                : AppTheme.secondaryText,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: _selectedRegion != '지역'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),

                // 서비스 필터
                GestureDetector(
                  onTap: _selectService,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedService != '서비스'
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.subtleText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: _selectedService != '서비스'
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                          : Border.all(color: AppTheme.borderSubColor)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: _selectedService != '서비스'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedService,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedService != '서비스' ? FontWeight.w600 : FontWeight.w500,
                            color: _selectedService != '서비스'
                                ? AppTheme.primaryColor
                                : AppTheme.secondaryText,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: _selectedService != '서비스'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),

                // 결제 방식 필터
                GestureDetector(
                  onTap: _selectPaymentMethod,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _paymentMethod != '결제방식'
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.subtleText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: _paymentMethod != '결제방식'
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                          : Border.all(color: AppTheme.borderSubColor)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 16,
                          color: _paymentMethod != '결제방식'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _paymentMethod,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _paymentMethod != '결제방식' ? FontWeight.w600 : FontWeight.w500,
                            color: _paymentMethod != '결제방식'
                                ? AppTheme.primaryColor
                                : AppTheme.secondaryText,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: _paymentMethod != '결제방식'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            '파트너를 불러오는 중입니다...',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
          Text(
            '파트너 정보를 찾을 수 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '필터를 초기화하거나 다른 검색어로 시도해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.subtleText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetFilters,
            style: AppTheme.primaryButtonStyle,
            child: const Text('필터 초기화'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerList() {
    final filteredList = _filteredPartners;

    return filteredList.isEmpty
        ? _buildNoResultsState()
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final partner = filteredList[index];
        return _buildPartnerCard(partner);
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '검색어나 필터를 변경해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.subtleText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(dynamic partner) {
    // 서비스 정보 가져오기
    String serviceType = '';
    if (partner['serviceData'] != null &&
        partner['serviceData'] is List &&
        partner['serviceData'].isNotEmpty) {
      serviceType = partner['serviceData'][0]['serviceNm'] ?? '';
    }

    // 이미지 URL 가져오기
    String imageUrl = 'https://via.placeholder.com/150';
    if (partner['imgData'] != null &&
        partner['imgData'] is List &&
        partner['imgData'].isNotEmpty &&
        partner['imgData'][0]['imgUrl'] != null) {
      imageUrl = partner['imgData'][0]['imgUrl'];
    }

    // 간편 결제 여부 (실제 데이터에 없으면 기본값 사용)
    bool hasEasyPayment = partner['easyPayment'] == true;

    // 경험(연차) 정보 (실제 데이터에 없으면 기본값 사용)
    String experience = partner['experience'] ?? '경력 정보 없음';

    // 완료 작업 및 리뷰 수 (실제 데이터에 없으면 기본값 사용)
    int completedJobs = partner['completedJobs'] ?? 0;
    int reviewCount = partner['reviewCount'] ?? 0;

    // 평점 (실제 데이터에 없으면 기본값 사용)
    double rating = partner['rating'] != null
        ? (partner['rating'] is int
        ? partner['rating'].toDouble()
        : partner['rating'])
        : 4.5; // 기본 평점

    // 회사명
    String companyName = partner['compName'] ?? '파트너';

    // 대표자명
    String bossName = partner['bossName'] ?? '';

    return GestureDetector(
      onTap: () {
        // 터치 시 포커스 해제 후 이동
        _unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDetailScreen(
              partnerId: partner['compCd'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: context.cardDecoration(borderColor: AppTheme.borderSubColor),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 파트너 프로필 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 파트너 이름과 간편결제 배지
                    Row(
                      children: [
                        Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        if (hasEasyPayment)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '간편결제',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 대표자명 (있을 경우)
                    if (bossName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '대표: $bossName',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // 평점 및 실적 정보 - 실제 데이터에 없을 경우 표시 안함
                    if (false) // 실제 데이터에 없으므로 숨김 처리
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.warning, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                          Expanded(
                            child: Text(
                              '완료 ${completedJobs}건 • 리뷰 ${reviewCount}건',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // 제공 서비스 태그
                    if (partner['serviceData'] != null && partner['serviceData'] is List)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var service in partner['serviceData'])
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                service['serviceNm'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
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
      ),
    );
  }
}