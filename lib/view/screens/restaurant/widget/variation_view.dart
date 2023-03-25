import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class VariationView extends StatefulWidget {
  final RestaurantController restController;
  final Product product;
  const VariationView({Key? key, required this.restController, required this.product}) : super(key: key);

  @override
  State<VariationView> createState() => _VariationViewState();
}

class _VariationViewState extends State<VariationView> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'variation'.tr,
        style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

      widget.restController.variationList.length > 0 ? ListView.builder(
          itemCount: widget.restController.variationList.length,
          shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
        return Stack(children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                        hintText: 'name'.tr,
                        showTitle: true,
                        showShadow: true,
                        controller: widget.restController.variationList[index].nameController,
                      )
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
                      child: CheckboxListTile(
                          value: widget.restController.variationList[index].required,
                          title: Text('required'.tr),
                          tristate: true,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value){
                            widget.restController.setVariationRequired(index);
                          }),
                    ),
                  )
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('select_type'.tr, style: robotoMedium),

                  Row( children: [
                    InkWell(
                      onTap: () =>  widget.restController.changeSelectVariationType(index),
                      child: Row(children: [
                        Radio(
                          value: true,
                          groupValue: widget.restController.variationList[index].isSingle,
                          onChanged: (bool? value){
                            widget.restController.changeSelectVariationType(index);
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Text('single'.tr)
                      ]),
                    ),
                    SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                    InkWell(
                      onTap: () =>  widget.restController.changeSelectVariationType(index),
                      child: Row(children: [
                        Radio(
                          value: false,
                          groupValue: widget.restController.variationList[index].isSingle,
                          onChanged: (bool? value){
                            widget.restController.changeSelectVariationType(index);
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Text('multiple'.tr)
                      ]),
                    ),
                  ]),
                ]),

                Visibility(
                  visible: !widget.restController.variationList[index].isSingle,
                  child: Row(children: [
                    Flexible(
                        child: CustomTextField(
                          hintText: 'min'.tr,
                          showTitle: true,
                          showShadow: true,
                          inputType: TextInputType.number,
                          controller: widget.restController.variationList[index].minController,
                        )
                    ),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                    Flexible(
                      child: CustomTextField(
                        hintText: 'max',
                        inputType: TextInputType.number,
                        showTitle: true,
                        showShadow: true,
                        controller: widget.restController.variationList[index].maxController,
                      ),
                    ),

                  ]),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    ListView.builder(
                        itemCount: widget.restController.variationList[index].options?.length,
                        shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i){
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Row(children: [
                              Flexible(
                                flex: 4,
                                child: CustomTextField(
                                  hintText: 'option_name'.tr,
                                  showTitle: true,
                                  showShadow: true,
                                  controller: widget.restController.variationList[index].options?[i].optionNameController,
                                ),
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                              Flexible(
                                flex: 4,
                                child: CustomTextField(
                                  hintText: 'additional_price'.tr,
                                  showTitle: true,
                                  showShadow: true,
                                  controller: widget.restController.variationList[index].options?[i].optionPriceController,
                                  inputType: TextInputType.number,
                                  inputAction: TextInputAction.done,
                                ),
                              ),

                              Flexible(flex: 1, child: Padding(
                                padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                                child: widget.restController.variationList[index].options!.length > 1 ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () => widget.restController.removeOptionVariation(index, i),
                                ) : SizedBox(),
                              ),
                              )
                            ]),
                          );
                        }),

                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    InkWell(
                      onTap: (){
                        print('option added');
                        widget.restController.addOptionVariation(index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), border: Border.all(color: Theme.of(context).primaryColor)),
                        child: Text('add_new_option'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT)),
                      ),
                    ),
                  ]),
                ),

              ]),
            ),

          Align( alignment: Alignment.topRight,
            child: IconButton(icon: Icon(Icons.clear),
              onPressed: () => widget.restController.removeVariation(index),
            ),
          ),
        ]);
      }) : SizedBox(),


      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

      InkWell(
        onTap: () {
          print('variation add');
          widget.restController.addVariation();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_SMALL),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
          child: Text('${widget.restController.variationList.length > 0 ? 'add_new_variation'.tr : 'add_variation'.tr}', style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.FONT_SIZE_DEFAULT)),
        ),
      ),

      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

    ]);
  }
}
