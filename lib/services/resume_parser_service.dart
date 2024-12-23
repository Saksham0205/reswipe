import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:convert';

class ResumeParserService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyCnLXSTQxMfGksxxK1gJKOSIdTGeaYMgNk',
  );

  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      String text = '';

      for (int i = 0; i < document.pages.count; i++) {
        text += await extractor.extractText(startPageIndex: i);
      }

      document.dispose();
      return text.trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  Future<Map<String, dynamic>> parseResumeWithGemini(String resumeText) async {
    try {
      final prompt = Content.text('''
You are an expert resume parser AI. Your task is to carefully analyze the provided resume text and extract specific information into a structured JSON format. Follow these strict guidelines:

1. Analyze Context:
   - Read the entire resume thoroughly
   - Understand the candidate's career progression
   - Identify key achievements and skills
   - Look for patterns in experience and education

2. Extraction Rules:
   - Extract EXACT text from resume when available
   - Use empty string "" for truly missing fields
   - Preserve original formatting of achievements
   - Keep dates in original format for experience
   - Extract skills as individual technical competencies
   - Format experience entries with company and duration
   - Include specific project details with technologies used

3. Required Fields:
{
  "fullName": "Complete name as written",
  "email": "Primary email address",
  "college": "Most recent educational institution",
  "collegeSession": "College years in YYYY-YYYY format",
  "education": "Highest qualification with specialization",
  "jobProfile": "Current or most recent job title",
  "skills": [
    "Individual technical skills",
    "Programming languages",
    "Tools and frameworks"
  ],
  "experience": [
    "Job Title at Company Name (Duration) - Key responsibilities",
    "Previous roles with similar format"
  ],
  "formattedAchievements": [
    "- Quantifiable achievement with metrics",
    "- Awards, certifications, recognition"
  ],
  "projects": [
    "Project Name: Description with technologies used",
    "Other significant projects"
  ]
}

Resume text to parse:
${resumeText.trim()}

Return ONLY the JSON object, no additional text.
''');

      final response = await _retryGenerateContent(prompt);
      final jsonString = _cleanJsonString(response.text);
      try {
        final Map<String, dynamic> parsed = json.decode(jsonString);
        return _validateAndCleanParsedData(parsed);
      } catch (jsonError) {
      throw Exception('Invalid JSON format: $jsonError\nResponse: $jsonString');
    }
    }catch (e) {
        print('❌ PDF Extraction Error: $e');
        throw Exception('Failed to parse resume: $e');
      }

  }

  Map<String, dynamic> _validateAndCleanParsedData(Map<String, dynamic> parsed) {
    final Map<String, dynamic> cleaned = {};

    // Handle string fields
    cleaned['fullName'] = parsed['fullName']?.toString() ?? '';
    cleaned['email'] = parsed['email']?.toString() ?? '';
    cleaned['college'] = parsed['college']?.toString() ?? '';
    cleaned['collegeSession'] = parsed['collegeSession']?.toString() ?? '';
    cleaned['education'] = parsed['education']?.toString() ?? '';
    cleaned['jobProfile'] = parsed['jobProfile']?.toString() ?? '';

    // Handle list fields
    cleaned['skills'] = (parsed['skills'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList() ?? [];

    cleaned['experience'] = (parsed['experience'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList() ?? [];

    cleaned['projects'] = (parsed['projects'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList() ?? [];

    cleaned['formattedAchievements'] = (parsed['formattedAchievements'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList() ?? [];

    return cleaned;
  }

  Future<GenerateContentResponse> _retryGenerateContent(
      Content prompt, {
        int maxAttempts = 3,
      }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await _model.generateContent([prompt]);
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) throw Exception('Failed after $maxAttempts attempts: $e');
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw Exception('Unexpected error in retry logic');
  }

  String _cleanJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    final startIndex = jsonString.indexOf('{');
    final endIndex = jsonString.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid JSON structure');
    }

    return jsonString.substring(startIndex, endIndex + 1);
  }
}