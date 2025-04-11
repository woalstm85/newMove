import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// AddressService 프로바이더
final addressServiceProvider = StateNotifierProvider<AddressServiceNotifier, AddressServiceState>((ref) {
  return AddressServiceNotifier();
});

// 상태 클래스
class AddressServiceState {
  final List<AddressResult> searchResults;
  final List<AddressResult> recentAddressesList;
  final String keyword;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMoreResults;
  final int currentPage;
  final SearchStatus searchStatus;

  AddressServiceState({
    this.searchResults = const [],
    this.recentAddressesList = const [],
    this.keyword = '',
    this.isLoading = false,
    this.errorMessage,
    this.hasMoreResults = false,
    this.currentPage = 1,
    this.searchStatus = SearchStatus.initial,
  });

  AddressServiceState copyWith({
    List<AddressResult>? searchResults,
    List<AddressResult>? recentAddressesList,
    String? keyword,
    bool? isLoading,
    String? errorMessage,
    bool? hasMoreResults,
    int? currentPage,
    SearchStatus? searchStatus,
  }) {
    return AddressServiceState(
      searchResults: searchResults ?? this.searchResults,
      recentAddressesList: recentAddressesList ?? this.recentAddressesList,
      keyword: keyword ?? this.keyword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
      currentPage: currentPage ?? this.currentPage,
      searchStatus: searchStatus ?? this.searchStatus,
    );
  }
}

// 검색 상태 열거형 추가
enum SearchStatus {
  initial,
  loading,
  success,
  noResults,
  error
}

// 주소 검색 결과를 위한 모델 클래스
class AddressResult {
  final String roadAddress;
  final String jibunAddress;
  final String buildingName;
  final String zipCode;

  AddressResult({
    required this.roadAddress,
    required this.jibunAddress,
    required this.buildingName,
    required this.zipCode,
  });

  // Map에서 객체 생성
  factory AddressResult.fromJson(Map<String, dynamic> json) {
    return AddressResult(
      roadAddress: json['roadAddress'] ?? '',
      jibunAddress: json['jibunAddress'] ?? '',
      buildingName: json['buildingName'] ?? '',
      zipCode: json['zonecode'] ?? '',
    );
  }

  // 객체를 Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'roadAddress': roadAddress,
      'jibunAddress': jibunAddress,
      'buildingName': buildingName,
      'zipCode': zipCode,
    };
  }

  // 전체 주소 (도로명 + 건물명)
  String get fullAddress {
    if (buildingName.isNotEmpty) {
      return '$roadAddress ($buildingName)';
    }
    return roadAddress;
  }
}

// 주소 검색 서비스 StateNotifier
class AddressServiceNotifier extends StateNotifier<AddressServiceState> {
  Timer? _debounceTimer;
  final _searchCache = <String, List<AddressResult>>{};
  static const String _recentAddressesKey = 'recent_search_addresses';
  static const int _maxRecentAddresses = 5;
  static const _debounceDuration = Duration(milliseconds: 500);

  AddressServiceNotifier() : super(AddressServiceState()) {
    _loadRecentAddresses();
  }

  // .env에서 API 키 가져오기
  String get _apiKey => dotenv.env['ADDRESS_API_KEY'] ?? '';
  String get _apiUrl => 'https://www.juso.go.kr/addrlink/addrLinkApi.do';

  // 최근 검색 주소 로드
  Future<void> _loadRecentAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedAddresses = prefs.getString(_recentAddressesKey);

