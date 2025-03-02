import 'dart:convert';
import 'package:seblak_sulthane_app/data/models/response/outlet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutletLocalDataSource {
  static const String _keyOutlets = 'outlets';

  static final OutletLocalDataSource _instance =
      OutletLocalDataSource._internal();
  factory OutletLocalDataSource() => _instance;
  OutletLocalDataSource._internal();

  Future<bool> saveOutlet(OutletModel outlet) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> outlets = {};
      if (prefs.containsKey(_keyOutlets)) {
        outlets = jsonDecode(prefs.getString(_keyOutlets) ?? '{}');
      }

      outlets['${outlet.id}'] = outlet.toMap();

      return await prefs.setString(_keyOutlets, jsonEncode(outlets));
    } catch (e) {
      print('Error saving outlet: $e');
      return false;
    }
  }

  Future<OutletModel?> getOutletById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_keyOutlets)) {
        print('No outlets found in SharedPreferences');
        return null;
      }

      final outlets = jsonDecode(prefs.getString(_keyOutlets) ?? '{}');
      print('All outlets: $outlets');

      if (outlets['$id'] == null) {
        print('Outlet with ID $id not found');
        return null;
      }

      print('Found outlet for ID $id: ${outlets['$id']}');
      return OutletModel.fromMap(outlets['$id']);
    } catch (e) {
      print('Error getting outlet: $e');
      return null;
    }
  }

  Future<List<OutletModel>> getAllOutlets() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_keyOutlets)) {
        return [];
      }

      final outlets = jsonDecode(prefs.getString(_keyOutlets) ?? '{}');

      return outlets.values
          .map<OutletModel>((outlet) => OutletModel.fromMap(outlet))
          .toList();
    } catch (e) {
      print('Error getting all outlets: $e');
      return [];
    }
  }

  Future<bool> clearOutlets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyOutlets);
    } catch (e) {
      print('Error clearing outlets: $e');
      return false;
    }
  }

  Future<String> getOutletAddress(int outletId) async {
    try {
      final OutletLocalDataSource outletDataSource = OutletLocalDataSource();
      final OutletModel? outlet =
          await outletDataSource.getOutletById(outletId);

      if (outlet != null && outlet.address != null) {
        return outlet.address!;
      } else {
        return 'Default Address, City, State, Zip';
      }
    } catch (e) {
      print('Error getting outlet address: $e');
      return 'Error getting address';
    }
  }
}
