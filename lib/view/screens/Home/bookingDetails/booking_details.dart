import 'package:didirooms2/view_models/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CustomerBookingDetails extends StatefulWidget {
  @override
  _CustomerBookingDetailsState createState() => _CustomerBookingDetailsState();
}

class _CustomerBookingDetailsState extends State<CustomerBookingDetails> {
  final DatabaseReference bookingRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> bookingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    try {
      DataSnapshot snapshot = await bookingRef
          .child('CustomerBookingDetails/${ap.userModel.uid}')
          .get();

      List<Map<String, dynamic>> bookings = [];
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(Map<String, dynamic>.from(value));
        });
      }

      setState(() {
        bookingList = bookings;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: GoogleFonts.poppins()),
        backgroundColor: Colors.yellow[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> booking = bookingList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailScreen(
                          days: booking['days'].toString(),
                          roomId: booking['roomId'],
                          total: booking['totalPrice'].toString(),
                          rooms:booking['numberOfRooms'].toString()

                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Check In Date: ${booking['startDate']}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Text(
                            "Check Out Date: ${booking['endDate']}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Days: ${booking['days']}",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ), Text(
                                  "Rooms: ${booking['numberOfRooms']}",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Total Price: Rs ${booking['totalPrice']}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.green[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


class BookingDetailScreen extends StatefulWidget {
  final String roomId; // Pass the roomId to fetch room details
  final String days;   // Total days for the booking
  final String total;
  final String rooms;

  const BookingDetailScreen({super.key, required this.roomId, required this.days, required this.total, required this.rooms});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? roomData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomDetails(); // Fetch room details when the screen loads
  }

  // Fetch room details from Firestore
  Future<void> _fetchRoomDetails() async {
    try {
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomId)
          .get();

      if (roomSnapshot.exists) {
        setState(() {
          roomData = roomSnapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching room details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build room details UI
  Widget _buildRoomDetails() {
    if (roomData == null) {
      return Center(child: Text('No data available for this room.'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roomData!['roomType'] ?? 'Room Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Rs ${roomData!['price']} per night',
              style: TextStyle(
                fontSize: 20,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Rs ${widget.total} Total',
              style: TextStyle(
                fontSize: 20,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total Days: ${widget.days}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'No of Rooms: ${widget.rooms}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '${roomData!['location']['city']}, ${roomData!['location']['state']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Amenities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _buildAmenitiesIcons(),
            ),
            SizedBox(height: 20),
            Text(
              'Images:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (roomData!['imageUrl'] as List).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        roomData!['imageUrl'][index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build amenities list based on available services and display as icons
  List<Widget> _buildAmenitiesIcons() {
    List<Widget> amenitiesIcons = [];

    Map<String, dynamic>? services = roomData!['Services'];

    if (services != null) {
      services.forEach((service, isAvailable) {
        if (isAvailable) {
          IconData iconData;
          switch (service.toLowerCase()) {
            case 'wifi':
              iconData = Icons.wifi;
              break;
            case 'food':
              iconData = Icons.fastfood;
              break;
            case 'laundry':
              iconData = Icons.local_laundry_service;
              break;
            case 'parking':
              iconData = Icons.local_parking;
              break;
            case 'roomservice':
              iconData = Icons.room_service;
              break;
            case 'workstation':
              iconData = Icons.computer;
              break;
            case 'library':
              iconData = Icons.library_books;
              break;
            default:
              iconData = Icons.info; // Default icon
          }

          amenitiesIcons.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.amber, size: 30),
                Text(service, style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }
      });
    } else {
      amenitiesIcons.add(Text('No amenities available.'));
    }

    return amenitiesIcons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildRoomDetails(),
    );
  }
}




