import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/chat/scam_rules.dart';

void main() {
  group('ScamRules.containsRisk', () {
    test('returns true for common anti-fraud keywords', () {
      expect(ScamRules.containsRisk('让我把养老金转账到安全账户'), isTrue);
      expect(ScamRules.containsRisk('特效药限时优惠，马上汇款'), isTrue);
      expect(ScamRules.containsRisk('这是验证码，请告诉我'), isTrue);
    });

    test('returns false for normal daily conversation', () {
      expect(ScamRules.containsRisk('今天天气不错，想去散步'), isFalse);
      expect(ScamRules.containsRisk('晚饭吃面条还是米饭'), isFalse);
    });

    test('is case and spacing tolerant', () {
      expect(ScamRules.containsRisk('请  立刻  转 账 到 安全 账户'), isTrue);
      expect(ScamRules.containsRisk('Please TRANSFER money now'), isTrue);
    });
  });
}
