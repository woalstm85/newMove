import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme_constants.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:flutter/services.dart' show rootBundle;

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({Key? key}) : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> with WidgetsBindingObserver {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isProcessing = false;

  // 이사 관련 가구 및 가전제품 목록 (영어 -> 한글 매핑)
  final Map<String, String> moveItemsMap = {
    'chair': '의자',
    'couch': '소파',
    'sofa': '소파',
    'bed': '침대',
    'dining table': '식탁',
    'refrigerator': '냉장고',
    'tv': 'TV',
    'television': 'TV',
    'laptop': '노트북',
    'book': '책',
    'clock': '시계',
    'vase': '화분',
    'potted plant': '화분',
    'cup': '컵/잔',
    'bottle': '병/용기',
    'desk': '책상',
    'table': '테이블',
    'monitor': '모니터',
    'keyboard': '키보드',
    'mouse': '마우스',
    'microwave': '전자레인지',
    'oven': '오븐',
    'toaster': '토스터',
    'sink': '싱크대',
    'washer': '세탁기',
    'washing machine': '세탁기',
    'dryer': '건조기',
    'toilet': '변기',
    'bathtub': '욕조',
    'shower': '샤워기',
    'cabinet': '캐비닛',
    'wardrobe': '옷장',
    'closet': '옷장',
    'bookshelf': '책장',
    'fan': '선풍기',
    'air conditioner': '에어컨',
    'lamp': '램프',
    'light': '조명',
    'drawer': '서랍장',
    'computer': '컴퓨터',
    'desk chair': '사무용 의자',
    'armchair': '안락의자',
    'dresser': '화장대',
    'mirror': '거울',
    'stool': '스툴',
    'ottoman': '오토만',
    'pillow': '베개',
    'blanket': '이불',
    'curtain': '커튼',
    'blind': '블라인드',
    'rug': '러그',
    'carpet': '카펫',
    'bench': '벤치',
    'piano': '피아노',
    'television set': 'TV 세트',
    'picture frame': '액자',
    'artwork': '예술품',
  };

  // 인식된 물체 저장 리스트
  List<RecognizedItem> currentDetectedItems = [];
  List<RecognizedItem> historyItems = [];
  bool showHistoryPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      if (mounted) {
        setState(() {
          isCameraInitialized = true;
        });
      }
    }
  }

  Future<void> _captureAndDetect() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        // UI 업데이트를 위해 처리 중임을 표시
        setState(() {
          isProcessing = true;
        });

        // 사진 촬영
        final XFile photo = await cameraController!.takePicture();
        final File imageFile = File(photo.path);

        // Google Cloud Vision API로 이미지 분석 (서비스 계정 사용)
        await analyzeImageWithServiceAccount(imageFile);

      } catch (e) {
        print('Image capture error: $e');
        _showErrorSnackBar('이미지 촬영 중 오류가 발생했습니다.');
      } finally {
        if (mounted) {
          setState(() {
            isProcessing = false;
          });
        }
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isProcessing = true;
      });

      try {
        final File imageFile = File(image.path);
        await analyzeImageWithServiceAccount(imageFile);
      } catch (e) {
        print('Gallery image processing error: $e');
        _showErrorSnackBar('갤러리 이미지 처리 중 오류가 발생했습니다.');
      } finally {
        if (mounted) {
          setState(() {
            isProcessing = false;
          });
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> analyzeImageWithServiceAccount(File imageFile) async {
    try {
      // 서비스 계정 자격 증명 로드
      final serviceAccountJson = await rootBundle.loadString('assets/service_account_key.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

      // 인증된 HTTP 클라이언트 가져오기
      final scopes = [vision.VisionApi.cloudVisionScope];
      final httpClient = await clientViaServiceAccount(credentials, scopes);

      // Vision API 클라이언트 생성
      final visionApi = vision.VisionApi(httpClient);

      // 이미지 파일을 바이트로 읽기
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 객체 감지 특성 요청
      final objectLocalizationFeature = vision.Feature()
        ..type = 'OBJECT_LOCALIZATION'
        ..maxResults = 20;

      // 라벨 감지 특성 요청
      final labelDetectionFeature = vision.Feature()
        ..type = 'LABEL_DETECTION'
        ..maxResults = 20;

      // 이미지 소스 생성
      final image = vision.Image()..content = base64Image;

      // 주석 요청 생성
      final request = vision.AnnotateImageRequest()
        ..features = [objectLocalizationFeature, labelDetectionFeature]
        ..image = image;

      // 배치 요청 실행
      final batchRequest = vision.BatchAnnotateImagesRequest()..requests = [request];
      final response = await visionApi.images.annotate(batchRequest);

      // 결과 처리
      if (response.responses != null && response.responses!.isNotEmpty) {
        final annotateImageResponse = response.responses![0];

        // 결과 처리를 위한 항목 목록
        List<RecognizedItem> detectedItems = [];

        // 객체 인식 결과 처리
        if (annotateImageResponse.localizedObjectAnnotations != null) {
          for (var object in annotateImageResponse.localizedObjectAnnotations!) {
            final String name = object.name ?? '';
            final double confidence = (object.score ?? 0) * 100;

            // 이사 관련 물품인지 확인
            String koreanName = moveItemsMap[name.toLowerCase()] ?? name;

            // 중복 항목 확인
            bool isDuplicate = false;
            for (var item in detectedItems) {
              if (item.label == koreanName) {
                isDuplicate = true;
                if (item.confidence < confidence) {
                  item.confidence = confidence;
                }
                break;
              }
            }

            if (!isDuplicate && confidence > 60) {
              // 바운딩 박스 파싱
              Rect boundingBox = _parseBoundingBoxFromApi(object.boundingPoly);

              detectedItems.add(RecognizedItem(
                label: koreanName,
                englishLabel: name,
                confidence: confidence,
                boundingBox: boundingBox,
                timestamp: DateTime.now(),
              ));
            }
          }
        }

        // 라벨 감지 결과 처리
        if (annotateImageResponse.labelAnnotations != null) {
          for (var label in annotateImageResponse.labelAnnotations!) {
            final String name = label.description ?? '';
            final double confidence = (label.score ?? 0) * 100;

            // 이사 관련 물품인지 확인
            String? koreanName = moveItemsMap[name.toLowerCase()];
            if (koreanName != null) {
              // 중복 항목 확인
              bool isDuplicate = false;
              for (var item in detectedItems) {
                if (item.label == koreanName) {
                  isDuplicate = true;
                  break;
                }
              }

              if (!isDuplicate && confidence > 60) {
                detectedItems.add(RecognizedItem(
                  label: koreanName,
                  englishLabel: name,
                  confidence: confidence,
                  boundingBox: null, // Label Detection은 위치 정보가 없음
                  timestamp: DateTime.now(),
                ));
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            currentDetectedItems = detectedItems;

            // 히스토리에 추가
            for (var item in detectedItems) {
              bool isNewItem = true;
              for (var historyItem in historyItems) {
                if (historyItem.label == item.label) {
                  // 이미 있는 항목이면 신뢰도 업데이트 (더 높은 값으로)
                  if (historyItem.confidence < item.confidence) {
                    historyItem.confidence = item.confidence;
                    historyItem.timestamp = item.timestamp;
                  }
                  isNewItem = false;
                  break;
                }
              }

              if (isNewItem) {
                historyItems.add(item);
              }
            }
          });
        }
      } else {
        _showErrorSnackBar('인식 결과가 없습니다.');
      }

      // HTTP 클라이언트 닫기
      httpClient.close();
    } catch (e) {
      print('이미지 분석 오류: $e');
      _showErrorSnackBar('이미지 분석 중 오류가 발생했습니다. 상세: $e');
    }
  }

  Rect _parseBoundingBoxFromApi(vision.BoundingPoly? boundingPoly) {
    // 바운딩 박스가 없는 경우 기본값 반환
    if (boundingPoly == null || boundingPoly.normalizedVertices == null || boundingPoly.normalizedVertices!.isEmpty) {
      return Rect.fromLTRB(0, 0, 1, 1);
    }

    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;

    for (var vertex in boundingPoly.normalizedVertices!) {
      double x = vertex.x ?? 0.0;
      double y = vertex.y ?? 0.0;

      minX = minX > x ? x : minX;
      minY = minY > y ? y : minY;
      maxX = maxX < x ? x : maxX;
      maxY = maxY < y ? y : maxY;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Rect _parseBoundingBox(Map<String, dynamic> boundingPoly) {
    final vertices = boundingPoly['normalizedVertices'] as List;

    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;
    for (var vertex in vertices) {
      double x = vertex['x'] ?? 0.0;
      double y = vertex['y'] ?? 0.0;
      minX = minX > x ? x : minX;
      minY = minY > y ? y : minY;
      maxX = maxX < x ? x : maxX;
      maxY = maxY < y ? y : maxY;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // 인식 기록 패널 토글
  void _toggleHistoryPanel() {
    setState(() {
      showHistoryPanel = !showHistoryPanel;
    });
  }

  // 인식 기록 삭제
  void _clearRecognizedItems() {
    setState(() {
      historyItems.clear();
    });
  }

  // 날짜 포맷 변환
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea를 사용하여 하단 네비게이션 바와 겹치지 않도록 함
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          '사물 인식',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 인식된 물체 기록 버튼
          IconButton(
            icon: Icon(
              showHistoryPanel ? Icons.history_toggle_off : Icons.history,
              color: AppTheme.primaryColor,
            ),
            onPressed: _toggleHistoryPanel,
          ),
          // 갤러리에서 이미지 선택 버튼
          IconButton(
            icon: Icon(
              Icons.photo_library,
              color: AppTheme.primaryColor,
            ),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: SafeArea(
        child: isCameraInitialized
            ? Stack(
          children: [
            // 카메라 미리보기
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              ),
            ),

            // 인식된 물체 표시 오버레이
            if (currentDetectedItems.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: ObjectDetectionPainter(
                    currentDetectedItems,
                    Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.width / cameraController!.value.aspectRatio,
                    ),
                  ),
                ),
              ),

            // 하단 컨트롤 패널
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 현재 인식된 물체 정보 표시
                    if (currentDetectedItems.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '인식된 물건',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _buildDetectedItemChips(),
                            ),
                          ],
                        ),
                      ),

                    // 사진 촬영 안내
                    if (currentDetectedItems.isEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.warning,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '인식하려는 물건이 화면에 보이도록 위치시키고 촬영 버튼을 눌러주세요.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 컨트롤 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 가이드 텍스트
                        Expanded(
                          child: Text(
                            '이사할 물건을 인식하여 목록을 만들어보세요',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(width: 20),

                        // 사진 촬영 버튼
                        GestureDetector(
                          onTap: isProcessing ? null : _captureAndDetect,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: isProcessing ? AppTheme.subtleText : AppTheme.primaryColor,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isProcessing ? AppTheme.subtleText : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 로딩 인디케이터
            if (isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '물건 인식 중...',
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 인식 기록 패널
            if (showHistoryPanel)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 150, // 하단 컨트롤 패널 위까지만
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 패널 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '인식된 물건 목록',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          Row(
                            children: [
                              // 기록 삭제 버튼
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.error,
                                ),
                                onPressed: historyItems.isEmpty ? null : _clearRecognizedItems,
                              ),
                              // 패널 닫기 버튼
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppTheme.secondaryText,
                                ),
                                onPressed: _toggleHistoryPanel,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // 구분선
                      Divider(height: 16, thickness: 1),

                      // 인식된 물건 목록
                      Expanded(
                        child: historyItems.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppTheme.subtleText,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '아직 인식된 물건이 없습니다',
                                style: TextStyle(
                                  color: AppTheme.subtleText,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '카메라로 물건을 촬영해 보세요',
                                style: TextStyle(
                                  color: AppTheme.subtleText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                            : ListView.separated(
                          itemCount: historyItems.length,
                          separatorBuilder: (context, index) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = historyItems[historyItems.length - 1 - index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _getIconForItem(item.label),
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              subtitle: Text(
                                '정확도: ${item.confidence.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              trailing: Text(
                                _formatTime(item.timestamp),
                                style: TextStyle(
                                  color: AppTheme.subtleText,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
            : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  // 인식된 물체들에 대한 칩 위젯 생성
  List<Widget> _buildDetectedItemChips() {
    return currentDetectedItems.map((item) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIconForItem(item.label), size: 16, color: AppTheme.primaryColor),
            SizedBox(width: 6),
            Text(
              '${item.label} ${item.confidence.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // 아이템에 따른 아이콘 선택
  IconData _getIconForItem(String label) {
    switch (label) {
      case '의자':
      case '사무용 의자':
        return Icons.chair;
      case '소파':
      case '안락의자':
        return Icons.weekend;
      case '침대':
        return Icons.bed;
      case '식탁':
      case '테이블':
        return Icons.table_restaurant;
      case '냉장고':
        return Icons.kitchen;
      case 'TV':
      case 'TV 세트':
        return Icons.tv;
      case '노트북':
      case '컴퓨터':
        return Icons.laptop;
      case '책':
        return Icons.book;
      case '시계':
        return Icons.watch;
      case '화분':
        return Icons.local_florist;
      case '컵/잔':
        return Icons.local_cafe;
      case '병/용기':
        return Icons.liquor;
      case '책상':
        return Icons.desk;
      case '모니터':
        return Icons.monitor;
      case '키보드':
        return Icons.keyboard;
      case '마우스':
        return Icons.mouse;
      case '전자레인지':
        return Icons.microwave;
      case '오븐':
        return Icons.countertops;
      case '토스터':
        return Icons.kitchen;
      case '싱크대':
        return Icons.wash;
      case '세탁기':
        return Icons.local_laundry_service;
      case '건조기':
        return Icons.dry_cleaning;
      case '변기':
        return Icons.wc;
      case '욕조':
        return Icons.bathtub;
      case '샤워기':
        return Icons.shower;
      case '캐비닛':
      case '서랍장':
        return Icons.shelves;
      case '옷장':
      case '화장대':
        return Icons.door_sliding;
      case '선풍기':
        return Icons.cyclone;
      case '에어컨':
        return Icons.ac_unit;
      case '램프':
      case '조명':
        return Icons.lightbulb;
      case '책장':
        return Icons.shelves;
      case '거울':
        return Icons.motion_photos_on;
      case '액자':
      case '예술품':
        return Icons.image;
      case '피아노':
        return Icons.piano;
      case '베개':
        return Icons.airline_seat_individual_suite;
      case '이불':
      case '커튼':
      case '블라인드':
      case '러그':
      case '카펫':
      case '스툴':
      case '벤치':
      case '오토만':
        return Icons.chair_alt;
      default:
        return Icons.category;
    }
  }
}

// 인식된 물체 클래스
class RecognizedItem {
  final String label;
  final String englishLabel;
  double confidence;
  final Rect? boundingBox;
  DateTime timestamp;

  RecognizedItem({
    required this.label,
    required this.englishLabel,
    required this.confidence,
    this.boundingBox,
    required this.timestamp,
  });
}

// 감지된 물체 그리기 위한 CustomPainter
class ObjectDetectionPainter extends CustomPainter {
  final List<RecognizedItem> items;
  final Size absoluteImageSize;

  ObjectDetectionPainter(this.items, this.absoluteImageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint boxPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final RecognizedItem item in items) {
      if (item.boundingBox != null) {
        final Rect scaledRect = Rect.fromLTRB(
          item.boundingBox!.left * scaleX,
          item.boundingBox!.top * scaleY,
          item.boundingBox!.right * scaleX,
          item.boundingBox!.bottom * scaleY,
        );

        // 경계 상자 그리기
        canvas.drawRect(scaledRect, boxPaint);

        // 레이블 텍스트 준비
        final TextSpan span = TextSpan(
          text: '${item.label} ${item.confidence.toStringAsFixed(0)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: AppTheme.primaryColor,
          ),
        );

        final TextPainter textPainter = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // 라벨 배경 그리기
        Paint backgroundPaint = Paint()..color = AppTheme.primaryColor;
        Rect backgroundRect = Rect.fromLTWH(
          scaledRect.left - 1,
          scaledRect.top - textPainter.height - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        canvas.drawRect(backgroundRect, backgroundPaint);

        // 라벨 텍스트 그리기
        textPainter.paint(
          canvas,
          Offset(
            scaledRect.left + 4,
            scaledRect.top - textPainter.height,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ObjectDetectionPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}