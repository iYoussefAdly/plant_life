import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/disease_entity.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/repos/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  int _scanCounter = 0;

  @override
  Future<ApiResult<ScanResultEntity>> scanImage({
    required String imagePath,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      _scanCounter++;
      final result = switch (_scanCounter % 3) {
        0 => _buildHealthyResult(imagePath),
        1 => _buildSingleDiseaseResult(imagePath),
        _ => _buildMultipleDiseaseResult(imagePath),
      };

      return Success(result);
    } catch (e) {
      return const Error(ServerFailure('Failed to analyze image'));
    }
  }

  @override
  Future<ApiResult<List<ScanResultEntity>>> getScanHistory() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final now = DateTime.now();
      final history = [
        ScanResultEntity(
          id: 'scan-1',
          imagePath: '',
          status: ScanStatus.diseased,
          diseases: const [
            DiseaseEntity(
              name: 'Powdery Mildew',
              confidence: 0.89,
              description: 'White powdery spots on leaves and stems',
            ),
          ],
          scannedAt: now.subtract(const Duration(hours: 2)),
        ),
        ScanResultEntity(
          id: 'scan-2',
          imagePath: '',
          status: ScanStatus.healthy,
          diseases: const [],
          scannedAt: now.subtract(const Duration(days: 1)),
        ),
        ScanResultEntity(
          id: 'scan-3',
          imagePath: '',
          status: ScanStatus.diseased,
          diseases: const [
            DiseaseEntity(
              name: 'Leaf Spot',
              confidence: 0.75,
              description: 'Brown or black spots on leaf surfaces',
            ),
            DiseaseEntity(
              name: 'Root Rot',
              confidence: 0.42,
              description: 'Yellowing leaves with mushy brown roots',
            ),
          ],
          scannedAt: now.subtract(const Duration(days: 3)),
        ),
        ScanResultEntity(
          id: 'scan-4',
          imagePath: '',
          status: ScanStatus.healthy,
          diseases: const [],
          scannedAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      return Success(history);
    } catch (e) {
      return const Error(ServerFailure('Failed to load scan history'));
    }
  }

  ScanResultEntity _buildHealthyResult(String imagePath) {
    return ScanResultEntity(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      status: ScanStatus.healthy,
      diseases: const [],
      scannedAt: DateTime.now(),
    );
  }

  ScanResultEntity _buildSingleDiseaseResult(String imagePath) {
    return ScanResultEntity(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      status: ScanStatus.diseased,
      diseases: const [
        DiseaseEntity(
          name: 'Powdery Mildew',
          confidence: 0.92,
          description:
              'A fungal disease causing white powdery coating on leaves. '
              'Thrives in warm, dry climates with high humidity.',
        ),
      ],
      scannedAt: DateTime.now(),
    );
  }

  ScanResultEntity _buildMultipleDiseaseResult(String imagePath) {
    return ScanResultEntity(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      status: ScanStatus.diseased,
      diseases: [
        const DiseaseEntity(
          name: 'Leaf Blight',
          confidence: 0.85,
          description:
              'Rapidly spreading brown lesions on leaves. '
              'Can cause significant defoliation if untreated.',
        ),
        DiseaseEntity(
          name: 'Bacterial Spot',
          confidence: 0.48,
          description:
              'Small, dark, water-soaked spots on leaves. '
              'Spread by splashing water and contaminated tools.',
        ),
      ],
      scannedAt: DateTime.now(),
    );
  }
}
