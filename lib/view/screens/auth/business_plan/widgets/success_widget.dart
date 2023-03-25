import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/widgets/registration_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SuccessWidget extends StatelessWidget {
  const SuccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

            authController.businessIndex == 1 ? RegistrationStepperWidget(status: authController.businessPlanStatus) : SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            SizedBox(height: context.height * 0.2),

            Image.asset(Images.checked, height: 90,width: 90),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            Text('congratulations'.tr, style: robotoBold.copyWith(fontSize: Dimensions.FONT_SIZE_OVER_LARGE)),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

            Text(
              'Your Registration Has been Completed Successfully.\n Admin will confirm your registration request / \n provide review within 48 hour',
              style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL), textAlign: TextAlign.center, softWrap: true,
            ),

          ]),
        );
      }
    );
  }
}
