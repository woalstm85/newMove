import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';
import 'move_result_service_type.dart';

class BoxMemoScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const BoxMemoScreen({
    super.key,
    required this.isRegularMove,
  });

  @override
  ConsumerState<BoxMemoScreen> createState() => _BoxMemoScreenState();
}

class _BoxMemoScreenState extends ConsumerState<BoxMemoScreen> with MoveFlowMixin, CommonUiMixin {
  TextEditingController memoController = TextEditingController();

  // 체크리스트 상태 관리
  Map<String, bool> specialItems = {
    '대형 가전제품': false,
    '피아노/전자피아노': false,
    '미술품/액자': false,
    '유리/도자기류': false,
    '운동기구': false,
  };

  // 선택된 메모 템플릿 관리
  List<String> selectedTemplates = [];

  // 메모 카테고리 관리
  int selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> memoCategories = [
    {'title': '일반 메모', 'icon': Icons.note_alt_outlined},
    {'title': '주의 사항', 'icon': Icons.warning_amber_outlined},
    {'title': '요청 사항', 'icon': Icons.question_answer_outlined},
  ];

  @override
  void initState() {
    super.initState();
    isRegularMove = widget.isRegularMove;
    _loadSavedData();
  }

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  // 저장된 데이터 불러오기
  Future<void> _loadSavedData() async {
    try {
      final moveState = widget.isRegularMove
          ? ref.read(regularMoveProvider)
          : ref.read(specialMoveProvider);

      if (moveState.moveData.memo != null) {
        memoController.text = moveState.moveData.memo!;
      }

      if (moveState.moveData.specialItems.isNotEmpty) {
        setState(() {
          specialItems = moveState.moveData.specialItems;
        });
      }

      setState(() {
        selectedCategoryIndex = moveState.moveData.selectedMemoCategory;
        selectedTemplates = moveState.moveData.selectedTemplates;
      });

    } catch (e) {
      debugPrint('데이터 로드 오류: $e');
    }
  }

  // 데이터 저장하기
  Future<void> _saveData() async {
    try {
      final moveNotifier = widget.isRegularMove
          ? ref.read(regularMoveProvider.notifier)
          : ref.read(specialMoveProvider.notifier);

      // 메모 데이터 저장
      await moveNotifier.setMemoData(
        memo: memoController.text,
        selectedCategory: selectedCategoryIndex,
        selectedTemplates: selectedTemplates,
      );

      // 특별 관리 항목 저장
      await moveNotifier.setSpecialItems(specialItems);

    } catch (e) {
      debugPrint('데이터 저장 오류: $e');
    }
  }

