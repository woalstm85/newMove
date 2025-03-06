import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/theme_constants.dart';

class PostcodeSearchScreen extends StatefulWidget {
  const PostcodeSearchScreen({Key? key}) : super(key: key);

  @override
  _PostcodeSearchScreenState createState() => _PostcodeSearchScreenState();
}

class _PostcodeSearchScreenState extends State<PostcodeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreResults = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // 키보드 자동 표시
    Future.delayed(Duration(milliseconds: 300), () {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMoreResults) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _searchAddress() async {
    final String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _errorMessage = '검색어를 입력해주세요';
        _searchResults = [];
      });
      return;
    }

    if (keyword.length < 2) {
      setState(() {
        _errorMessage = '검색어는 2글자 이상 입력해주세요';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentPage = 1;
    });

    try {
      final results = await _fetchAddressResults(keyword, 1);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _hasMoreResults = results.length >= 10; // 10개 이상이면 더 있을 수 있음
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '주소 검색 중 오류가 발생했습니다: $e';
        _searchResults = [];
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final moreResults = await _fetchAddressResults(_searchController.text.trim(), nextPage);

      setState(() {
        _currentPage = nextPage;
        _searchResults.addAll(moreResults);
        _hasMoreResults = moreResults.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '더 많은 결과를 불러오는 중 오류가 발생했습니다';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAddressResults(String keyword, int page) async {
    // 행정안전부 주소 검색 API URL
    const String apiUrl = 'https://www.juso.go.kr/addrlink/addrLinkApi.do';

    // API 키 (실제 사용 시 발급받은 키로 변경 필요)
    const String apiKey = 'devU01TX0FVVEgyMDI1MDMwNjEyMDIyMTExNTUyNDk=';  // 발급받은 API 키로 교체 필요

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {
        'confmKey': apiKey,
        'currentPage': page.toString(),
        'countPerPage': '10',
        'keyword': keyword,
        'resultType': 'json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      if (data['results']['common']['errorCode'] == '0') {
        final List<dynamic> juso = data['results']['juso'];

        return juso.map((address) => {
          'roadAddress': address['roadAddr'],
          'jibunAddress': address['jibunAddr'],
          'buildingName': address['bdNm'],
          'zonecode': address['zipNo'],
        }).toList();
      } else {
        throw Exception(data['results']['common']['errorMessage']);
      }
    } else {
      throw Exception('주소 검색 API 요청 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      fontSize: 14,
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
                            fontSize: 14,
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
                              color: AppTheme.primaryColor,
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
                          backgroundColor: AppTheme.primaryColor,
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
                        fontSize: 12,
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
                          fontSize: 16,
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
                    final String roadAddress = address['roadAddress'] ?? '';
                    final String jibunAddress = address['jibunAddress'] ?? '';
                    final String buildingName = address['buildingName'] ?? '';
                    final String zonecode = address['zonecode'] ?? '';

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, address);
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
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '도로명',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '[${zonecode}]',
                                  style: TextStyle(
                                    fontSize: 12,
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            if (buildingName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                buildingName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryColor,
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
                                      fontSize: 11,
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
                                      fontSize: 13,
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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