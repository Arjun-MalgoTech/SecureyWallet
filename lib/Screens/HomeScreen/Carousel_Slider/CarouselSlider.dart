import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:securywallet/Crypto_Utils/Media_query/MediaQuery.dart';

class CarouselAdSlider extends StatefulWidget {
  CarouselAdSlider(this.corouselList);

  final List<Widget> corouselList;

  @override
  State<CarouselAdSlider> createState() => _CarouselAdSliderState();
}

class _CarouselAdSliderState extends State<CarouselAdSlider> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            carouselController: _controller,
            items: widget.corouselList
                .map(
                  (slide) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: slide,
                    ),
                  ),
                )
                .toList(),
            options: CarouselOptions(
              height: SizeConfig.height(context, 15),
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: 1,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) => setState(
                () => _currentIndex = index,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.corouselList.length,
                (int index) {
                  return Container(
                    width: 20,
                    height: 3,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _currentIndex == index
                            ? Color(0xFFB982FF)
                            : Colors.white
                        // : Colors.grey.withOpacity(0.5),
                        ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
