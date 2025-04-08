import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme_constants.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:flutter/services.dart' show rootBundle;

enum ScreenState { camera, processing, result }

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

  // 화면 상태 관리 변수들
  ScreenState currentScreen = ScreenState.camera;
  XFile? capturedImage; // 촬영된 이미지 저장

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

  Future<void> _captureAndAnalyze() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        // 사진 촬영
        final XFile photo = await cameraController!.takePicture();
        capturedImage = photo;

        // 이미지 분석
        await analyzeImageWithServiceAccount(File(photo.path));

        // 결과 화면으로 전환
        setState(() {
          currentScreen = ScreenState.result;
        });
      } catch (e) {
        print('Image capture error: $e');
        _showErrorSnackBar('이미지 촬영 중 오류가 발생했습니다.');
        setState(() {
          currentScreen = ScreenState.camera;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isProcessing = true;
        currentScreen = ScreenState.processing;
        capturedImage = image;
      });

      try {
        final File imageFile = File(image.path);
        await analyzeImageWithServiceAccount(imageFile);

        setState(() {
          currentScreen = ScreenState.result;
        });
      } catch (e) {
        print('Gallery image processing error: $e');
        _showErrorSnackBar('갤러리 이미지 처리 중 오류가 발생했습니다.');
        setState(() {
          currentScreen = ScreenState.camera;
        });
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> analyzeImageWithServiceAccount(File imageFile) async {
    try {
      // 서비스 계정 자격 증명 로드
      final serviceAccountJson = await rootBundle.loadString(
          'assets/service_account_key.json');
      final credentials = ServiceAccountCredentials.fromJson(
          jsonDecode(serviceAccountJson));

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
      final image = vision.Image()
        ..content = base64Image;

      // 주석 요청 생성
      final request = vision.AnnotateImageRequest()
        ..features = [objectLocalizationFeature, labelDetectionFeature]
        ..image = image;

      // 배치 요청 실행
      final batchRequest = vision.BatchAnnotateImagesRequest()
        ..requests = [request];
      final response = await visionApi.images.annotate(batchRequest);

      // 결과 처리
      if (response.responses != null && response.responses!.isNotEmpty) {
        final annotateImageResponse = response.responses![0];

        // 결과 처리를 위한 항목 목록
        List<RecognizedItem> detectedItems = [];

        // 객체 인식 결과 처리
        if (annotateImageResponse.localizedObjectAnnotations != null) {
          for (var object in annotateImageResponse
              .localizedObjectAnnotations!) {
            final String name = object.name ?? '';
            final double confidence = (object.score ?? 0) * 100;

            // 이사 관련 물품인지 확인
            String? koreanName = moveItemsMap[name.toLowerCase()];
            if (koreanName != null) {
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
                Rect boundingBox = _parseBoundingBoxFromApi(
                    object.boundingPoly);

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
        }

        // 라벨 감지 결과 처리 (물체 인식에서 놓친 항목을 위해)
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
                  boundingBox: null,
                  // Label Detection은 위치 정보가 없음
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
      _showErrorSnackBar('이미지 분석 중 오류가 발생했습니다.');
      rethrow;
    }
  }

  Rect _parseBoundingBoxFromApi(vision.BoundingPoly? boundingPoly) {
    // 바운딩 박스가 없는 경우 기본값 반환
    if (boundingPoly == null || boundingPoly.normalizedVertices == null ||
        boundingPoly.normalizedVertices!.isEmpty) {
      return Rect.fromLTRB(0.1, 0.1, 0.9, 0.9); // 테스트용 기본값 (화면의 90% 크기)
    }

    double minX = 1.0,
        minY = 1.0,
        maxX = 0.0,
        maxY = 0.0;

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
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString()
        .padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 결과 화면 또는 처리 화면일 경우, 카메라 화면으로 돌아가기
        if (currentScreen == ScreenState.result || currentScreen == ScreenState.processing) {
          setState(() {
            currentScreen = ScreenState.camera;
          });
          return false; // 뒤로가기 이벤트 처리 완료 (네비게이션 스택에서 pop하지 않음)
        }
        // 카메라 화면인 경우 정상적으로 뒤로가기 (홈으로 돌아감)
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('사물 인식', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // 결과 화면 또는 처리 화면일 경우, 카메라 화면으로 돌아가기
              if (currentScreen == ScreenState.result || currentScreen == ScreenState.processing) {
                setState(() {
                  currentScreen = ScreenState.camera;
                });
              } else {
                // 카메라 화면에서는 홈으로 돌아가기
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (currentScreen == ScreenState.result)
              IconButton(
                icon: Icon(Icons.history),
                onPressed: _toggleHistoryPanel,
                tooltip: '인식 기록',
              ),
          ],
        ),
        body: SafeArea(
          child: currentScreen == ScreenState.camera
              ? _buildCameraScreen()
              : currentScreen == ScreenState.processing
              ? _buildLoadingScreen()
              : _buildResultScreen(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _buildResultScreen() {
    if (capturedImage == null || currentDetectedItems.isEmpty) {
      // 결과가 없는 경우 처리
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.subtleText),
            SizedBox(height: 16),
            Text('인식 결과가 없습니다.', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentScreen = ScreenState.camera;
                });
              },
              child: Text('다시 촬영하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 기본 결과 화면 (기존 LayoutBuilder 부분)
        LayoutBuilder(
          builder: (context, constraints) {
            // 하단 정보창 높이 조정 (더 작게)
            final double infoBarHeight = constraints.maxHeight * 0.25;

            // 사용 가능한 이미지 영역 계산
            final double availableImageHeight = constraints.maxHeight - infoBarHeight;

            return Column(
              children: [
                // 이미지 및 바운딩 박스가 표시될 영역
                Container(
                  height: availableImageHeight,
                  width: constraints.maxWidth,
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 이미지 표시
                      Center(
                        child: Image.file(
                          File(capturedImage!.path),
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 바운딩 박스 오버레이
                      LayoutBuilder(
                        builder: (context, innerConstraints) {
                          return CustomPaint(
                            painter: ObjectDetectionPainter(
                              currentDetectedItems,
                              innerConstraints.biggest,
                            ),
                            size: innerConstraints.biggest,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 인식된 물체 정보 (하단 영역)
                Expanded( // Expanded로 변경하여 사용 가능한 공간에 맞추도록 함
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
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
                              '인식된 물건',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              '${currentDetectedItems.length}개 발견',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.subtleText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Expanded( // 목록이 스크롤되도록 Expanded 적용
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _buildDetectedItemChips(),
                          ),
                        ),
                        SizedBox(height: 12), // 간격 줄임
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  currentScreen = ScreenState.camera;
                                });
                              },
                              icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                              label: Text('다시 촬영'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // 물품 목록에 추가하는 로직
                                _showSuccessSnackBar('물품 목록에 추가되었습니다.');
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text('목록에 추가'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 히스토리 패널 (showHistoryPanel이 true일 때만 표시)
        if (showHistoryPanel)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '인식 기록',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: _toggleHistoryPanel,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // 히스토리 목록이 비어 있는 경우
                      if (historyItems.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history, size: 48, color: Colors.grey[300]),
                                SizedBox(height: 16),
                                Text(
                                  '인식 기록이 없습니다',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                      // 히스토리 목록 표시
                        Expanded(
                          child: ListView.separated(
                            itemCount: historyItems.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              final item = historyItems[index];
                              return ListTile(
                                leading: Icon(_getIconForItem(item.label), color: AppTheme.primaryColor),
                                title: Text(item.label),
                                subtitle: Text('신뢰도: ${item.confidence.toStringAsFixed(0)}%'),
                                trailing: Text(
                                  _formatTime(item.timestamp),
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 16),

                      // 기록 삭제 버튼
                      if (historyItems.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () {
                            _clearRecognizedItems();
                            _showSuccessSnackBar('인식 기록이 삭제되었습니다.');
                          },
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          label: Text('기록 삭제'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraScreen() {
    if (!isCameraInitialized) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Stack(
      children: [
        // 카메라 프리뷰
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: cameraController!.value.aspectRatio,
            child: CameraPreview(cameraController!),
          ),
        ),

        // 가이드 텍스트
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '인식하려는 물건이 화면 중앙에 오도록 위치시키고 촬영 버튼을 눌러주세요.',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // 촬영 및 갤러리 버튼
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 갤러리 버튼 (왼쪽)
              Padding(
                padding: EdgeInsets.only(right: 40),
                child: GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // 촬영 버튼 (중앙)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentScreen = ScreenState.processing;
                  });
                  _captureAndAnalyze();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppTheme.primaryColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
      default:
        return Icons.category;
    }
  }

// 인식된 물체들에 대한 칩 위젯 생성
  List<Widget> _buildDetectedItemChips() {
    return currentDetectedItems.map((item) {
      return Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  final Size displaySize;

  ObjectDetectionPainter(this.items, this.displaySize);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    // 각 사물별로 다른 색상을 사용하기 위한 색상 리스트
    final List<Color> boxColors = [
      Color(0xFF76FF03),  // 연두색 (기본)
      Color(0xFF2196F3),  // 파란색
      Color(0xFFFF9800),  // 주황색
      Color(0xFFE91E63),  // 핑크색
      Color(0xFF9C27B0),  // 보라색
      Color(0xFF00BCD4),  // 청록색
      Color(0xFFFFEB3B),  // 노란색
      Color(0xFF795548),  // 갈색
    ];

    for (int i = 0; i < items.length; i++) {
      final RecognizedItem item = items[i];
      if (item.boundingBox != null) {
        // 각 사물마다 다른 색상 사용 (인덱스에 따라 순환)
        final Color boxColor = boxColors[i % boxColors.length];

        // 바운딩 박스 Paint 설정
        final Paint boxPaint = Paint()
          ..color = boxColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

        // 원본 이미지에서의 상대적 좌표 (0~1 범위)를 화면 좌표로 변환
        final Rect scaledRect = Rect.fromLTRB(
          item.boundingBox!.left * displaySize.width,
          item.boundingBox!.top * displaySize.height,
          item.boundingBox!.right * displaySize.width,
          item.boundingBox!.bottom * displaySize.height,
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
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        );

        final TextPainter textPainter = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // 라벨 배경 그리기 (박스와 같은 색상의 반투명 배경)
        Paint backgroundPaint = Paint()..color = boxColor.withOpacity(0.7);
        Rect backgroundRect = Rect.fromLTWH(
          scaledRect.left,
          scaledRect.top - textPainter.height - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );

        // 텍스트가 화면 상단을 벗어나지 않도록 조정
        if (backgroundRect.top < 0) {
          backgroundRect = Rect.fromLTWH(
            scaledRect.left,
            scaledRect.bottom + 2,
            textPainter.width + 8,
            textPainter.height + 4,
          );

          // 텍스트 그리기 (하단에)
          canvas.drawRect(backgroundRect, backgroundPaint);
          textPainter.paint(
            canvas,
            Offset(
              scaledRect.left + 4,
              scaledRect.bottom + 4,
            ),
          );
        } else {
          // 텍스트 그리기 (상단에)
          canvas.drawRect(backgroundRect, backgroundPaint);
          textPainter.paint(
            canvas,
            Offset(
              scaledRect.left + 4,
              scaledRect.top - textPainter.height - 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ObjectDetectionPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}