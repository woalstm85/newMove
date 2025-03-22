import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_constants.dart';

class NewUserPromotionScreen extends StatefulWidget {
  const NewUserPromotionScreen({Key? key}) : super(key: key);

  @override
  _NewUserPromotionScreenState createState() => _NewUserPromotionScreenState();
}

class _NewUserPromotionScreenState extends State<NewUserPromotionScreen> {
  final String inviteCode = 'FRIEND2023';
  bool isCodeCopied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경으로 스타벅스 배너 이미지를 확장해서 사용
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          Image.asset(
            'assets/images/banner1.png',
            fit: BoxFit.cover,
          ),

          // 상단 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF00704A).withOpacity(0.6),
                  Color(0xFF00704A).withOpacity(0.9),
                  Color(0xFF00704A),
                ],
                stops: [0.1, 0.5, 0.8, 1.0],
              ),
            ),
          ),

          // 메인 콘텐츠
          SafeArea(
            child: Column(
              children: [
                // 상단 앱바
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        '친구 초대 이벤트',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          // 공유 기능
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('친구 초대 링크가 공유되었습니다.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 스크롤 가능한 콘텐츠
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // 이벤트 소개 섹션
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '친구를 초대하고',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '스타벅스 커피를 즐기세요!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '친구 초대 한 명당 아메리카노 쿠폰을 드립니다.\n최대 10명까지 초대 가능합니다.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 본문 카드 콘텐츠
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 초대 코드 카드
                              Card(
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        '나의 초대 코드',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                              12),
                                          border: Border.all(
                                            color: Color(0xFF00704A)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Text(
                                              inviteCode,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                                color: Color(0xFF00704A),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: inviteCode));
                                                setState(() {
                                                  isCodeCopied = true;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(content: Text(
                                                      '초대 코드가 복사되었습니다.')),
                                                );
                                                Future.delayed(
                                                    Duration(seconds: 2), () {
                                                  if (mounted) {
                                                    setState(() {
                                                      isCodeCopied = false;
                                                    });
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                isCodeCopied
                                                    ? Icons.check
                                                    : Icons.copy,
                                                size: 18,
                                              ),
                                              label: Text(isCodeCopied
                                                  ? '복사됨'
                                                  : '코드 복사'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isCodeCopied
                                                    ? Colors.green.shade700
                                                    : Color(0xFF00704A),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                // 카카오톡 공유 기능
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(content: Text(
                                                      '카카오톡으로 공유가 준비 중입니다.')),
                                                );
                                              },
                                              icon: Icon(
                                                  Icons.message, size: 18),
                                              label: Text('카카오톡'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xFFFEE500),
                                                foregroundColor: Colors.black87,
                                                elevation: 0,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                // 링크 공유 기능
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(content: Text(
                                                      '링크가 복사되었습니다.')),
                                                );
                                              },
                                              icon: Icon(Icons.link, size: 18),
                                              label: Text('링크 복사'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                elevation: 0,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                side: BorderSide(
                                                    color: Colors.grey
                                                        .shade300),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 혜택 설명 카드
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 24, bottom: 16),
                                child: Text(
                                  '이벤트 참여 방법',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              _buildStepCard(
                                step: 1,
                                title: '친구에게 초대 코드 공유',
                                description: '위 초대 코드를 복사하여 친구에게 공유하세요.',
                                icon: Icons.share_outlined,
                              ),

                              _buildStepCard(
                                step: 2,
                                title: '친구 회원가입',
                                description: '친구가 회원가입 시 귀하의 초대 코드를 입력하면 자동으로 참여됩니다.',
                                icon: Icons.person_add_alt_1_outlined,
                              ),

                              _buildStepCard(
                                step: 3,
                                title: '스타벅스 쿠폰 수령',
                                description: '친구의 가입이 확인되면 스타벅스 아메리카노 쿠폰이 발급됩니다.',
                                icon: Icons.local_cafe_outlined,
                              ),

                              // 내 초대 현황
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 24, bottom: 16),
                                child: Text(
                                  '내 초대 현황',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              Card(
                                elevation: 2,
                                shadowColor: Colors.black.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        children: [
                                          _buildStatItem(
                                            value: '2',
                                            label: '초대한 친구',
                                            icon: Icons.people_alt_outlined,
                                          ),
                                          Container(height: 40,
                                              width: 1,
                                              color: Colors.grey.shade300),
                                          _buildStatItem(
                                            value: '2',
                                            label: '발급된 쿠폰',
                                            icon: Icons.card_giftcard_outlined,
                                          ),
                                          Container(height: 40,
                                              width: 1,
                                              color: Colors.grey.shade300),
                                          _buildStatItem(
                                            value: '8',
                                            label: '남은 초대',
                                            icon: Icons.person_add_outlined,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      LinearProgressIndicator(
                                        value: 0.2,
                                        // 2/10 = 0.2
                                        backgroundColor: Colors.grey.shade200,
                                        color: Color(0xFF00704A),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '2/10 완료',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 유의사항
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 30, bottom: 8),
                                child: Text(
                                  '유의사항',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                              _buildNoticeItem(
                                  '초대받은 친구는 기존 회원이 아닌 신규 회원이어야 합니다.'),
                              _buildNoticeItem('한 사람당 최대 10명까지 친구 초대가 가능합니다.'),
                              _buildNoticeItem('스타벅스 쿠폰은 발급일로부터 30일간 유효합니다.'),
                              _buildNoticeItem(
                                  '본 이벤트는 당사 사정에 의해 예고 없이 변경될 수 있습니다.'),
                              _buildNoticeItem(
                                  '부정한 방법으로 참여 시 이벤트 참여가 제한되거나 혜택이 회수될 수 있습니다.'),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 유의사항 아이템 위젯
  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
// 통계 아이템 위젯
  Widget _buildStatItem({required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Color(0xFF00704A).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00704A),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }


// 단계 설명 카드 위젯
  Widget _buildStepCard({
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFF00704A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: TextStyle(
                    color: Color(0xFF00704A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(
              icon,
              color: Color(0xFF00704A),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}