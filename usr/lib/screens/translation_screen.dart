import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController(text: 'https://api.openai.com/v1/chat/completions');
  final OpenAIService _openAIService = OpenAIService();
  
  String _outputText = '';
  bool _isLoading = false;
  String _selectedModel = 'gpt-3.5-turbo';
  
  // Language options
  final List<String> _languages = [
    'Chinese (Simplified)',
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Korean',
    'Russian',
    'Portuguese',
    'Italian',
    'Arabic',
    'Hindi',
  ];

  final List<String> _models = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4o',
    'gpt-4-turbo',
  ];

  String _sourceLanguage = 'Auto Detect';
  String _targetLanguage = 'English';

  @override
  void dispose() {
    _inputController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your OpenAI API Key in Settings')),
      );
      _showSettingsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _outputText = '';
    });

    try {
      final result = await _openAIService.translate(
        text: _inputController.text,
        targetLanguage: _targetLanguage,
        sourceLanguage: _sourceLanguage,
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
        model: _selectedModel,
      );

      setState(() {
        _outputText = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapLanguages() {
    if (_sourceLanguage == 'Auto Detect') return;
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language Selection Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sourceLanguage,
                          isExpanded: true,
                          items: ['Auto Detect', ..._languages].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _sourceLanguage = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                      onPressed: _swapLanguages,
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetLanguage,
                          isExpanded: true,
                          items: _languages.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _targetLanguage = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Input Area
              const Text('Original Text', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _inputController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter text to translate...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Translate Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _translate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            const Text('Translating...'),
                          ],
                        )
                      : const Text('Translate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Output Area
              const Text('Translation', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: SelectableText(
                  _outputText.isEmpty ? 'Translation will appear here...' : _outputText,
                  style: TextStyle(
                    color: _outputText.isEmpty ? Colors.grey : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OpenAI API Key', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'sk-...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  
                  const Text('Model', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _models.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedModel = newValue!;
                        // Update the parent state as well so it persists after dialog closes
                        this.setState(() {
                          _selectedModel = newValue!;
                        });
                      });
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  const Text('API Base URL (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Useful for proxies or custom endpoints', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.openai.com/v1/chat/completions',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }
      ),
    );
  }
}
