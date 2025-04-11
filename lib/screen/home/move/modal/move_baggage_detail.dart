import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class ItemDetailModal extends StatefulWidget {
  final String itemName;
  final Map<String, String>? preselectedOptions;
  final List<Map<String, dynamic>> subData; // 동적 옵션 데이터를 받음
  final List<String> duplicateItems;  // 같은 카테고리의 다른 항목들
  final Function(Map<String, String>, List<String>) onConfirm;  // 선택 완료 콜백
  final Color themeColor; // 테마 색상 (일반/특수이사에 따라 다름)

  ItemDetailModal({
    required this.itemName,
    this.preselectedOptions,
    required this.subData,
    required this.duplicateItems,
    required this.onConfirm,
    required this.themeColor,
  });

  @override
  _ItemDetailModalState createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends State<ItemDetailModal> {
  Map<String, String> selectedOptions = {};
  Map<String, bool> checkedDuplicates = {}; // 체크된 중복 항목 관리

  @override
  void initState() {
    super.initState();
    if (widget.preselectedOptions != null) {
      selectedOptions = Map.from(widget.preselectedOptions!);
    }
    // 중복 항목 체크박스 초기화
    for (var item in widget.duplicateItems) {
      checkedDuplicates[item] = false;
    }
  }

  // 카테고리별 옵션을 동적으로 생성하는 함수 (2열 구성)
  Widget _buildOptionCategory(String category,
      List<Map<String, dynamic>> options) {
    // 옵션이 홀수일 경우 빈 항목 추가
    if (options.length.isOdd) {
      options.add({'loadTypeNm': '', 'isDisabled': true});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category),
                color: widget.themeColor,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.themeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 옵션 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isDisabled = option['isDisabled'] == true;

            if (isDisabled) return SizedBox();

            return _buildOptionCell(option, category);
          },
        ),
      ],
    );
  }

  // 개별 옵션 셀 빌드 함수
  Widget _buildOptionCell(Map<String, dynamic> option, String category,
      {bool isDisabled = false}) {
    final isSelected = selectedOptions[category] == option['loadTypeNm'];
    final optionName = option['loadTypeNm'] ?? '';

    if (optionName.isEmpty) return SizedBox();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
          setState(() {
            selectedOptions[category] = optionName;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[300]!
                  : isSelected
                  ? widget.themeColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isDisabled
                ? Colors.grey[200]
                : isSelected
                ? widget.themeColor.withOpacity(0.1)
                : Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                Flexible(
                  child: Text(
                    optionName,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey
                          : isSelected
                          ? widget.themeColor
                          : AppTheme.primaryText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .normal,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // subData에서 카테고리별 데이터를 필터링하고 UI 생성
  Widget _buildDynamicOptions() {
    // subData에서 loadSubSNm을 카테고리별로 그룹핑
    Map<String, List<Map<String, dynamic>>> categorizedOptions = {};

    for (var data in widget.subData) {
      String category = data['loadSubSNm'] ?? '기타'; // 카테고리 타이틀로 loadSubSNm 사용
      List<Map<String, dynamic>> typeData = (data['typeData'] as List?)
          ?.where((e) => e is Map<String, dynamic>) // 각 요소가 Map인지 확인
          .map((e) => e as Map<String, dynamic>)
          .toList() ?? [];

      if (!categorizedOptions.containsKey(category)) {
        categorizedOptions[category] = [];
      }
      categorizedOptions[category]!.addAll(typeData); // 각 카테고리에 옵션 추가
    }

    // 카테고리별로 동적 옵션 UI 생성
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categorizedOptions.entries.map((entry) {
        return _buildOptionCategory(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDuplicateItemsSection() {
    if (widget.duplicateItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.content_copy,
                color: widget.themeColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '동일 옵션 일괄 적용',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '같은 종류의 제품이 여러 개 있는 경우, 동일한 옵션을 적용할 항목을 선택해주세요.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 16),
          // 중복 항목 목록
          if (widget.duplicateItems.isNotEmpty)
            Column(
              children: widget.duplicateItems.map((item) =>
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: checkedDuplicates[item] == true
                          ? widget.themeColor.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: checkedDuplicates[item] == true
                            ? widget.themeColor
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontWeight: checkedDuplicates[item] == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      value: checkedDuplicates[item] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          checkedDuplicates[item] = value ?? false;
                        });
                      },
                      activeColor: widget.themeColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ).toList(),
            )
          else
            Center(
              child: Text(
                '동일한 종류의 다른 제품이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 모든 옵션이 선택되었는지 확인하는 함수
  bool allOptionsSelected() {
    // 모든 카테고리를 가져와서 selectedOptions에 해당 카테고리가 선택된 값이 있는지 확인
    for (var data in widget.subData) {
      String category = data['loadSubSNm'] ?? '기타'; // 카테고리 이름 설정

      // 카테고리가 선택되지 않았거나 값이 비어 있으면 false 반환
      if (!selectedOptions.containsKey(category) ||
          selectedOptions[category]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  // 완료율 계산
  int getCompletionPercentage() {
    if (widget.subData.isEmpty) return 100;

    int totalCategories = 0;
    int completedCategories = 0;

    for (var data in widget.subData) {
      String category = data['loadSubSNm'] ?? '기타';
      totalCategories++;

      if (selectedOptions.containsKey(category) &&
          selectedOptions[category]!.isNotEmpty) {
        completedCategories++;
      }
    }

    return ((completedCategories / totalCategories) * 100).round();
  }

  // 카테고리 아이콘 가져오기
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '크기':
      case '사이즈':
        return Icons.straighten;
      case '종류':
      case '타입':
        return Icons.category;
      case '용량':
      case '무게':
        return Icons.line_weight;
      case '재질':
        return Icons.texture;
      case '색상':
        return Icons.color_lens;
      case '상태':
        return Icons.info_outline;
      case '기타':
        return Icons.more_horiz;
      case '프레임':
        return Icons.crop_portrait;
      case '특이사항':
        return Icons.report_problem_outlined;
      default:
        return Icons.label_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 완료율 계산
    final completionPercentage = getCompletionPercentage();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.itemName,
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 바
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: widget.themeColor,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '상세 정보 작성 중...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: completionPercentage / 100,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<
                                            Color>(
                                          widget.themeColor,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '$completionPercentage%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: widget.themeColor,
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

                  SizedBox(height: 20),

                  // 옵션 선택 타이틀
                  Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: widget.themeColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '세부 옵션 선택',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // 동적 옵션 UI
                  _buildDynamicOptions(),

                  SizedBox(height: 20),

                  // 중복 항목 선택 섹션
                  _buildDuplicateItemsSection(),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: allOptionsSelected()
                      ? () {
                    // 선택된 중복 항목 리스트 생성
                    final selectedDuplicates = checkedDuplicates.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();
                    // 선택된 옵션과 중복 적용할 항목들 전달
                    widget.onConfirm(selectedOptions, selectedDuplicates);
                    Navigator.pop(context);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}