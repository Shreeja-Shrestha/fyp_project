import 'package:flutter/material.dart';
import 'food_list_page.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);
  final Color backgroundColor = const Color(0xFFF7FBFD);

  final List<Map<String, dynamic>> foodCategories = const [
    {
      "title": "Barista Experience",
      "subtitle":
          "Learn coffee making, espresso basics, milk steaming, and latte art.",
      "image": "assets/barista.png",
      "subcategory": "barista",
      "icon": Icons.coffee,
    },
    {
      "title": "Cultural Cooking",
      "subtitle":
          "Prepare authentic Nepali dishes with local ingredients and guidance.",
      "image": "assets/cooking.png",
      "subcategory": "cooking_class",
      "icon": Icons.soup_kitchen,
    },
  ];

  void openCategory(BuildContext context, String subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodListPage(subcategory: subcategory)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Food Experiences",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _headerSection(),
          const SizedBox(height: 20),

          ...foodCategories.map((item) {
            return _experienceCard(context, item);
          }),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softSkyBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_dining, color: primarySkyBlue, size: 34),
          const SizedBox(height: 12),
          const Text(
            "Choose your experience",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Book hands-on food experiences designed for travelers who want to learn, taste, and explore local culture.",
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => openCategory(context, item["subcategory"]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: softSkyBlue.withOpacity(0.75)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                item["image"],
                height: 92,
                width: 92,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      color: softSkyBlue.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item["icon"], color: primarySkyBlue, size: 36),
                  );
                },
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"],
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item["subtitle"],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(item["icon"], size: 16, color: primarySkyBlue),
                      const SizedBox(width: 5),
                      Text(
                        "Bookable experience",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: softSkyBlue.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: primarySkyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
