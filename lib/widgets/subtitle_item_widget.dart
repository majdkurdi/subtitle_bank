import 'package:flutter/material.dart';

import '../modals/downloader.dart';

class SubtitleItem extends StatelessWidget {
  final Map subtitleInfo;
  final Function startD;
  final Function endD;
  final Function showSnackB;
  SubtitleItem(this.subtitleInfo, this.startD, this.endD, this.showSnackB);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () async {
            bool done = false;
            startD();
            Downloader downloader = Downloader();
            try {
              await downloader.downloadFile(
                  subtitleInfo['ZipDownloadLink'], subtitleInfo['SubFileName']);
              done = true;
            } catch (e) {
              showSnackB('No Internet Connection');
              done = false;
            }

            endD(done);
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
