import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

Future<String?> showServiceDialog(BuildContext context) {
  final List<Map<String, dynamic>> services = [
    {
      'id': 'S0010',
      'name': '소형이사',
      'description': '원룸, 투룸 등 소규모 이사',
      'icon': Icons.apartment,
    },
    {
      'id': 'S0020',
      'name': '가정이사',
      'description': '2~3인 가족 규모의 이사',
      'icon': Icons.home,
    },
    {
      'id': 'S0030',
      'name': '사무실이사',
      'description': '소규모 및 중대형 사무실 이사',
      'icon': Icons.business,
    },
    {
      'id': 'S0040',
      'name': '보관이사',
      'description': '일정 기간 물품 보관 후 이사',
      'icon': Icons.inventory_2,
    },
  ];

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      String? selectedServiceId;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        '서비스 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(width: 48), // 더미 공간으로 제목 중앙 정렬
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
                                '서비스 선택 안내',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '필요하신 서비스를 선택하시면 해당 서비스를 제공하는 파트너를 찾을 수 있습니다.',
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

                // 전체 선택 옵션
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedServiceId = '전체';
                    });
                    Navigator.pop(context, '전체');
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedServiceId == '전체'
                          ? AppTheme.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedServiceId == '전체'
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selectedServiceId == '전체'
                                ? Colors.white.withOpacity(0.2)
                                : AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.all_inclusive,
                            color: selectedServiceId == '전체'
                                ? Colors.white
                                : AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '전체 서비스',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedServiceId == '전체'
                                      ? Colors.white
                                      : AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '모든 서비스 유형을 제공하는 파트너',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedServiceId == '전체'
                                      ? Colors.white.withOpacity(0.8)
                                      : AppTheme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedServiceId == '전체')
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),

                // 서비스 목록
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final bool isSelected = selectedServiceId == service['id'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedServiceId = service['id'];
                            });
                            Navigator.pop(context, service['name']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : AppTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    service['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        service['description'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.8)
                                              : AppTheme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  bottom: true,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);  // 선택 없이 그냥 창 닫기
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              disabledBackgroundColor: AppTheme.subtleText,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppTheme.borderColor),  // 테두리 추가
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              '취소',
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
        },
      );
    },
  );
}