class QuickSuggestions {
  static const List<Map<String, dynamic>> hydraulicQuestions = [
    // Pressure & Safety
    {
      'text': 'What is the working pressure for R2AT hose?',
      'category': 'pressure',
      'icon': 'pressure_gauge',
    },
    {
      'text': 'Safety factor for hydraulic systems',
      'category': 'safety',
      'icon': 'security',
    },
    {
      'text': 'Maximum pressure for 4SH spiral hose',
      'category': 'pressure',
      'icon': 'pressure_gauge',
    },

    // Hose Selection
    {
      'text': 'Difference between R1AT and R2AT hose',
      'category': 'selection',
      'icon': 'compare',
    },
    {
      'text': 'Which hose for high pressure application?',
      'category': 'selection',
      'icon': 'help',
    },
    {
      'text': 'Temperature rating for hydraulic hoses',
      'category': 'specifications',
      'icon': 'thermostat',
    },

    // Calculations
    {
      'text': 'How to calculate hose burst pressure?',
      'category': 'calculations',
      'icon': 'calculate',
    },
    {
      'text': 'Flow rate calculation for hydraulic system',
      'category': 'calculations',
      'icon': 'calculate',
    },
    {
      'text': 'Pressure drop in hydraulic lines',
      'category': 'calculations',
      'icon': 'trending_down',
    },

    // Troubleshooting
    {
      'text': 'Why is my hydraulic system overheating?',
      'category': 'troubleshooting',
      'icon': 'warning',
    },
    {
      'text': 'Hydraulic pump making noise',
      'category': 'troubleshooting',
      'icon': 'volume_up',
    },
    {
      'text': 'System pressure dropping suddenly',
      'category': 'troubleshooting',
      'icon': 'error',
    },

    // Standards & Compliance
    {
      'text': 'SAE 100R2AT specifications',
      'category': 'standards',
      'icon': 'rule',
    },
    {
      'text': 'DIN EN 853 hose standards',
      'category': 'standards',
      'icon': 'rule',
    },
    {
      'text': 'ISO 18752 hydraulic hose requirements',
      'category': 'standards',
      'icon': 'verified',
    },

    // Maintenance
    {
      'text': 'How often to replace hydraulic hoses?',
      'category': 'maintenance',
      'icon': 'schedule',
    },
    {
      'text': 'Signs of hydraulic hose failure',
      'category': 'maintenance',
      'icon': 'warning',
    },
    {
      'text': 'Proper hose storage procedures',
      'category': 'maintenance',
      'icon': 'inventory',
    },
  ];

  static List<String> getQuestionsByCategory(String category) {
    return hydraulicQuestions
        .where((q) => q['category'] == category)
        .map((q) => q['text'] as String)
        .toList();
  }

  static List<String> getRandomSuggestions({int count = 3}) {
    final shuffled = List.from(hydraulicQuestions)..shuffle();
    return shuffled.take(count).map((q) => q['text'] as String).toList();
  }

  static List<String> getContextualSuggestions(String userInput) {
    final input = userInput.toLowerCase();

    // Context-aware suggestions based on user input
    if (input.contains('pressure')) {
      return getQuestionsByCategory('pressure');
    } else if (input.contains('hose') ||
        input.contains('r1at') ||
        input.contains('r2at')) {
      return getQuestionsByCategory('selection');
    } else if (input.contains('calculate') || input.contains('formula')) {
      return getQuestionsByCategory('calculations');
    } else if (input.contains('problem') ||
        input.contains('issue') ||
        input.contains('not working')) {
      return getQuestionsByCategory('troubleshooting');
    } else if (input.contains('standard') ||
        input.contains('sae') ||
        input.contains('din')) {
      return getQuestionsByCategory('standards');
    } else if (input.contains('maintenance') ||
        input.contains('replace') ||
        input.contains('service')) {
      return getQuestionsByCategory('maintenance');
    }

    // Default to random suggestions
    return getRandomSuggestions();
  }
}
