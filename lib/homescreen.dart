import 'package:drortho/components/carousel.dart';
import 'package:drortho/components/starRating.dart';
import 'package:drortho/components/testimonialsCarousel.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/sizeconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:drortho/utilities/notification.dart';
import 'package:dynamic_grid_view/dynamic_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../utilities/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    //notificationService.isTokenRefresh();
    notificationService.getDeviceToken().then((value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    openProductDetailScreen(int id, HomeProvider homeProvider) {
      homeProvider.getProductDetails(id);
      homeProvider.getUser();
      homeProvider.getProductGallery(id);
      Navigator.pushNamed(context, productDetailsRoute);
    }

    getYoutubeID(String url) {
      final regex = RegExp(
        r"https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube(?:-nocookie)?\.com\S*?[^\w\s-])([\w-]{11})(?=[^\w-]|$)(?![?=&+%\w.-]*(?:[^<>]*>|<\/a>))[?=&+%\w.-]*",
        caseSensitive: false,
      );

      try {
        if (regex.hasMatch(url)) {
          return regex.firstMatch(url)!.group(1);
        }
      } catch (e) {
        return "";
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                topCategoriesBar(homeProvider.categories, homeProvider),
                Stack(
                  children: [
                    Carousel(
                      width: width,
                      itemList: homeProvider.carousel,
                      onClick: (id) {
                        openProductDetailScreen(id, homeProvider);
                      },
                    ),
                    cardListing(homeProvider.featuredProducts, homeProvider,
                        openProductDetailScreen),
                  ],
                ),
                // youtubeListing(homeProvider, getYoutubeID),
                homeProvider.banner.isNotEmpty && homeProvider.banner[0] != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () {
                            openProductDetailScreen(
                                int.parse(homeProvider.banner[0]['id']),
                                homeProvider);
                          },
                          child: Image.network(
                            homeProvider.banner[0]['banner'],
                            fit: BoxFit.cover,
                            height: homeAdHeight,
                            width: width,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                newArrivals(homeProvider.products, homeProvider,
                    openProductDetailScreen),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orthoticRangeText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bottomBarColor,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                DynamicGridView(
                    width: width,
                    horizontalPadding: 16,
                    dataSet: homeProvider.products.toList(),
                    child: (context, index) {
                      final item = homeProvider.products[index];
                      final List images = item["images"];
                      return GestureDetector(
                        onTap: () {
                          openProductDetailScreen(item['id'], homeProvider);
                        },
                        child: SizedBox(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: cardBackgroundColor,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Shimmer(
                                    child: ShimmerLoading(
                                        isLoading: images.isEmpty,
                                        child: images.isEmpty
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SizedBox(
                                                  height: 60,
                                                  child: Image.network(
                                                    images[0]['src'],
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  child: Text(
                                    item['name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                TestimonialsCarousel(
                  width: width,
                  itemList: homeProvider.reviews,
                ),
                homeProvider.banner.length >= 2 &&
                        homeProvider.banner[0] != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            openProductDetailScreen(
                                int.parse(homeProvider.banner[1]['id']),
                                homeProvider);
                          },
                          child: Image.network(
                            homeProvider.banner[1]['banner'],
                            fit: BoxFit.cover,
                            height: homeAdHeight,
                            width: width,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Container(
                  height: whychooseusCardHeight,
                  width: width,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(whyusbgImage),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          whyDrOrtho,
                          style: TextStyle(
                              color: bottomBarColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          whychooseusItem(ayurvedaImage, ayurvedaText),
                          whychooseusItem(authenticImage, authenticityText),
                          whychooseusItem(
                              resultOrientedImage, resultOrientedText),
                          whychooseusItem(chemicalsImage, noChemicalsText),
                        ],
                      )
                    ],
                  ),
                ),

                youtubeListing(homeProvider, getYoutubeID),
                homeProvider.blogs.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Text(
                              blogText,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bottomBarColor,
                                  fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: blogHeight,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(right: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: homeProvider.blogs.length,
                              itemBuilder: (ctx, index) {
                                const wrapperWidth =
                                    (blogHeight * (4 / 3)) - 16;
                                final Map blogData = homeProvider.blogs[index];
                                final String htmlContent =
                                    blogData['content']['rendered'];
                                dom.Document document =
                                    htmlparser.parse(htmlContent);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, webviewRoute,
                                        arguments: {"url": blogData["link"]});
                                  },
                                  child: Container(
                                    width: wrapperWidth,
                                    margin: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)),
                                            child: Image.network(
                                              document
                                                  .getElementsByTagName("img")
                                                  .first
                                                  .attributes["src"]!,
                                              fit: BoxFit.cover,
                                              width: wrapperWidth,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: SizedBox(
                                            height: blogHeight * 0.30,
                                            child: Text(
                                              blogData['title']['rendered'] ??
                                                  "",
                                              style: const TextStyle(
                                                  color: bottomBarColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 2 + 10),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget whychooseusItem(String image, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: whychooseusCardHeight / 4,
            height: whychooseusCardHeight / 4,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                border: Border.all(
                    width: 1.2,
                    style: BorderStyle.solid,
                    color: bottomBarColor)),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              text,
              style: const TextStyle(color: bottomBarColor, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget youtubeListing(
      HomeProvider homeProvider, String? Function(String url) getYoutubeID) {
    return homeProvider.videos.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  youtubeVideosText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bottomBarColor,
                      fontSize: 16),
                ),
              ),
              SizedBox(
                height: youtubeCardHeight,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: homeProvider.videos.length,
                  itemBuilder: (ctx, index) {
                    String youtubeframe =
                        '<iframe width="${(youtubeCardHeight * (16 / 9)) + 16}" height="$youtubeCardHeight" src="https://www.youtube.com/embed/${getYoutubeID(homeProvider.videos[index])}" frameborder="0"></iframe>';

                    return Container(
                      clipBehavior: Clip.hardEdge,
                      width: (youtubeCardHeight * (16 / 9)) + 16,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      margin: const EdgeInsets.only(left: 16),
                      child: Html(
                        data: youtubeframe,
                        extensions: const [IframeHtmlExtension()],
                        style: {
                          '#': Style(
                            margin: Margins.zero,
                            fontSize: FontSize(8),
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget newArrivals(List products, HomeProvider homeProvider,
      Function openProductDetailScreen) {
    return products.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  newArrivalsText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bottomBarColor,
                      fontSize: 16),
                ),
              ),
              SizedBox(
                height: homeNewArrialsHeight,
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final List images = product['images'];
                    return GestureDetector(
                      onTap: () {
                        openProductDetailScreen(product['id'], homeProvider);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: index == 0 ? 16 : 4,
                          right: 4,
                        ),
                        width: homeNewArrialsHeight / 1.5,
                        height: homeNewArrialsHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: cardBackgroundColor,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Shimmer(
                                  child: ShimmerLoading(
                                      isLoading: images.isEmpty,
                                      child: images.isEmpty
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Image.network(
                                                images[0]['src'],
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(
                                          product['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget cardListing(List products, HomeProvider homeProvider,
      Function openProductDetailScreen) {
    return products.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(
              top: homeBannerHeight - (homeBannerHeight * .35),
            ),
            child: SizedBox(
              height: homeCardHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 10, right: 0),
                        width: homeCardHeight,
                        height: homeCardHeight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, allProductsRoute,
                                arguments: {
                                  "category": orthoticRangeText,
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: cardBackgroundColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/cat.png', scale: 8),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  'View Categories',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        )),
                    ListView.builder(
                      clipBehavior: Clip.none,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final List images = product['images'];
                        return GestureDetector(
                          onTap: () {
                            openProductDetailScreen(
                                product['id'], homeProvider);
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: index == 0 ? 8 : 4, right: 4),
                            width: homeCardHeight,
                            height: homeCardHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: cardBackgroundColor,
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: Shimmer(
                                          child: ShimmerLoading(
                                              isLoading: images.isEmpty,
                                              child: images.isEmpty
                                                  ? Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  cardBackgroundColor),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Image.network(
                                                        images[0]['src'],
                                                        // fit: BoxFit.cover,
                                                      ),
                                                    )),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          product['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  product['on_sale']
                                      ? Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            height: 16,
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                                color: themeRed,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5))),
                                            child: FittedBox(
                                              child: Text(
                                                "${(((int.parse(product['regular_price']) - int.parse(product['sale_price'])) / int.parse(product['regular_price'])) * 100).toStringAsFixed(0)}% off"
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget topCategoriesBar(List categories, HomeProvider homeProvider) {
    return categories.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 10, bottom: 5),
            height: categoryItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryItem = categories[index];

                return GestureDetector(
                  onTap: () {
                    homeProvider.getCategoryItems(categoryItem['id']);
                    Navigator.pushNamed(context, categoryItemRoute,
                        arguments: {"category": categoryItem['name'] ?? ""});
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: index == 0 ? 16 : 4, right: 4),
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            categoryItem['image']['src'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          categoryItem['name'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox.shrink();
  }
}

class AllProductsinGrid extends StatefulWidget {
  const AllProductsinGrid({
    super.key,
  });

  @override
  State<AllProductsinGrid> createState() => _AllProductsinGridState();
}

class _AllProductsinGridState extends State<AllProductsinGrid> {
  @override
  Widget build(
    BuildContext context,
  ) {
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

    openProductDetailScreen(int id, HomeProvider homeProvider) {
      homeProvider.getProductDetails(id);
      homeProvider.getUser();
      Navigator.pushNamed(context, productDetailsRoute);
    }

    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (_, homeProvider, __) {
                  List products = homeProvider.products;

                  return homeProvider.products.isNotEmpty
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 20),
                              child: Row(
                                children: [
                                  Text(
                                    args['category'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: bottomBarColor,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: homeProvider.products.length,
                                  itemBuilder: (context, index) {
                                    final item = products[index];
                                    final List images = item['images'];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          openProductDetailScreen(
                                              item['id'], homeProvider);
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        color:
                                                            cardBackgroundColor,
                                                      ),
                                                      width: 120,
                                                      height: 150,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Image.network(
                                                          images[0]['src'],
                                                          fit: BoxFit.contain,
                                                        ),
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item['name'],
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        SmoothStarRating(
                                                          color: startColor,
                                                          borderColor:
                                                              startColor,
                                                          rating: double
                                                                  .tryParse(item[
                                                                      'average_rating']) ??
                                                              0,
                                                          size: 20,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        2),
                                                                decoration: const BoxDecoration(
                                                                    color:
                                                                        bottomBarColor,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(2))),
                                                                child:
                                                                    const Text(
                                                                  "Bestseller",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          2 + 10),
                                                                ),
                                                              ),
                                                              const Text(
                                                                "From Dr. Ortho Store",
                                                                style: TextStyle(
                                                                    color:
                                                                        bottomBarColor,
                                                                    fontSize:
                                                                        2 + 10),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                            "Rs. ${item['regular_price']} ",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    2 + 15))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        )

                      // ? SingleChildScrollView(
                      //     padding: const EdgeInsets.only(bottom: 16),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Column(
                      //           children: [
                      //             ItemsGrid(
                      //               width: width,
                      //               gridItems: homeProvider.products,
                      //               title: args['category'] ?? "",
                      //               homeProvider: homeProvider,
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                args['category'] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: bottomBarColor,
                                    fontSize: 12),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox.shrink()),
                            Image.asset(emptyImage),
                            const Center(
                              child: Text(
                                noDataFoundText,
                                style: TextStyle(color: hintTextColor),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: const BoxDecoration(
                                    color: bottomBarColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Back to home",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(flex: 3, child: SizedBox.shrink()),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
