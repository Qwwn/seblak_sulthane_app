import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seblak_sulthane_app/data/models/response/discount_response_model.dart';
import 'package:seblak_sulthane_app/presentation/setting/bloc/discount/discount_bloc.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/constants/colors.dart';

class ManageDiscountCard extends StatelessWidget {
  final Discount data;
  final VoidCallback onEditTap;

  const ManageDiscountCard({
    super.key,
    required this.data,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.card),
          borderRadius: BorderRadius.circular(19),
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(top: 30.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.disabled.withOpacity(0.4),
                ),
                child: Text(
                  '${data.value!.replaceAll('.00', '')}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Nama Promo : ',
                    children: [
                      TextSpan(
                        text: data.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      color: AppColors.primary,
                    ),
                    child: Assets.icons.edit.svg(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Diskon'),
                        content: const Text(
                            'Apakah Anda yakin ingin menghapus diskon ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<DiscountBloc>().add(
                                    DiscountEvent.deleteDiscount(data.id!),
                                  );
                              Navigator.pop(context);
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
