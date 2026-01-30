import 'package:flutter/material.dart';
import 'package:fyp_project/package_service.dart';

class AddPackagePage extends StatefulWidget {
  final Map<String, dynamic>? package; // optional for editing

  // ❌ Remove 'const' here, allow package parameter
  AddPackagePage({super.key, this.package});

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController destinationController;
  late TextEditingController priceController;
  late TextEditingController durationController;
  late TextEditingController descriptionController;

  String selectedCategory = "Adventure";

  final List<String> localImages = const [
    "assets/bouddha.jpg",
    "assets/everest.jpg",
    "assets/janakpur.jpg",
    "assets/lumbini.jpg",
    "assets/kanchan.jpg",
  ];

  late String selectedImage;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.package?['title'] ?? '',
    );
    destinationController = TextEditingController(
      text: widget.package?['destination'] ?? '',
    );
    priceController = TextEditingController(
      text: widget.package?['price']?.toString() ?? '',
    );
    durationController = TextEditingController(
      text: widget.package?['duration'] ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.package?['description'] ?? '',
    );
    selectedCategory = widget.package?['category'] ?? "Adventure";
    selectedImage = widget.package?['image'] ?? "assets/kanchan.jpg";
  }

  @override
  void dispose() {
    titleController.dispose();
    destinationController.dispose();
    priceController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> savePackage() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> packageData = {
        "title": titleController.text,
        "destination": destinationController.text,
        "price": priceController.text,
        "duration": durationController.text,
        "category": selectedCategory,
        "description": descriptionController.text,
        "image": selectedImage,
        "created_by": 1, // admin id placeholder
      };

      bool success = false;

      if (widget.package == null) {
        success = await PackageService.addPackage(packageData);
      } else {
        success = await PackageService.updatePackage(
          widget.package!['id'],
          packageData,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.package == null
                  ? "Package added successfully!"
                  : "Package updated successfully!",
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save package")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.package == null ? "Add Tour Package" : "Edit Tour Package",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image preview + dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Package Image:"),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(selectedImage, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedImage,
                    isExpanded: true,
                    items: localImages
                        .map(
                          (img) => DropdownMenuItem(
                            value: img,
                            child: Text(img.split("/").last),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedImage = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Package Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter title"
                    : null,
              ),
              const SizedBox(height: 12),
              // Destination
              TextFormField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: "Destination",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter destination"
                    : null,
              ),
              const SizedBox(height: 12),
              // Price
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (Rs.)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter price"
                    : null,
              ),
              const SizedBox(height: 12),
              // Duration
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: "Duration (e.g. 3 Days)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter duration"
                    : null,
              ),
              const SizedBox(height: 12),
              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Adventure",
                    child: Text("Adventure"),
                  ),
                  DropdownMenuItem(value: "Family", child: Text("Family")),
                  DropdownMenuItem(value: "Budget", child: Text("Budget")),
                  DropdownMenuItem(value: "Luxury", child: Text("Luxury")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? "Adventure";
                  });
                },
              ),
              const SizedBox(height: 12),
              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter description"
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: savePackage,
                  child: Text(
                    widget.package == null ? "Save Package" : "Update Package",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
