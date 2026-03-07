class ScamRules {
  static const List<String> _cjkKeywords = <String>[
    '转账',
    '汇款',
    '安全账户',
    '养老金',
    '验证码',
    '特效药',
  ];

  static const List<String> _englishKeywords = <String>[
    'transfer',
    'wire',
    'verification code',
  ];

  static bool containsRisk(String text) {
    if (text.trim().isEmpty) {
      return false;
    }

    final normalizedCjk = _normalizeForCjk(text);
    final hasCjkRisk = _cjkKeywords.any((keyword) {
      final normalizedKeyword = _normalizeForCjk(keyword);
      return normalizedCjk.contains(normalizedKeyword);
    });
    if (hasCjkRisk) {
      return true;
    }

    final normalizedEnglish = _normalizeForEnglish(text);
    return _englishKeywords.any((keyword) {
      final normalizedKeyword = _normalizeForEnglish(keyword);
      final pattern = RegExp(
        '(^| )${RegExp.escape(normalizedKeyword)}(?= |\$)',
      );
      return pattern.hasMatch(normalizedEnglish);
    });
  }

  static String _normalizeForCjk(String input) {
    final normalized = input.toLowerCase();
    return normalized.replaceAll(
      RegExp(r'[^a-z0-9\u4E00-\u9FFF]+'),
      '',
    );
  }

  static String _normalizeForEnglish(String input) {
    final normalized = input.toLowerCase();
    return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
