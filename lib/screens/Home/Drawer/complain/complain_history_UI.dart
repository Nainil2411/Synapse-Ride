import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/complain_controller.dart';

class ComplainHistory extends StatelessWidget {
  const ComplainHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final ComplainController controller = Get.find<ComplainController>();

    return Obx(() {
      if (controller.complaints.isEmpty) {
        return const CommonEmptyState(
          icon: Icons.history_rounded,
          title: 'No complaints yet',
          subtitle: 'Your complaint history will appear here',
          actionText: 'Switch to "New Complaint" tab to get started',
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
                final complaint = controller.complaints[index];
                return CommonHistoryCard(
                  title: complaint.type,
                  subtitle: '',
                  description: complaint.description,
                  date: _formatDate(complaint.date),
                  id: '#${(index + 1).toString().padLeft(3, '0')}',
                  icon: _getIssueIcon(complaint.type),
                  iconColor: _getIssueColor(complaint.type),
                  statusChip: const CommonStatusChip(
                    text: 'Pending',
                    color: Colors.orange,
                  ),
                  onTap: () => _showComplaintDetails(complaint),
                  onDelete: () => _showDeleteConfirmation(index, controller),
                );
              },
              childCount: controller.complaints.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      );
    });
  }

  Widget _buildHistoryHeader(ComplainController controller) {
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
                'Your Complaints',
                style: AppTextStyles.labelLarge.copyWith(
                  color: CustomColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${controller.complaints.length} complaint${controller.complaints.length == 1 ? '' : 's'} submitted',
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

  void _showComplaintDetails(complaint) {
    CommonDialogs.showDetailBottomSheet(
      data: {
        'description': complaint.description,
        'date': complaint.date,
      },
      title: complaint.type,
      icon: _getIssueIcon(complaint.type),
      iconColor: _getIssueColor(complaint.type),
    );
  }

  void _showDeleteConfirmation(int index, ComplainController controller) {
    CommonDialogs.showDeleteConfirmation(
      context: Get.context!,
      title: 'Delete Complaint?',
      message: 'This action cannot be undone. The complaint will be permanently removed.',
      onConfirm: () => controller.deleteComplaint(index),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIssueIcon(String type) {
    switch (type) {
      case 'Vehicle not clean':
        return Icons.cleaning_services_rounded;
      case 'User was late':
        return Icons.access_time_rounded;
      case 'Over Speeding':
        return Icons.speed_rounded;
      case 'Rude behavior':
        return Icons.sentiment_dissatisfied_rounded;
      case 'Wrong destination':
        return Icons.wrong_location_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getIssueColor(String type) {
    switch (type) {
      case 'Vehicle not clean':
        return Colors.blue;
      case 'User was late':
        return Colors.orange;
      case 'Over Speeding':
        return Colors.red;
      case 'Rude behavior':
        return Colors.purple;
      case 'Wrong destination':
        return Colors.green;
      default:
        return CustomColors.grey400;
    }
  }
}