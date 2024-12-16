import 'package:flutter/material.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:convert';
import 'package:skeletons/skeletons.dart';

class LikeButtonPost extends StatefulWidget {
  final String eventId;
  final String postId; //post id
  const LikeButtonPost({Key? key, required this.eventId, required this.postId})
      : super(key: key);

  @override
  State<LikeButtonPost> createState() => _LikeButtonPostState();
}

class _LikeButtonPostState extends State<LikeButtonPost> {
  APICalls api = APICalls();

  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: api.getItem('/v3/events/:0/:1/:2/:3',
            [api.getCurrentUser(), 'likepost', widget.eventId, widget.postId]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var response = [json.decode(snapshot.data.body)];
            _liked = response[0]["message"] == "Le ha dado like";
            return IconButton(
                iconSize: 20,
                color: _liked
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  // if (_liked) {
                  api.putItem('/v3/events/:0/:1/:2/:3', [
                    widget.eventId,
                    'post',
                    widget.postId,
                    'like'
                  ], {
                    "user_id": api.getCurrentUser()
                  }).then((value) => {
                        setState(() {
                          _liked = false;
                        })
                      });
                  // } else {
                  //   api.putItem('/v3/events/:0/:1', [
                  //     widget.id,
                  //     'like'
                  //   ], {
                  //     "user_id": api.getCurrentUser()
                  //   }).then((value) => {
                  //         setState(() {
                  //           _liked = true;
                  //         })
                  //       });
                  // }
                });
          } else {
            return const SkeletonItem(
              child: SkeletonAvatar(
                style: SkeletonAvatarStyle(
                    shape: BoxShape.circle, width: 20, height: 20),
              ),
            );
          }
        });
  }
}
