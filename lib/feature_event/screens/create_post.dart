import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_event/widgets/image_selector.dart';
import 'package:viajuntos/utils/api_controller.dart';

class CreatePostScreen extends StatefulWidget {
  final String id;
  const CreatePostScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  List<String> images = [];
  List<String> uploadImages = [];
  TextEditingController textEditingController = TextEditingController();

  Future<void> publishPost() async {
    var response = await APICalls().postItem('/v3/events/:0/post/', [
      widget.id
    ], {
      "parent_post_id": "",
      "text": textEditingController.text,
      "post_image_uris": uploadImages
    });

    if (response == null) return;
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text("PublishSuccessTitle").tr(),
                  content: Text("PublishSuccessContent").tr(),
                  actions: [
                    TextButton(
                      child: Text('Ok').tr(),
                      onPressed: () =>
                          {Navigator.pop(context), Navigator.pop(context)},
                    )
                  ]));
    }
  }

  void _handleImagesChanged(List<String> newUploadImages) {
    setState(() {
      uploadImages = newUploadImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('NewPost').tr(),
        actions: <Widget>[
          IconButton(
            iconSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.send),
            onPressed: () async {
              publishPost();
            },
          )
        ],
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                color: Colors.grey[300],
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: constraints.maxHeight,
                ),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'EnterText'.tr(),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              );
            },
          ),
          SizedBox(height: 10),
          ImageSelector(
              path: "PostImages/" + widget.id,
              uploadImages: uploadImages,
              onImagesChanged: _handleImagesChanged)
        ],
      ),
    );
  }
}
