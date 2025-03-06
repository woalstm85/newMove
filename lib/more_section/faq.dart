import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<String> categories = [
    '이사 관련', '견적/결제', '간편결제', '기타 문의'
  ];

  final List<List<Map<String, String>>> faqData = [
    // 이사 관련
    [
      {
        "question": "이사 종류별로 어떤 차이점이 있나요?",
        "answer": "이사 종류에는 포장이사, 반포장이사, 일반이사가 있습니다.\n\n1. 포장이사는 모든 짐을 포장부터 운반, 정리까지 전문가가 해드립니다.\n\n2. 반포장이사는 대형 가구와 가전을 중심으로 포장과 운반을 도와드리고, 소형 물품은 고객님이 직접 포장합니다.\n\n3. 일반이사는 고객님이 미리 포장해둔 짐을 운반만 해드리는 서비스입니다.\n\n각 이사 종류별로 가격과 소요시간이 다르므로 상황에 맞게 선택하시면 됩니다."
      },
      {
        "question": "짐 입력하는 방법을 알려주세요.",
        "answer": "주소 입력 다음 단계에서 이사할 짐을 입력하는 방법을 선택하실 수 있습니다. 견적을 신청하는 두 가지 방법에 대해 안내해 드리겠습니다.\n\n[방 사진 찍기]\n이사할 공간(방, 거실, 베란다)의 사진을 찍어 업로드하는 방식입니다. 방 전체가 보이도록 사진을 촬영하셔야 하며 사진이 많을수록 보다 정확한 견적을 받을 수 있습니다.\n\n[짐 목록 선택]\n짐 목록에서 이사할 짐을 선택하여 입력하는 방식입니다. 아이콘에 없는 짐은 모두 박스 수량으로 체크해 주시길 바랍니다.\n\n박스는 파트너와 상호 이해를 위해 우체국 5호 박스로 기준하고 있으며, 정확한 사이즈는 박스 선택 단계에서 확인하실 수 있습니다."
      },
      {
        "question": "추가금은 언제 발생되나요?",
        "answer": "추가금이 발생할 수 있는 상황은 다음과 같습니다:\n\n1. 견적 신청 시 입력하신 짐의 양보다 실제 짐의 양이 많은 경우\n2. 엘리베이터가 없거나 사용이 불가능한 상황이 발생한 경우\n3. 주차가 불가능하여 주정차 단속 위험이 있는 경우\n4. 대형 가구(피아노, 돌침대 등)가 추가된 경우\n5. 수납장 내부 물품이 정리되지 않은 경우\n\n이러한 상황에서는 파트너가 현장에서 추가 비용을 안내드릴 수 있으며, 고객님의 동의 없이는 추가 비용이 발생하지 않습니다."
      },
    ],
    // 견적/결제
    [
      {
        "question": "견적은 부가세 포함인가요?",
        "answer": "네, 모든 견적 금액은 부가세(10%)가 포함된 가격입니다. 별도로 부가세를 추가로 지불하실 필요가 없습니다.\n\n견적서와 영수증이 필요하신 경우, 서비스 완료 후 앱 내에서 '영수증 발급' 버튼을 통해 요청하실 수 있습니다."
      },
      {
        "question": "같은 서비스를 동시에 여러 개 추가 신청을 하고 싶어요.",
        "answer": "같은 서비스를 여러 개 동시에 신청하시려면 다음과 같이 진행해 주세요:\n\n1. 앱 메인 화면에서 원하시는 서비스를 선택합니다.\n2. 첫 번째 서비스 신청을 완료합니다.\n3. 결제 완료 화면에서 '추가 서비스 신청' 버튼을 선택합니다.\n4. 동일한 서비스를 다시 선택하여 추가 신청을 진행합니다.\n\n또는 고객센터(1:1 문의)를 통해 동시 예약을 도와드릴 수 있습니다."
      },
    ],
    // 간편결제
    [
      {
        "question": "간편 결제 이용 방법이 궁금해요.",
        "answer": "간편 결제는 다음과 같이 이용하실 수 있습니다:\n\n1. 서비스 신청 시 결제 단계에서 '간편결제'를 선택합니다.\n2. 처음 이용하시는 경우 카드 정보를 등록합니다.\n3. 이후에는 비밀번호 확인만으로 빠르게 결제가 가능합니다.\n\n간편결제는 신용카드, 체크카드를 등록하여 이용 가능하며, 한 번 등록해두시면 다음 결제 시 카드 정보를 다시 입력하실 필요가 없습니다."
      },
      {
        "question": "결제 취소는 어떻게 하나요?",
        "answer": "결제 취소는 다음 경로로 진행하실 수 있습니다:\n\n1. 앱 하단 메뉴에서 '예약 내역'을 선택합니다.\n2. 취소하실 예약을 선택합니다.\n3. 상세 화면에서 '예약 취소' 버튼을 선택합니다.\n4. 취소 사유를 선택하고 확인을 누르시면 취소가 완료됩니다.\n\n* 서비스 예정 시간 기준 24시간 이내 취소 시 취소 수수료가 발생할 수 있습니다.\n* 파트너가 이미 출발한 경우에는 앱에서 직접 취소가 불가능하며, 고객센터로 문의해 주세요."
      },
    ],
    // 기타 문의
    [
      {
        "question": "예약을 변경하고 싶어요.",
        "answer": "예약 변경은 다음과 같이 진행하실 수 있습니다:\n\n1. 앱 하단 메뉴에서 '예약 내역'을 선택합니다.\n2. 변경하실 예약을 선택합니다.\n3. 상세 화면에서 '예약 변경' 버튼을 선택합니다.\n4. 원하시는 날짜와 시간으로 변경 후 저장합니다.\n\n* 서비스 예정 시간 기준 48시간 이내에는 앱에서 직접 변경이 어려울 수 있으며, 이 경우 고객센터로 문의해 주세요."
      },
      {
        "question": "서비스 품질이 만족스럽지 않았어요.",
        "answer": "서비스에 불만족하셨다면 매우 죄송합니다. 다음과 같이 도움을 드릴 수 있습니다:\n\n1. 앱 하단 메뉴에서 '예약 내역'을 선택합니다.\n2. 해당 서비스를 선택하고 '불만족 신고' 버튼을 누릅니다.\n3. 구체적인 불만 사항을 작성해 주시면 확인 후 연락드립니다.\n\n또는 고객센터(1:1 문의)를 통해 직접 문의하실 수도 있습니다. 최대한 빠르게 문제 해결을 도와드리겠습니다."
      },
      {
        "question": "영수증이나 세금계산서를 발급받고 싶어요.",
        "answer": "영수증 및 세금계산서는 다음과 같이 발급받으실 수 있습니다:\n\n1. 앱 하단 메뉴에서 '예약 내역'을 선택합니다.\n2. 영수증이 필요한 서비스를 선택합니다.\n3. 상세 화면에서 '영수증/세금계산서 발급' 버튼을 선택합니다.\n4. 원하시는 발급 유형을 선택하고 필요 정보를 입력합니다.\n\n개인용 영수증은 즉시 발급되며, 세금계산서는 영업일 기준 1-2일 내에 발급됩니다."
      },
    ],
  ];

  int _selectedCategoryIndex = 0;
  Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      initialIndex: _selectedCategoryIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            '자주 묻는 질문',
            style: TextStyle(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              tabs: categories.map((category) => Tab(text: category)).toList(),
              labelColor: AppTheme.primaryColor,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelColor: AppTheme.secondaryText,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              onTap: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                  _expandedItems.clear(); // 탭 변경 시 펼친 항목 초기화
                });
              },
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: List.generate(
              categories.length,
                  (categoryIndex) => buildFAQList(categoryIndex),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFAQList(int categoryIndex) {
    final List<Map<String, String>> currentCategoryFAQs = faqData[categoryIndex];

    return currentCategoryFAQs.isEmpty
        ? Center(
      child: Text(
        '등록된 FAQ가 없습니다.',
        style: TextStyle(color: AppTheme.secondaryText),
      ),
    )
        : ListView.separated(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 12,
      ),
      itemCount: currentCategoryFAQs.length,
      separatorBuilder: (context, index) => SizedBox(height: 8),
      itemBuilder: (context, index) => buildFAQItem(currentCategoryFAQs[index], index, categoryIndex),
    );
  }

  Widget buildFAQItem(Map<String, String> faq, int index, int categoryIndex) {
    final itemKey = categoryIndex * 100 + index; // 카테고리별로 고유한 키 생성
    final bool isExpanded = _expandedItems.contains(itemKey);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      elevation: isExpanded ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpanded ? AppTheme.primaryColor : Colors.grey.shade200,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // 질문 부분
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedItems.remove(itemKey);
                  } else {
                    _expandedItems.add(itemKey);
                  }
                });
              },
                child: Container(  // Container 추가
                  decoration: BoxDecoration(
                    color: isExpanded ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,  // 배경색 설정
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: isExpanded ? Radius.zero : Radius.circular(12),
                      bottomRight: isExpanded ? Radius.zero : Radius.circular(12),
                    ),
                  ),
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            color: isExpanded ? Colors.white : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq["question"]!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          if (!isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '답변 보기',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isExpanded ? Icons.remove : Icons.add,
                          size: 16,
                          color: isExpanded ? AppTheme.primaryColor : AppTheme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 답변 부분 (펼쳐졌을 때만 표시)
            if (isExpanded)
              Container(
                width: double.infinity,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          faq["answer"]!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryText,
                            height: 1.6,
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
    );
  }
}