import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/ai_extract/controllers/ai_extract_controller.dart';

class AiExtractScreen extends GetView<AiExtractController> {
  const AiExtractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Extract')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extract transaction data using AI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a receipt or describe your transaction in text.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Receipt Scan Options
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera',
                    subtitle: 'Scan receipt',
                    onTap: controller.extractFromReceipt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    context,
                    icon: Icons.photo_library_outlined,
                    title: 'Gallery',
                    subtitle: 'Pick image',
                    onTap: controller.extractFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Text Input
            const Divider(),
            const SizedBox(height: 16),
            Text('Or describe your transaction', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            CustomTextField(
              controller: controller.textController,
              hintText: 'e.g., Spent \$12.50 at Tesco for lunch yesterday',
              maxLines: 3,
              prefixIcon: const Icon(Icons.text_fields),
            ),
            const SizedBox(height: 12),
            Obx(() => CustomButton(
                  text: 'Extract from Text',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.extractFromText,
                )),
            const SizedBox(height: 24),

            // Results
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('AI is analyzing...'),
                      ],
                    ),
                  ),
                );
              }

              final data = controller.extractedData.value;
              if (data == null) return const SizedBox.shrink();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Overview',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                          if (data.confidence != null)
                            Chip(
                              label: Text('${(data.confidence! * 100).toStringAsFixed(0)}% confidence'),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nothing is saved yet. Review these values, edit if needed, then confirm on the next step.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const Divider(),
                      _resultRow('Amount', '\$${data.amount?.toStringAsFixed(2) ?? 'N/A'}'),
                      _resultRow('Description', data.description ?? 'N/A'),
                      _resultRow('Date', data.date ?? 'N/A'),
                      _resultRow('Type', data.type ?? 'N/A'),
                      _resultRow('Category', data.category ?? 'N/A'),
                      _resultRow('Merchant', data.merchant ?? 'N/A'),
                      _resultRow('Currency', data.currency ?? 'N/A'),
                      if (data.items != null && data.items!.isNotEmpty) ...[
                        const Divider(),
                        Text('Items', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...data.items!.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('${item.name ?? ''} x${item.quantity ?? 1}')),
                                  Text('\$${item.price?.toStringAsFixed(2) ?? '0.00'}'),
                                ],
                              ),
                            )),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.clearExtractedData,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Start Over'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Get.toNamed(
                                Routes.addExpense,
                                arguments: {'aiDraft': data},
                              ),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Review & Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}



