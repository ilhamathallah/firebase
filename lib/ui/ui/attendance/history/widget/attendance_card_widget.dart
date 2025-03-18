import 'dart:math';

import 'package:flutter/material.dart';

class AttendanceCardWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String attendanceId;

  const AttendanceCardWidget(
      {super.key, required this.data, required this.attendanceId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                (data['name']?.isNotEmpty ?? false)
                    ? data['name'][0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ), // Membuat ujung melengkung hanya di kiri
                    ),
                  ),
                ),
                // Card utama
                Padding(
                  padding: const EdgeInsets.only(left: 6), // Menyesuaikan dengan lebar garis
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Membuat card lebih smooth
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Agar teks rata kiri
                        children: [
                          Text(
                            data['name'] ?? 'no name',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.bookmark, color: Colors.blue, size: 18,),
                              SizedBox(width: 5),
                              Text(
                                data['description'] ?? 'no attendance',
                                style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.access_time_outlined, color: Colors.grey, size: 18),
                              SizedBox(width: 5),
                              Text(
                                data['datetime'].toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.green, size: 18),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  data['address'] ?? 'No Address',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
