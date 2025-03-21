import 'package:bloc/bloc.dart';
import 'package:seblak_sulthane_app/data/models/response/item_sales_response_model.dart';
import 'package:seblak_sulthane_app/data/datasources/order_item_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_sales_report_event.dart';
part 'item_sales_report_state.dart';
part 'item_sales_report_bloc.freezed.dart';

class ItemSalesReportBloc
    extends Bloc<ItemSalesReportEvent, ItemSalesReportState> {
  final OrderItemRemoteDatasource datasource;

  ItemSalesReportBloc(this.datasource) : super(const _Initial()) {
    on<_GetItemSales>((event, emit) async {
      emit(const _Loading());

      final result = await datasource.getItemSalesByRangeDate(
        event.startDate,
        event.endDate,
        event.outletId,
      );

      result.fold(
        (l) => emit(_Error(l)),
        (r) {
          if (r.data != null && r.data!.isNotEmpty) {
            emit(_Loaded(r.data!));
          } else {
            emit(const _Error("No item sales data for this outlet"));
          }
        },
      );
    });
  }
}
