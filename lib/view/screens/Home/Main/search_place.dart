import 'package:flutter/material.dart';

class searchScreen extends StatefulWidget {
  final String cityName;
  const searchScreen({super.key, required this.cityName,});

  @override
  State<searchScreen> createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false; // Track if the search field is active

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.cityName;
    _isSearchActive = widget.cityName.isNotEmpty;

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearchActive = _searchController
          .text.isNotEmpty; // Show cross icon when there's text
    });
  }

  void _clearSearch() {
    _searchController.clear(); // Clear the search field
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Form with Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back Button

                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: 'Search for city, location or hotel',
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        suffixIcon: _isSearchActive
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed:
                                    _clearSearch, // Clear the search text
                              )
                            : null,
                        // Show cross icon only when there is text
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nearby Location Option
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'Use my current location',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Suggested Locations or Result List
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Assume we have 10 dummy locations
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blueAccent),
                    title: Text("Location ${index + 1}"),
                    subtitle: Text("Subtitle for Location ${index + 1}"),
                    onTap: () {
                      // Handle location tap
                      print("Tapped on Location ${index + 1}");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
