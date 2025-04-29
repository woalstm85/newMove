import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/constants/faq_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/models/faq_model.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/widgets/faq_item.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  late List<FAQCategory> categories;
  int _selectedCategoryIndex = 0;
  Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    // 실제 애플리케이션에서는 API 또는 로컬 데이터베이스에서 가져옴
    categories = getSampleFAQs();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      initialIndex: _selectedCategoryIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: TabBarView(
            children: List.generate(
              categories.length,
                  (categoryIndex) => _buildFAQList(categoryIndex),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        FAQConstants.appBarTitle,
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
          tabs: categories.map((category) => Tab(text: category.name)).toList(),
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
    );
  }

  Widget _buildFAQList(int categoryIndex) {
    final FAQCategory category = categories[categoryIndex];
    final List<FAQItemModel> faqItems = category.items;

    return faqItems.isEmpty
        ? _buildEmptyState()
        : ListView.separated(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 12,
      ),
      itemCount: faqItems.length,
      separatorBuilder: (context, index) => SizedBox(height: FAQConstants.listItemSpacing),
      itemBuilder: (context, index) => _buildFAQItem(faqItems[index], index, categoryIndex),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        FAQConstants.noFAQsMessage,
        style: TextStyle(color: AppTheme.secondaryText),
      ),
    );
  }

  Widget _buildFAQItem(FAQItemModel faq, int index, int categoryIndex) {
    final itemKey = categoryIndex * 100 + index; // 카테고리별로 고유한 키 생성
    final bool isExpanded = _expandedItems.contains(itemKey);

    return FAQItemWidget(
      faqItem: faq,
      isExpanded: isExpanded,
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedItems.remove(itemKey);
          } else {
            _expandedItems.add(itemKey);
          }
        });
      },
    );
  }
}