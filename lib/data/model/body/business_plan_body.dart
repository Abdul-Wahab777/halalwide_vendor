class BusinessPlanBody {
  String? businessPlan;
  String? restaurantId;
  String? packageId;
  String? payment;
  String? type;

  BusinessPlanBody({this.businessPlan, this.restaurantId, this.packageId, this.payment, this.type});

  BusinessPlanBody.fromJson(Map<String, dynamic> json) {
    businessPlan = json['business_plan'];
    restaurantId = json['restaurant_id'];
    packageId = json['package_id'];
    payment = json['payment'];
    type = json['type'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['business_plan'] = this.businessPlan!;
    data['restaurant_id'] = this.restaurantId!;
    data['package_id'] = this.packageId!;
    data['payment'] = this.payment!;
    data['type'] = this.type!;
    return data;
  }
}
