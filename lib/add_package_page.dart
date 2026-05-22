import 'package:flutter/material.dart';
import 'package:fyp_project/services/package_service.dart';

class AddPackagePage extends StatefulWidget {
  final Map<String, dynamic>? package;

  const AddPackagePage({super.key, this.package});

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

  String selectedCategory = "food";
  String selectedSubcategory = "barista";
  String selectedDifficulty = "Beginner";

  final List<String> localImages = const [
    // General / Culture / Tour images
    "assets/bouddha.jpg",
    "assets/everest.jpg",
    "assets/janakpur.jpg",
    "assets/lumbini.jpg",
    "assets/kanchan.jpg",
    "assets/mardi.jpg",
    "assets/mardi3.jpg",
    "assets/muktinath.jpg",
    "assets/tilicho.jpg",
    "assets/pashupati.jpg",
    "assets/nagarkotSunrisePoint.jpg",
    "assets/annapurna.jpg",
    "assets/shey.jpg",
    "assets/pokhara.jpg",
    "assets/gumba.jpg",
    "assets/dhaulagiri.jpg",

    // Outdoor images
    "assets/rafting1.png",
    "assets/rafting2.jpg",
    "assets/junglesafri.jpg",
    "assets/camping.jpg",
    "assets/trek1.jpg",
    "assets/outdoor.jpg",

    // Food images
    "assets/food.jpg",
    "assets/cooking1.jpg",
    "assets/cooking2.jpg",
    "assets/cooking3.jpg",
    "assets/barista1.jpg",
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

    selectedCategory = widget.package?['category'] ?? "food";

    selectedSubcategory =
        widget.package?['subcategory'] ?? _defaultSubcategory(selectedCategory);

    selectedDifficulty = widget.package?['difficulty'] ?? "Beginner";

    selectedImage = widget.package?['image'] ?? "assets/kanchan.jpg";

    if (!localImages.contains(selectedImage)) {
      selectedImage = "assets/kanchan.jpg";
    }
  }

  String _defaultSubcategory(String category) {
    if (category == "food") {
      return "barista";
    }

    if (category == "outdoor") {
      return "trekking";
    }

    if (category == "water") {
      return "rafting";
    }

    return "";
  }

  bool _hasSubcategory(String category) {
    return category == "food" || category == "outdoor" || category == "water";
  }

  void _onCategoryChanged(String value) {
    setState(() {
      selectedCategory = value;

      if (value == "food") {
        selectedSubcategory = "barista";
      } else if (value == "outdoor") {
        selectedSubcategory = "trekking";
      } else if (value == "water") {
        selectedSubcategory = "rafting";
      } else {
        selectedSubcategory = "";
      }
    });
  }

  List<DropdownMenuItem<String>> _subcategoryItems() {
    if (selectedCategory == "food") {
      return const [
        DropdownMenuItem(value: "barista", child: Text("Barista")),
        DropdownMenuItem(value: "cooking_class", child: Text("Cooking Class")),
      ];
    }

    if (selectedCategory == "outdoor") {
      return const [
        DropdownMenuItem(value: "trekking", child: Text("Trekking")),
        DropdownMenuItem(value: "camping", child: Text("Camping")),
        DropdownMenuItem(value: "safari", child: Text("Safari")),
      ];
    }

    if (selectedCategory == "water") {
      return const [
        DropdownMenuItem(value: "rafting", child: Text("Rafting")),
        DropdownMenuItem(value: "boating", child: Text("Boating")),
      ];
    }

    return const [];
  }

  String _subcategoryLabel() {
    if (selectedCategory == "food") {
      return "Food Subcategory";
    }

    if (selectedCategory == "outdoor") {
      return "Outdoor Subcategory";
    }

    if (selectedCategory == "water") {
      return "Water Subcategory";
    }

    return "Subcategory";
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
      final Map<String, dynamic> packageData = {
        "title": titleController.text.trim(),
        "destination": destinationController.text.trim(),
        "price": priceController.text.trim(),
        "duration": durationController.text.trim(),
        "category": selectedCategory,
        "subcategory": _hasSubcategory(selectedCategory)
            ? selectedSubcategory
            : null,
        "description": descriptionController.text.trim(),
        "image": selectedImage,
        "difficulty": selectedDifficulty,
        "created_by": 1,
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

      if (!mounted) return;

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
              // IMAGE
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
                      child: Image.asset(
                        selectedImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
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
                      if (value != null) {
                        setState(() {
                          selectedImage = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Package Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter title";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // DESTINATION
              TextFormField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: "Destination",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter destination";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // PRICE
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (Rs.)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter price";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // DURATION
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: "Duration",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter duration";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "food", child: Text("Food")),
                  DropdownMenuItem(value: "outdoor", child: Text("Outdoor")),
                  DropdownMenuItem(value: "culture", child: Text("Culture")),
                  DropdownMenuItem(value: "water", child: Text("Water")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _onCategoryChanged(value);
                  }
                },
              ),

              const SizedBox(height: 12),

              // SUBCATEGORY FOR FOOD AND OUTDOOR ONLY
              if (_hasSubcategory(selectedCategory)) ...[
                DropdownButtonFormField<String>(
                  value: selectedSubcategory,
                  decoration: InputDecoration(
                    labelText: _subcategoryLabel(),
                    border: const OutlineInputBorder(),
                  ),
                  items: _subcategoryItems(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSubcategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              // DIFFICULTY
              DropdownButtonFormField<String>(
                value: selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: "Difficulty",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Beginner", child: Text("Beginner")),
                  DropdownMenuItem(value: "Moderate", child: Text("Moderate")),
                  DropdownMenuItem(value: "Expert", child: Text("Expert")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDifficulty = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 12),

              // DESCRIPTION
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter description";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // SAVE BUTTON
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
