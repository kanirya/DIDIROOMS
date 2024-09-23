import 'dart:convert';
import 'package:didirooms2/utils/global/global_variables.dart'; // For API key
import 'package:didirooms2/view/screens/Home/Main/room_search.dart';
import 'package:didirooms2/view_models/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  final String cityName;

  const SearchScreen({
    super.key,
    required this.cityName,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false; // Track if the search field is active
  List<dynamic> _placeSuggestions = []; // Store place suggestions

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

  void _onSearchChanged() async {
    setState(() {
      _isSearchActive = _searchController.text.isNotEmpty;
    });

    if (_searchController.text.isNotEmpty) {
      // Fetch suggestions when the input is not empty
      _placeSuggestions = await _getPlaceSuggestions(_searchController.text);
      setState(() {}); // Trigger a rebuild to show the updated suggestions
    }
  }

  void _clearSearch() {
    _searchController.clear(); // Clear the search field
    setState(() {
      _isSearchActive = false;
      _placeSuggestions = []; // Clear suggestions when search is cleared
    });
  }

  Future<List<dynamic>> _getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      return [];
    }
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String requestUrl =
        '$baseUrl?input=$input&key=$APIKEY&language=en';

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        return json['predictions'];
      }
      return [];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    String requestUrl = '$baseUrl?place_id=$placeId&key=$APIKEY';

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['result'];
    } else {
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Form with Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
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
            InkWell(
              onTap: () {
                ap.getCurrentLocation().then((onValue) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NearbyRoomsScreen(
                        Rlocation: LatLng(ap.currentPosition!.latitude,
                            ap.currentPosition!.longitude),
                      ),
                    ),
                  );
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
              child: _placeSuggestions.isEmpty
                  ? Center(
                child: Text("No suggestions available."),
              )
                  : ListView.builder(
                itemCount: _placeSuggestions.length,
                itemBuilder: (context, index) {
                  var suggestion = _placeSuggestions[index];
                  return ListTile(
                    leading:
                    Icon(Icons.location_on, color: Colors.blueAccent),
                    title: Text(suggestion['description']),
                    onTap: () async {
                      // Get place details on tap
                      String placeId = suggestion['place_id'];
                      var placeDetails =
                      await _getPlaceDetails(placeId);
                      print(placeDetails); // Use this data as needed
                      // Navigate or show place details
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
