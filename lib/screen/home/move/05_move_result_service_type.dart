import 'package:MoveSmart/screen/home/move/move_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/screen/home/move/final_review_screen.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';


class ServiceTypeScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const ServiceTypeScreen({
    Key? key,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  ConsumerState<ServiceTypeScreen> createState() => _ServiceTypeScreenState();
}

class _ServiceTypeScreenState extends ConsumerState<ServiceTypeScreen> with MoveFlowMixin {
  String? selectedService;
  bool isCheckboxChecked = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isRegularMove = widget.isRegularMove;
    _loadInitialData();
  }

  void _loadInitialData() {
    final moveState = widget.isRegularMove
        ? ref.read(regularMoveProvider)
        : ref.read(specialMoveProvider);

    final moveType = moveState.moveData.selectedMoveType;

    // 일반이사일 경우 소형이사(small_move)는 '일반'을 기본값으로, 포장이사는 단일 '포장'옵션만 있음
    if (widget.isRegularMove) {
      if (moveType == 'small_move') {
        setState(() {
          selectedService = 'normal';  // 기본값은 일반이사
        });
      } else if (moveType == 'package_move') {
        setState(() {
          selectedService = 'package';  // 포장이사는 단일 옵션
        });
      }
    } else {
      // 특수이사의 경우 moveType 그대로 사용
      setState(() {
        selectedService = moveType;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 서비스 유형에 따른 단계 반환 메서드
  List<Map<String, dynamic>> _getServiceSteps(String serviceType, bool isRegularMove) {
    if (isRegularMove) {
      if (serviceType == 'normal') {
        return [
          {'icon': Icons.inventory_2, 'title': '고객 포장', 'subtitle': '고객님이 모든 짐을 포장'},
          {'icon': Icons.local_shipping, 'title': '짐 운반', 'subtitle': '포장된 짐을 트럭에 싣기'},
          {'icon': Icons.home, 'title': '운송 및 배달', 'subtitle': '목적지까지 안전하게 운송'},
          {'icon': Icons.check_circle, 'title': '하차 및 확인', 'subtitle': '짐 하차 및 확인'},
        ];
      } else if (serviceType == 'semiPackage') {
        return [
          {'icon': Icons.inventory_2, 'title': '소형 물품 포장', 'subtitle': '고객님이 소형 물품 포장'},
          {'icon': Icons.handyman, 'title': '대형 가구 포장', 'subtitle': '파트너가 가구/가전 포장'},
          {'icon': Icons.local_shipping, 'title': '짐 운반 및 운송', 'subtitle': '포장된 짐을 목적지로 운송'},
          {'icon': Icons.home, 'title': '배치 및 정리', 'subtitle': '기본 가구 배치 제공'},
        ];
      } else if (serviceType == 'package') {
        return [
          {'icon': Icons.inventory_2, 'title': '전문 포장', 'subtitle': '모든 물품 전문가 포장'},
          {'icon': Icons.local_shipping, 'title': '짐 운반 및 운송', 'subtitle': '안전하게 목적지로 운송'},
          {'icon': Icons.home, 'title': '배치', 'subtitle': '가구 및 가전 배치'},
          {'icon': Icons.cleaning_services, 'title': '정리', 'subtitle': '기본 정리 및 포장재 처리'},
        ];
      }
    } else {
      if (serviceType == 'office_move') {
        return [
          {'icon': Icons.business, 'title': '사무실 평가', 'subtitle': '전문가 방문 평가'},
          {'icon': Icons.handyman, 'title': '장비/가구 포장', 'subtitle': '사무 장비 전문 포장'},
          {'icon': Icons.local_shipping, 'title': '운송', 'subtitle': '안전한 운송 및 설치'},
          {'icon': Icons.business_center, 'title': '재배치', 'subtitle': '사무실 가구 재배치 및 세팅'},
        ];
      } else if (serviceType == 'storage_move') {
        return [
          {'icon': Icons.inventory_2, 'title': '포장', 'subtitle': '전문가 포장 서비스'},
          {'icon': Icons.local_shipping, 'title': '운송', 'subtitle': '보관 장소로 운송'},
          {'icon': Icons.lock, 'title': '보관', 'subtitle': '안전한 환경에서 보관'},
          {'icon': Icons.home, 'title': '배송', 'subtitle': '원하는 시기에 새 장소로 배송'},
        ];
      } else if (serviceType == 'simple_transport') {
        return [
          {'icon': Icons.add_box, 'title': '물품 확인', 'subtitle': '운송 물품 확인 및 준비'},
          {'icon': Icons.local_shipping, 'title': '픽업 및 운송', 'subtitle': '지정 물품 운송'},
          {'icon': Icons.check_box, 'title': '배달 및 배치', 'subtitle': '목적지 배달 및 간단 배치'},
        ];
      }
    }

    // 기본값
    return [
      {'icon': Icons.inventory_2, 'title': '포장', 'subtitle': '짐 포장 서비스'},
      {'icon': Icons.local_shipping, 'title': '운송', 'subtitle': '목적지까지 운송'},
      {'icon': Icons.home, 'title': '배치', 'subtitle': '물품 배치 서비스'},
    ];
  }

  // 소형이사(small_move) 서비스 옵션
  final Map<String, Map<String, dynamic>> smallMoveOptions = {
    'normal': {
      'title': '일반이사',
      'description': '고객님이 포장을 완료하면, 파트너가 짐을 목적지까지 운반합니다.',
      'steps': [
        '이사 전까지 모든 짐을 포장해주세요.',
        '가전제품은 분리/세척 등을 완료해주세요.',
        '파트너는 포장된 짐만 운반합니다.',
        '도착지에서 직접 짐을 풀고 정리해야 합니다.',
      ],
      'image': 'assets/images/normal_moving.png',
      'price': '가장 경제적인 옵션',
      'time': '1~2시간 소요',
    },
    'semiPackage': {
      'title': '반포장이사',
      'description': '파트너가 가구, 가전 등 큰 물품을 포장하고, 소형 물품은 고객님이 포장합니다.',
      'steps': [
        '옷, 책, 주방용품 등 소형 물품은 직접 포장해주세요.',
        '가구, 가전제품 등은 파트너가 포장/운반합니다.',
        '도착지에서 기본 가구 배치까지 진행해 드립니다.',
        '소형 물품은 직접 정리해야 합니다.',
      ],
      'image': 'assets/images/semi_package.png',
      'price': '합리적인 중간 옵션',
      'time': '2~3시간 소요',
    },
    'package': {
      'title': '포장이사',
      'description': '파트너가 모든 짐의 포장부터 운반, 정리까지 진행하는 편리한 서비스입니다.',
      'steps': [
        '별도의 사전 포장이 필요 없습니다.',
        '파트너가 모든 짐을 포장하고 운반합니다.',
        '도착지에서 가구 배치 및 기본 정리를 해드립니다.',
        '개인 물품의 세부 정리는 직접 하셔야 합니다.',
      ],
      'image': 'assets/images/package_moving.png',
      'price': '가장 편리한 프리미엄 옵션',
      'time': '3~5시간 소요',
    },
  };

  // 대형이사(package_move) 서비스 - 단일 옵션
  final Map<String, dynamic> packageMoveDetails = {
    'title': '포장이사',
    'description': '넓은 공간에 적합한 전문 포장이사 서비스입니다. 파트너가 모든 짐을 포장하고 운반, 정리까지 도와드립니다.',
    'steps': [
      '별도의 사전 포장이 필요 없습니다.',
      '파트너가 모든 짐을 전문적으로 포장하고 운반합니다.',
      '가구 배치와 가전 설치까지 진행해 드립니다.',
      '이사 후 포장재 폐기물을 정리해 드립니다.',
    ],
    'image': 'assets/images/large_package_moving.png',
    'price': '30평 이상 공간에 적합',
    'time': '5~8시간 소요',
  };

  // 특수 이사 서비스 타입
  final Map<String, Map<String, dynamic>> specialMoveDetails = {
    'office_move': {
      'title': '사무실 이사',
      'description': '업무 공간에 특화된 서비스로, 사무 가구와 장비를 안전하게 이동합니다.',
      'steps': [
        '서류와 개인 물품은 미리 정리해주세요.',
        '책상, 의자, OA기기 등은 파트너가 포장/운반합니다.',
        '도착지에서 가구 배치도에 따라 배치해 드립니다.',
        '업무 중단을 최소화하는 주말/야간 이사가 가능합니다.',
      ],
      'image': 'assets/images/office_moving.png',
      'price': '정밀한 사무공간 이전',
      'time': '사무실 규모에 따라 상이',
    },
    'storage_move': {
      'title': '보관 이사',
      'description': '일정 기간 짐을 보관한 후 새로운 장소로 이동하는 서비스입니다.',
      'steps': [
        '보관이 필요한 짐을 선별해주세요.',
        '파트너가 짐을 포장하여 안전한 보관소로 이동합니다.',
        '보관 기간은 최소 1개월부터 가능합니다.',
        '원하는 시기에 새로운 장소로 배송해 드립니다.',
      ],
      'image': 'assets/images/storage_moving.png',
      'price': '안전한 임시 보관 솔루션',
      'time': '보관 기간 선택 가능',
    },
    'simple_transport': {
      'title': '단순 운송',
      'description': '소량의 짐이나 대형 가구 등을 간편하게 운송하는 서비스입니다.',
      'steps': [
        '운송이 필요한 물품을 지정해주세요.',
        '파트너가 해당 물품만 안전하게 운반합니다.',
        '목적지에서 물품 하차 및 기본 배치까지만 진행합니다.',
        '당일 예약 및 빠른 배송이 가능합니다.',
      ],
      'image': 'assets/images/simple_transport.png',
      'price': '빠르고 간편한 운송',
      'time': '1~2시간 소요',
    },
  };

  @override
  Widget build(BuildContext context) {
    // 이사 유형 정보 가져오기
    final moveState = widget.isRegularMove
        ? ref.watch(regularMoveProvider)
        : ref.watch(specialMoveProvider);

    final moveType = moveState.moveData.selectedMoveType;

    // 화면 타이틀 결정
    String screenTitle = '';
    bool showTabs = false;

    if (widget.isRegularMove) {
      if (moveType == 'small_move') {
        screenTitle = '소형이사 서비스';
        showTabs = true;  // 소형이사는 탭 표시 (일반/반포장/포장)
      } else if (moveType == 'package_move') {
        screenTitle = '포장이사 서비스';
        showTabs = false;  // 포장이사는 단일 옵션만
      }
    } else {
      // 특수이사
      if (moveType == 'office_move') screenTitle = '사무실 이사 서비스';
      else if (moveType == 'storage_move') screenTitle = '보관 이사 서비스';
      else screenTitle = '단순 운송 서비스';
      showTabs = false;  // 특수이사는 단일 옵션만
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '서비스 확인',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 진행 상황 표시 바 (앱바 바로 아래)
          MoveProgressBar(
            currentStep: 4,  // 첫 번째 단계
            isRegularMove: isRegularMove,
          ),
          // 헤더 섹션
          Padding(
            padding: EdgeInsets.all(context.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  screenTitle,
                  style: TextStyle(
                    fontSize: context.scaledFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  showTabs ? '원하시는 서비스 유형을 선택해주세요' : '서비스 내용을 확인해주세요',
                  style: TextStyle(
                    fontSize: context.scaledFontSize(14),
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // 탭 표시 (소형이사의 경우만)
          if (showTabs) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.defaultPadding),
              child: _buildServiceTypeTabs(),
            ),
          ],



          // 서비스 세부 내용
          if (selectedService != null)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.all(context.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 서비스 상세 정보
                      _buildServiceContent(moveType),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
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
              onPressed: !isCheckboxChecked
                  ? null
                  : () async {
                // 선택된 서비스 저장 (Riverpod)
                final moveNotifier = widget.isRegularMove
                    ? ref.read(regularMoveProvider.notifier)
                    : ref.read(specialMoveProvider.notifier);

                // 서비스 타입 저장
                await moveNotifier.setServiceType(selectedService!);

                // 최종 리뷰 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinalReviewScreen(
                      isRegularMove: widget.isRegularMove,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
              ),
              child: Text(
                '다음',
                style: TextStyle(
                  fontSize: context.scaledFontSize(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// 서비스 탭 위젯 (일반/반포장/포장) - 소형이사만 사용
  Widget _buildServiceTypeTabs() {
    final serviceOptions = ['normal', 'semiPackage', 'package'];
    final tabTitles = ['일반', '반포장', '포장'];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: List.generate(
          serviceOptions.length,
              (index) {
            final serviceKey = serviceOptions[index];
            final title = tabTitles[index];
            final isSelected = selectedService == serviceKey;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedService = serviceKey;
                    isCheckboxChecked = false;

                    // 스크롤 맨 위로
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  margin: EdgeInsets.all(4),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: context.scaledFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 서비스 세부 정보 표시
  Widget _buildServiceContent(String? moveType) {
    if (selectedService == null) return SizedBox.shrink();

    Map<String, dynamic> details = {};

    // 이사 유형에 따라 서비스 상세 정보 결정
    if (widget.isRegularMove) {
      if (moveType == 'small_move') {
        details = smallMoveOptions[selectedService]!;
      } else {
        details = packageMoveDetails;
      }
    } else {
      details = specialMoveDetails[moveType]!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 서비스 타이틀과 설명을 카드로 감싸기
        Container(
          padding: EdgeInsets.all(context.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderSubColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details['title'].toString(),
                style: TextStyle(
                  fontSize: context.scaledFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 12),

              // 가격 및 시간 정보
              Row(
                children: [
                  _buildInfoBadge(details['price'].toString(), Icons.monetization_on_outlined),
                  SizedBox(width: 12),
                  _buildInfoBadge(details['time'].toString(), Icons.access_time),
                ],
              ),

              SizedBox(height: 16),

              // 서비스 설명
              Text(
                details['description'].toString(),
                style: TextStyle(
                  fontSize: context.scaledFontSize(15),
                  color: AppTheme.primaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // 서비스 진행 과정 카드
        Container(
          padding: EdgeInsets.all(context.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderSubColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서비스 진행 과정',
                style: TextStyle(
                  fontSize: context.scaledFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              SizedBox(height: 16),
              _buildCleanTimeline(context, selectedService!, widget.isRegularMove),
            ],
          ),
        ),

        SizedBox(height: 20),

        // 고객님 필수 진행 사항 카드
        Container(
          padding: EdgeInsets.all(context.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderSubColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '고객님 필수 진행 사항',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(16),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 단계별 안내
              ...List.generate(
                (details['steps'] as List).length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.scaledFontSize(12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          details['steps'][index].toString(),
                          style: TextStyle(
                            fontSize: context.scaledFontSize(14),
                            color: AppTheme.primaryText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // 동의 체크박스
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isCheckboxChecked
                ? primaryColor.withOpacity(0.1)
                : primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1.0,
            ),
          ),
          child: CheckboxListTile(
            value: isCheckboxChecked,
            onChanged: (value) {
              setState(() {
                isCheckboxChecked = value ?? false;
              });
            },
            title: Text(
              '위 서비스 내용 및 진행 사항을 확인하였습니다.',
              style: TextStyle(
                fontSize: context.scaledFontSize(14),
                fontWeight: isCheckboxChecked ? FontWeight.w600 : FontWeight.w500,
                color: isCheckboxChecked ? primaryColor : AppTheme.primaryText,
              ),
            ),
            activeColor: primaryColor,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
            dense: true,
          ),
        )
      ],
    );
  }

  Widget _buildCleanTimeline(BuildContext context, String serviceType, bool isRegularMove) {
    // 서비스 단계 정의
    List<Map<String, dynamic>> steps = _getServiceSteps(serviceType, isRegularMove);

    return Column(
      children: List.generate(
        steps.length,
            (index) => Container(
          margin: EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderSubColor),

          ),
          child: InkWell(
            child: Row(
              children: [
                // 단계 아이콘
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      steps[index]['icon'],
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // 단계 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title'],
                        style: TextStyle(
                          fontSize: context.scaledFontSize(15),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        steps[index]['subtitle'],
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 정보 뱃지 위젯
  Widget _buildInfoBadge(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: primaryColor,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: context.scaledFontSize(12),
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

} // _ServiceTypeScreenState 클래스 닫기

