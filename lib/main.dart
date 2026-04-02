import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: HDREditor(), theme: ThemeData.dark(), debugShowCheckedModeBanner: false));

class HDREditor extends StatefulWidget {
  @override
  _HDREditorState createState() => _HDREditorState();
}

class _HDREditorState extends State<HDREditor> {
  bool isProcessing = false;
  String status = "Video Select Karen";

  Future<void> processVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() { isProcessing = true; status = "8K HDR Apply Ho Raha Hai..."; });
      String input = result.files.single.path!;
      final dir = await getTemporaryDirectory();
      final output = "${dir.path}/hdr_video_${DateTime.now().millisecondsSinceEpoch}.mp4";

      // Best 8K HDR Command (Red balance fixed)
      String cmd = "-i $input -vf unsharp=5:5:1.5,eq=contrast=1.4:saturation=1.5:brightness=0.05,colorbalance=rh=0.4:bh=0.5 -c:v libx264 -preset superfast $output";

      await FFmpegKit.execute(cmd).then((session) async {
        final returnCode = await session.getReturnCode();
        if (returnCode!.isSuccess()) {
          await GallerySaver.saveVideo(output);
          setState(() { isProcessing = false; status = "Gallery Mein Save Ho Gayi!"; });
        } else {
          setState(() { isProcessing = false; status = "Error! Dobara Try Karen."; });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("8K HDR SAVER"), backgroundColor: Colors.red[900]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 20),
            Text(status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], padding: EdgeInsets.all(20)),
              onPressed: isProcessing ? null : processVideo,
              child: Text("SELECT VIDEO", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