  // 이사 유형에 따른 저장 키 접두사 가져오기
  String get _keyPrefix => widget.isRegularMove ? 'regular_' : 'special_';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '상세 정보 입력',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 텍스트
                  Text(
                    '파트너가 알아야 할 추가 정보를 입력해주세요.',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(16),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Text(
                    '사진에 담기지 않은 구석이나 짐들에 한해 추가요금이 발생할 수 있어요.',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(14),
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  SizedBox(height: 24),

                  // 특별 관리 항목 체크리스트
                  _buildSpecialItemsSection(),

                  SizedBox(height: 24),

                  // 메모 섹션
                  _buildMemoSection(),
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
                padding: EdgeInsets.all(context.defaultPadding),
                child: ElevatedButton(
                  onPressed: () async {
                    // 데이터 저장 후 다음 단계로 이동
                    await _saveData();

                    // ServiceTypeScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceTypeScreen(
                          isRegularMove: widget.isRegularMove,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // 특별 관리 항목 섹션
  Widget _buildSpecialItemsSection() {
    return buildInfoCard(
      title: '특별 관리 항목',
      icon: Icons.checklist_outlined,
      iconColor: primaryColor,
      children: [
        Text(
          '특별히 주의가 필요한 항목을 선택해주세요',
          style: TextStyle(
            fontSize: context.scaledFontSize(13),
            color: AppTheme.secondaryText,
          ),
        ),
        SizedBox(height: 16),

        // 체크리스트 항목
        ...specialItems.entries.map((entry) => _buildChecklistItem(entry.key, entry.value)),
      ],
    );
  }

  // 체크리스트 항목 위젯
  Widget _buildChecklistItem(String title, bool isChecked) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked ? primaryColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isChecked ? primaryColor.withOpacity(0.3) : AppTheme.borderColor,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
            color: isChecked ? primaryColor : AppTheme.primaryText,
          ),
        ),
        value: isChecked,
        onChanged: (value) {
          setState(() {
            specialItems[title] = value!;

            // 체크된 경우 메모에 자동 추가
            if (value) {
              String currentText = memoController.text;
              if (currentText.isNotEmpty && !currentText.endsWith('\n')) {
                currentText += '\n';
              }
              if (!currentText.contains(title)) {
                memoController.text = currentText + '• $title 있음\n';
              }
            }
          });
        },
        activeColor: primaryColor,
        checkColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }

  // 메모 섹션
// 메모 섹션
  Widget _buildMemoSection() {
    return buildInfoCard(
      title: '메모',
      icon: Icons.note_alt_outlined,
      iconColor: primaryColor,
      children: [
        // 메모 카테고리 선택 탭
        _buildMemoCategoryTabs(),
        SizedBox(height: 16),

        // 빠른 입력 템플릿
        _buildQuickTemplates(),
        SizedBox(height: 16),

        // 메모 입력 필드
        TextField(
          controller: memoController,
          maxLines: 7,
          style: TextStyle(  // 입력 텍스트 색상을 연하게 설정
            color: AppTheme.primaryText.withOpacity(0.8),
            fontSize: context.scaledFontSize(14),
          ),
          decoration: InputDecoration(
            hintText: _getHintTextForCategory(),
            hintStyle: TextStyle(
              color: AppTheme.subtleText.withOpacity(0.7),  // 힌트 텍스트 더 연하게
              fontSize: context.scaledFontSize(14),
            ),
            fillColor: Colors.grey[50],
            filled: true,
            border: OutlineInputBorder(  // 기본 테두리 색상을 연하게
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderSubColor,  // 테두리 색상 연하게
                width: 1.0,  // 테두리 두께 줄이기
              ),
            ),
            enabledBorder: OutlineInputBorder(  // 활성화 상태 테두리 (추가)
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderSubColor,  // 테두리 색상 연하게
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(  // 포커스 상태 테두리
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor.withOpacity(0.7),  // 포커스 테두리 연하게
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // 메모 카테고리 탭
  Widget _buildMemoCategoryTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          memoCategories.length,
              (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedCategoryIndex == index
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        memoCategories[index]['icon'],
                        size: 16,
                        color: selectedCategoryIndex == index
                            ? Colors.white
                            : AppTheme.secondaryText,
                      ),
                      SizedBox(width: 6),
                      Text(
                        memoCategories[index]['title'],
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          fontWeight: FontWeight.w600,
                          color: selectedCategoryIndex == index
                              ? Colors.white
                              : AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// 빠른 입력 템플릿
  Widget _buildQuickTemplates() {
    List<String> templates = _getTemplatesForCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '빠른 입력',
              style: TextStyle(
                fontSize: context.scaledFontSize(14),
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText,
              ),
            ),
            // 일괄 삭제 버튼
            if (selectedTemplates.isNotEmpty)
              GestureDetector(
                onTap: _clearAllSelectedTemplates,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.redAccent.withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '모두 지우기',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(12),
                          color: Colors.redAccent.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: templates.map((template) => _buildTemplateChip(template)).toList(),
        ),
      ],
    );
  }

// 모든 선택된 템플릿 지우기

  void _clearAllSelectedTemplates() {
    setState(() {
      // 현재 선택된 템플릿들에 대한 목록 저장
      List<String> templatesToRemove = List.from(selectedTemplates);

      // 메모에서 선택된 템플릿 모두 삭제
      String currentText = memoController.text;
      List<String> lines = currentText.split('\n');

      // 각 템플릿에 대해 해당 줄 제거
      for (String template in templatesToRemove) {
        lines.removeWhere((line) => line.trim() == '• $template');
        selectedTemplates.remove(template);
      }

      // 메모 텍스트 업데이트
      memoController.text = lines.join('\n');
    });
  }
// 템플릿 칩 위젯
  Widget _buildTemplateChip(String label) {
    bool isSelected = selectedTemplates.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          String currentText = memoController.text;

          if (isSelected) {
            // 이미 선택된 경우 - 해당 내용 삭제
            selectedTemplates.remove(label);

            // 메모에서 해당 줄 삭제
            List<String> lines = currentText.split('\n');
            lines.removeWhere((line) => line.trim() == '• $label');
            memoController.text = lines.join('\n');
          } else {
            // 선택되지 않은 경우 - 내용 추가
            if (!currentText.contains(label)) {
              if (currentText.isNotEmpty && !currentText.endsWith('\n')) {
                currentText += '\n';
              }
              memoController.text = currentText + '• $label\n';
              selectedTemplates.add(label);
            }
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 14,
              color: isSelected ? primaryColor : AppTheme.secondaryText,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: context.scaledFontSize(12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리별 힌트 텍스트 반환
  String _getHintTextForCategory() {
    switch (selectedCategoryIndex) {
      case 0:
        return '파트너에게 전달되어야 하는 일반적인 정보를 입력해주세요.';
      case 1:
        return '주의가 필요한 물품이나 환경에 대해 알려주세요.';
      case 2:
        return '특별히 요청하실 사항이 있다면 입력해주세요.';
      default:
        return '메모를 입력해주세요.';
    }
  }

  // 카테고리별 템플릿 반환
  List<String> _getTemplatesForCategory() {
    switch (selectedCategoryIndex) {
      case 0: // 일반 메모
        return ['짐이 많아요', '시간 여유를 두고 진행해주세요', '포장이 필요해요', '추가 비용 가능합니다'];
      case 1: // 주의 사항
        return ['파손 주의 물품', '무거운 가구 있음', '좁은 계단 주의', '귀중품 따로 포장', '전문인력 필요'];
      case 2: // 요청 사항
        return ['가구 조립 필요', '벽걸이 TV 설치', '냉장고 연결', '빠른 이사 희망', '정리정돈 요청'];
      default:
        return [];
    }
  }
}