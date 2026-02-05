import 'package:flutter/material.dart';
import 'package:fyp_project/admin_profile_page.dart';
import 'package:fyp_project/services/package_service.dart';
import 'add_package_page.dart';

class AdminManagePackagesPage extends StatefulWidget {
  const AdminManagePackagesPage({super.key});

  @override
  State<AdminManagePackagesPage> createState() =>
      _AdminManagePackagesPageState();
}

class _AdminManagePackagesPageState extends State<AdminManagePackagesPage> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  /// Fetch all packages from backend
  Future<void> fetchPackages() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<dynamic> data = await PackageService.getPackages();
      setState(() {
        packages = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch packages: $e")));
    }
  }

  /// Delete package
  Future<void> deletePackage(int id) async {
    bool success = await PackageService.deletePackage(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Package deleted successfully")),
      );
      fetchPackages();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete package")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminProfilePage()),
            );
          },
        ),
        title: const Text("Manage Tour Packages"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new package
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPackagePage()),
          ).then((_) => fetchPackages());
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : packages.isEmpty
          ? const Center(child: Text("No packages available"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                          child: package['image'] != null
                              ? Image.asset(package['image'], fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 50),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Destination: ${package['destination'] ?? ''}",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Price: Rs.${package['price'] ?? ''} | Duration: ${package['duration'] ?? ''}",
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Edit package
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPackagePage(
                                      package: package, // ✅ Pass package
                                    ),
                                  ),
                                ).then((_) => fetchPackages());
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                if (package['id'] != null) {
                                  deletePackage(package['id']);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
