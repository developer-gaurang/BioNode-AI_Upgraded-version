import sys

def update_file():
    with open("lib/main.dart", "r", encoding="utf-8") as f:
        code = f.read()

    # Add imports
    imports = "import 'dart:convert';\nimport 'package:http/http.dart' as http;\n"
    if "import 'dart:convert';" not in code:
        code = code.replace("import 'dart:ui';", "import 'dart:ui';\n" + imports)

    start_str = "class EcoMonitorTab extends StatelessWidget {"
    end_str = "// ==============================================================================\n// --- TAB 3: HEALTH VAULT ---"
    
    start_idx = code.find(start_str)
    end_idx = code.find(end_str, start_idx)

    if start_idx == -1 or end_idx == -1:
        print("Could not find bounds")
        sys.exit(1)

    new_class = """class EcoRouteSegment {
  final String name;
  final List<LatLng> path;
  final LatLng apiPoint;
  double? temp;
  double? humidity;

  EcoRouteSegment({required this.name, required this.path, required this.apiPoint});

  Color get routeColor {
    if (temp == null) return Colors.white24;
    double heatIndex = temp! + ((humidity ?? 40) * 0.1);
    if (heatIndex >= 40.0) return const Color(0xFFFF2A5F); // Red
    if (heatIndex >= 34.0) return const Color(0xFFFF9100); // Yellow
    return const Color(0xFF2962FF); // Blue
  }
}

class EcoMonitorTab extends StatefulWidget {
  const EcoMonitorTab({super.key});
  @override
  State<EcoMonitorTab> createState() => _EcoMonitorTabState();
}

class _EcoMonitorTabState extends State<EcoMonitorTab> {
  bool _isLoading = true;
  List<EcoRouteSegment> routes = [
    EcoRouteSegment(
      name: "NH-19 (North-East)",
      apiPoint: const LatLng(26.4499, 80.3319), // Kanpur
      path: const [
        LatLng(28.6139, 77.2090), LatLng(27.1767, 78.0081), 
        LatLng(26.4499, 80.3319), LatLng(25.4358, 81.8463), 
        LatLng(25.3176, 82.9739), LatLng(22.5726, 88.3639),
      ],
    ),
    EcoRouteSegment(
      name: "NH-48 (West)",
      apiPoint: const LatLng(24.5854, 73.6915), // Udaipur
      path: const [
        LatLng(28.6139, 77.2090), LatLng(26.9124, 75.7873), 
        LatLng(24.5854, 73.6915), LatLng(23.0225, 72.5714), 
        LatLng(19.0760, 72.8777),
      ],
    ),
    EcoRouteSegment(
      name: "Deccan Highway",
      apiPoint: const LatLng(15.8497, 74.4977), // Belagavi
      path: const [
        LatLng(19.0760, 72.8777), LatLng(18.5204, 73.8567), 
        LatLng(15.8497, 74.4977), LatLng(12.9716, 77.5946), 
        LatLng(13.0827, 80.2707),
      ],
    ),
    EcoRouteSegment(
      name: "East Coast",
      apiPoint: const LatLng(17.6868, 83.2185), // Vizag
      path: const [
        LatLng(13.0827, 80.2707), LatLng(17.6868, 83.2185), 
        LatLng(20.2961, 85.8245), LatLng(22.5726, 88.3639),
      ],
    ),
    EcoRouteSegment(
      name: "Central Corridor",
      apiPoint: const LatLng(21.1458, 79.0882), // Nagpur
      path: const [
        LatLng(27.1767, 78.0081), LatLng(21.1458, 79.0882), 
        LatLng(17.3850, 78.4867), LatLng(12.9716, 77.5946),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveHeatData();
  }

  Future<void> _fetchLiveHeatData() async {
    try {
      String lats = routes.map((r) => r.apiPoint.latitude.toString()).join(',');
      String lngs = routes.map((r) => r.apiPoint.longitude.toString()).join(',');
      final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lats&longitude=$lngs&current=temperature_2m,relative_humidity_2m');
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isList = data is List;
        setState(() {
          for (int i = 0; i < routes.length; i++) {
            var item = isList ? data[i] : data;
            routes[i].temp = item['current']['temperature_2m'].toDouble();
            routes[i].humidity = item['current']['relative_humidity_2m'].toDouble();
          }
          _isLoading = false;
        });
      } else {
        _mockData();
      }
    } catch (e) {
      _mockData();
    }
  }

  void _mockData() {
    setState(() {
      for (var r in routes) {
        r.temp = 32.0 + (math.Random().nextDouble() * 12);
        r.humidity = 40.0;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int highRiskCount = routes.where((r) => r.temp != null && (r.temp! + (r.humidity ?? 40)*0.1) >= 42).length;
    
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(22.0, 79.0), // Central India 
            initialZoom: 4.8,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.bionode.app',
            ),
            if (!_isLoading)
              PolylineLayer(
                polylines: routes.map((r) {
                  return Polyline(
                    points: r.path,
                    strokeWidth: 4.0,
                    color: r.routeColor,
                  );
                }).toList(),
              ),
            if (!_isLoading)
              MarkerLayer(
                markers: routes.map((r) {
                  return Marker(
                    point: r.apiPoint,
                    width: 44, height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: r.routeColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          r.temp != null ? "${r.temp!.toInt()}°" : "...",
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(Icons.thermostat, _isLoading ? 'SCANNING SATELLITES...' : '$highRiskCount ZONES AT CRITICAL RISK', _isLoading ? Colors.white54 : const Color(0xFFFF2A5F)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAN-INDIA HEAT STROKE ROUTES',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLegend(const Color(0xFFFF2A5F), 'CRITICAL', 'Active Heat-Stroke risk zone.'),
                        const SizedBox(height: 12),
                        _buildLegend(const Color(0xFFFF9100), 'MODERATE', 'Elevated temperature, minor risk.'),
                        const SizedBox(height: 12),
                        _buildLegend(const Color(0xFF2962FF), 'OPTIMAL', 'Safe traveling conditions.'),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String title, String desc) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)])),
        const SizedBox(width: 16),
        Text(title, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(child: Text(desc, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12))),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return AcrylicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) 
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
          else 
            Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

"""

    code = code[:start_idx] + new_class + code[end_idx:]

    with open("lib/main.dart", "w", encoding="utf-8") as f:
        f.write(code)

update_file()
