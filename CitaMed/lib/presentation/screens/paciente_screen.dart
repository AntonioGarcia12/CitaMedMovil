import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PacienteScreen extends StatefulWidget {
  static const String name = 'PacienteScreen';
  const PacienteScreen({super.key});

  @override
  State<PacienteScreen> createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  String _userName = '';
  String _userImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final nuevaImagen = prefs.getString('imagen') ?? '';
    if (nuevaImagen != _userImage) {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }

    setState(() {
      _userName = prefs.getString('nombre') ?? '';
      _userImage = nuevaImagen;
    });
  }

  Future<void> _refreshPage() async {
    await _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final showGreeting =
        GoRouterState.of(context).uri.toString() == '/paciente';

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
                              'Hola, $_userName',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF00838F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final updated = await context.push(
                                '/perfilPaciente',
                              );
                              if (updated == true) {
                                _loadUserName();
                              }
                            },
                            child: CircleAvatar(
                              key: ValueKey(_userImage),
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
                      child: RefreshIndicator(
                        onRefresh: _refreshPage,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 24.0,
                          ),
                          child: Container(
                            width: min(size.width * 0.95, 450),
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF006064,
                                    // ignore: deprecated_member_use
                                  ).withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: InicioWidget(),
                            ),
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

class InicioWidget extends StatelessWidget {
  const InicioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Image.asset('assets/imgs/iconoCitaMed.webp', height: 64),
        const SizedBox(height: 16),
        Text(
          'Bienvenido a CitaMed',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tu salud es nuestra prioridad.',
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
              imagePath: 'assets/imgs/fotosDeCitasMedicas.webp',
              label: 'Pedir citas',
              onTap: () => context.go('/citas'),
            ),
            buildCardButton(
              context: context,
              imagePath: 'assets/imgs/fotoMapaCentros.webp',
              label: 'Centros de salud',
              onTap: () => context.go('/mapa'),
            ),
            buildCardButton(
              context: context,
              imagePath: 'assets/imgs/fotoCitas.webp',
              label: 'Mis citas',
              onTap: () => context.go('/citasActuales'),
            ),
          ],
        ),
      ],
    );
  }
}
