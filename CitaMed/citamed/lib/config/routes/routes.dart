import 'package:go_router/go_router.dart';

import '../../presentation/screens/screens.dart';

final appRouter = GoRouter(initialLocation: '/login', routes: [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/registrar',
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: '/paciente',
    builder: (context, state) => const PacienteScreen(),
  ),
  GoRoute(
    path: '/medico',
    builder: (context, state) => const MedicoScreen(),
  ),
]);
