import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context);
    // ignore: unrelated_type_equality_checks
    final currentIndex = location == '/perfilPaciente' ? 1 : 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF00838F),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/paciente');
            break;
          case 1:
            context.go('/perfilPaciente');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}
