import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../utils/ui_extensions.dart';

class TimelineDetailModal extends StatelessWidget {
  final String serviceType;
  final Map<String, dynamic> step;
  final int index;
  final bool isRegularMove;

  const TimelineDetailModal({
    Key? key,
    required this.serviceType,
    required this.step,
    required this.index,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isRegularMove
        ? AppTheme.primaryColor
        : AppTheme.greenColor;

    return Container(

      child: Column(
        children: [
          // 상단 드래그 핸들
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),

          // 헤더 (제목과 닫기 버튼)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          step['icon'],
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontSize: context.scaledFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.secondaryText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 스크롤 가능한 본문
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 단계 설명
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step['subtitle'],
                              style: TextStyle(
                                fontSize: context.scaledFontSize(15),
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // 상세 정보 섹션
                    Text(
                      "상세 정보",
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(height: 12),

                    // 단계별 세부 안내
                    ...getDetailedInstructions().map((item) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: primaryColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
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

                    SizedBox(height: 24),

                    // 팁 섹션
                    if (getTips().isNotEmpty) ...[
                      Text(
                        "도움이 되는 팁",
                        style: TextStyle(
                          fontSize: context.scaledFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: getTips().map((tip) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: context.scaledFontSize(13),
                                          color: AppTheme.primaryText,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 서비스 타입과 단계에 따른 세부 안내 반환
  List<String> getDetailedInstructions() {
    if (isRegularMove) {
      if (serviceType == 'normal') {
        switch (index) {
          case 0: // 고객 포장
            return [
              "이사 전날까지 모든 물품을 튼튼한 박스에 포장해주세요.",
              "무거운 물건은 작은 박스에 나눠 담으면 운반이 쉽습니다.",
              "깨지기 쉬운 물건은 신문지나 에어캡으로 감싸주세요.",
              "박스에 내용물과 방 위치를 표시하면 정리가 수월합니다.",
            ];
          case 1: // 짐 운반
            return [
              "전문 인력이 포장된 짐을 안전하게 운반합니다.",
              "이사 당일 출입구와 엘리베이터 이동 경로를 확보해주세요.",
              "귀중품과 중요 서류는 직접 챙겨 별도 보관해주세요.",
              "파손 위험이 있는 물품은 미리 알려주시면 특별히 관리합니다.",
            ];
          case 2: // 운송 및 배달
            return [
              "안전 운전과 물품 보호를 최우선으로 합니다.",
              "앱에서 실시간 위치 추적이 가능합니다.",
              "도착 예정 시간보다 지연 시 사전 연락드립니다.",
              "특수 상황(교통 체증 등)은 실시간으로 안내해 드립니다.",
            ];
          case 3: // 하차 및 확인
            return [
              "지정하신 위치에 물품을 배치해 드립니다.",
              "모든 물품의 이상 유무를 함께 확인합니다.",
              "누락 물품이 없는지 체크리스트로 확인해 드립니다.",
              "만족도 조사에 참여해 주시면 서비스 개선에 도움이 됩니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'semiPackage') {
        switch (index) {
          case 0: // 소형 물품 포장
            return [
              "옷, 책, 소품 등 작은 물품은 고객님이 미리 포장해주세요.",
              "주방용품, 욕실용품 등은 종류별로 분류하여 포장하시면 좋습니다.",
              "박스 포장 시 내용물이 흔들리지 않도록 빈 공간을 채워주세요.",
              "당일 필요한 생활필수품은 별도로 표시해두시면 편리합니다.",
            ];
          case 1: // 대형 가구 포장
            return [
              "가구와 가전제품은 전문 인력이 안전하게 포장합니다.",
              "이사 전 가전제품의 전원은 미리 분리해주세요.",
              "고가 가구나 특수 관리가 필요한 가구는 사전에 알려주세요.",
              "가구 내부의 물품은 미리 비워주시면 좋습니다.",
            ];
          case 2: // 짐 운반 및 운송
            return [
              "포장된 모든 짐을 안전하게 차량에 적재합니다.",
              "중량물과 파손 위험이 있는 물품은 특별 관리합니다.",
              "운송 중 흔들림이나 충격을 최소화하는 적재 방식을 사용합니다.",
              "최적의 경로로 신속하게 목적지까지 이동합니다.",
            ];
          case 3: // 배치 및 정리
            return [
              "도착지에서 가구와 대형 가전을 원하시는 위치에 배치해 드립니다.",
              "가구 위치 조정이 필요하면 언제든 말씀해주세요.",
              "소형 물품은 지정하신 공간에 정리해 드립니다.",
              "모든 작업 완료 후 함께 확인 절차를 진행합니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'package') {
        switch (index) {
          case 0: // 전문 포장
            return [
              "모든 물품을 전문 인력이 체계적으로 포장합니다.",
              "물품별 특성에 맞는 최적의 포장재를 사용합니다.",
              "파손 위험이 있는 물품은 특수 포장재로 안전하게 보호합니다.",
              "포장 전 귀중품이나 중요 서류는 별도로 알려주세요.",
            ];
          case 1: // 짐 운반 및 운송
            return [
              "포장된 물품을 손상 없이 안전하게 차량에 적재합니다.",
              "적재 시 무게 분산과 안정성을 고려합니다.",
              "운송 중 물품 이동을 방지하는 고정 장치를 사용합니다.",
              "GPS 실시간 위치 추적으로 운송 상황을 확인할 수 있습니다.",
            ];
          case 2: // 배치
            return [
              "도착지에서 가구와 가전을 원하시는 위치에 정확히 배치합니다.",
              "대형 가구는 조립 및 설치까지 완료해 드립니다.",
              "가전제품은 기본적인 연결까지 도와드립니다.",
              "배치 중 바닥과 벽면 손상을 방지하기 위한 보호 조치를 취합니다.",
            ];
          case 3: // 정리
            return [
              "사용한 포장재를 모두 수거하여 처리합니다.",
              "기본적인 청소를 진행하여 공간을 정리합니다.",
              "물품 상태를 함께 최종 확인합니다.",
              "추가적인 배치 조정이 필요하면 말씀해주세요.",
            ];
          default:
            return [];
        }
      }
    } else { // 특수이사
      if (serviceType == 'office_move') {
        switch (index) {
          case 0: // 사무실 평가
            return [
              "전문가가 방문하여 사무실 환경과 물품을 평가합니다.",
              "이동이 필요한 가구와 장비의 목록을 작성합니다.",
              "특수 장비나 민감한 물품을 파악합니다.",
              "최적의 이사 일정과 인력 배치를 계획합니다.",
            ];
          case 1: // 장비/가구 포장
            return [
              "사무용 가구와 장비를 안전하게 포장합니다.",
              "컴퓨터와 전자기기는 정전기 방지 포장재를 사용합니다.",
              "서류와 중요 문서는 별도로 안전하게 보관합니다.",
              "모든 물품에 라벨을 부착하여 정확한 위치 배치가 가능하도록 합니다.",
            ];
          case 2: // 운송
            return [
              "포장된 사무 물품을 안전하게 차량에 적재합니다.",
              "충격에 민감한 장비는 특별 관리합니다.",
              "효율적인 경로로 신속하게 이동합니다.",
              "업무 중단을 최소화하기 위해 약속된 시간을 엄수합니다.",
            ];
          case 3: // 재배치
            return [
              "새 사무실에 가구와 장비를 사전 계획된 레이아웃에 따라 배치합니다.",
              "데스크와 파티션을 정확히 조립하고 설치합니다.",
              "전자기기와 네트워크 장비의 기본 설치를 지원합니다.",
              "모든 물품이 제대로 작동하는지 기본 확인을 진행합니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'storage_move') {
        switch (index) {
          case 0: // 포장
            return [
              "장기 보관에 적합한 견고한 포장을 진행합니다.",
              "습기와 먼지로부터 물품을 보호하는 특수 포장재를 사용합니다.",
              "모든 물품의 상세 목록을 작성하여 관리합니다.",
              "고객님과 함께 물품 상태를 확인하고 기록합니다.",
            ];
          case 1: // 운송
            return [
              "포장된 물품을 안전하게 보관 시설로 운송합니다.",
              "중요 물품과 파손 위험이 있는 물품은 특별 관리합니다.",
              "운송 중 물품 안전을 위한 특수 고정 장치를 사용합니다.",
              "운송 경로와 예상 도착 시간을 안내해 드립니다.",
            ];
          case 2: // 보관
            return [
              "항온항습이 유지되는 안전한 환경에서 물품을 보관합니다.",
              "24시간 보안 시스템으로 물품을 안전하게 관리합니다.",
              "정기적인 물품 상태 점검을 진행합니다.",
              "필요시 앱을 통해 보관 중인 물품 목록을 확인할 수 있습니다.",
            ];
          case 3: // 배송
            return [
              "원하시는 시기에 보관 물품을 새 장소로 배송합니다.",
              "물품 목록을 확인하여 누락 없이 모두 배송합니다.",
              "배송 전 물품 상태를 재확인합니다.",
              "새 장소에서 원하시는 위치에 물품을 배치해 드립니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'simple_transport') {
        switch (index) {
          case 0: // 물품 확인
            return [
              "운송이 필요한 물품의 크기와 무게를 확인합니다.",
              "특별한 관리가 필요한 물품이 있는지 체크합니다.",
              "효율적인 운송을 위한 포장 방법을 안내해 드립니다.",
              "물품에 따른 적합한 차량과 인력을 배정합니다.",
            ];
          case 1: // 픽업 및 운송
            return [
              "약속된 시간에 전문 인력이 방문합니다.",
              "지정된 물품을 안전하게 차량에 적재합니다.",
              "물품 보호를 위한 안전 조치를 취합니다.",
              "최단 경로로 목적지까지 신속하게 이동합니다.",
            ];
          case 2: // 배달 및 배치
            return [
              "목적지에 도착하여 물품을 안전하게 하차합니다.",
              "지정하신 위치에 물품을 배치해 드립니다.",
              "간단한 조립이 필요한 경우 도움을 드립니다.",
              "물품 상태를 함께 확인하고 서비스를 완료합니다.",
            ];
          default:
            return [];
        }
      }
    }
    // 기본값
    return [];
  }

  // 서비스 타입과 단계에 따른 팁 반환
  List<String> getTips() {
    if (isRegularMove) {
      if (serviceType == 'normal') {
        switch (index) {
          case 0: // 고객 포장
            return [
              "박스 바닥은 이중으로 테이핑하면 더 안전합니다.",
              "접시나 유리 제품은 수직으로 세워 포장하면 파손 위험이 줄어듭니다.",
              "옷은 행거에 걸린 채로 비닐을 씌워 이동하면 편리합니다.",
            ];
          case 1: // 짐 운반
            return [
              "이사 전날 엘리베이터 사용 예약을 미리 해두세요.",
              "애완동물은 안전한 공간에 분리해두시는 것이 좋습니다.",
              "출입 경로에 장애물이 없는지 미리 확인해주세요.",
            ];
          case 2: // 운송 및 배달
            return [
              "새 집 주소와 정확한 위치를 미리 파악해두세요.",
              "도착 전 주차 공간 확보를 부탁드립니다.",
              "이사 당일 날씨를 확인하여 비나 눈이 예상될 경우 미리 알려주세요.",
            ];
          case 3: // 하차 및 확인
            return [
              "짐 정리는 침구류부터 시작하면 편리합니다.",
              "중요한 물품이 들어있는 박스는 별도 표시를 해두세요.",
              "가전제품은 설치 전 최소 30분 이상 안정화 시간을 두는 것이 좋습니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'semiPackage') {
        switch (index) {
          case 0: // 소형 물품 포장
            return [
              "종이 박스보다 플라스틱 상자가 더 견고하고 재사용이 가능합니다.",
              "소형 물품은 지퍼백에 분류해 담으면 관리가 편리합니다.",
              "박스마다 내용물 목록을 부착하면 나중에 찾기 쉽습니다.",
            ];
          case 1: // 대형 가구 포장
            return [
              "가구 서랍은 비워두는 것이 안전합니다.",
              "거울이나 유리가 있는 가구는 미리 알려주세요.",
              "가구 이동 전 바닥에 흠집이 생길 수 있는 부분을 사진으로 기록해두세요.",
            ];
          case 2: // 짐 운반 및 운송
            return [
              "이사 당일 날씨를 확인하고 비가 예상되면 미리 알려주세요.",
              "도착지 주변 교통 상황을 미리 확인해두면 도움이 됩니다.",
              "귀중품은 직접 운송하는 것이 가장 안전합니다.",
            ];
          case 3: // 배치 및 정리
            return [
              "가구 위치는 미리 도면에 표시해두면 배치가 수월합니다.",
              "가전제품은 설치 후 바로 사용하지 말고 일정 시간 안정화시키세요.",
              "빠른 정착을 위해 침구류와 욕실용품을 가장 먼저 정리하세요.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'package') {
        switch (index) {
          case 0: // 전문 포장
            return [
              "귀중품과 중요 서류는 별도로 챙겨두세요.",
              "냉장고는 하루 전에 미리 전원을 차단하고 비워두세요.",
              "이사 당일 착용할 옷과 필수품은 따로 준비해두세요.",
            ];
          case 1: // 짐 운반 및 운송
            return [
              "이사 당일 출입문과 엘리베이터 사용 여부를 미리 확인해주세요.",
              "주차 공간 확보를 부탁드립니다.",
              "이동 중 필요할 수 있는 중요 물품은 별도 가방에 보관하세요.",
            ];
          case 2: // 배치
            return [
              "가구 배치 계획을 미리 생각해두면 더 효율적으로 진행됩니다.",
              "바닥재나 벽지에 민감한 부분이 있다면 미리 알려주세요.",
              "전자제품 설치 위치의 콘센트와 상태를 미리 확인해두세요.",
            ];
          case 3: // 정리
            return [
              "정리 순서는 침실, 욕실, 주방 순으로 하면 효율적입니다.",
              "버려야 할 포장재와 보관할 포장재를 구분해주세요.",
              "이사 후 첫날 필요한 물품 목록을 미리 작성해두세요.",
            ];
          default:
            return [];
        }
      }
    } else { // 특수이사
      if (serviceType == 'office_move') {
        switch (index) {
          case 0: // 사무실 평가
            return [
              "사무실 도면과 새 공간의 레이아웃 계획을 준비해두세요.",
              "직원들에게 중요 물품은 미리 정리하도록 안내해주세요.",
              "특수 장비가 있다면 매뉴얼이나 주의사항을 준비해주세요.",
            ];
          case 1: // 장비/가구 포장
            return [
              "컴퓨터 데이터는 백업해두는 것이 안전합니다.",
              "네트워크 장비의 연결 상태를 사진으로 기록해두세요.",
              "중요 서류는 별도 보관함에 정리하여 직접 관리하세요.",
            ];
          case 2: // 운송
            return [
              "주말이나 업무 시간 외 이사를 진행하면 업무 중단을 최소화할 수 있습니다.",
              "새 사무실 건물의 이사 규정을 미리 확인해주세요.",
              "이사 전후 인터넷과 전화선 설치 일정을 조율해두세요.",
            ];
          case 3: // 재배치
            return [
              "IT 담당자가 함께 있으면 장비 설치가 수월합니다.",
              "직원별 좌석 배치도를 미리 준비해두세요.",
              "공용 장비와 물품의 위치를 표시해두면 적응이 빠릅니다.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'storage_move') {
        switch (index) {
          case 0: // 포장
            return [
              "장기 보관 물품은 습기 방지 처리가 중요합니다.",
              "가구는 분해하여 보관하면 공간을 절약할 수 있습니다.",
              "보관 중 필요할 수 있는 물품은 쉽게 찾을 수 있도록 별도 표시하세요.",
            ];
          case 1: // 운송
            return [
              "보관소 위치와 접근성을 미리 확인해두세요.",
              "보험 가입 여부와 보장 범위를 확인하세요.",
              "중요 물품의 사진을 미리 찍어두면 상태 확인에 도움이 됩니다.",
            ];
          case 2: // 보관
            return [
              "보관 기간 동안 필요한 물품에 대한 출고 절차를 미리 문의해두세요.",
              "장기 보관 시 정기적인 상태 확인을 요청하세요.",
              "계절 의류나 도서 등은 진공 포장하면 보관 효율이 높아집니다.",
            ];
          case 3: // 배송
            return [
              "출고 요청은 최소 3일 전에 미리 해주세요.",
              "부분 출고가 필요한 경우 물품 목록을 정확히 전달해주세요.",
              "새 주소의 접근성과 주차 가능 여부를 미리 확인해주세요.",
              "배송 후 물품 상태를 꼼꼼히 확인하세요.",
            ];
          default:
            return [];
        }
      } else if (serviceType == 'simple_transport') {
        switch (index) {
          case 0: // 물품 확인
            return [
              "운송할 물품의 정확한 크기와 무게를 측정해주세요.",
              "물품 포장 상태를 사진으로 기록해두면 좋습니다.",
              "특별한 취급이 필요한 물품은 미리 알려주세요.",
            ];
          case 1: // 픽업 및 운송
            return [
              "픽업 장소의 주차 가능 여부를 확인해주세요.",
              "대형 물품의 경우 출입문 크기를 미리 측정해두세요.",
              "운송 중 필요한 연락처를 미리 준비해두세요.",
            ];
          case 2: // 배달 및 배치
            return [
              "배치할 공간의 크기를 미리 측정해두면 좋습니다.",
              "바닥 보호가 필요한 경우 미리 준비해주세요.",
              "물품 설치 시 필요한 도구가 있다면 미리 알려주세요.",
            ];
          default:
            return [];
        }
      }
    }
    // 기본값
    return [];
  }
}