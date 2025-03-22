import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_constants.dart';
import '../modal/home_modal/move_regular_type.dart';
import '../modal/home_modal/move_special_type.dart';
import './widgets/move_widget.dart';
import '../providers/move_provider.dart';

// StatefulWidget을 ConsumerStatefulWidget으로 변경
class LeftBox extends ConsumerStatefulWidget {
  final double height;

  const LeftBox({super.key, required this.height});

  @override
  ConsumerState<LeftBox> createState() => _LeftBoxState();
}

// State를 ConsumerState로 변경
class _LeftBoxState extends ConsumerState<LeftBox> {
  bool _isRegularMoveInProgress = false;
  bool _isSpecialMoveInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkMoveProgress();
  }

  // 이사 정보 로드 및 진행 상태 확인
  Future<void> _checkMoveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // 일반이사 정보 확인 (간단한 키 몇 개만 확인)
    final hasRegularMoveType = prefs.getString('regular_selectedMoveType') != null;
    final hasRegularDate = prefs.getString('regular_selectedDate') != null;

    // 특수이사 정보 확인 (간단한 키 몇 개만 확인)
    final hasSpecialMoveType = prefs.getString('special_selectedMoveType') != null;
    final hasSpecialDate = prefs.getString('special_selectedDate') != null;

    // 주소 정보도 확인
    final hasRegularStartAddress = prefs.getString('regular_startAddress') != null;
    final hasSpecialStartAddress = prefs.getString('special_startAddress') != null;

    setState(() {
      // 간단한 조건: 정보가 하나라도 있으면 작성 중으로 간주
      _isRegularMoveInProgress = hasRegularMoveType || hasRegularDate || hasRegularStartAddress;
      _isSpecialMoveInProgress = hasSpecialMoveType || hasSpecialDate || hasSpecialStartAddress;
    });
  }

  // 모달 표시 함수 - 코드 재사용 (수정)
  void _showMoveTypeModal(BuildContext context, Widget modalContent) {
    // 데이터 로드 확인 후 모달 표시
    if (modalContent is RegularMoveTypeModal) {
      // 데이터 강제 로드
      ref.read(regularMoveProvider.notifier).forceReload().then((_) {
        _showModalContent(context, modalContent);
      });
    } else if (modalContent is SpecialMoveTypeModal) {
      ref.read(specialMoveProvider.notifier).forceReload().then((_) {
        _showModalContent(context, modalContent);
      });
    } else {
      _showModalContent(context, modalContent);
    }
  }

  void _showModalContent(BuildContext context, Widget modalContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
          child: modalContent,
        );
      },
    ).then((_) {
      // 모달이 닫힌 후 상태 다시 확인
      _checkMoveProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이제 ref 객체를 사용할 수 있습니다
    return Row(
      children: [
        // 일반이사 버튼 (왼쪽)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MoveButton(
              height: widget.height,
              title: "일반이사",
              subtitles: const ["소형이사", "포장이사"],
              icon: Icons.home_outlined,
              primaryColor: AppTheme.primaryColor,
              secondaryColor: const Color(0xFF6A92FF),
              buttonText: "견적등록",
              isWritingInProgress: _isRegularMoveInProgress,
              onTap: () => _showMoveTypeModal(context, const RegularMoveTypeModal()),
            ),
          ),
        ),

        // 특수이사 버튼 (오른쪽)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: MoveButton(
              height: widget.height,
              title: "특수이사",
              subtitles: const ["사무실이사", "보관이사/단순운송"],
              icon: Icons.miscellaneous_services_outlined,
              primaryColor: const Color(0xFF009688),
              secondaryColor: const Color(0xFF26A69A),
              buttonText: "견적등록",
              isWritingInProgress: _isSpecialMoveInProgress,
              onTap: () => _showMoveTypeModal(context, const SpecialMoveTypeModal()),
            ),
          ),
        ),
      ],
    );
  }
}