import 'package:go_router/go_router.dart';

import '../../presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/registrar', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/paciente', builder: (c, s) => const PacienteScreen()),
    GoRoute(path: '/medico', builder: (c, s) => const MedicoScreen()),
    GoRoute(path: '/mapa', builder: (c, s) => const MapaScreen()),
    GoRoute(
      path: '/perfilPaciente',
      builder: (c, s) => const PerfilPacienteScreen(),
    ),
    GoRoute(
      path: '/perfilMedico',
      builder: (c, s) => const PerfilMedicoScreen(),
    ),
    GoRoute(path: '/citas', builder: (c, s) => const CitaScreen()),
    GoRoute(
      path: '/crearHorario',
      builder: (c, s) => const CrearHorarioMedicoScreen(),
    ),
    GoRoute(path: '/horarios', builder: (c, s) => const HorarioMedicoScreen()),
    GoRoute(
      path: '/editarHorario/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditarHorarioMedicoScreen(id: id);
      },
    ),
  ],
);
