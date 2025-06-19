import 'package:flutter/material.dart';

class EmissaoFaturaScreen extends StatelessWidget {
  const EmissaoFaturaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Tela de Emissao Fatura",
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}










/*
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin/components/side_menu.dart';

class FilialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            /////Expanded(
              // It takes 5/6 part of the screen
             ////// flex: 5,
             ///// child: DashboardScreen(),
            //////),
          ],
        ),
      ),
    );
  }
}

*/

















/*
import 'package:flutter/material.dart';

class Item {
  final String title;
  final IconData icon;
  final Color color;

  Item({required this.title, required this.icon, required this.color});
}

final items = [
  Item(title: "Home Page", icon: Icons.home, color: Colors.redAccent),
  Item(title: "Profile Page", icon: Icons.person, color: Colors.blueAccent),
  Item(title: "Settings Page", icon: Icons.settings, color: Colors.cyan),
  Item(title: "Email Page", icon: Icons.email, color: Colors.green),
  Item(title: "Phone Page", icon: Icons.phone, color: Colors.purpleAccent),
];

class FilialPage extends StatefulWidget {
  const FilialPage({super.key});

  @override
  State<FilialPage> createState() => _HeroListViewState();
}

class _HeroListViewState extends State<FilialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hero List View")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          minTileHeight: 100,
          title: Text(items[index].title),
          leading: Hero(
            tag: "hero_list_item_$index",
            child: Container(
              width: 60,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: items[index].color.withValues(alpha: 0.1),
              ),
              child: Icon(items[index].icon, color: items[index].color),
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroListItemPage(index: index),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroListItemPage extends StatelessWidget {
  final int index;
  const HeroListItemPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hero List Item Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: "hero_list_item_$index",
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: items[index].color.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    items[index].icon,
                    color: items[index].color,
                    size: 100,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              items[index].title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
*/