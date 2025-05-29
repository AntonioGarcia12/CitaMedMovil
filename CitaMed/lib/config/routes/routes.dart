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
    GoRoute(
      path: '/crearHistorialMedico',
      builder: (c, s) => const CrearHistorialMedicoScreen(),
    ),
    GoRoute(
      path: '/historiales',
      builder: (c, s) => const HistorialMedicoScreen(),
    ),
    GoRoute(
      name: EditarHistorialMedicoScreen.name,
      path: '/editarHistorial/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditarHistorialMedicoScreen(id: id);
      },
    ),
    GoRoute(
      name: DetalleCitaScreen.name,
      path: '/detalleCita/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetalleCitaScreen(medicoId: id);
      },
    ),
    GoRoute(
      name: CitaPacienteScreen.name,
      path: '/citasPaciente/:id',
      builder: (c, s) {
        final id = int.parse(s.pathParameters['id']!);
        return CitaPacienteScreen(id: id);
      },
    ),
    GoRoute(path: '/citasMedico', builder: (c, s) => const CitasMedicoScreen()),
    GoRoute(
      name: EditarCitaScreen.name,
      path: '/editarCita/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditarCitaScreen(id: id);
      },
    ),
  ],
);
