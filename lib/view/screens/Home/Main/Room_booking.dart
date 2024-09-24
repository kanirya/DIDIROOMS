import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoomBookingCalendar extends StatefulWidget {
  final String roomId;
  final String price;
  final Map<String, dynamic> location;
  final Map<String, dynamic> services;
  final List<String> imageUrls;
  final String ownerId;
  final String roomType;

  RoomBookingCalendar({
    required this.roomId,
    required this.price,
    required this.location,
    required this.services,
    required this.imageUrls,
    required this.ownerId,
    required this.roomType,
  });

  @override
  _RoomBookingCalendarState createState() => _RoomBookingCalendarState();
}

class _RoomBookingCalendarState extends State<RoomBookingCalendar> {
  int _currentImageIndex = 0;
  Map<String, dynamic>? ownerData;
  DateTimeRange? selectedDateRange;
  DateTime? checkoutDate;
  Map<DateTime, int>? availableRooms;
  bool showAllRooms = false;

  @override
  void initState() {
    super.initState();
    fetchOwnerData();
  }

  // Fetch owner data from Firestore
  Future<void> fetchOwnerData() async {
    try {
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .doc(widget.ownerId)
          .get();

      if (ownerSnapshot.exists) {
        setState(() {
          ownerData = ownerSnapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Error fetching owner data: $e');
    }
  }

  // Select date range for booking
  Future<void> selectDateRange() async {
    DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ?? DateTimeRange(
        start: now,
        end: now.add(Duration(days: 1)),
      ),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        checkoutDate = picked.end.add(Duration(days: 1));
      });
      await checkRoomAvailability();
    }
  }

  // Check room availability within the selected date range
  Future<void> checkRoomAvailability() async {
    if (selectedDateRange != null) {
      try {
        DocumentSnapshot availabilitySnapshot = await FirebaseFirestore.instance
            .collection('Rooms')
            .doc(widget.roomId)
            .get();

        if (availabilitySnapshot.exists) {
          Map<String, dynamic> availabilityData =
          availabilitySnapshot.data() as Map<String, dynamic>;

          Map<String, dynamic> roomAvailability =
              availabilityData['roomAvailability'] ?? {};

          int totalRooms = int.parse(availabilityData['rooms'] ?? '0');
          availableRooms = {};

          // Loop through the selected date range
          for (DateTime date = selectedDateRange!.start;
          date.isBefore(selectedDateRange!.end.add(Duration(days: 1)));
          date = date.add(Duration(days: 1))) {
            String dateKey = date.toIso8601String().split("T").first;

            // Check for available rooms on that date
            if (roomAvailability.containsKey(dateKey)) {
              int availableCount = roomAvailability[dateKey]['available'] ?? 0;
              availableRooms![date] = availableCount;
            } else {
              availableRooms![date] = totalRooms; // Use total if no data
            }
          }

          print('Available Rooms: $availableRooms');
        }
      } catch (e) {
        print('Error checking room availability: $e');
      }

      setState(() {
        showAllRooms = availableRooms == null || availableRooms!.isEmpty;
      });
    }
  }

  // Date formatter
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Room Booking",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ownerData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildImageThumbnails(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRoomDetails(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDateSelection(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRoomAvailability(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildServicesSection(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildOwnerDetails(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the image carousel
  Widget _buildImageCarousel() {
    return CarouselSlider(
      items: widget.imageUrls.map((url) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 250,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          setState(() {
            _currentImageIndex = index;
          });
        },
      ),
    );
  }

  // Build image thumbnails
  Widget _buildImageThumbnails() {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index; // Update carousel index
              });
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentImageIndex == index
                      ? Colors.blueGrey
                      : Colors.transparent,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Display room details
  Widget _buildRoomDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Details (${widget.roomType})",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        Text(
          "Nearby: ${widget.location['landmark']}",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          "Price: Rs ${widget.price}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Location: ${widget.location['city']}, ${widget.location['street']}",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Display date selection
  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Booking Dates",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: selectDateRange,
          child: Text('Select Date Range'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
          ),
        ),
        if (selectedDateRange != null) ...[
          SizedBox(height: 8),
          Text(
            'Selected Dates: ${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Checkout Date: ${dateFormat.format(checkoutDate!)}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ],
    );
  }

  // Build room availability section
  Widget _buildRoomAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Availability",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        if (showAllRooms) ...[
          Text(
            'All Rooms Available',
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ] else if (availableRooms != null && availableRooms!.isNotEmpty) ...[
          for (var entry in availableRooms!.entries)
            Text(
              '${dateFormat.format(entry.key)}: ${entry.value} rooms available',
              style: TextStyle(fontSize: 16),
            ),
        ] else ...[
          Text(
            'No availability for selected dates.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ],
    );
  }

  // Build services section
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services Offered",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        ...widget.services.entries.map((entry) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(entry.key),
            trailing: Text(entry.value.toString()),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOwnerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Owner Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(ownerData!['imageUrl']),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ownerData!['name'],
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Phone: ${ownerData!['phone']}",
                    style: TextStyle(fontSize: 16),
                  ),

                ],
              ),
            ),
          ],
        ),

      ],
    );
  }
}