import 'package:flutter/material.dart';
import 'package:fyp_project/services/package_service.dart';
import 'package:fyp_project/tour_detail_page.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  List<dynamic> raftingPackages = [];
  List<dynamic> boatingPackages = [];

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);

  final List<Map<String, String>> categories = const [
    {
      "title": "Rafting",
      "subtitle": "Adventure river experience",
      "image": "assets/rafting1.png",
      "subcategory": "rafting",
    },
    {
      "title": "Boating",
      "subtitle": "Peaceful lake experience",
      "image": "assets/pokhara.jpg",
      "subcategory": "boating",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchWaterPackages();
  }

  Future<void> fetchWaterPackages() async {
    try {
      final rafting = await PackageService.getPackagesByCategoryAndSubcategory(
        "water",
        "rafting",
      );

      final boating = await PackageService.getPackagesByCategoryAndSubcategory(
        "water",
        "boating",
      );

      if (!mounted) return;

      setState(() {
        raftingPackages = rafting;
        boatingPackages = boating;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load water packages: $e")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _packagesForSubcategory(String subcategory) {
    if (subcategory == "rafting") {
      return raftingPackages;
    }

    if (subcategory == "boating") {
      return boatingPackages;
    }

    return [];
  }

  int get totalPackages => raftingPackages.length + boatingPackages.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        title: const Text(
          "Water",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primarySkyBlue,
          indicatorWeight: 3,
          labelColor: primarySkyBlue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Experiences"),
            Tab(text: "Packages"),
            Tab(text: "Highlights"),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primarySkyBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExperiences(),
                _buildPackages(),
                _buildHighlights(),
              ],
            ),
    );
  }

  // -------------------------------
  // EXPERIENCES TAB
  // -------------------------------
  Widget _buildExperiences() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildWaterIntroCard(),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Choose Experience",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              "Water Tours",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ...categories.map((cat) {
          return _categoryCard(
            cat["title"]!,
            cat["subtitle"]!,
            cat["image"]!,
            cat["subcategory"]!,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWaterIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarySkyBlue, const Color(0xFF48CAE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primarySkyBlue.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Water Adventures",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalPackages available package${totalPackages == 1 ? "" : "s"}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
    String title,
    String subtitle,
    String image,
    String subcategory,
  ) {
    final count = _packagesForSubcategory(subcategory).length;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(1);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: softSkyBlue,
                      child: Icon(
                        Icons.water_drop,
                        color: primarySkyBlue,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.82),
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primarySkyBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_travel_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$count Package${count == 1 ? "" : "s"}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 14,
                top: 14,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),
                      child: const Text(
                        "View packages",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // PACKAGES TAB
  // -------------------------------
  Widget _buildPackages() {
    final allWaterPackages = [...raftingPackages, ...boatingPackages];

    if (allWaterPackages.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      color: primarySkyBlue,
      onRefresh: fetchWaterPackages,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _sectionTitle("Rafting Packages", raftingPackages.length),
          const SizedBox(height: 10),
          raftingPackages.isEmpty
              ? _smallEmptyText("No rafting packages added yet.")
              : Column(
                  children: raftingPackages
                      .map((package) => _packageCard(package))
                      .toList(),
                ),

          const SizedBox(height: 24),

          _sectionTitle("Boating Packages", boatingPackages.length),
          const SizedBox(height: 10),
          boatingPackages.isEmpty
              ? _smallEmptyText("No boating packages added yet.")
              : Column(
                  children: boatingPackages
                      .map((package) => _packageCard(package))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _packageCard(dynamic package) {
    final image = package["image"]?.toString() ?? "";
    final title = package["title"]?.toString() ?? "Untitled Package";
    final destination = package["destination"]?.toString() ?? "Unknown";
    final duration = package["duration"]?.toString() ?? "";
    final price = package["price"]?.toString() ?? "0";
    final subcategory = package["subcategory"]?.toString() ?? "";

    return GestureDetector(
      onTap: () {
        final id = package["id"];

        if (id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TourDetailPage(tourId: id)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: _packageImage(image),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: softSkyBlue.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subcategory.toUpperCase(),
                        style: TextStyle(
                          color: primarySkyBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: primarySkyBlue,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: primarySkyBlue,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      "Rs. $price",
                      style: TextStyle(
                        color: primarySkyBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packageImage(String image) {
    if (image.startsWith("http")) {
      return Image.network(
        image,
        width: 118,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    return Image.asset(
      image.isNotEmpty ? image : "assets/pokhara.jpg",
      width: 118,
      height: 140,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imageFallback();
      },
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 118,
      height: 140,
      color: softSkyBlue,
      child: Icon(Icons.water_drop, color: primarySkyBlue, size: 35),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: softSkyBlue.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              color: primarySkyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallEmptyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softSkyBlue.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primarySkyBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return RefreshIndicator(
      color: primarySkyBlue,
      onRefresh: fetchWaterPackages,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Icon(Icons.water_drop, size: 72, color: primarySkyBlue),
          const SizedBox(height: 14),
          const Text(
            "No Water Packages Yet",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add rafting or boating packages from the admin panel.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // HIGHLIGHTS TAB
  // -------------------------------
  Widget _buildHighlights() {
    final highlights = [
      {
        "title": "Rafting",
        "desc":
            "Rafting is an adventure-based water activity where users experience river rapids with safety equipment and guides.",
        "icon": Icons.waves,
      },
      {
        "title": "Boating",
        "desc":
            "Boating is a calm water activity suitable for families, couples, and users who prefer relaxing lake experiences.",
        "icon": Icons.directions_boat,
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: softSkyBlue.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: softSkyBlue),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: primarySkyBlue, size: 30),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Water category is divided into adventure and leisure experiences.",
                  style: TextStyle(fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        ...highlights.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 1.5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: softSkyBlue,
                child: Icon(item["icon"] as IconData, color: primarySkyBlue),
              ),
              title: Text(
                item["title"] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item["desc"] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
