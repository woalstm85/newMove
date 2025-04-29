import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/notice/constants/notice_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/notice/models/notice_model.dart';
import 'package:MoveSmart/screen/more/sections/subpages/notice/widgets/notice_item.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  late List<NoticeModel> notices;
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    // 실제 애플리케이션에서는 API 또는 로컬 데이터베이스에서 가져옴
    notices = getSampleNotices();
  }

  void _toggleExpand(int index) {
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          NoticeConstants.appBarTitle,
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
      body: SafeArea(
        child: Column(
          children: [
            // 필터 섹션
            _buildHeaderSection(),

            Divider(height: 1),

            // 공지사항 목록
            Expanded(
              child: _buildNoticeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            NoticeConstants.totalCountFormat.replaceFirst('%d', notices.length.toString()),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          // 여기에 필터 드롭다운 또는 버튼 추가 가능
        ],
      ),
    );
  }

  Widget _buildNoticeList() {
    return ListView.separated(
      itemCount: notices.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        return NoticeItem(
          notice: notices[index],
          isExpanded: expandedIndex == index,
          onTap: () => _toggleExpand(index),
        );
      },
    );
  }
}