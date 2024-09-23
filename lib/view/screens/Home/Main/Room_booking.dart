import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RoomBookingCalendar extends StatelessWidget {
  final String roomId;
  final String price;
  final Map<String, dynamic> location;
  final Map<String, dynamic> services;
  final List<String> imageUrls;

  RoomBookingCalendar({
    required this.roomId,
    required this.price,
    required this.location,
    required this.services,
    required this.imageUrls,
  });

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel for room images
              _buildImageCarousel(),

              SizedBox(height: 16),

              // Room Details
              _buildRoomDetails(),

              SizedBox(height: 16),

              // Services Icons
              _buildServicesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the image carousel
  Widget _buildImageCarousel() {
    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIndex) {
        return buildImage(imageUrls[index], index, imageUrls.length);
      },
      options: CarouselOptions(
        height: 250,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget buildImage(String url, int index, int totalImages) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}/$totalImages',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Method to display room details
  Widget _buildRoomDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        Text(
          "Room ID: $roomId",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          "Price: Rs $price",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Location: ${location['city']}, ${location['street']}",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Method to display services with icons
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Services",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (services['AC']) _buildServiceIcon(Icons.ac_unit, "AC"),
              if (services['wifi']) _buildServiceIcon(Icons.wifi, "WiFi"),
              if (services['Food'])
                _buildServiceIcon(Icons.restaurant, "Food"),
              if (services['laundry'])
                _buildServiceIcon(Icons.local_laundry_service, "Laundry"),
              if (services['parking'])
                _buildServiceIcon(Icons.local_parking, "Parking"),
              if (services['roomService'])
                _buildServiceIcon(Icons.room_service, "Room Service"),
              if (services['library'])
                _buildServiceIcon(Icons.library_books, "Library"),
              if (services['workStation'])
                _buildServiceIcon(Icons.desktop_mac, "WorkStation"),
            ],
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
}
