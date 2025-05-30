part of 'order_bloc.dart';

@freezed
class OrderEvent with _$OrderEvent {
  const factory OrderEvent.started() = _Started;
  const factory OrderEvent.order(
    List<ProductQuantity> items,
    int discount,
    int discountAmount,
    int tax,
    int serviceCharge,
    int paymentAmount,
    String customerName,
    int tableNumber,
    String status,
    String paymentStatus,
    String paymentMethod,
    int totalPriceFinal, {
    @Default('dine_in') String orderType, // Use named parameter with default value
  }) = _Order;
  const factory OrderEvent.loadHistoricalOrder(OrderModel order) = _LoadHistoricalOrder;

}