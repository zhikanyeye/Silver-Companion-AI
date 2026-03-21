import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';

class ChildDashboardService {
  const ChildDashboardService();

  Future<ChildDashboardData> loadDashboard() async {
    return mockChildDashboardData;
  }
}
