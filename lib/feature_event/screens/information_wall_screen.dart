import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
import 'package:viajuntos/feature_event/models/post_model.dart';
import 'package:viajuntos/feature_event/screens/create_post.dart';
import 'package:viajuntos/feature_event/widgets/image_card.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/like_button_post.dart';

class InformationWallScreen extends StatefulWidget {
  final EventModel event; // id of the event
  const InformationWallScreen({Key? key, required this.event})
      : super(key: key);

  @override
  State<InformationWallScreen> createState() => _InformationWallScreenState();
}

class _InformationWallScreenState extends State<InformationWallScreen> {
  late int selectedPage;
  late final PageController _pageController;
  final APICalls api = APICalls();
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Future<ReviewRequestModel> _reviewFuture; // 存储 review
  late Future<List<Post>> _postsFuture; // 存储 posts
  late Future<List<User>> _userFuture; // 存储 user
  late List<Post> _cachedPosts;
  late Future<Map<String, List>> _postsAndReviewsFuture;
  final ValueNotifier<int> _selectedRatingNotifier =
      ValueNotifier<int>(0); // 使用 ValueNotifier 追踪评分

  Future<List<Post>> getAllPostOfEvent() async {
    final response = await APICalls().getCollectionNullable(
        '/v3/events/:0/post/', [widget.event.id.toString()], null);
    if (response == null) {
      List<Post> posts = [];
      return posts;
    }
    List<Post> posts = jsonDecode(response.body)
        .map<Post>((item) => Post.fromJson(item))
        .toList();
    return posts;
  }

  Future<void> createReview() async {
    final response = await api.postItem('/v3/events/review', [], {
      "event_id": widget.event.id.toString(),
      "user_id": api.getCurrentUser(),
      "comment": _commentController.text,
      "rating": _selectedRatingNotifier.value.toString(),
    });
    int a = 0;
  }