      if (savedAddresses != null) {
        final List<dynamic> decoded = jsonDecode(savedAddresses);
        final recentAddresses = decoded
            .map((item) => AddressResult.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        state = state.copyWith(recentAddressesList: recentAddresses);
      }
    } catch (e) {
      debugPrint('최근 검색 주소 로드 오류: $e');
    }
  }

  // 최근 검색 주소 저장
  Future<void> _saveRecentAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> addressesJson =
      state.recentAddressesList.map((address) => address.toJson()).toList();
      await prefs.setString(_recentAddressesKey, jsonEncode(addressesJson));
    } catch (e) {
      debugPrint('최근 검색 주소 저장 오류: $e');
    }
  }

  // 디바운싱 기능이 추가된 주소 검색 메서드
  void searchAddressWithDebounce(String keyword) {
    // 이전 타이머 취소
    _debounceTimer?.cancel();

    // 검색어가 너무 짧은 경우 즉시 상태 업데이트
    if (keyword.length < 2) {
      state = state.copyWith(
        errorMessage: '검색어는 2글자 이상 입력해주세요',
        searchResults: [],
        searchStatus: SearchStatus.initial,
      );
      return;
    }

    // 새 타이머 생성
    _debounceTimer = Timer(_debounceDuration, () {
      searchAddress(keyword);
    });
  }

  // 최근 검색 주소에 추가
  Future<void> addToRecentAddresses(AddressResult address) async {
    // 이미 존재하는 같은 주소가 있으면 제거
    final newList = [...state.recentAddressesList];
    newList.removeWhere((a) => a.roadAddress == address.roadAddress);

    // 최근 검색 주소 목록 앞에 추가
    newList.insert(0, address);

    // 최대 개수 유지
    if (newList.length > _maxRecentAddresses) {
      newList.removeRange(_maxRecentAddresses, newList.length);
    }

    // 상태 업데이트
    state = state.copyWith(recentAddressesList: newList);

    // 저장
    await _saveRecentAddresses();
  }

  // 최근 검색 주소 삭제
  Future<void> removeRecentAddress(int index) async {
    if (index >= 0 && index < state.recentAddressesList.length) {
      final newList = [...state.recentAddressesList];
      newList.removeAt(index);

      state = state.copyWith(recentAddressesList: newList);
      await _saveRecentAddresses();
    }
  }

  // 모든 최근 검색 주소 삭제
  Future<void> clearRecentAddresses() async {
    state = state.copyWith(recentAddressesList: []);
    await _saveRecentAddresses();
  }

  // 주소 검색 실행
  Future<void> searchAddress(String keyword) async {
    // 이전 타이머 취소
    _debounceTimer?.cancel();

    // 이전 검색 정보 초기화
    state = state.copyWith(
      keyword: keyword,
      currentPage: 1,
      errorMessage: null,
      isLoading: true,
      searchStatus: SearchStatus.loading,
    );

    // 캐시에 있는지 확인
    if (_searchCache.containsKey(keyword)) {
      state = state.copyWith(
        searchResults: _searchCache[keyword]!,
        hasMoreResults: _searchCache[keyword]!.length >= 10,
        isLoading: false,
        searchStatus: _searchCache[keyword]!.isEmpty
            ? SearchStatus.noResults
            : SearchStatus.success,
      );
      return;
    }

    try {
      final results = await _fetchAddressResults(keyword, 1);

      // 상태 업데이트
      state = state.copyWith(
        searchResults: results,
        hasMoreResults: results.length >= 10,
        isLoading: false,
        searchStatus: results.isEmpty
            ? SearchStatus.noResults
            : SearchStatus.success,
      );

      // 결과 캐시에 저장
      _searchCache[keyword] = results;
    } catch (e) {
      state = state.copyWith(
        errorMessage: '주소 검색 중 오류가 발생했습니다: $e',
        searchResults: [],
        isLoading: false,
        searchStatus: SearchStatus.error,
      );
    }
  }

  // 검색 재시도 메서드 추가
  void retrySearch() {
    if (state.keyword.isNotEmpty) {
      searchAddress(state.keyword);
    }
  }

  // 더 많은 결과 로드
  Future<void> loadMoreResults() async {
    if (state.isLoading || !state.hasMoreResults) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final moreResults = await _fetchAddressResults(state.keyword, nextPage);

      final allResults = [...state.searchResults, ...moreResults];

      state = state.copyWith(
        currentPage: nextPage,
        searchResults: allResults,
        hasMoreResults: moreResults.length >= 10,
        isLoading: false,
      );

      // 캐시 업데이트
      if (_searchCache.containsKey(state.keyword)) {
        _searchCache[state.keyword] = allResults;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '더 많은 결과를 불러오는 중 오류가 발생했습니다',
        isLoading: false,
      );
    }
  }

  // API 호출하여 주소 결과 가져오기
  Future<List<AddressResult>> _fetchAddressResults(String keyword, int page) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {
        'confmKey': _apiKey,
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

        return juso.map((address) => AddressResult.fromJson({
          'roadAddress': address['roadAddr'],
          'jibunAddress': address['jibunAddr'],
          'buildingName': address['bdNm'],
          'zonecode': address['zipNo'],
        })).toList();
      } else {
        throw Exception(data['results']['common']['errorMessage']);
      }
    } else {
      throw Exception('주소 검색 API 요청 실패: ${response.statusCode}');
    }
  }

  // 검색 초기화
  void reset() {
    state = state.copyWith(
      searchResults: [],
      keyword: '',
      errorMessage: null,
      hasMoreResults: false,
      currentPage: 1,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}