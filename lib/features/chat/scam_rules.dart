class ScamRules {
  static const List<String> _keywords = <String>[
    '转账',
    '汇款',
    '安全账户',
    '养老金',
    '验证码',
    '特效药',
    'transfer',
    'wire',
    'verification code',
  ];

  static bool containsRisk(String text) {
    if (text.trim().isEmpty) {
      return false;
    }

    final normalized = text.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return _keywords.any((keyword) {
      final k = keyword.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      return normalized.contains(k);
    });
  }
}