  @override
  void initState() {
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);
    super.initState();
    _reviewFuture = _fetchReviewData();
    _postsFuture = _fetchPostsData();
    _userFuture = _fetchUsersData();
    _postsAndReviewsFuture = _fetchPostsAndReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _selectedRatingNotifier.dispose(); // 释放 ValueNotifier
    super.dispose();
  }

  Future<Map<String, List>> _fetchPostsAndReviews() async {
    final List<Post> posts = await _fetchPostsData();
    final ReviewRequestModel reviewData = await _fetchReviewData();

    return {
      "posts": posts, // 确定为 List<Post>
      "reviews": reviewData.reviews ?? [], // 确定为 List
    };
  }

  Future<ReviewRequestModel> _fetchReviewData() async {
    final response = await APICalls().getCollectionNullable(
      '/v3/events/review',
      [],
      {"eventid": widget.event.id.toString()},
    );
    if (response == null) {
      return ReviewRequestModel(
        email: null,
        event: null,
        reviews: [],
        username: null,
      );
    }
    return ReviewRequestModel.fromJson(jsonDecode(response.body));
  }

  Future<List<Post>> _fetchPostsData() async {
    final response = await APICalls().getCollectionNullable(
        '/v3/events/:0/post/', [widget.event.id.toString()], null);
    if (response == null) {
      _cachedPosts = []; // 缓存为空列表
      return _cachedPosts;
    }
    _cachedPosts = jsonDecode(response.body)
        .map<Post>((item) => Post.fromJson(item))
        .toList();
    return _cachedPosts;
  }

  Future<List<User>> _fetchUsersData() async {
    final posts = await _postsFuture;
    final reviewRequest = await _reviewFuture;

    final postUserIds = posts.map((post) => post.user_id).toSet();

    final reviewUserIds = reviewRequest.reviews
            ?.map((review) => review.user_id)
            .toSet()
            .whereType<String>() ??
        {};

    final allUserIds = {...postUserIds, ...reviewUserIds};

    List<User> users = [];
    for (String userId in allUserIds.whereType<String>()) {
      final response =
          await APICalls().getItem("/v2/users/:0", [userId.toString()]);
      if (response != null) {
        users.add(User.fromJson(response.body));
      }
    }

    return users;
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        double starValue = rating - index;
        return Icon(
          starValue >= 1
              ? Icons.star
              : starValue >= 0.5
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: 36.0,
        );
      }),
    );
  }

  Widget _buildPostItem(
      Post post, List<String> linksList, BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: api.getItem("/v2/users/:0", [post.user_id.toString()]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  User user = User.fromJson(jsonDecode(snapshot.data.body));
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(id: user.id.toString()),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundImage: user.image_url != null
                              ? NetworkImage(user.image_url!)
                              : AssetImage('assets/noProfileImage.png')
                                  as ImageProvider,
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          user.username.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                post.text.toString(),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            if (linksList.isNotEmpty && linksList[0] != "")
              SizedBox(height: 8.0),
            if (linksList.isNotEmpty && linksList[0] != "")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageCard(
                    linksImage: linksList,
                    maxWidth: double.infinity,
                    maxHeight: 200,
                  ),
                ],
              ),
            // 添加时间显示，无论是否有图片
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                DateFormat('HH:mm, dd/MM/yyyy').format(post.datetime!),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review, BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: api.getItem("/v2/users/:0", [review.user_id.toString()]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  User user = User.fromJson(jsonDecode(snapshot.data.body));
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(id: user.id.toString()),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundImage: user.image_url != null
                              ? NetworkImage(user.image_url!)
                              : AssetImage('assets/noProfileImage.png')
                                  as ImageProvider,
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          user.username.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  _buildStarRating(review.rating!.toDouble()), // 星级评分
                  SizedBox(height: 8.0),
                  Text(
                    review.comment.toString(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                DateFormat('HH:mm, dd/MM/yyyy').format(review.datetime!),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.event.name!.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Created by '.tr() + widget.event.creator_name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8), // 添加头像和用户名之间的间距
            if (widget.event.creator_image_url != null &&
                widget.event.creator_image_url!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // 头像点击事件，跳转到创建者的个人资料页
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        id: widget.event.user_creator!,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 16, // 圆形头像的半径
                  backgroundImage:
                      NetworkImage(widget.event.creator_image_url!),
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: _reviewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      ReviewRequestModel reviewRequest = snapshot.data!;

                      // 计算平均评分
                      double? averageRating;
                      if (reviewRequest.reviews != null &&
                          reviewRequest.reviews!.isNotEmpty) {
                        averageRating = reviewRequest.reviews!
                                .map((review) => review.rating ?? 0)
                                .reduce((a, b) => a + b) /
                            reviewRequest.reviews!.length;
                      }

                      // 判断是否包含当前用户的评分
                      final currentUserReview =
                          reviewRequest.reviews?.firstWhere(
                        (review) => review.user_id == api.getCurrentUser(),
                        orElse: () => ReviewModel(
                          user_id: '', // 假设 user_id 是 String 类型
                          rating: 0,
                          comment: '',
                        ),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 平均评分始终显示在最上方
                          if (averageRating != null) ...[
                            Text(
                              "Average Rating:",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            _buildStarRating(averageRating),
                            SizedBox(height: 10.0),
                          ] else ...[
                            Center(
                              child: Text(
                                "NoRatingYet",
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                          // 判断是否为活动创建者
                          if (widget.event.user_creator.toString() !=
                              APICalls().getCurrentUser()) ...[
                            if (currentUserReview == null ||
                                currentUserReview.rating == 0) ...[
                              // 用户未评分的界面
                              Text(
                                "Rate this event:",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: _selectedRatingNotifier,
                                builder: (context, rating, _) {
                                  return Row(
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 36.0,
                                        ),
                                        onPressed: () {
                                          _selectedRatingNotifier.value =
                                              index + 1; // 更新评分
                                        },
                                      );
                                    }),
                                  );
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Leave a comment...",
                                ),
                                maxLines: 3,
                              ),
                              SizedBox(height: 10.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.secondary,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(200, 40),
                                ),
                                onPressed: () async {
                                  if (_selectedRatingNotifier.value == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please select a rating between 1 and 5 stars."),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_commentController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Comment cannot be empty.")),
                                    );
                                    return;
                                  }
                                  await createReview();
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InformationWallScreen(
                                        event: widget.event,
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Submit Review").tr(),
                              ),
                            ] else ...[
                              // 用户已评分的界面
                              Text(
                                "Your Review:",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (currentUserReview.rating ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 36.0,
                                  );
                                }),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                currentUserReview.comment ??
                                    "No comment provided.",
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.grey[700]),
                              ),
                            ],
                          ] else ...[
                            // 活动创建者的提示信息
                            Text(
                              "You are the event creator, rating is disabled.",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      );
                    } else {
                      return Center(
                        child: Text("No data available"),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _postsAndReviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final Map<String, List> data = snapshot.data!;
                      final List<Post> posts = data["posts"] as List<Post>;
                      final List<ReviewModel> reviews =
                          data["reviews"] as List<ReviewModel>;

                      if (posts.isEmpty && reviews.isEmpty) {
                        return Center(
                          child: Text('No post or review yet').tr(),
                        );
                      } else {
                        // 合并 posts 和 reviews，并按时间排序
                        final List<dynamic> mixedItems = [...posts, ...reviews];
                        mixedItems.sort((a, b) {
                          final aTime = a is Post
                              ? a.datetime
                              : (a as ReviewModel).datetime;
                          final bTime = b is Post
                              ? b.datetime
                              : (b as ReviewModel).datetime;
                          return bTime!.compareTo(aTime!); // 时间降序排序
                        });

                        return ListView.builder(
                          itemCount: mixedItems.length,
                          itemBuilder: (context, index) {
                            final item = mixedItems[index];
                            if (item is Post) {
                              // 显示 posts
                              String linksString =
                                  item.post_image_uris.toString();
                              String cleanString = linksString.substring(
                                  1, linksString.length - 1);
                              List<String> linksList = cleanString.split(', ');

                              return _buildPostItem(item, linksList, context);
                            } else if (item is ReviewModel) {
                              // 显示 reviews
                              return _buildReviewItem(item, context);
                            } else {
                              return SizedBox.shrink(); // 安全兜底
                            }
                          },
                        );
                      }
                    } else {
                      return Center(
                        child: Text('Error loading data').tr(),
                      );
                    }
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
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreatePostScreen(id: widget.event.id.toString())),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
