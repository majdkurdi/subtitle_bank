import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SubtitleGetter with ChangeNotifier {
  List subs = [];

  Future getSubtitles(String id, String lang) async {
    List<dynamic> responseBody;

    HttpClient client = HttpClient();
    client.userAgent = 'obadasub';
    HttpClientRequest request = await client.getUrl(Uri.parse(
        'https://rest.opensubtitles.org/search/imdbid-$id/sublanguageid-$lang'));

    HttpClientResponse response = await request.close();
    var result = new StringBuffer();
    await for (var contents in response.transform(Utf8Decoder())) {
      result.write(contents);
    }
    responseBody = jsonDecode(result.toString());
    print(responseBody);
    return responseBody;
  }

  Future<dynamic> getMovieSubs(String title, String lang) async {
    final newtitle = title.replaceAll(' ', '+');
    Response resp = await get(Uri.parse(
        'http://www.omdbapi.com/?t=$newtitle&type=movie&apikey=61b1b953'));
    final movieData = jsonDecode(resp.body);
    print(movieData['imdbID']);
    if (movieData['Response'] == 'True') {
      var id = movieData['imdbID'];
      var subtitle = await getSubtitles(id, lang);
      subs = subtitle;
      if (subs.isEmpty) {
        return 'No Subtitles found!';
      }

      notifyListeners();
    }
    if (movieData['Response'] == 'False') {
      return 'Movie Not Found';
    }
  }

  Future<dynamic> getSeriesSubs(
      String title, String season, String episode, String lang) async {
    final newtitle = title.replaceAll(' ', '+');
    Response resp = await get(Uri.parse(
        'http://www.omdbapi.com/?t=$newtitle&type=series&apikey=61b1b953'));
    final seriesData = jsonDecode(resp.body);
    if (seriesData['Response'] == 'True') {
      var id = seriesData['imdbID'];

      Response finalresp = await get(Uri.parse(
          'http://www.omdbapi.com/?i=$id&Season=$season&Episode=$episode&apikey=61b1b953'));
      final episodeData = jsonDecode(finalresp.body);
      if (episodeData['Response'] == 'True') {
        var episodeId = episodeData['imdbID'];
        var subtitle = await getSubtitles(episodeId, lang);
        subs = subtitle;
        notifyListeners();
      } else if (episodeData['Response'] == 'False') {
        return 'episode not found!';
      }
    } else if (seriesData['Response'] == 'False') {
      return 'Series Not Found';
    }
  }
}
