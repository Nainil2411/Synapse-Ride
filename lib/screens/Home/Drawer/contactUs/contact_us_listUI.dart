import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/utility.dart';

class ComplaintsListUI extends StatelessWidget {
  final void Function() onBackPressed;
  final Function(String) onDeleteComplaint;

  const ComplaintsListUI({
    super.key,
    required this.onBackPressed,
    required this.onDeleteComplaint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseAuth.instance.currentUser != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('contact_us')
                    .orderBy('timestamp', descending: true)
                    .snapshots()
                : Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return UIUtils.circleloading();
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${AppStrings.error}: ${snapshot.error}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: CustomColors.background),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noComplaintsFound,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: CustomColors.background),
                  ),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['timestamp'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat('MMM d, yyyy - h:mm a')
                          .format(timestamp.toDate())
                      : AppStrings.dateNotAvailable;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        data['message'] ?? AppStrings.noMessage,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: CustomColors.background,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '${AppStrings.from}: ${data['name']}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: CustomColors.grey400),
                          ),
                          Text(
                            '${AppStrings.email}: ${data['email']}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: CustomColors.grey400),
                          ),
                          Text(
                            '${AppStrings.phone}: ${data['phone']}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: CustomColors.grey400),
                          ),
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: CustomColors.grey400),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete, color: CustomColors.error),
                        onPressed: () => onDeleteComplaint(doc.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
