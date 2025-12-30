import 'package:http/http.dart' as http;

/// Fetches the content from a given URL and extracts the HLS manifest URL
/// using a regular expression.
///
/// Returns the extracted HLS manifest URL as a String, or null if not found
/// or if an error occurs during fetching.
Future<String?> fetchAndExtractHlsManifestUrl(String url) async {
  final uri = Uri.parse(url);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final String body = response.body;

    // Regex to find "hlsManifestUrl":"<URL>"
    // It looks for a literal string "hlsManifestUrl":"
    // then captures any characters non-greedily (.*?) until the next "
    final RegExp regExp = RegExp(r'"hlsManifestUrl":"(.*?)"');
    final Match? match = regExp.firstMatch(body);

    if (match != null && match.groupCount >= 1) {
      final String? hlsManifestUrl = match.group(1);
      return hlsManifestUrl;
    } else {
      return null; // hlsManifestUrl not found
    }
  } else {
    return null;
  }
}

void main() async {
  const String targetUrl = 'https://m.youtube.com/watch?v=36YnV9STBqc';

  final String? hlsManifestUrl = await fetchAndExtractHlsManifestUrl(targetUrl);
  print(hlsManifestUrl);
}
