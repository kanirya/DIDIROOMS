import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didirooms2/utils/global/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../res/components/button_components.dart';

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
  int roomCount = 1;
  int maxRoomCount = 10; // Maximum available rooms
  int currentImageIndex = 0;
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
      initialDateRange: selectedDateRange ??
          DateTimeRange(
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
          maxRoomCount = totalRooms; // Set the maximum available rooms
          setState(() {
            if(roomCount>totalRooms){
            roomCount=totalRooms;}
          });

          // Loop through the selected date range
          for (DateTime date = selectedDateRange!.start;
              date.isBefore(selectedDateRange!.end.add(Duration(days: 1)));
              date = date.add(Duration(days: 1))) {
            String dateKey = date.toIso8601String().split("T").first;

            // Check if the selected date exists in roomAvailability
            if (roomAvailability.containsKey(dateKey)) {
              // Date is found, show the available rooms for that date
              int availableCount =
                  roomAvailability[dateKey]['available'] is String
                      ? int.parse(roomAvailability[dateKey]['available'])
                      : roomAvailability[dateKey]['available'] ?? 0;
              availableRooms![date] = availableCount;
            } else {
              // Date is not found, show all rooms available
              availableRooms![date] = totalRooms;
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
          style: GoogleFonts.poppins(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        backgroundColor: Colors.teal[600],
      ),
      body: ownerData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImage(),
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
  Widget _buildMainImage() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.imageUrls[_currentImageIndex]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Build image thumbnails
  Widget _buildImageThumbnails() {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index; // Update the current index
              });
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentImageIndex == index
                      ? Colors.teal
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
  // Add this method inside your _RoomBookingCalendarState class
  Widget _buildRoomDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Details (${widget.roomType})",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.teal)),
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
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
        ),
        SizedBox(height: 16), // Increased spacing for better visual
        // Counter Widget
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Number of Rooms:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.teal[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        if (roomCount > 1) roomCount--;
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Text(
                      '$roomCount',
                      style: TextStyle(fontSize: 23, color: mainColor,fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        if (roomCount < maxRoomCount) roomCount++; // Limit increment
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
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
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal),
          ),
        ),
        Divider(color: Colors.grey),

        SizedBox(height: 8),
        CustomButton(
          onPressed: () {
            selectDateRange();
          },
          color: Colors.black87,
          cornerRadius: 4,
          text: "Select Date Range",
        ),
        const SizedBox(height: 10,),
        Text(
          selectedDateRange != null
              ? "${dateFormat.format(selectedDateRange!.start)}   to   ${dateFormat.format(selectedDateRange!.end)}"
              : "Please select a date range",
          style: TextStyle(fontSize: 16, color: Colors.black87,fontWeight: FontWeight.bold),
        ),

        if (selectedDateRange != null) ...[
          SizedBox(height: 4),
          Text(
            'Checkout Date: ${dateFormat.format(checkoutDate!)}',
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10,),
          if(selectedDateRange!=null)
            Text("Days: ${selectedDateRange!.end.difference(selectedDateRange!.start).inDays + 1}",style: GoogleFonts.montserrat(textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),),

        ],
      ],
    );
  }

  // Display room availability
  Widget _buildRoomAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Availability",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal),
          ),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        availableRooms == null
            ? Text(
                "Room availability data is not available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            : showAllRooms
                ? Text(
                    "All rooms are available for the selected dates.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  )
                : Column(
                    children: availableRooms!.entries
                        .map((entry) => Text(
                              "${dateFormat.format(entry.key)}: ${entry.value} rooms available",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ))
                        .toList(),
                  ),
      ],
    );
  }

  // Services Section
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Services",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal)),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.services.entries.map((entry) {
              return entry.value
                  ? _buildServiceIcon(_getServiceIcon(entry.key), entry.key)
                  : SizedBox.shrink();
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.blueGrey,
              size: 30,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[700],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String serviceKey) {
    switch (serviceKey) {
      case 'AC':
        return Icons.ac_unit;
      case 'wifi':
        return Icons.wifi;
      case 'Food':
        return Icons.restaurant;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'parking':
        return Icons.local_parking;
      case 'roomService':
        return Icons.room_service;
      case 'library':
        return Icons.library_books;
      case 'workStation':
        return Icons.desktop_mac;
      default:
        return Icons.help_outline;
    }
  }

  // Display owner details
  Widget _buildOwnerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Owner / Hotel Information",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.teal)),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(ownerData?['imageUrl']),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownerData?['name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text("Phone: ${ownerData?['phone']}"),
              ],
            ),
          ],
        ),
        Divider(height: 20,thickness: 3,),
        const SizedBox(height: 10,),
        CustomButton(text: 'Book Now', cornerRadius: 5, color: mainColor, onPressed: (){}),
        Divider(height: 20,thickness: 3,),
      ],
    );
  }
}
