import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:skeletons/skeletons.dart';
import 'package:viajuntos/feature_event/models/post_model.dart';
import 'package:viajuntos/feature_event/screens/create_post.dart';
import 'package:viajuntos/feature_event/widgets/edit_event_form.dart';
import 'package:viajuntos/feature_event/widgets/image_card.dart';
import 'package:viajuntos/utils/api_controller.dart';

class InformationWallScreen extends StatefulWidget {
  final String id; //id of the event
  const InformationWallScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<InformationWallScreen> createState() => _InformationWallScreenState();
}

class _InformationWallScreenState extends State<InformationWallScreen> {
  late int selectedPage;
  late final PageController _pageController;
  Future<List<Post>> getAllPostOfEvent() async {
    final response = await APICalls()
        .getCollection('/v3/events/:0/post/', [widget.id], null);
    List<Post> posts = jsonDecode(response.body)
        .map<Post>((item) => Post.fromJson(item))
        .toList();
    return posts;
  }

  @override
  void initState() {
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('InformationWall').tr(),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder(
            future: APICalls()
                .getCollection('/v3/events/:0/post/', [widget.id], null),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<Post> posts = jsonDecode(snapshot.data.body)
                    .map<Post>((item) => Post.fromJson(item))
                    .toList();
                if (posts.length == 0) {
                  return Center(
                    child: Text('No posts yet').tr(),
                  );
                } else
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      print(posts[index].post_image_uris.toString());
                      String linksString =
                          posts[index].post_image_uris.toString();
                      String cleanString =
                          linksString.substring(1, linksString.length - 1);

                      List<String> linksList = cleanString.split(', ');
                      var a = linksList.length;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxWidth = constraints.maxWidth;
                                double maxHeight = 200;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        posts[index].user_id.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(
                                        posts[index].text.toString(),
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    ImageCard(
                                        linksImage: linksList,
                                        maxWidth: maxWidth,
                                        maxHeight: maxHeight),
                                    // Container(
                                    //   color: Colors.red,
                                    //   height: 200,
                                    //   width: maxWidth,
                                    //   child: Column(
                                    //     children: [
                                    //       Expanded(
                                    //         child: PageView(
                                    //           controller: _pageController,
                                    //           onPageChanged: (page) {
                                    //             // setState(() {
                                    //             //   selectedPage = page;
                                    //             // });
                                    //             selectedPage = page;
                                    //             _pageController.animateToPage(
                                    //               selectedPage,
                                    //               duration: const Duration(
                                    //                   milliseconds: 200),
                                    //               curve: Curves.easeInOut,
                                    //             );
                                    //           },
                                    //           children: List.generate(
                                    //               linksList.length, (index) {
                                    //             return Image.network(
                                    //               linksList[index],
                                    //               fit: BoxFit.cover,
                                    //             );
                                    //           }),
                                    //         ),
                                    //       ),
                                    //       Padding(
                                    //         padding: const EdgeInsets.symmetric(
                                    //             horizontal: 24),
                                    //         child: PageViewDotIndicator(
                                    //           currentItem: selectedPage,
                                    //           count: linksList.length,
                                    //           unselectedColor: Colors.grey,
                                    //           selectedColor: Colors.white,
                                    //           size: const Size(8, 8),
                                    //           duration: const Duration(
                                    //               milliseconds: 200),
                                    //           boxShape: BoxShape.circle,

                                    //           // onItemClicked: (index) {
                                    //           //   _pageController.animateToPage(
                                    //           //     index,
                                    //           //     duration: const Duration(
                                    //           //         milliseconds: 200),
                                    //           //     curve: Curves.easeInOut,
                                    //           //   );
                                    //           // },
                                    //         ),
                                    //       ),
                                    //       const SizedBox(
                                    //         height: 16,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Icon(Icons.thumb_up),
                                          Icon(Icons.comment),
                                          // Icon(Icons.share),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )),
                      );
                    },
                  );
              } else {
                return Row(
                  children: [
                    SkeletonItem(
                      child: SkeletonParagraph(
                        style: SkeletonParagraphStyle(
                          lines: 1,
                          spacing: 2,
                          lineStyle: SkeletonLineStyle(
                            width: 40,
                            height: 20,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Center(
                      child: SkeletonItem(
                        child: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            shape: BoxShape.circle,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreatePostScreen(id: widget.id)),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // ListView.builder(
      //   itemCount: 10,
      //   itemBuilder: (context, index) {
      //     return Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Container(
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(12.0),
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.grey.withOpacity(0.3),
      //               spreadRadius: 2,
      //               blurRadius: 5,
      //               offset: Offset(0, 3),
      //             ),
      //           ],
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: <Widget>[
      //             Padding(
      //               padding: const EdgeInsets.all(12.0),
      //               child: Text(
      //                 '用户名',
      //                 style: TextStyle(
      //                   fontWeight: FontWeight.bold,
      //                   fontSize: 16.0,
      //                 ),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 12.0),
      //               child: Text(
      //                 '这里是一些信息...',
      //                 style: TextStyle(fontSize: 14.0),
      //               ),
      //             ),
      //             SizedBox(height: 8.0),
      //             Image.network(
      //               'https://via.placeholder.com/300',
      //               fit: BoxFit.cover,
      //             ),
      //             SizedBox(height: 8.0),
      //             Padding(
      //               padding: const EdgeInsets.all(12.0),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: <Widget>[
      //                   Icon(Icons.thumb_up),
      //                   Icon(Icons.comment),
      //                   Icon(Icons.share),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
