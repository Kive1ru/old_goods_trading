import 'package:flutter/material.dart';
import 'package:old_goods_trading/utils/toast.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../model/home_goods_list_model.dart';
import '../net/service_repository.dart';

class HomeState with ChangeNotifier {
  int _page = 1;

  String latitude = '';
  String longitude = '';

  int _tabBarIndex = 0;

  int get tabBarIndex => _tabBarIndex;

  final RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialLoadStatus: LoadStatus.idle);

  RefreshController get refreshController => _refreshController;

  final List<GoodsInfoModel> _goodsList = [];

  List<GoodsInfoModel> get goodsList => _goodsList;

  //附近商品数据
  final List<GoodsInfoModel> _nearbyGoodsList = [];

  List<GoodsInfoModel> get nearbyGoodsList => _nearbyGoodsList;

  //banner数据
  final List<Advs> _advsList = [];

  List<Advs> get advsList => _advsList;

  void changeTabBarIndex(int index) {
    _tabBarIndex = index;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _page = 1;
    if (_tabBarIndex == 0) {
      _goodsList.clear();
      await _getData();
    } else {
      _nearbyGoodsList.clear();
      await _getNearbyData();
    }
  }

  Future<void> onLoadingData() async {
    _page++;
    if (_tabBarIndex == 0) {
      await _getData();
    } else {
      await _getNearbyData();
    }
  }

  Future<void> _getData() async {
    HomeGoodsListModel? model = await ServiceRepository.getHomeGoodsList(
        page: _page.toString(), pageSize: '10');

    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
    if (model != null &&
        model.goodsLists != null &&
        model.goodsLists?.data != null &&
        model.goodsLists!.data!.isNotEmpty) {
      _goodsList.addAll(model.goodsLists!.data!);

      if (model.goodsLists!.data!.length < 10) {
        _refreshController.loadNoData();
      }
    } else {
      _refreshController.loadNoData();
    }

    if(model != null && (model.advs??[]).isNotEmpty){
      _advsList.addAll(model.advs??[]);
    }
    notifyListeners();
  }

  Future<void> _getNearbyData() async {
    if (latitude.isEmpty || longitude.isEmpty) {
      ToastUtils.showText(text: '未获取到位置信息');
      return;
    }

    HomeGoodsListModel? model = await ServiceRepository.getNearbyGoodsList(
      page: _page.toString(),
      pageSize: '10',
      latitude: latitude,
      longitude: longitude,
    );

    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
    if (model != null &&
        model.goodsLists != null &&
        model.goodsLists?.data != null &&
        model.goodsLists!.data!.isNotEmpty) {
      _nearbyGoodsList.addAll(model.goodsLists!.data!);

      if (model.goodsLists!.data!.length < 10) {
        _refreshController.loadNoData();
      }
    } else {
      _refreshController.loadNoData();
    }
    notifyListeners();
  }
}