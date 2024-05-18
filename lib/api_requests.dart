import 'package:noso_rest_api/api_service.dart';
import 'package:noso_rest_api/enum/time_range.dart';
import 'package:noso_rest_api/models/set_price.dart';

class ApiRequests {
  final NosoApiService restApi;

  ApiRequests(this.restApi);

  Future<int> getLockedNoso() async {
    var response = await restApi.fetchLockedSupply();
    if (response.value != null && response.error == null) {
      return response.value ?? 0;
    }

    return 0;
  }

  Future<int> getSupplyNoso() async {
    var response = await restApi.fetchCirculatingSupply();
    if (response.value != null && response.error == null) {
      return response.value ?? 0;
    }

    return 0;
  }

  Future<List<String>> infoNode() async {
    var response = await restApi.fetchNodesInfo();
    if (response.value != null && response.error == null) {
      var countMN = response.value?.count ?? 0;
      var reward = response.value?.reward ?? 0;
      var block = response.value?.blockId ?? 0;
      return [countMN.toString(), reward.toString(), block.toString()];
    }

    return ["0", "0", "0"];
  }

  Future<double> getCurrentPrice() async {
    var response =
        await restApi.fetchPrice(SetPriceRequest(TimeRange.minute, 10));
    if (response.value != null && response.error == null) {
      return response.value?.first.price ?? 0.0;
    }

    return 0.0;
  }

  getUpdateTime() {
    DateTime now = DateTime.now().toUtc();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
