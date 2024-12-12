import 'package:flutter/material.dart';
import 'package:depd_2024_mvvm/data/response/api_response.dart';
import 'package:depd_2024_mvvm/model/city.dart';
import 'package:depd_2024_mvvm/model/model.dart';
import 'package:depd_2024_mvvm/model/costs/costs.dart';
import 'package:depd_2024_mvvm/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final _homeRepo = HomeRepository();

  // Province handling
  ApiResponse<List<Province>> provinceList = ApiResponse.loading();

  void setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  Future<void> getProvinceList() async {
    setProvinceList(ApiResponse.loading());
    try {
      final response = await _homeRepo.fetchProvinceList();
      setProvinceList(ApiResponse.completed(response));
    } catch (error) {
      setProvinceList(ApiResponse.error(error.toString()));
    }
  }

  // City handling
  ApiResponse<List<City>> cityList = ApiResponse.loading();

  void setCityList(ApiResponse<List<City>> response) {
    cityList = response;
    notifyListeners();
  }

  Future<List<City>> getCityList(dynamic provId) async {
    setCityList(ApiResponse.loading());
    try {
      final response = await _homeRepo.fetchCityList(provId);
      setCityList(ApiResponse.completed(response));
      return response;
    } catch (error) {
      setCityList(ApiResponse.error(error.toString()));
      rethrow;
    }
  }

  // Shipping cost handling
  ApiResponse<List<Costs>> shippingCosts = ApiResponse.loading();

  void setShippingCosts(ApiResponse<List<Costs>> response) {
    shippingCosts = response;
    notifyListeners();
  }

  Future<List<Costs>> calculateShippingCost({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    setShippingCosts(ApiResponse.loading());
    try {
      final costs = await _homeRepo.fetchShippingCosts(
        origin: origin,
        destination: destination,
        weight: weight,
        courier: courier,
      );
      setShippingCosts(ApiResponse.completed(costs));
      return costs;
    } catch (error) {
      setShippingCosts(ApiResponse.error(error.toString()));
      throw error;
    }
  }
}
