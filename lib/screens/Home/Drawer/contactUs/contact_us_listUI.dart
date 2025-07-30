import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/contact_us_controller.dart';

class ContactUsHistory extends StatelessWidget {
  const ContactUsHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactUsController controller = Get.find<ContactUsController>();

    return Obx(() {
      if (controller.contacts.isEmpty) {
        return const CommonEmptyState(
          icon: Icons.message_outlined,
          title: 'No messages yet',
          subtitle: 'Your message history will appear here',
          actionText: 'Switch to "Send Message" tab to get started',
        );
      }

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: _buildHistoryHeader(controller),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final contact = controller.contacts[index];
                return CommonHistoryCard(
                  title: contact['name'] ?? 'Unknown',
                  subtitle: contact['email'] ?? '',
                  description: contact['message'] ?? 'No message',
                  date: _formatDate(contact['timestamp']),
                  id: '#${(index + 1).toString().padLeft(3, '0')}',
                  icon: Icons.message_rounded,
                  iconColor: Colors.blue,
                  statusChip: const CommonStatusChip(
                    text: 'Sent',
                    color: Colors.green,
                  ),
                  onTap: () => _showContactDetails(contact),
                  onDelete: () => _showDeleteConfirmation(index, controller),
                );
              },
              childCount: controller.contacts.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      );
    });
  }

  Widget _buildHistoryHeader(ContactUsController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomColors.yellow1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomColors.yellow1.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.history_rounded,
            color: CustomColors.yellow1,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message History',
                style: AppTextStyles.labelLarge.copyWith(
                  color: CustomColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${controller.contacts.length} message${controller.contacts.length == 1 ? '' : 's'} sent',
                style: AppTextStyles.bodySmall.copyWith(
                  color: CustomColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactDetails(Map<String, dynamic> contact) {
    CommonDialogs.showDetailBottomSheet(
      data: contact,
      title: contact['name'] ?? 'Unknown',
      icon: Icons.message_rounded,
      iconColor: Colors.blue,
      additionalDetails: [
        DetailItem(
          label: 'Email',
          value: contact['email'] ?? 'N/A',
          icon: Icons.email_outlined,
        ),
        DetailItem(
          label: 'Phone',
          value: contact['phone'] ?? 'N/A',
          icon: Icons.phone_outlined,
        ),
      ],
    );
  }

  void _showDeleteConfirmation(int index, ContactUsController controller) {
    CommonDialogs.showDeleteConfirmation(
      context: Get.context!,
      title: 'Delete Message?',
      message: 'This action cannot be undone. The message will be permanently removed.',
      onConfirm: () => controller.deleteContact(index),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date not available';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        date = timestamp.toDate();
      }
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date not available';
    }
  }
}