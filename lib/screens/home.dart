import 'package:crud_rutas360/services/dashboard_metrics_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Color mainColor = const Color(0xFF4D67AE);
  late final DashboardMetricsService _metricsService;
  late Future<DashboardMetrics> _metricsFuture;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const EdgeInsets _heroContentPadding = EdgeInsets.symmetric(horizontal: 32, vertical: 30);
  static const EdgeInsets _statCardPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  static const TextStyle _headerTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle _headerSubtitleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    height: 1.35,
  );
  static const TextStyle _statTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  static const TextStyle _statValueStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 15,
  );
  static const TextStyle _statErrorStyle = TextStyle(
    color: Colors.white70,
    fontWeight: FontWeight.w500,
    fontSize: 13,
  );
  static const double _statLoaderSize = 18;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();

    _metricsService = DashboardMetricsService();
    _metricsFuture = _metricsService.fetchDashboardMetrics();
  }

  void _refreshMetrics() {
    // Reinicia la consulta de métricas para soportar reintentos desde la UI.
    setState(() {
      _metricsFuture = _metricsService.fetchDashboardMetrics();
    });
  }

  BoxDecoration _heroHeaderDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          mainColor.withValues(alpha: 0.95),
          mainColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: mainColor.withValues(alpha: 0.25),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  List<_StatCardData> _buildStatCards(
    DashboardMetrics? metrics,
    bool isLoading,
    bool hasError,
  ) {
    final shouldShowLoader = isLoading && !hasError;
    final retryCallback = hasError ? _refreshMetrics : null;

    return <_StatCardData>[
      _StatCardData(
        icon: Icons.route,
        title: 'Rutas',
        value: metrics != null ? '${metrics.routes} activas' : null,
        color: mainColor,
        isLoading: shouldShowLoader,
        hasError: hasError,
        onRetry: retryCallback,
      ),
      _StatCardData(
        icon: Icons.place,
        title: 'POIs',
        value: metrics != null ? '${metrics.pois} registrados' : null,
        color: const Color(0xFF7E57C2),
        isLoading: shouldShowLoader,
        hasError: hasError,
        onRetry: retryCallback,
      ),
      _StatCardData(
        icon: Icons.category,
        title: 'Categorías',
        value: metrics != null ? '${metrics.categories} totales' : null,
        color: const Color(0xFF26A69A),
        isLoading: shouldShowLoader,
        hasError: hasError,
        onRetry: retryCallback,
      ),
      _StatCardData(
        icon: Icons.directions_walk,
        title: 'Actividades',
        value: metrics != null ? '${metrics.activities} disponibles' : null,
        color: const Color(0xFFFF7043),
        isLoading: shouldShowLoader,
        hasError: hasError,
        onRetry: retryCallback,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(),
                    const SizedBox(height: 40),
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildDashboardGrid(context),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======= HERO HEADER (con métricas integradas) =============================
  Widget _buildHeroHeader() {
    return FutureBuilder<DashboardMetrics>(
      future: _metricsFuture,
      builder: (context, snapshot) {
        final bool isWaiting = snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active;
        final bool hasError = snapshot.hasError;
        final stats = _buildStatCards(snapshot.data, isWaiting, hasError);

        return Container(
          width: double.infinity,
          padding: _heroContentPadding,
          decoration: _heroHeaderDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Bienvenido a Rutas 360°', style: _headerTitleStyle),
                        SizedBox(height: 6),
                        Text(
                          'Gestiona rutas, puntos de interés, categorías y actividades desde un solo lugar.',
                          style: _headerSubtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.map_rounded, color: Colors.white, size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 1;
                  if (constraints.maxWidth >= 1100) {
                    count = 4;
                  } else if (constraints.maxWidth >= 700) {
                    count = 2;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (context, i) => _buildStatCard(stats[i]),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ======= CARD DE MÉTRICA (dentro del hero) ================================
  Widget _buildStatCard(_StatCardData data) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      padding: _statCardPadding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: _statTitleStyle),
                const SizedBox(height: 4),
                if (data.isLoading)
                  const SizedBox(
                    height: _statLoaderSize,
                    width: _statLoaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else if (data.hasError)
                  Row(
                    // Presenta un mensaje contextual y permite reintentar sin romper la estética original.

                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xB3FFFFFF),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'No pudimos cargar las métricas',
                          style: _statErrorStyle,
                        ),
                      ),
                      if (data.onRetry != null)
                        TextButton(
                          onPressed: data.onRetry,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reintentar'),
                        ),
                    ],
                  )
                else
                  Text(
                    data.value ?? '0',
                    style: _statValueStyle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======= GRID PRINCIPAL (CRUD) ============================================
  Widget _buildDashboardGrid(BuildContext context) {
    final items = <_DashItem>[
      _DashItem(
        title: "Rutas",
        subtitle: "Crea y administra rutas interactivas.",
        icon: Icons.route_rounded,
        color: mainColor,
        onTap: () => context.go('/rutas'),
      ),
      _DashItem(
        title: "Puntos de Interés",
        subtitle: "Agrega y gestiona los POIs del mapa.",
        icon: Icons.place_rounded,
        color: const Color(0xFF7E57C2),
        onTap: () => context.go('/pois'),
      ),
      _DashItem(
        title: "Categorías",
        subtitle: "Clasifica y organiza el contenido del sistema.",
        icon: Icons.category_rounded,
        color: const Color(0xFF26A69A),
        onTap: () => context.go('/categorias'),
      ),
      _DashItem(
        title: "Actividades",
        subtitle: "Define actividades disponibles para los usuarios.",
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFFFF7043),
        onTap: () => context.go('/actividades'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        if (constraints.maxWidth >= 1200) {
          columns = 4;
        } else if (constraints.maxWidth >= 900) {
          columns = 3;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (_, i) => _buildDashboardCard(items[i]),
        );
      },
    );
  }

  Widget _buildDashboardCard(_DashItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                item.icon,
                size: 100,
                color: item.color.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 26, color: item.color),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Entrar",
                            style: TextStyle(
                              color: item.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios,
                              size: 13, color: item.color),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ======= MODELOS AUXILIARES ==================================================
class _DashItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _StatCardData {
  const _StatCardData({
    required this.icon,
    required this.title,
    this.value,
    required this.color,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Color color;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;
}
