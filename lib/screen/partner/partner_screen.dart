import 'package:MoveSmart/screen/partner/API/partner_api_service.dart';
import 'package:flutter/material.dart';
import 'package:MoveSmart/services/api_service.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'modal/partner_sort.dart';
import 'modal/partner_region.dart';
import 'modal/partner_service.dart';
import 'modal/partner_payment.dart';
import 'partner_detail_screen.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // 필터된 파트너 목록을 캐싱하기 위한 변수들
  List<dynamic>? _cachedFilteredPartners;
  String? _lastSearchQuery;
  String? _lastSelectedRegion;
  String? _lastSelectedService;
  String? _lastPaymentMethod;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 다른 위젯으로 이동 전에 포커스 해제
  void _unfocus() {
    _searchFocusNode.unfocus();
  }

  void _navigateToPartnerDetail(dynamic partner) {
    _unfocus();
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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final fetchedPartners = await PartnerService.fetchPartnersForSearchScreen();

      if (mounted) {
        setState(() {
          _partners = fetchedPartners;
          _isLoading = false;
          // 캐싱된 필터링된 목록 초기화
          _cachedFilteredPartners = null;
        });
      }
    } catch (e) {
      debugPrint("파트너 데이터 로딩 중 오류 발생: $e");
      if (mounted) {
        setState(() {
          _partners = [];
          _isLoading = false;
        });
      }
    }
  }

  // 모든 필터 상태를 한 번에 업데이트하여 불필요한 재빌드 방지
  void _updateFilterState({String? region, String? service, String? paymentMethod, String? sort}) {
    if (!mounted) return;

    setState(() {
      if (region != null) _selectedRegion = region;
      if (service != null) _selectedService = service;
      if (paymentMethod != null) _paymentMethod = paymentMethod;
      if (sort != null) _selectedSort = sort;

      _selectedFilterCount = 0;
      if (_selectedRegion != '지역') _selectedFilterCount++;
      if (_selectedService != '서비스') _selectedFilterCount++;
      if (_paymentMethod != '결제방식') _selectedFilterCount++;

      // 필터 변경 시 캐싱된 필터링된 목록 초기화
      _cachedFilteredPartners = null;
    });
  }

  void _resetFilters() {
    if (!mounted) return;

    setState(() {
      _selectedRegion = '지역';
      _selectedService = '서비스';
      _paymentMethod = '결제방식';
      _selectedFilterCount = 0;
      _searchController.clear();
      _searchQuery = '';

      // 필터 초기화 시 캐싱된 필터링된 목록 초기화
      _cachedFilteredPartners = null;
    });
  }

  Future<void> _selectSortOption() async {
    final selectedSort = await showSortDialog(context, initialSelection: _selectedSort);
    if (selectedSort != null) {
      _updateFilterState(sort: selectedSort);
    }
  }

  Future<void> _selectRegion() async {
    final selectedRegion = await showRegionDialog(
        context,
        initialSelection: _selectedRegion != '지역' ? _selectedRegion : null
    );
    if (selectedRegion != null) {
      _updateFilterState(region: selectedRegion);
    }
  }

  Future<void> _selectService() async {
    final selectedService = await showServiceDialog(context);
    if (selectedService != null) {
      _updateFilterState(service: selectedService);
    }
  }

  Future<void> _selectPaymentMethod() async {
    final selectedPayment = await showPaymentDialog(context);
    if (selectedPayment != null) {
      _updateFilterState(paymentMethod: selectedPayment);
    }
  }

  // 메모이제이션을 활용한 필터링된 파트너 목록 getter
  List<dynamic> get _filteredPartners {
    // 상태가 이전과 동일하면 캐싱된 결과 반환
    if (_cachedFilteredPartners != null &&
        _lastSearchQuery == _searchQuery &&
        _lastSelectedRegion == _selectedRegion &&
        _lastSelectedService == _selectedService &&
        _lastPaymentMethod == _paymentMethod) {
      return _cachedFilteredPartners!;
    }

    // 상태가 변경되었으면 새로 필터링
    final filteredList = _partners.where((partner) {
      // 검색어 필터링
      final companyName = partner['compName'] ?? '';
      final searchMatch = _searchQuery.isEmpty ||
          companyName.toLowerCase().contains(_searchQuery.toLowerCase());

      // 지역 필터링
      final regionMatch = _selectedRegion == '지역' ||
          (partner['regionNm'] ?? '') == _selectedRegion;

      // 서비스 필터링
      bool serviceMatch = _selectedService == '서비스';
      if (!serviceMatch && partner['serviceData'] != null && partner['serviceData'] is List) {
        serviceMatch = partner['serviceData'].any((service) =>
        (service['serviceNm'] ?? '') == _selectedService);
      }

      // 결제 방식 필터링
      bool paymentMatch = _paymentMethod == '결제방식';
      if (!paymentMatch) {
        final hasEasyPayment = partner['easyPayment'] == true ||
            (partner['paymentData'] != null &&
                partner['paymentData'].contains(_paymentMethod));
        paymentMatch = _paymentMethod == '간편결제' ? hasEasyPayment : !hasEasyPayment;
      }

      return searchMatch && regionMatch && serviceMatch && paymentMatch;
    }).toList();

    // 현재 상태 저장 및 결과 캐싱
    _lastSearchQuery = _searchQuery;
    _lastSelectedRegion = _selectedRegion;
    _lastSelectedService = _selectedService;
    _lastPaymentMethod = _paymentMethod;
    _cachedFilteredPartners = filteredList;

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _unfocus();
        return true;
      },
      child: GestureDetector(
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
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            // 검색어 변경 시 캐싱된 필터링된 목록 초기화
            _cachedFilteredPartners = null;
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
                _buildFilterChip(
                  icon: Icons.sort,
                  label: _selectedSort,
                  isSelected: true, // 항상 선택됨
                  onTap: _selectSortOption,
                ),

                // 초기화 필터
                if (_selectedFilterCount > 0)
                  _buildFilterChip(
                    icon: Icons.refresh,
                    label: '초기화 $_selectedFilterCount',
                    isSelected: false,
                    onTap: _resetFilters,
                    useSubtleColors: true,
                  ),

                // 지역 필터
                _buildFilterChip(
                  icon: Icons.place,
                  label: _selectedRegion,
                  isSelected: _selectedRegion != '지역',
                  onTap: _selectRegion,
                ),

                // 서비스 필터
                _buildFilterChip(
                  icon: Icons.category,
                  label: _selectedService,
                  isSelected: _selectedService != '서비스',
                  onTap: _selectService,
                ),

                // 결제 방식 필터
                _buildFilterChip(
                  icon: Icons.payment,
                  label: _paymentMethod,
                  isSelected: _paymentMethod != '결제방식',
                  onTap: _selectPaymentMethod,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 필터 칩 위젯 - 코드 중복 제거
  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool useSubtleColors = false,
  }) {
    final Color bgColor = useSubtleColors
        ? AppTheme.subtleText.withOpacity(0.1)
        : isSelected
        ? AppTheme.primaryColor.withOpacity(0.1)
        : AppTheme.subtleText.withOpacity(0.1);

    final Color textColor = useSubtleColors
        ? AppTheme.secondaryText
        : isSelected
        ? AppTheme.primaryColor
        : AppTheme.secondaryText;

    final BorderSide borderSide = useSubtleColors
        ? BorderSide.none
        : isSelected
        ? BorderSide(color: AppTheme.primaryColor.withOpacity(0.3))
        : BorderSide(color: AppTheme.borderSubColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(borderSide),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: textColor,
            ),
          ],
        ),
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
    // 필요한 데이터 추출
    final String companyName = partner['compName'] ?? '파트너';
    final String bossName = partner['bossName'] ?? '';
    final bool hasEasyPayment = partner['easyPayment'] == true;

    // 이미지 URL 가져오기
    String imageUrl = 'https://via.placeholder.com/150';
    if (partner['imgData'] != null &&
        partner['imgData'] is List &&
        partner['imgData'].isNotEmpty &&
        partner['imgData'][0]['imgUrl'] != null) {
      imageUrl = partner['imgData'][0]['imgUrl'];
    }

    return GestureDetector(
      onTap: () => _navigateToPartnerDetail(partner),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          // Border 설정 제거
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 파트너 프로필 이미지 - CachedNetworkImage 사용
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.subtleText.withOpacity(0.1),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.subtleText.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.subtleText,
                    ),
                  ),
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
                        Expanded(
                          child: Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
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