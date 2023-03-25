import 'package:card_swiper/card_swiper.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/package_model.dart';
import 'package:efood_multivendor_restaurant/helper/color_coverter.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RenewSubscriptionScreen extends StatefulWidget {
  const RenewSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<RenewSubscriptionScreen> createState() => _RenewSubscriptionScreenState();
}

class _RenewSubscriptionScreenState extends State<RenewSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().getPackageList();
    Get.find<AuthController>().initializeRenew();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'change_subscription_plan'.tr, onBackPressed: (){
        if(Get.find<AuthController>().renewStatus != 'packages') {
          Get.find<AuthController>().renewChangePackage('packages');
        }else{
          Get.back();
        }
       }
      ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          int _activePackageIndex = -1;
          if(authController.packageModel != null){
            authController.packageModel.packages?.forEach((element) {
              if(authController.profileModel?.subscription?.package?.id == element.id){
                _activePackageIndex = authController.packageModel.packages!.indexOf(element);
                print('active package : $_activePackageIndex');
              }
            });
          }
          return authController.packageModel != null ? Column(children: [

            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  authController.renewStatus == 'packages' ? SizedBox(
                    height: 600,
                    child: (authController.packageModel.packages!.isNotEmpty && authController.packageModel.packages?.length != 0) ? Swiper(
                      itemCount: authController.packageModel.packages!.length,
                      itemWidth: context.width * 0.8,
                      itemHeight: 600.0,
                      index: _activePackageIndex,
                      layout: SwiperLayout.STACK,
                      onIndexChanged: (index){
                        authController.selectSubscriptionCard(index);
                        authController.activePackage(_activePackageIndex == index);
                      },
                      itemBuilder: (BuildContext context, int index){
                        Packages _package = authController.packageModel.packages![index];

                        Color _color = ColorConverter.stringToColor(_package.color!);

                        return GetBuilder<AuthController>(
                            builder: (authController) {

                              return Stack(clipBehavior: Clip.none, children: [

                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
                                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 10)],
                                  ),
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_LARGE, bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  child: SubscriptionCard(index: index, authController: authController, package: _package, color: _color),
                                ),

                                authController.activeSubscriptionIndex == index ? Positioned(
                                  top: 5, right: -10,
                                  child: Container(
                                    height: 40, width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: _color, border: Border.all(color: Theme.of(context).cardColor, width: 2),
                                    ),
                                    child: Icon(Icons.check, color: Theme.of(context).cardColor),
                                  ),
                                ) : SizedBox(),

                              ]);
                            }
                        );
                      },
                    ) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Images.empty_box, height: 150),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          Text('no_package_available'.tr),
                        ]),
                    ),
                  ) : Padding(
                    padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Column(children: [
                      refundPaymentCart(
                        title: 'pay_from_restaurant_wallet'.tr,
                        subTitle: '${PriceConverter.convertPrice(authController.profileModel!.balance!)} ${'payable_amount_in_your_wallet'.tr}',
                        index: 0,
                        onTap: (){
                          authController.setRefundPaymentIndex(0);
                        },
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                      // refundPaymentCart(title: 'pay_manually'.tr, index: 1, onTap: ()=> authController.setPaymentIndex(1)),
                    ]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.FONT_SIZE_LARGE, vertical: Dimensions.PADDING_SIZE_SMALL),
              child: (authController.packageModel.packages!.isNotEmpty && authController.packageModel.packages!.length != 0)
                  ? !authController.isLoading ? CustomButton(
                buttonText: (authController.isActivePackage && _activePackageIndex != -1) ? 'renew'.tr : 'shift_this_plan'.tr,
                onPressed: (){
                  if(authController.renewStatus == 'packages') {
                    authController.renewChangePackage('payment');
                  }else{
                    authController.renewBusinessPlan(authController.profileModel!.restaurants![0].id.toString());
                  }
                },
              ) : Center(child: CircularProgressIndicator()) : SizedBox(),
            )
          ]) : Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
  Widget refundPaymentCart({required String title, required String subTitle, required int index, required Function() onTap}){
    return GetBuilder<AuthController>(
        builder: (authController) {
          return Stack( clipBehavior: Clip.none, children: [
            InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                  border: authController.refundPaymentIndex == index ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
                  boxShadow: authController.refundPaymentIndex != index ? [BoxShadow(color: Colors.grey[300]!, blurRadius: 10)] : null,
                  color: authController.refundPaymentIndex == index ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
                ),
                alignment: Alignment.center,
                width: context.width,
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      title, style: robotoBold.copyWith(color: authController.refundPaymentIndex == index ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyText1?.color),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    Text(
                      subTitle, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyText1?.color),
                    ),

                ]),
              ),
            ),

            authController.paymentIndex == index ? Positioned(
              top: -8, right: -8,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                child: Icon(Icons.check, size: 18, color: Theme.of(context).cardColor),
              ),
            ) : SizedBox(),
          ],
          );
        }
    );
  }
}

