import 'dart:io';

import 'package:efood_multivendor_restaurant/controller/addon_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/body/variation_model_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_time_picker.dart';
import 'package:efood_multivendor_restaurant/view/base/my_text_field.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/widget/variation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatefulWidget {
  final Product product;
  final List<Translation> translations;
  AddProductScreen({required this.product, required this.translations});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  TextEditingController _c = TextEditingController();
  final FocusNode _priceNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  bool? _update;
  Product? _product;

  @override
  void initState() {
    super.initState();

    _product = widget.product;
    _update = widget.product != null;
    Get.find<RestaurantController>().getAttributeList(widget.product);
    if(_update!) {
      _priceController.text = _product!.price.toString();
      _discountController.text = _product!.discount.toString();
      Get.find<RestaurantController>().setDiscountTypeIndex(_product?.discountType == 'percent' ? 0 : 1, false);
      Get.find<RestaurantController>().setVeg(_product?.veg == 1, false);
      Get.find<RestaurantController>().setExistingVariation(_product!.variations!);
    }else {
      Get.find<RestaurantController>().setEmptyVariationList();
      _product = Product();
      Get.find<RestaurantController>().pickImage(false, true);
      Get.find<RestaurantController>().setVeg(false, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.product != null ? 'update_food'.tr : 'add_food'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {

        return restController.categoryList != null ? Column(children: [

          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              MyTextField(
                hintText: 'price'.tr,
                controller: _priceController,
                focusNode: _priceNode,
                nextFocus: _discountNode,
                isAmount: true,
                amountIcon: true,
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Row(children: [

                Expanded(child: MyTextField(
                  hintText: 'discount'.tr,
                  controller: _discountController,
                  focusNode: _discountNode,
                  isAmount: true,
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'discount_type'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<String>(
                      value: restController.discountTypeIndex == 0 ? 'percent' : 'amount',
                      items: <String>['percent', 'amount'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.tr),
                        );
                      }).toList(),
                      onChanged: (value) {
                        restController.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Align(alignment: Alignment.centerLeft, child: Text(
                'food_type'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
              )),
              Row(children: [

                Expanded(child: RadioListTile<String>(
                  title: Text(
                    'non_veg'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                  ),
                  groupValue: restController.isVeg ? 'veg' : 'non_veg',
                  value: 'non_veg',
                  contentPadding: EdgeInsets.zero,
                  onChanged: (String? value) => restController.setVeg(value == 'veg', true),
                  activeColor: Theme.of(context).primaryColor,
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: RadioListTile<String>(
                  title: Text(
                    'veg'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                  ),
                  groupValue: restController.isVeg ? 'veg' : 'non_veg',
                  value: 'veg',
                  contentPadding: EdgeInsets.zero,
                  onChanged: (String? value) => restController.setVeg(value == 'veg', true),
                  activeColor: Theme.of(context).primaryColor,
                  dense: false,
                )),

              ]),
              SizedBox(height: Get.find<SplashController>().configModel.toggleVegNonVeg==true ? Dimensions.PADDING_SIZE_LARGE : 0),

              Row(children: [

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'category'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<int>(
                      value: restController.categoryIndex,
                      items: restController.categoryIds.map((int value) {
                        return DropdownMenuItem<int>(
                          value: restController.categoryIds.indexOf(value),
                          child: Text(value != 0 ? restController.categoryList[(restController.categoryIds.indexOf(value)-1)].name.toString() : 'Select'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        restController.setCategoryIndex(value!, true);
                        restController.getSubCategoryList(value != 0 ? restController.categoryList[value-1].id!: 0, Product());
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'sub_category'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                    ),
                    child: DropdownButton<int>(
                      value: restController.subCategoryIndex,
                      items: restController.subCategoryIds.map((int value) {
                        return DropdownMenuItem<int>(
                          value: restController.subCategoryIds.indexOf(value),
                          child: Text(value != 0 ? restController.subCategoryList[(restController.subCategoryIds.indexOf(value)-1)].name.toString() : 'Select'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        restController.setSubCategoryIndex(value!, true);
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                ])),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              VariationView(restController: restController, product: widget.product),

              Text(
                'addons'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              GetBuilder<AddonController>(builder: (addonController) {
                List<int> _addons = [];
                if(addonController.addonList != null) {
                  for(int index=0; index<addonController.addonList!.length; index++) {
                    if(addonController.addonList?[index].status == 1 && !restController.selectedAddons.contains(index)) {
                      _addons.add(index);
                    }
                  }
                }
                return Autocomplete<int>(
                  optionsBuilder: (TextEditingValue value) {
                    if(value.text.isEmpty) {
                      return Iterable<int>.empty();
                    }else {
                      return _addons.where((addon) => addonController.addonList![addon].name!.toLowerCase().contains(value.text.toLowerCase()));
                    }
                  },
                  fieldViewBuilder: (context, controller, node, onComplete) {
                    _c = controller;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: node,
                        onEditingComplete: () {
                          onComplete();
                          controller.text = '';
                        },
                        decoration: InputDecoration(
                          hintText: 'addons'.tr,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), borderSide: BorderSide.none),
                        ),
                      ),
                    );
                  },
                  displayStringForOption: (value) => addonController.addonList![value].name!,
                  onSelected: (int value) {
                    _c.text = '';
                    restController.setSelectedAddonIndex(value, true);
                    //_addons.removeAt(value);
                  },
                );
              }),
              SizedBox(height: restController.selectedAddons.length > 0 ? Dimensions.PADDING_SIZE_SMALL : 0),
              SizedBox(
                height: restController.selectedAddons.length > 0 ? 40 : 0,
                child: ListView.builder(
                  itemCount: restController.selectedAddons.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      ),
                      child: Row(children: [
                        GetBuilder<AddonController>(builder: (addonController) {
                          return Text(
                            addonController.addonList![restController.selectedAddons[index]].name.toString(),
                            style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                          );
                        }),
                        InkWell(
                          onTap: () => restController.removeAddon(index),
                          child: Padding(
                            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Row(children: [

                Expanded(child: CustomTimePicker(
                  title: 'available_time_starts'.tr, time: _product!.availableTimeStarts!,
                  onTimeChanged: (time) => _product!.availableTimeStarts = time,
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                Expanded(child: CustomTimePicker(
                  title: 'available_time_ends'.tr, time: _product!.availableTimeEnds!,
                  onTimeChanged: (time) => _product!.availableTimeEnds = time,
                )),

              ]),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Text(
                'food_image'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Align(alignment: Alignment.center, child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  child: restController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                    restController.pickedLogo!.path, width: 150, height: 120, fit: BoxFit.cover,
                  ) : Image.file(
                    File(restController.pickedLogo!.path), width: 150, height: 120, fit: BoxFit.cover,
                  ) : FadeInImage.assetNetwork(
                    placeholder: Images.placeholder,
                    image: '${Get.find<SplashController>().configModel.baseUrls?.productImageUrl}/${_product?.image != null ? _product?.image : ''}',
                    height: 120, width: 150, fit: BoxFit.cover,
                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 120, width: 150, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => restController.pickImage(true, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ])),

            ]),
          )),

          !restController.isLoading ? CustomButton(
            buttonText: _update==true ? 'update'.tr : 'submit'.tr,
            margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            height: 50,
            onPressed: () {
              String _price = _priceController.text.trim();
              String _discount = _discountController.text.trim();
              bool _variationNameEmpty = false;
              bool _variationMinMaxEmpty = false;
              bool _variationOptionNameEmpty = false;
              bool _variationOptionPriceEmpty = false;
              bool _variationMinLessThenZero = false;
              bool _variationMaxSmallThenMin = false;
              bool _variationMaxBigThenOptions = false;

              for(VariationModelBody variationModel in restController.variationList){
                if(variationModel.nameController!.text.isEmpty){
                  _variationNameEmpty = true;
                }else if(!variationModel.isSingle){
                  if(variationModel.minController!.text.isEmpty || variationModel.maxController!.text.isEmpty){
                    _variationMinMaxEmpty = true;
                  }else if(int.parse(variationModel.minController!.text) < 1){
                    _variationMinLessThenZero = true;
                  }else if(int.parse(variationModel.maxController!.text) < int.parse(variationModel.minController!.text)){
                    _variationMaxSmallThenMin = true;
                  }else if(int.parse(variationModel.maxController!.text) > variationModel.options!.length){
                    _variationMaxBigThenOptions = true;
                  }
                }else {
                  for(Option option in variationModel.options!){
                    if(option.optionNameController!.text.isEmpty){
                      _variationOptionNameEmpty = true;
                    }else if(option.optionPriceController!.text.isEmpty){
                      _variationOptionPriceEmpty = true;
                    }
                  }
                }
              }

              if(_price.isEmpty) {
                showCustomSnackBar('enter_food_price'.tr);
              }else if(_discount.isEmpty) {
                showCustomSnackBar('enter_food_discount'.tr);
              }else if(restController.categoryIndex == 0) {
                showCustomSnackBar('select_a_category'.tr);
              }else if(_variationNameEmpty){
                showCustomSnackBar('enter_name_for_every_variation'.tr);
              }else if(_variationMinMaxEmpty){
                showCustomSnackBar('enter_min_max_for_every_multipart_variation'.tr);
              }else if(_variationOptionNameEmpty){
                showCustomSnackBar('enter_option_name_for_every_variation'.tr);
              }else if(_variationOptionPriceEmpty){
                showCustomSnackBar('enter_option_price_for_every_variation'.tr);
              }else if(_variationMinLessThenZero){
                showCustomSnackBar('minimum_type_cant_be_less_then_1'.tr);
              }else if(_variationMaxSmallThenMin){
                showCustomSnackBar('max_type_cant_be_less_then_minimum_type'.tr);
              }else if(_variationMaxBigThenOptions){
                showCustomSnackBar('max_type_length_should_not_be_more_then_options_length'.tr);
              } else if(_product?.availableTimeStarts == null) {
                showCustomSnackBar('pick_start_time'.tr);
              }else if(_product?.availableTimeEnds == null) {
                showCustomSnackBar('pick_end_time'.tr);
              }else {
                _product?.veg = restController.isVeg ? 1 : 0;
                _product?.price = double.parse(_price);
                _product?.discount = double.parse(_discount);
                _product?.discountType = restController.discountTypeIndex == 0 ? 'percent' : 'amount';
                _product?.categoryIds = [];
                _product?.categoryIds?.add(CategoryIds(id: restController.categoryList[restController.categoryIndex-1].id.toString()));
                if(restController.subCategoryIndex != 0) {
                  _product?.categoryIds?.add(CategoryIds(id: restController.subCategoryList[restController.subCategoryIndex-1].id.toString()));
                }
                _product?.addOns = [];
                restController.selectedAddons.forEach((index) {
                  _product?.addOns?.add(Get.find<AddonController>().addonList![index]);
                });
                _product?.variations = [];
                if(restController.variationList.length > 0){
                  restController.variationList.forEach((variation) {
                    List<VariationOption> _values = [];
                    variation.options?.forEach((option) {
                      _values.add(VariationOption(level: option.optionNameController?.text.trim(), optionPrice: option.optionPriceController?.text.trim()));
                    });

                    _product?.variations?.add(Variation(
                      name: variation.nameController?.text.trim(), type: variation.isSingle ? 'single' : 'multi', min: variation.minController?.text.trim(),
                      max: variation.maxController?.text.trim(), required: variation.required ? 'on' : 'off', variationValues: _values),
                    );
                  });
                }
                _product?.translations = [];
                _product?.translations?.addAll(widget.translations);
                restController.addProduct(_product!, widget.product == null);
              }
            },
          ) : Center(child: CircularProgressIndicator()),

        ]) : Center(child: CircularProgressIndicator());
      }),
    );
  }
}