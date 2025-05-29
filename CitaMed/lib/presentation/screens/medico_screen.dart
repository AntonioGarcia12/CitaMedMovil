import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicoScreen extends StatefulWidget {
  static const String name = 'MedicoScreen';
  const MedicoScreen({super.key});

  @override
  State<MedicoScreen> createState() => _MedicoScreenState();
}

class _MedicoScreenState extends State<MedicoScreen> {
  String _userName = '';
  String _userImage = '';
  String _sexo = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nombre') ?? '';
      _userImage = prefs.getString('imagen') ?? '';
      _sexo = prefs.getString('sexo') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final showGreeting = GoRouterState.of(context).uri.toString() == '/medico';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00838F), Color(0xFF006064)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -50,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(125),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showGreeting)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _sexo == 'Hombre'
                                  ? 'Hola Dr. $_userName'
                                  : 'Hola Dra. $_userName',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF00838F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/perfilMedico'),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  _userImage.isNotEmpty
                                      ? NetworkImage(_userImage)
                                      : const AssetImage(
                                            'assets/imgs/imagenDefault.webp',
                                          )
                                          as ImageProvider,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Container(
                          width: min(size.width * 0.95, 500),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: const Color(0xFF006064).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: MedicoInicioWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

class MedicoInicioWidget extends StatelessWidget {
  const MedicoInicioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Image.asset('assets/imgs/iconoCitaMed.webp', height: 64),
        const SizedBox(height: 16),
        Text(
          'Portal Médico CitaMed',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona tus pacientes de forma eficiente.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            buildCardButton(
              context: context,
              imagePath: 'assets/imgs/fotoAgenda.webp',
              label: 'Mi agenda',
              onTap: () {
                context.go('/citasMedico');
              },
            ),

            buildCardButton(
              context: context,
              imagePath: 'assets/imgs/fotoHistorialClinico.webp',
              label: 'Historial clínico de pacientes',
              onTap: () {
                context.go('/historiales');
              },
            ),
            buildCardButton(
              context: context,
              imagePath: 'assets/imgs/fotoCrearConsulta.webp',
              label: 'Horarios',
              onTap: () {
                context.go('/horarios');
              },
            ),
          ],
        ),
      ],
    );
  }
}
