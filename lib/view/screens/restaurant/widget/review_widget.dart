import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/review_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:efood_multivendor_restaurant/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel review;
  final bool hasDivider;
  final bool fromRestaurant;
  ReviewWidget({required this.review, required this.hasDivider, required this.fromRestaurant});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Row(children: [

        ClipOval(
          child: CustomImage(
            image: '${fromRestaurant==true ? Get.find<SplashController>().configModel.baseUrls?.productImageUrl
                : Get.find<SplashController>().configModel.baseUrls?.customerImageUrl}/${fromRestaurant==true
                ? review.foodImage : review.customer != null ? review.customer?.image : ''}',
            height: 60, width: 60, fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text(
            fromRestaurant==true ? review.foodName! : review.customer != null ? '${review.customer != null ? review.customer?.fName : ''} ${review.customer
                != null ? review.customer?.lName : ''}' : 'customer_not_found'.tr,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: review.customer != null ? Theme.of(context).textTheme.headline1?.backgroundColor : Theme.of(context).disabledColor),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
  
          RatingBar(rating: review.rating!.toDouble(), ratingCount:0, size: 15),

          fromRestaurant ? Text(
            review.customerName != null ? review.customerName! : 'customer_not_found'.tr,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL, color: 
            review.customer != null ? Theme.of(context).textTheme.headline1?.color : Theme.of(context).disabledColor
            ),
          ) : SizedBox(),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

          Text(review.comment.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL, color: Theme.of(context).disabledColor)),

        ])),

      ]),

      hasDivider ? Padding(
        padding: EdgeInsets.only(left: 70),
        child: Divider(color: Theme.of(context).disabledColor),
      ) : SizedBox(),

    ]);
  }
}
