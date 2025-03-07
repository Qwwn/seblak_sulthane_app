class TableModel {
  int? id;
  final int tableNumber;
  final String startTime;
  final String status;
  final int orderId;
  final int paymentAmount;

  TableModel({
    this.id,
    required this.tableNumber,
    required this.startTime,
    required this.status,
    required this.orderId,
    required this.paymentAmount,
  });

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'],
      tableNumber: map['table_number'],
      startTime: map['start_time'],
      status: map['status'],
      orderId: map['order_id'],
      paymentAmount: map['payment_amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'table_number': tableNumber,
      'status': status,
      'start_time': startTime,
      'order_id': orderId,
      'payment_amount': paymentAmount,
    };
  }
}
