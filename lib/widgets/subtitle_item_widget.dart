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
          child: Text(subtitleInfo['SubFileName']),
        ),
        Divider()
      ]),
    );
  }
}
