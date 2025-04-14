import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/services/address_service.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';

class PostcodeSearchScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const PostcodeSearchScreen({Key? key, required this.isRegularMove}) : super(key: key);

  @override
  ConsumerState<PostcodeSearchScreen> createState() => _PostcodeSearchScreenState();
}

class _PostcodeSearchScreenState extends ConsumerState<PostcodeSearchScreen> with MoveFlowMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // MoveFlowMixin의 isRegularMove 설정 추가
    isRegularMove = widget.isRegularMove;

    _scrollController.addListener(_scrollListener);

    // 키보드 자동 표시
    Future.delayed(Duration(milliseconds: 300), () {
      _searchFocusNode.requestFocus();
    });

    // 위젯 트리 빌드 후에 Provider 상태 초기화
    Future.microtask(() {
      if (mounted) {
        ref.read(addressServiceProvider.notifier).reset();
      }
    });

    // 검색 컨트롤러에 리스너 추가 (디바운싱)
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(addressServiceProvider.notifier).searchAddressWithDebounce(
      _searchController.text.trim(),
    );
  }

  void _scrollListener() {
    final state = ref.read(addressServiceProvider);
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (state.hasMoreResults && !state.isLoading) {
        ref.read(addressServiceProvider.notifier).loadMoreResults();
      }
    }
  }

  void _searchAddress() {
    final String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      return;
    }

    ref.read(addressServiceProvider.notifier).searchAddress(keyword);
  }

  // 최근 검색 주소 위젯
  Widget _buildRecentAddresses() {
    final recentAddresses = ref.watch(addressServiceProvider).recentAddressesList;

    if (recentAddresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색 주소',
                style: TextStyle(
                  fontSize: context.scaledFontSize(14),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(addressServiceProvider.notifier).clearRecentAddresses();
                },
                child: Text(
                  '전체 삭제',
                  style: TextStyle(
                    fontSize: context.scaledFontSize(12),
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentAddresses.length,
            itemBuilder: (context, index) {
              final address = recentAddresses[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, {
                    'roadAddress': address.roadAddress,
                    'jibunAddress': address.jibunAddress,
                    'buildingName': address.buildingName,
                    'zonecode': address.zipCode,
                  });
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.roadAddress,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(14),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.buildingName.isNotEmpty
                            ? '(${address.buildingName})'
                            : '',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(12),
                          color: AppTheme.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 상태 구독
    final addressState = ref.watch(addressServiceProvider);
    final _searchResults = addressState.searchResults;
    final _isLoading = addressState.isLoading;
    final _errorMessage = addressState.errorMessage ?? '';
    final _hasMoreResults = addressState.hasMoreResults;
    final _searchStatus = addressState.searchStatus;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '주소 검색',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '도로명, 건물명, 지번으로 검색하세요',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(14),
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: '예) 테헤란로 123, 디딤빌딩',
                          hintStyle: TextStyle(
                            color: AppTheme.subtleText,
                            fontSize: context.scaledFontSize(14),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchAddress(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('검색'),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: context.scaledFontSize(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 검색 결과 리스트 또는 안내 메시지
          Expanded(
            child: Stack(
              children: [
                _searchResults.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: AppTheme.subtleText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage.isEmpty ? '검색어를 입력하여 주소를 검색하세요' : _errorMessage,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(16),
                          color: AppTheme.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: _scrollController,
                  itemCount: _searchResults.length + (_hasMoreResults ? 1 : 0),
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == _searchResults.length) {
                      return _hasMoreResults
                          ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : const SizedBox.shrink();
                    }

                    final address = _searchResults[index];
                    final String roadAddress = address.roadAddress;
                    final String jibunAddress = address.jibunAddress;
                    final String buildingName = address.buildingName;
                    final String zonecode = address.zipCode;

                    return InkWell(
                      onTap: () {
                        // 전환할 때는 맵 형태로 변환
                        Navigator.pop(context, {
                          'roadAddress': roadAddress,
                          'jibunAddress': jibunAddress,
                          'buildingName': buildingName,
                          'zonecode': zonecode,
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '도로명',
                                    style: TextStyle(
                                      fontSize: context.scaledFontSize(11),
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '[${zonecode}]',
                                  style: TextStyle(
                                    fontSize: context.scaledFontSize(12),
                                    color: AppTheme.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              roadAddress,
                              style: TextStyle(
                                fontSize: context.scaledFontSize(15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            if (buildingName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                buildingName,
                                style: TextStyle(
                                  fontSize: context.scaledFontSize(13),
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '지번',
                                    style: TextStyle(
                                      fontSize: context.scaledFontSize(11),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    jibunAddress,
                                    style: TextStyle(
                                      fontSize: context.scaledFontSize(13),
                                      color: AppTheme.secondaryText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_isLoading && _searchResults.isEmpty)
                  Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
}