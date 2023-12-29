import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class ImageCard extends StatefulWidget {
  final List<String> linksImage;
  final double maxWidth;
  final double maxHeight;
  const ImageCard(
      {Key? key,
      required this.linksImage,
      required this.maxWidth,
      required this.maxHeight})
      : super(key: key);

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  int selectedPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      height: this.widget.maxHeight,
      width: this.widget.maxWidth,
      child: Stack(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  selectedPage = page;
                });
                // selectedPage = page;
                _pageController.animateToPage(
                  selectedPage,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
              children: List.generate(this.widget.linksImage.length, (index) {
                return Image.network(
                  this.widget.linksImage[index],
                  fit: BoxFit.cover,
                );
              }),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PageViewDotIndicator(
                currentItem: selectedPage,
                count: this.widget.linksImage.length,
                unselectedColor: Colors.grey,
                selectedColor: Colors.white,
                size: const Size(8, 8),
                duration: const Duration(milliseconds: 200),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 16,
          // ),
        ],
      ),
    );
  }
}
