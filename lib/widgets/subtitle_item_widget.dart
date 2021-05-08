import 'package:flutter/material.dart';

import '../modals/downloader.dart';

class SubtitleItem extends StatelessWidget {
  final Map subtitleInfo;
  final Function startD;
  final Function endD;
  SubtitleItem(this.subtitleInfo, this.startD, this.endD);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () async {
            startD();
            try {
              Downloader downloader = Downloader();
              await downloader.downloadFile(
                  subtitleInfo['ZipDownloadLink'], subtitleInfo['SubFileName']);
            } catch (e) {
              print(e);
            }
            endD();
          },
          child: Row(
            children: [
              Expanded(flex: 6, child: Text(subtitleInfo['SubFileName'])),
              SizedBox(
                width: 10,
              ),
              Text('${(int.parse(subtitleInfo['SubSize']) / 1000).round()} KB'),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.file_download)
            ],
          ),
        ),
        Divider()
      ]),
    );
  }
}
