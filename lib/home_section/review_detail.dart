import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 숫자 포맷을 위한 패키지
import '../api_service.dart'; // ✅ API 모듈 가져오기

class ReviewDetailScreen extends StatefulWidget {
  final String reviewId;

  const ReviewDetailScreen({super.key, required this.reviewId});

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  Map<String, dynamic>? review;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviewDetail();
  }

  Future<void> loadReviewDetail() async {
    Map<String, dynamic>? fetchedReview = await ApiService.fetchReviewDetail(widget.reviewId);
    setState(() {
      review = fetchedReview;
      isLoading = false;
    });
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy.MM.dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String formatAmount(int? amount) {
    if (amount == null) return '';
    return NumberFormat('#,###').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '리뷰보기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : review == null
            ? const Center(child: Text('리뷰 정보를 불러오지 못했습니다.'))
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(review!['startCnt'] ?? 0, (index) {
                            return const Icon(
                              Icons.star,
                              color: Colors.blue,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(review!['serviceDt'] ?? ''),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildDetailRow('서비스', review!['serviceNm']),
                    buildDetailRow('파트너', review!['parterNm']),
                    buildDetailRow('금액', formatAmount(review!['amount'])),
                    buildDetailRow('건물', review!['buildingNm']),
                    buildDetailRow('한줄평', review!['comments']),
                    const SizedBox(height: 16),
                    Text(
                      review!['contents'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              data ?? '',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}