import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

Future<String?> showRegionDialog(BuildContext context, {String? initialSelection}) {
  final Map<String, List<String>> regions = {
    '전체': ['전국(전체)'],
    '서울': ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'],
    '경기': ['수원시', '성남시', '고양시', '용인시', '부천시', '안산시', '안양시', '남양주시', '화성시', '평택시', '의정부시', '시흥시', '파주시', '광명시', '김포시', '군포시', '광주시', '이천시', '양주시', '오산시', '구리시', '안성시', '포천시', '의왕시', '하남시', '여주시', '동두천시', '과천시', '연천군', '가평군', '양평군'],
    '인천': ['미추홀구', '연수구', '남동구', '부평구', '계양구', '서구', '동구', '중구', '강화군', '옹진군'],
    '대전': ['동구', '중구', '서구', '유성구', '대덕구'],
    '부산': ['해운대구', '수영구', '연제구', '사하구', '강서구', '금정구', '기장군', '남구', '동구', '동래구', '부산진구', '북구', '사상구', '서구', '영도구', '중구'],
    '대구': ['남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구'],
    '울산': ['남구', '동구', '북구', '중구', '울주군'],
    '광주': ['광산구', '남구', '동구', '북구', '서구'],
    '세종': ['세종특별자치시'],
    '강원': ['강릉시', '고성군', '동해시', '삼척시', '속초시', '양구군', '양양군', '영월군', '원주시', '인제군', '정선군', '철원군', '춘천시', '태백시', '평창군', '홍천군', '화천군', '횡성군'],
    '충북': ['제천시', '청주시', '충주시', '괴산군', '단양군', '보은군', '영동군', '옥천군', '음성군', '증평군', '진천군'],
    '충남': ['계룡시', '공주시', '논산시', '당진시', '보령시', '서산시', '아산시', '천안시', '금산군', '부여군', '서천군', '예산군', '청양군', '태안군', '홍성군'],
    '전북': ['군산시', '김제시', '남원시', '익산시', '전주시', '정읍시', '고창군', '무주군', '부안군', '순창군', '완주군', '임실군', '장수군', '진안군'],
    '전남': ['광양시', '나주시', '목포시', '순천시', '여수시', '강진군', '고흥군', '곡성군', '구례군', '담양군', '무안군', '보성군', '신안군', '영광군', '영암군', '완도군', '장성군', '장흥군', '진도군', '함평군', '해남군', '화순군'],
    '경북': ['경산시', '경주시', '구미시', '김천시', '문경시', '상주시', '안동시', '영주시', '영천시', '포항시', '고령군', '군위군', '봉화군', '성주군', '영덕군', '영양군', '예천군', '울릉군', '울진군', '의성군', '청도군', '청송군', '칠곡군'],
    '경남': ['거제시', '김해시', '밀양시', '사천시', '양산시', '진주시', '창원시', '통영시', '거창군', '고성군', '남해군', '산청군', '의령군', '창녕군', '하동군', '함안군', '함양군', '합천군'],
    '제주': ['서귀포시', '제주시'],
  };

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      // 초기 선택을 파싱
      String? selectedRegion;
      String? selectedDistrict;

      // 초기 선택값이 있다면 파싱
      if (initialSelection != null && initialSelection != '지역') {
        final parts = initialSelection.split(' ');
        if (parts.length > 0) {
          selectedRegion = parts[0];
          if (parts.length > 1) {
            selectedDistrict = parts.sublist(1).join(' ');
          }
        }
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          // 선택된 값이 없으면 기본값으로 설정
          if (selectedRegion == null) {
            selectedRegion = '전체';
            selectedDistrict = '전국(전체)';
          }
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: Column(
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // 타이틀
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        '지역 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(width: 48), // 더미 공간으로 제목 중앙 정렬
                    ],
                  ),
                ),

                // 안내 문구
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '지역 선택 안내',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '원하시는 지역을 선택하면 해당 지역에서 활동하는 파트너를 찾을 수 있습니다.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 지역 선택 컨테이너
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 왼쪽에 큰 지역 (서울, 경기 등)
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBackground,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: regions.keys.length,
                            itemBuilder: (BuildContext context, int index) {
                              String region = regions.keys.elementAt(index);
                              bool isSelected = selectedRegion == region;

                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.scaffoldBackground,
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    region,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.secondaryText,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedRegion = region;
                                      selectedDistrict = null;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // 수직 구분선
                        Container(
                          width: 1,
                          color: AppTheme.borderColor,
                        ),

                        // 오른쪽에 선택된 큰 지역의 행정구역 (구, 군 등)
                        Expanded(
                          child: selectedRegion == null
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 48,
                                  color: AppTheme.subtleText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '지역을 선택해주세요',
                                  style: TextStyle(
                                    color: AppTheme.secondaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            itemCount: regions[selectedRegion]!.length,
                            itemBuilder: (BuildContext context, int index) {
                              String district = regions[selectedRegion]![index];
                              bool isSelected = selectedDistrict == district;

                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withOpacity(0.05)
                                      : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.borderColor.withOpacity(0.5),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    district,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryText,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedDistrict = district;
                                    });
                                    // 선택 완료 후 화면 닫고 결과 반환
                                    Navigator.pop(context, '$selectedRegion $selectedDistrict');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 하단 버튼
// 하단 버튼
                SafeArea(
                  bottom: true,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedRegion != null ? () {
                              if (selectedDistrict != null) {
                                Navigator.pop(context, '$selectedRegion $selectedDistrict');
                              } else if (regions[selectedRegion]!.isNotEmpty) {
                                // 구/군을 선택하지 않았으면 첫 번째 구/군을 자동 선택
                                Navigator.pop(context, '$selectedRegion ${regions[selectedRegion]![0]}');
                              } else {
                                Navigator.pop(context, selectedRegion);
                              }
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              disabledBackgroundColor: AppTheme.subtleText,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              '선택 완료',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}