import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class FreeQuoteScreen extends StatelessWidget {
  const FreeQuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '무료 견적 서비스',
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
                    Color(0xFFFF9045).withOpacity(0.8),
                    Color(0xFFFFAB45).withOpacity(0.8),
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
                            Icons.calculate_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "방문 견적 무료 서비스",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "정확한 견적으로\n투명한 이사 비용",
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

            // 견적 서비스 설명
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "무료 견적 서비스란?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "디딤돌은 전문가의 방문 견적을 통해 정확하고 투명한 이사 비용을 안내해 드립니다.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // 이미지 및 설명 섹션
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 이미지 영역 (실제 이미지 대신 아이콘 사용)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            SizedBox(width: 16),
                            // 텍스트 영역
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "전문 견적사 방문",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "디딤돌의 인증된 전문가가 직접 방문하여 이사 물품을 확인합니다.",
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // 견적 서비스 장점
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "무료 견적의 장점",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildAdvantageCard(
                    title: "정확한 비용 산정",
                    description: "이사 물품의 양과 특성을 직접 확인하여 정확한 비용을 산정합니다.",
                    icon: Icons.check_circle_outline,
                  ),
                  SizedBox(height: 12),

                  _buildAdvantageCard(
                    title: "숨겨진 비용 없음",
                    description: "모든 서비스 항목과 비용을 투명하게 안내해 드립니다.",
                    icon: Icons.check_circle_outline,
                  ),
                  SizedBox(height: 12),

                  _buildAdvantageCard(
                    title: "맞춤형 서비스 제안",
                    description: "고객님의 이사 상황에 맞는 최적의 서비스를 제안해 드립니다.",
                    icon: Icons.check_circle_outline,
                  ),
                  SizedBox(height: 12),

                  _buildAdvantageCard(
                    title: "전문가의 조언",
                    description: "이사 준비 과정에서 필요한 팁과 조언을 받으실 수 있습니다.",
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 견적 과정 섹션
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Text(
                    "무료 견적 진행 과정",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "간편한 3단계로 무료 견적을 받아보세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  SizedBox(height: 32),

                  // 견적 단계
                  _buildProcessStep(
                    number: "1",
                    title: "견적 신청",
                    description: "앱에서 무료 견적 서비스를 신청합니다.",
                    icon: Icons.edit_note,
                  ),

                  _buildStepConnector(),

                  _buildProcessStep(
                    number: "2",
                    title: "방문 일정 협의",
                    description: "고객님의 편한 시간에 방문 일정을 잡습니다.",
                    icon: Icons.event_available,
                  ),

                  _buildStepConnector(),

                  _buildProcessStep(
                    number: "3",
                    title: "전문가 방문 견적",
                    description: "전문가가 방문하여 정확한 견적을 산출합니다.",
                    icon: Icons.calculate,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 고객 후기 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "고객 후기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "무료 견적 서비스를 이용한 고객님들의 후기입니다.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),

                  // 후기 카드들
                  _buildReviewCard(
                    name: "김동현",
                    rating: 5,
                    content: "정확한 견적으로 추가 비용 없이 이사를 완료했습니다. 전문가의 조언이 이사 준비에 큰 도움이 되었어요!",
                    date: "2주 전",
                  ),
                  SizedBox(height: 12),

                  _buildReviewCard(
                    name: "이지영",
                    rating: 5,
                    content: "방문 견적사가 매우 친절했고, 상세하게 설명해주셔서 좋았습니다. 견적 금액도 합리적이었어요.",
                    date: "1개월 전",
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // 하단 배너: 견적 신청하기
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.secondaryColor.withOpacity(0.7),
                    Color(0xFFFFAB45).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.2),
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
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "지금 바로 견적 받기",
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
                    "빠르고 정확한 무료 견적 서비스로 이사 준비를 시작해보세요. 원하시는 날짜와 시간에 전문가가 방문합니다.",
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
                        // 견적 신청 페이지로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.secondaryColor,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '무료 견적 신청',
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

  // 장점 카드 위젯
  Widget _buildAdvantageCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Icon(
            icon,
            color: AppTheme.secondaryColor,
            size: 20,
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

  // 프로세스 단계 위젯
  Widget _buildProcessStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 단계 연결선 위젯
  Widget _buildStepConnector() {
    return Container(
      margin: EdgeInsets.only(left: 24),
      width: 2,
      height: 30,
      color: AppTheme.secondaryColor.withOpacity(0.3),
    );
  }

  // 후기 카드 위젯
  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String content,
    required String date,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.subtleText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppTheme.warning,
                size: 18,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}