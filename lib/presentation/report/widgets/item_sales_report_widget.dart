import 'dart:developer';

import 'package:seblak_sulthane_app/core/components/spaces.dart';
import 'package:seblak_sulthane_app/core/constants/colors.dart';
import 'package:seblak_sulthane_app/core/extensions/int_ext.dart';
import 'package:seblak_sulthane_app/core/utils/file_opener.dart';
import 'package:flutter/material.dart';
import 'package:seblak_sulthane_app/core/utils/item_sales_invoice.dart';
import 'package:seblak_sulthane_app/core/utils/permession_handler.dart';
import 'package:seblak_sulthane_app/data/datasources/product_remote_datasource.dart';
import 'package:seblak_sulthane_app/data/models/response/item_sales_response_model.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:permission_handler/permission_handler.dart';

class ItemSalesReportWidget extends StatefulWidget {
  final String title;
  final String searchDateFormatted;
  final List<ItemSales> itemSales;
  final List<Widget>? headerWidgets;

  const ItemSalesReportWidget({
    super.key,
    required this.itemSales,
    required this.title,
    required this.searchDateFormatted,
    required this.headerWidgets,
  });

  @override
  State<ItemSalesReportWidget> createState() => _ItemSalesReportWidgetState();
}

class _ItemSalesReportWidgetState extends State<ItemSalesReportWidget> {
  List<ItemSales> itemSalesWithCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final productRemoteDataSource = ProductRemoteDatasource();
      final productsResult = await productRemoteDataSource.getProducts();

      Map<int, String> productCategories = {};

      productsResult.fold(
        (error) {
          // Jika terjadi error, lanjutkan dengan produk tanpa kategori
        },
        (productResponse) {
          if (productResponse.data != null) {
            for (var product in productResponse.data!) {
              if (product.id != null && product.category?.name != null) {
                productCategories[product.id!] = product.category!.name!;
              }
            }
          }
        },
      );

      // Tambahkan kategori ke penjualan item
      final updatedSales = widget.itemSales.map((item) {
        return item.copyWith(
            categoryName: productCategories.containsKey(item.productId)
                ? productCategories[item.productId]
                : 'Tanpa Kategori');
      }).toList();

      setState(() {
        itemSalesWithCategories = updatedSales;
        isLoading = false;
      });
    } catch (e) {
      log('Gagal mengambil kategori: $e');
      // Jika terjadi exception, lanjutkan dengan produk tanpa kategori
      setState(() {
        itemSalesWithCategories = widget.itemSales;
        isLoading = false;
      });
    }
  }

  Future<void> _handleExport(
    BuildContext context,
    bool isPdf,
  ) async {
    final status = await PermessionHelper().checkPermission();
    if (status) {
      try {
        final file = isPdf
            ? await ItemSalesInvoice.generatePdf(
                itemSalesWithCategories, widget.searchDateFormatted)
            : await ItemSalesInvoice.generateExcel(
                itemSalesWithCategories, widget.searchDateFormatted);

        log("File yang dihasilkan: $file");

        await FileOpenerService.openFile(file, context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File ${isPdf ? 'PDF' : 'Excel'} berhasil dibuat!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        log("Kesalahan saat menangani file: $e");
        if (!context.mounted) return;

        if (!e.toString().contains('No APP found to open this file')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Kesalahan dengan file ${isPdf ? 'PDF' : 'Excel'}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin Dibutuhkan'),
          content: const Text(
            'Aplikasi membutuhkan izin untuk menyimpan dan mengakses file. Harap aktifkan izin di pengaturan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Pengaturan'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buat widget header jika tidak disediakan atau jika perlu diperbarui untuk kategori
    final List<Widget> headerWidgetsWithCategory = widget.headerWidgets ??
        [
          _getTitleItemWidget('ID', 80),
          _getTitleItemWidget('Pesanan', 60),
          _getTitleItemWidget('Produk', 160),
          _getTitleItemWidget('Kategori', 120), // Kolom kategori baru
          _getTitleItemWidget('Jumlah', 60),
          _getTitleItemWidget('Harga', 140),
          _getTitleItemWidget('Total', 140),
        ];

    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          const SpaceHeight(24.0),
          Center(
            child: Text(
              widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.searchDateFormatted,
                  style: const TextStyle(fontSize: 16.0),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleExport(context, false),
                      child: const Row(
                        children: [
                          Text(
                            "Excel",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Icon(
                            Icons.download_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _handleExport(context, true),
                      child: const Row(
                        children: [
                          Text(
                            "PDF",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Icon(
                            Icons.download_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SpaceHeight(16.0),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: HorizontalDataTable(
                        leftHandSideColumnWidth: 80,
                        rightHandSideColumnWidth:
                            680, // Lebar kolom diperbesar untuk kolom baru
                        isFixedHeader: true,
                        headerWidgets: headerWidgetsWithCategory,
                        leftSideItemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            height: 52,
                            alignment: Alignment.centerLeft,
                            child: Center(
                                child: Text(itemSalesWithCategories[index]
                                    .id
                                    .toString())),
                          );
                        },
                        rightSideItemBuilder: (context, index) {
                          return Row(
                            children: <Widget>[
                              Container(
                                width: 60,
                                height: 52,
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(itemSalesWithCategories[index]
                                      .orderId
                                      .toString()),
                                ),
                              ),
                              Container(
                                width: 160,
                                height: 52,
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(itemSalesWithCategories[index]
                                      .productName),
                                ),
                              ),
                              // Kolom kategori baru
                              Container(
                                width: 120,
                                height: 52,
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(
                                    itemSalesWithCategories[index]
                                            .categoryName ??
                                        'Tanpa Kategori',
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 52,
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(itemSalesWithCategories[index]
                                      .quantity
                                      .toString()),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 52,
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(
                                    (itemSalesWithCategories[index].price)
                                        .currencyFormatRp,
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 52,
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(
                                    (itemSalesWithCategories[index].price *
                                            itemSalesWithCategories[index]
                                                .quantity)
                                        .currencyFormatRp,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: itemSalesWithCategories.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black38,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                        leftHandSideColBackgroundColor: AppColors.white,
                        rightHandSideColBackgroundColor: AppColors.white,
                        itemExtent: 55,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      color: AppColors.white,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
