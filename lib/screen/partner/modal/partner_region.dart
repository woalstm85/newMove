import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/partner/api/area_api_service.dart';

Future<String?> showRegionDialog(BuildContext context, {String? initialSelection}) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _RegionSelectionDialog(initialSelection: initialSelection);
    },
  );
}

class _RegionSelectionDialog extends StatefulWidget {
  final String? initialSelection;

  const _RegionSelectionDialog({this.initialSelection});

  @override
  _RegionSelectionDialogState createState() => _RegionSelectionDialogState();
}

class _RegionSelectionDialogState extends State<_RegionSelectionDialog> {
  String? selectedRegion;
  String? selectedDistrict;
  late ScrollController _leftScrollController;
  late ScrollController _rightScrollController;
  List<AreaModel>? areas;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _leftScrollController = ScrollController();
    _rightScrollController = ScrollController();

    // 초기 선택값이 있다면 파싱
    if (widget.initialSelection != null && widget.initialSelection != '지역') {
      final parts = widget.initialSelection!.split(' ');
      if (parts.isNotEmpty) {
        selectedRegion = parts[0];
        if (parts.length > 1) {
          selectedDistrict = parts.sublist(1).join(' ');
        }
      }
    }

    // 지역 데이터 로드
    _loadAreaData();
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  // 지역 데이터 로드 메서드
  Future<void> _loadAreaData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final areaData = await AreaApiService.getAreas();
      final areaDataWithAll = AreaApiService.addAllRegionOption(areaData);

      if (mounted) {
        setState(() {
          areas = areaDataWithAll;
          isLoading = false;

          // 초기 선택이 없는 경우 기본값으로 설정
          if (selectedRegion == null && areas != null && areas!.isNotEmpty) {
            selectedRegion = areas![0].areaDivNm;
          }

          // 왼쪽 스크롤 위치 계산 및 설정
          if (selectedRegion != null && areas != null) {
            _scrollToSelectedRegion();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  // 선택된 지역으로 왼쪽 스크롤 이동
  void _scrollToSelectedRegion() {
    if (areas == null || selectedRegion == null) return;

    final index = areas!.indexWhere((area) => area.areaDivNm == selectedRegion);
    if (index >= 0) {
      // 약간의 지연을 두어 빌드가 완료된 후 스크롤 위치를 설정
      Future.delayed(Duration(milliseconds: 100), () {
        if (_leftScrollController.hasClients) {
          final itemHeight = 48.0; // ListTile의 대략적인 높이
          _leftScrollController.animateTo(
            index * itemHeight,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // 지역 선택 시 호출되는 메서드
  void _selectRegion(String region) {
    if (selectedRegion != region) {
      setState(() {
        selectedRegion = region;
        selectedDistrict = null;
        // 오른쪽 스크롤 초기화
        _rightScrollController.jumpTo(0);
      });
    }
  }

  // 세부 지역 선택 시 호출되는 메서드
  void _selectDistrict(String district) {
    setState(() {
      selectedDistrict = district;
    });
    // 선택 완료 후 화면 닫고 결과 반환
    Navigator.pop(context, '$selectedRegion $selectedDistrict');
  }

  // 선택 완료 버튼 클릭 시 호출되는 메서드
  void _completeSelection() {
    if (selectedRegion != null && areas != null) {
      final selectedAreaModel = areas!.firstWhere(
            (area) => area.areaDivNm == selectedRegion,
        orElse: () => areas![0],
      );

      if (selectedDistrict != null) {
        Navigator.pop(context, '$selectedRegion $selectedDistrict');
      } else if (selectedAreaModel.subData.isNotEmpty) {
        // 구/군을 선택하지 않았으면 첫 번째 구/군을 자동 선택
        Navigator.pop(context, '$selectedRegion ${selectedAreaModel.subData[0].areaNm}');
      } else {
        Navigator.pop(context, selectedRegion);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(width: 48), // 더미 공간으로 제목 중앙 정렬
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

          // API 데이터 로딩 및 지역 선택 UI
          Expanded(
            child: _buildAreaSelectionContent(),
          ),

          // 하단 버튼
          SafeArea(
            bottom: true,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedRegion != null ? _completeSelection : null,
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
                      child: const Text(
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
  }

  Widget _buildAreaSelectionContent() {
    // 로딩 중일 때 표시할 UI
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    // 에러 발생 시 표시할 UI
    if (hasError || areas == null || areas!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.subtleText,
            ),
            const SizedBox(height: 16),
            Text(
              '지역 정보를 불러오는데 실패했습니다.',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadAreaData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 현재 선택된 지역에 해당하는 AreaModel 찾기
    final selectedAreaModel = areas!.firstWhere(
          (area) => area.areaDivNm == selectedRegion,
      orElse: () => areas![0],
    );

    return Container(
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
            // ScrollController를 적용한 ListView
            child: ListView.builder(
              controller: _leftScrollController,
              itemCount: areas!.length,
              itemBuilder: (BuildContext context, int index) {
                final area = areas![index];
                final isSelected = selectedRegion == area.areaDivNm;

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
                      area.areaDivNm,
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
                    onTap: () => _selectRegion(area.areaDivNm),
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
              controller: _rightScrollController,
              itemCount: selectedAreaModel.subData.length,
              itemBuilder: (BuildContext context, int index) {
                final subArea = selectedAreaModel.subData[index];
                final isSelected = selectedDistrict == subArea.areaNm;

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
                      subArea.areaNm,
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
                    onTap: () => _selectDistrict(subArea.areaNm),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}