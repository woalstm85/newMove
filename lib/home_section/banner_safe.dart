import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class SafeMovingScreen extends StatelessWidget {
  const SafeMovingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '안전한 이사 보장',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 헤더 이미지 섹션
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5C6BC0).withOpacity(0.8),
                    Color(0xFF7986CB).withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 배경 원형 장식
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),

                  // 헤더 내용
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "소중한 물품 안전 보장",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "안심하고 맡기는\n디딤돌 안전 이사",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 안전 이사 개요
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "안전한 이사, 디딤돌이 책임집니다",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "물품 손상 발생 시 신속한 보상과 처리로 고객님의 소중한 자산을 책임지겠습니다.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // 안전 보장 설명 카드
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF5C6BC0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF5C6BC0).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF5C6BC0),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "디딤돌 안전 보장 프로그램",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C6BC0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "모든 디딤돌 이사 서비스는 물품 손상에 대한 보상 프로그램이 기본 포함됩니다. 전문적인 포장과 운송 과정에서 최대한 안전하게 물품을 다루겠습니다.",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 안전 보장 서비스 내용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "안전 보장 서비스",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildServiceCard(
                    title: "전문 포장 서비스",
                    description: "파손 위험이 있는 물품은 전문 포장재와 기술로 안전하게 포장합니다.",
                    icon: Icons.inventory_2_outlined,
                  ),
                  SizedBox(height: 16),

                  _buildServiceCard(
                    title: "손상 물품 보상",
                    description: "이사 과정에서 발생한 물품 손상은 최대 500만원까지 보상해 드립니다.",
                    icon: Icons.payments_outlined,
                  ),
                  SizedBox(height: 16),

                  _buildServiceCard(
                    title: "추가 보험 옵션",
                    description: "고가의 물품이 많은 경우, 추가 보험 가입으로 더 높은 보상 한도를 설정할 수 있습니다.",
                    icon: Icons.add_chart,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 보상 프로세스 섹션
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Text(
                    "보상 프로세스",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "손상된 물품에 대한 보상 절차",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  SizedBox(height: 32),

                  // 보상 단계
                  _buildCompensationStep(
                    number: 1,
                    title: "손상 신고",
                    description: "물품 손상 발견 시 24시간 이내에 앱이나 고객센터로 신고합니다.",
                  ),

                  SizedBox(height: 16),

                  _buildCompensationStep(
                    number: 2,
                    title: "손상 확인",
                    description: "담당자가 손상 상태를 확인하고 보상 범위를 결정합니다.",
                  ),

                  SizedBox(height: 16),

                  _buildCompensationStep(
                    number: 3,
                    title: "보상 처리",
                    description: "확인 후 3일 이내에 보상금 지급 또는 수리 서비스를 제공합니다.",
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 안전한 이사를 위한 팁 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "안전한 이사를 위한 팁",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "이사 전 준비하면 좋은 사항들",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),

                  // 팁 목록
                  _buildTipItem(
                    tip: "고가의 물품이나 귀중품은 미리 알려주세요.",
                  ),
                  _buildTipItem(
                    tip: "파손되기 쉬운 물품은 별도로 표시해 주세요.",
                  ),
                  _buildTipItem(
                    tip: "전자제품은 가능한 원래 포장재를 보관하면 좋습니다.",
                  ),
                  _buildTipItem(
                    tip: "이사 당일 중요한 서류나 귀중품은 직접 챙겨주세요.",
                  ),
                  _buildTipItem(
                    tip: "이사 후 24시간 이내에 모든 물품을 확인해 주세요.",
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // FAQ 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "자주 묻는 질문",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildFaqItem(
                    question: "모든 물품이 보상 대상인가요?",
                    answer: "귀중품, 현금, 유가증권 등 일부 품목은 보상 대상에서 제외됩니다. 자세한 내용은 서비스 이용 약관을 참고해 주세요.",
                  ),
                  SizedBox(height: 12),

                  _buildFaqItem(
                    question: "언제까지 손상 신고를 해야 하나요?",
                    answer: "물품 인수 후 24시간 이내에 신고해 주셔야 원활한 보상 처리가 가능합니다.",
                  ),
                  SizedBox(height: 12),

                  _buildFaqItem(
                    question: "보상 한도를 높일 수 있나요?",
                    answer: "네, 추가 보험 옵션을 통해 보상 한도를 높일 수 있습니다. 이사 서비스 예약 시 문의해 주세요.",
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // 하단 배너: 문의하기
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5C6BC0).withOpacity(0.7),
                    Color(0xFF7986CB).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5C6BC0).withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.headset_mic_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "더 궁금한 점이 있으신가요?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "안전 보장 서비스에 대해 더 자세히 알고 싶으시다면 고객센터로 문의해 주세요. 친절하게 안내해 드리겠습니다.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // 고객센터 문의 페이지로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF5C6BC0),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '문의하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 서비스 카드 위젯
  Widget _buildServiceCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF5C6BC0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF5C6BC0),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 보상 과정 단계 위젯
// 보상 과정 단계 위젯
  Widget _buildCompensationStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFF5C6BC0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 안전 팁 항목 위젯
  Widget _buildTipItem({required String tip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFF5C6BC0),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

// FAQ 아이템 위젯
  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF5C6BC0).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.question_answer_outlined,
                color: Color(0xFF5C6BC0),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}