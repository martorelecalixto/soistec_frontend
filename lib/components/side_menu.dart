import 'package:admin/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SideMenu extends StatelessWidget {
  final Function(int) onMenuItemSelected;

  const SideMenu({
    Key? key,
    required this.onMenuItemSelected,
  }) : super(key: key);

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //Navigator.pushReplacementNamed(context,  LoginScreen());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );     
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => onMenuItemSelected(0),
          ),
          DrawerListTile(
            title: "Empresa",
            svgSrc: "assets/icons/building.svg",
            press: () => onMenuItemSelected(1),
          ),
          DrawerListTile(
            title: "Filial",
            svgSrc: "assets/icons/warehouse.svg",
            press: () => onMenuItemSelected(2),
          ),
          DrawerListTile(
            title: "Atividade",
            svgSrc: "assets/icons/kanban.svg",
            press: () => onMenuItemSelected(3),
          ),
          DrawerListTile(
            title: "Acomodacao",
            svgSrc: "assets/icons/bed.svg",
            press: () => onMenuItemSelected(4),
          ),
          DrawerListTile(
            title: "Tipo Serviço",
            svgSrc: "assets/icons/stack-overflow.svg",
            press: () => onMenuItemSelected(5),
          ),
          DrawerListTile(
            title: "Entidade",
            svgSrc: "assets/icons/users.svg",
            press: () => onMenuItemSelected(6),
          ),
          DrawerListTile(
            title: "Venda Aereo",
            svgSrc: "assets/icons/ticket.svg",
            press: () => onMenuItemSelected(7),
          ),
          DrawerListTile(
            title: "Venda Serviço",
            svgSrc: "assets/icons/briefcase.svg",
            press: () => onMenuItemSelected(8),
          ),
          DrawerListTile(
            title: "Titulo Receber",
            svgSrc: "assets/icons/plus.svg",
            press: () => onMenuItemSelected(9),
          ),
          DrawerListTile(
            title: "Sair",
            svgSrc: "assets/icons/sign-out.svg",
            press: () => _logout(context),
          ),
          // ➕ Adicione outros menus aqui
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}












/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/pages/filial_page.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Transaction",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Filial",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  FilialPage()),
    );},
          ),
          DrawerListTile(
            title: "Documents",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Store",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
*/