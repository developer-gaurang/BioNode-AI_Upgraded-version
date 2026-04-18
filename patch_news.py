import sys

with open(r"d:\Projects\My_Apps\bionode_ai\lib\main.dart", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Lines 2848-2920 (1-indexed) = indices 2847-2919 (0-indexed)
start_idx = 2847  # line 2848
end_idx = 2919    # line 2920 (inclusive)

new_method = '''  Future<void> _fetchGlobalNews() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _newsItems = []; });

    try {
      // Gemini-only: zero external HTTP, zero CORS issues on Flutter Web
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) throw Exception('No API key');

      final now = DateTime.now();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = \'\'\'Today is $dateStr. You are BioNode Global Pulse — an elite environmental & biotech intelligence feed.

Generate 10 real, factual, currently-relevant news items from 2024-2025 covering:
- Environment (climate change, pollution, renewable energy, ocean health, biodiversity)
- Biotechnology (CRISPR, synthetic biology, biofuels, medical biotech)
- AI for sustainability (climate modeling, species detection, energy optimization)

Rules: Base each item on REAL events. Include real organizations, scientists, countries, or journals. Be specific.

Output for each:
1. "title": Sharp factual headline, max 12 words.
2. "time": One of: "10m ago", "30m ago", "1h ago", "2h ago", "4h ago", "6h ago", "10h ago", "16h ago", "1d ago", "2d ago".
3. "source": Real outlet: Nature, Reuters, BBC Science, The Guardian, Science, TechCrunch, Bloomberg Green, WIRED, NPR, MIT Tech Review, AP, New Scientist.
4. "summary": Exactly 2 factual sentences with specific details (numbers, percentages, locations, names).

Return ONLY a raw JSON array — no markdown fences, no commentary:
[{"title":"...","time":"...","source":"...","summary":"..."}]\'\'\';

      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        String jsonTxt = response.text!.trim();
        final s = jsonTxt.indexOf('[');
        final e = jsonTxt.lastIndexOf(']');
        if (s != -1 && e != -1) jsonTxt = jsonTxt.substring(s, e + 1);
        final parsed = jsonDecode(jsonTxt) as List;
        if (mounted) {
          setState(() {
            _newsItems = parsed.map((e) => {
              'title': (e['title'] ?? '').toString(),
              'time': (e['time'] ?? '').toString(),
              'source': (e['source'] ?? '').toString(),
              'summary': (e['summary'] ?? '').toString(),
            }).toList();
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("Global Pulse Error: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }
'''

# Verify we're replacing the right lines
print(f"Line {start_idx+1}: {lines[start_idx].strip()}")
print(f"Line {end_idx+1}: {lines[end_idx].strip()}")

new_lines = lines[:start_idx] + [new_method] + lines[end_idx+1:]

with open(r"d:\Projects\My_Apps\bionode_ai\lib\main.dart", "w", encoding="utf-8", newline='\r\n') as f:
    f.writelines(new_lines)

print(f"Done. Old lines: {len(lines)}, New lines: {len(new_lines)}")
