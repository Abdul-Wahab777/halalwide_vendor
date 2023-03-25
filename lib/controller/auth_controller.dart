import 'dart:convert';
import 'dart:math';

import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/api/api_checker.dart';
import 'package:efood_multivendor_restaurant/data/model/body/business_plan_body.dart';
import 'package:efood_multivendor_restaurant/data/model/body/restaurant_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/address_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/package_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/place_details_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/prediction_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/response_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/zone_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor_restaurant/data/repository/auth_repo.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/business_plan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
   _notification = authRepo.isNotificationActive();
  }

  bool _isLoading = false;
  bool _notification = true;
  ProfileModel? _profileModel;
  XFile? _pickedFile;

  XFile? _pickedLogo;
  XFile? _pickedCover;
  LatLng? _restaurantLocation;
  int? _selectedZoneIndex = 0;
  List<ZoneModel> _zoneList=[];
  List<int> _zoneIds=[];
  List<PredictionModel> _predictionList = [];
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1);
  String _pickAddress = '';
  bool _loading = false;
  bool _inZone = false;
  int _zoneID = 0;
  int _businessIndex = Get.find<SplashController>().configModel.businessPlan != null && Get.find<SplashController>().configModel.businessPlan?.commission == 0 ? 1 : 0;
  PackageModel? _packageModel;
  int _activeSubscriptionIndex = 0;
  String _businessPlanStatus = 'business';
  int _paymentIndex = 0;
  String ?_subscribedType;
  bool isFirstTime = true;
  bool _showSubscriptionAlertDialog = true;
  bool? _isActivePackage;
  String _renewStatus = 'packages';
  int _refundPaymentIndex = 0;
  String? _expiredToken;

  bool get isLoading => _isLoading;
  bool get notification => _notification;
  ProfileModel? get profileModel => _profileModel!;
  XFile get pickedFile => _pickedFile!;

  XFile? get pickedLogo => _pickedLogo;
  XFile? get pickedCover => _pickedCover;
  LatLng? get restaurantLocation => _restaurantLocation;
  int get selectedZoneIndex => _selectedZoneIndex!;
  List<ZoneModel> get zoneList => _zoneList;
  List<int> get zoneIds => _zoneIds;
  List<PredictionModel> get predictionList => _predictionList;
  String get pickAddress => _pickAddress;
  bool get loading => _loading;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  int get businessIndex => _businessIndex;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;
  String get businessPlanStatus => _businessPlanStatus;
  int get paymentIndex => _paymentIndex;
  PackageModel get packageModel => _packageModel!;
  bool get showSubscriptionAlertDialog => _showSubscriptionAlertDialog;
  bool get isActivePackage => _isActivePackage!;
  String get renewStatus => _renewStatus;
  int get refundPaymentIndex => _refundPaymentIndex;

  void initializeRenew(){
    _renewStatus = 'packages';
    _isActivePackage = true;
  }

  void setRefundPaymentIndex(int index){
    _refundPaymentIndex = index;
    update();
  }

  void activePackage(bool status){
    _isActivePackage = status;
    update();
  }

  // int existPackage(){
  //   _packageModel.packages.forEach((element) {
  //     if(_profileModel.subscription.package.id == element.id){
  //       _activePackageIndex = authController.packageModel.packages.indexOf(element);
  //       print('active package : $_activePackageIndex');
  //     }
  //   })
  // }

  void renewChangePackage(String statusPackage){
    _renewStatus = statusPackage;
    update();
  }

  void closeAlertDialog(){
    if(_showSubscriptionAlertDialog) {
      _showSubscriptionAlertDialog = !_showSubscriptionAlertDialog;
      update();
    }
  }

  void showAlert({bool isUpdate = false}){
    _showSubscriptionAlertDialog = !_showSubscriptionAlertDialog;
    if(isUpdate){
      update();
    }
  }

  void showBackPressedDialogue(String title){
    Get.dialog(ConfirmationDialog(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
    ), useSafeArea: false);
  }

  void resetBusiness(){
    _businessIndex = Get.find<SplashController>().configModel.businessPlan != null && Get.find<SplashController>().configModel.businessPlan?.commission == 0 ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    isFirstTime = true;
    _paymentIndex = Get.find<SplashController>().configModel.freeTrialPeriodStatus == 0 ? 1 : 0;
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status){
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }

  Future<void> getPackageList() async {
    Response response = await authRepo.getPackageList();
    if (response.statusCode == 200) {
      _packageModel = null;
      _packageModel = PackageModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> submitBusinessPlan(int _restaurantId)async {
    String _businessPlan;
    if(businessIndex == 0){
      _businessPlan = 'commission';
      if(_restaurantId != null) {
        setUpBusinessPlan(BusinessPlanBody(businessPlan: _businessPlan, restaurantId: _restaurantId.toString(), type: _subscribedType!));
      }else{
        showCustomSnackBar('Restaurant id not provider');
      }
    }else{
      _businessPlanStatus = 'payment';
      if(!isFirstTime) {
        if (_businessPlanStatus == 'payment') {
          _businessPlan = 'subscription';
          int _packageId = _packageModel!.packages![_activeSubscriptionIndex].id!;
          String _payment = _paymentIndex == 0 ? 'free_trial' : 'paying_now';
          if(_restaurantId != null) {
            setUpBusinessPlan(BusinessPlanBody(businessPlan: _businessPlan,
                packageId: _packageId.toString(),
                restaurantId: _restaurantId.toString(),
                payment: _payment, type: _subscribedType!));
          }else{
            showCustomSnackBar('Restaurant id not provider');
          }
        } else {
          showCustomSnackBar('please_select_any_process'.tr);
        }
      }else{
        isFirstTime = false;
      }
    }

    update();
  }

  Future<ResponseModel> setUpBusinessPlan(BusinessPlanBody businessPlanBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.setUpBusinessPlan(businessPlanBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _businessPlanStatus = 'complete';
      showCustomSnackBar(response.body['message'], isError: false);
      responseModel = ResponseModel(true, response.body.toString());
      Future.delayed(Duration(seconds: 2),()=> Get.offAllNamed(RouteHelper.getSignInRoute()));
    } else {
      responseModel = ResponseModel(false, response.statusText??"");
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> renewBusinessPlan(String restaurantId) async {
    _isLoading = true;
    update();
    int _packageId = _packageModel!.packages![_activeSubscriptionIndex].id!;
    Map<String, String> body = {
      'package_id' : _packageId.toString(),
      'restaurant_id': restaurantId,
      'type': _isActivePackage==true ? 'renew' : 'null',
      'payment_type': _refundPaymentIndex == 0 ? 'wallet' : 'pay_now',
      'payment_method': '',
    };
    Map<String, String> _header={};
    if(_expiredToken != null){
      _header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_expiredToken'
      };
    }
    Response response = await authRepo.renewBusinessPlan(body, _header);
    ResponseModel? responseModel;
    if (response.statusCode == 200) {
      _renewStatus = 'packages';
      await getProfile();
      Get.back();
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return responseModel!;
  }

  Future<ResponseModel> login(String email, String password) async {
    _isLoading = true;
    update();
    Response response = await authRepo.login(email, password);
    ResponseModel? responseModel;
    if (response.statusCode == 200) {
      if(response.body['subscribed'] != null){
        int _restaurantId = response.body['subscribed']['restaurant_id'];
        _subscribedType = response.body['subscribed']['type'];
        Get.to(()=> BusinessPlanScreen(restaurantId: _restaurantId));
        responseModel = ResponseModel(false, 'no');
      }else{
        authRepo.saveUserToken(response.body['token'], response.body['zone_wise_topic']);
        await authRepo.updateToken();
        responseModel = ResponseModel(true, 'successful');
      }
    } else if(response.statusCode == 426){

      if(Get.find<SplashController>().configModel.businessPlan?.subscription == 1){
        _expiredToken = response.body['token'];
        _profileModel = ProfileModel(
          restaurants: [Restaurant(id: response.body['restaurant_id'])],
          balance: response.body['balance'] != null ? response.body['balance'].toDouble() : null,
          subscription: Subscription.fromJson(response.body['subscription']),
          subscriptionOtherData: SubscriptionOtherData.fromJson(response.body['subscription_other_data']),
        );
        Get.toNamed(RouteHelper.getSubscriptionViewRoute());
      }else{
        responseModel = ResponseModel(false, 'subscription_not_available_please_contact_with_admin'.tr);
      }
    } else {
      responseModel = ResponseModel(false, response.statusText??"");
    }
    _isLoading = false;
    update();
    return responseModel!;
  }

  Future<void> getProfile() async {
    Response response = await authRepo.getProfileInfo();
    if (response.statusCode == 200) {
      _profileModel = ProfileModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> updateUserInfo(ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    http.StreamedResponse response = await authRepo.updateProfile(updateUserModel, _pickedFile!, token);
    _isLoading = false;
    bool _isSuccess;
    if (response.statusCode == 200) {
      _profileModel = updateUserModel;
      showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      _isSuccess = true;
    } else {
      ApiChecker.checkApi(Response(statusCode: response.statusCode, statusText: '${response.statusCode} ${response.reasonPhrase}'));
      _isSuccess = false;
    }
    update();
    return _isSuccess;
  }

  void pickImage() async {
    _pickedFile = (await ImagePicker().pickImage(source: ImageSource.gallery))!;
    update();
  }

  void pickImageForReg(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    }else {
      if (isLogo) {
        _pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        _pickedCover = await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      update();
    }
  }

  Future<bool> changePassword(ProfileModel updatedUserModel, String password) async {
    _isLoading = true;
    update();
    bool _isSuccess;
    Response response = await authRepo.changePassword(updatedUserModel, password);
    _isLoading = false;
    if (response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('password_updated_successfully'.tr, isError: false);
      _isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      _isSuccess = false;
    }
    update();
    return _isSuccess;
  }

  Future<ResponseModel> forgetPassword(String email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassword(email);

    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<ResponseModel> verifyToken(String email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyToken(email, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String resetToken, String email, String password, String confirmPassword) async {
    _isLoading = true;
    update();
    Response response = await authRepo.resetPassword(resetToken, email, password, confirmPassword);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  String _verificationCode = '';

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    update();
  }


  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password) {
    authRepo.saveUserNumberAndPassword(number, password);
  }

  String getUserNumber() {
    return authRepo.getUserNumber() ;
  }
  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  bool setNotificationActive(bool isActive) {
    _notification = isActive;
    authRepo.setNotificationActive(isActive);
    update();
    return _notification;
  }

  void initData() {
    _pickedFile = null;
  }

  Future<void> toggleRestaurantClosedStatus() async {
    Response response = await authRepo.toggleRestaurantClosedStatus();
    if (response.statusCode == 200) {
      getProfile();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future removeVendor() async {
    _isLoading = true;
    update();
    Response response = await authRepo.deleteVendor();
    _isLoading = false;
    if (response.statusCode == 200) {
      showCustomSnackBar('your_account_remove_successfully'.tr,isError: false);
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }else{
      Get.back();
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _restaurantLocation = null;
    _zoneIds = [];
    Response response = await authRepo.getZoneList();
    if (response.statusCode == 200) {
      _zoneList = [];
      response.body.forEach((zone) => _zoneList.add(ZoneModel.fromJson(zone)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> registerRestaurant(RestaurantBody restaurantBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerRestaurant(restaurantBody, _pickedLogo!, _pickedCover!);
    if(response.statusCode == 200) {
      // Get.offAllNamed(RouteHelper.getInitialRoute());
      // showCustomSnackBar('restaurant_registration_successful'.tr, isError: false);
      int _restaurantId = response.body['restaurant_id'];
      Get.off(() => BusinessPlanScreen(restaurantId: _restaurantId));
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void setZoneIndex(int index) {
    _selectedZoneIndex = index;
    update();
  }

  void setLocation(LatLng location) async{
    ZoneResponseModel _response = await getZone(
      location.latitude.toString(), location.longitude.toString(), false,
    );
    if(_response != null && _response.isSuccess && _response.zoneIds.length > 0) {
      _restaurantLocation = location;
      _zoneIds = _response.zoneIds;
      for(int index=0; index<_zoneList.length; index++) {
        if(_zoneIds.contains(_zoneList[index].id)) {
          _selectedZoneIndex = index;
          break;
        }
      }
    }else {
      _restaurantLocation = null;
      _zoneIds = [];
    }
    update();
  }

  Future<void> zoomToFit(GoogleMapController controller, List<LatLng> list, {double padding = 0.5}) async {
    LatLngBounds _bounds = _computeBounds(list);
    LatLng _centerBounds = LatLng(
      (_bounds.northeast.latitude + _bounds.southwest.latitude)/2,
      (_bounds.northeast.longitude + _bounds.southwest.longitude)/2,
    );

    if(controller != null) {
      controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _centerBounds, zoom: GetPlatform.isWeb ? 10 : 16)));
    }

    bool keepZoomingOut = true;

    int _count = 0;
    while(keepZoomingOut) {
      _count++;
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(_fits(_bounds, screenBounds) || _count == 200) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  LatLngBounds _computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  Future<List<PredictionModel>> searchLocation(BuildContext context, String text) async {
    if(text != null && text.isNotEmpty) {
      Response response = await authRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) => _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  Future<Position> setSuggestedLocation(String placeID, String address, GoogleMapController mapController) async {
    _isLoading = true;
    update();

    LatLng _latLng = LatLng(0, 0);
    Response response = await authRepo.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel _placeDetails = PlaceDetailsModel.fromJson(response.body);
      if(_placeDetails.status == 'OK') {
        _latLng = LatLng(_placeDetails.result!.geometry!.location!.lat!, _placeDetails.result!.geometry!.location!.lng!);
      }
    }

    _pickPosition = Position(
      latitude: _latLng.latitude, longitude: _latLng.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
    );

    _pickAddress = address;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 16)));
    }
    _isLoading = false;
    update();
    return _pickPosition;
  }

  Future<ZoneResponseModel> getZone(String lat, String long, bool markerLoad, {bool updateInAddress = false}) async {
    if(markerLoad) {
      _loading = true;
    }else {
      _isLoading = true;
    }
    print('problem start');
    if(!updateInAddress){
      update();
    }
    ZoneResponseModel _responseModel;
    Response response = await authRepo.getZone(lat, long);
    if(response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> _zoneIds = [];
      jsonDecode(response.body['zone_id']).forEach((zoneId){
        _zoneIds.add(int.parse(zoneId.toString()));
      });
      List<ZoneData> _zoneData = [];
      response.body['zone_data'].forEach((zoneData) => _zoneData.add(ZoneData.fromJson(zoneData)));
      _responseModel = ZoneResponseModel(true, '' , _zoneIds, _zoneData);
      if(updateInAddress) {
        print('here problem');
        AddressModel _address = getUserAddress();
        _address.zoneData = _zoneData;
        saveUserAddress(_address);
      }
    }else {
      _inZone = false;
      _responseModel = ZoneResponseModel(false, response.statusText!, [], []);
    }
    if(markerLoad) {
      _loading = false;
    }else {
      _isLoading = false;
    }
    update();
    return _responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await authRepo.saveUserAddress(userAddress);
  }

  AddressModel getUserAddress() {
    AddressModel? _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(authRepo.getUserAddress()));
    }catch(e) {}
    return _addressModel!;
  }

}