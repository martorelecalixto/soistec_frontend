import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
           ////martorele Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                     ////martorele MyFiles(),
                      ////martorele SizedBox(height: defaultPadding),
                      ////martorele RecentFiles(),
                     ////martorele if (Responsive.isMobile(context))
                     ////martorele   SizedBox(height: defaultPadding),
                     ////martorele if (Responsive.isMobile(context)) StorageDetails(),
                    ],
                  ),
                ),
                ////martorele if (!Responsive.isMobile(context))
                ////martorele  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
               ////martorele if (!Responsive.isMobile(context))
               /////martorele   Expanded(
               ////martorele     flex: 2,
               ////martorele     child: StorageDetails(),
               ////martorele   ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
