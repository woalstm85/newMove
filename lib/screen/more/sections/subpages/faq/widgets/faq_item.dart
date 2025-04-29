import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/models/faq_model.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/constants/faq_constants.dart';

class FAQItemWidget extends StatelessWidget {
  final FAQItemModel faqItem;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQItemWidget({
    Key? key,
    required this.faqItem,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: FAQConstants.listPadding,
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
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: isExpanded ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: isExpanded ? Radius.zero : Radius.circular(12),
                    bottomRight: isExpanded ? Radius.zero : Radius.circular(12),
                  ),
                ),
                padding: FAQConstants.itemPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionIcon(isExpanded),
                    SizedBox(width: FAQConstants.iconSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faqItem.question,
                            style: TextStyle(
                              fontSize: FAQConstants.questionFontSize,
                              fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          if (!isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                FAQConstants.viewAnswerText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildExpandIcon(isExpanded),
                  ],
                ),
              ),
            ),

            // 답변 부분 (펼쳐졌을 때만 표시)
            if (isExpanded) _buildAnswerSection(),
          ],
        ),
      ),
    );
  }

  // 질문 아이콘 위젯
  Widget _buildQuestionIcon(bool isExpanded) {
    return Container(
      width: FAQConstants.questionIconSize,
      height: FAQConstants.questionIconSize,
      decoration: BoxDecoration(
        color: isExpanded
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          FAQConstants.questionChar,
          style: TextStyle(
            color: isExpanded ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // 확장 아이콘 위젯
  Widget _buildExpandIcon(bool isExpanded) {
    return Container(
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
    );
  }

  // 답변 섹션 위젯
  Widget _buildAnswerSection() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: Padding(
        padding: FAQConstants.itemPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: FAQConstants.answerIconSize,
              height: FAQConstants.answerIconSize,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  FAQConstants.answerChar,
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: FAQConstants.iconSpacing),
            Expanded(
              child: Text(
                faqItem.answer,
                style: TextStyle(
                  fontSize: FAQConstants.answerFontSize,
                  color: AppTheme.primaryText,
                  height: FAQConstants.lineHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}