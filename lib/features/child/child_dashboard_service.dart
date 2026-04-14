import 'package:yinling/features/child/mock_family_data.dart';

class ChildDashboardService {
  const ChildDashboardService();

  Future<ChildDashboardData> loadDashboard() async {
    return mockChildDashboardData;
  }
}
