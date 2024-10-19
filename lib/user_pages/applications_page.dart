import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ApplicationsPage extends StatefulWidget {
  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  Set<String> expandedCards = {};

  void toggleCard(String applicationId) {
    setState(() {
      if (expandedCards.contains(applicationId)) {
        expandedCards.remove(applicationId);
      } else {
        expandedCards.add(applicationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong', style: TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No applications yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot application = snapshot.data!.docs[index];
              Map<String, dynamic> data = application.data() as Map<String, dynamic>;
              bool isExpanded = expandedCards.contains(application.id);

              Color statusColor;
              IconData statusIcon;
              switch (data['status']) {
                case 'accepted':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_empty;
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () => toggleCard(application.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information (Always Visible)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['jobTitle'] ?? 'Unknown Job',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['status'] ?? 'Pending',
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Company Name
                        Text(
                          data['companyName'] ?? 'Unknown Company',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Applied on: ${DateFormat('MMM d, yyyy').format((data['timestamp'] as Timestamp).toDate())}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),

                        // Expanded Information (Only visible when card is expanded)
                        if (isExpanded) ...[
                          const Divider(height: 24),
                          Text(
                            'Job Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                data['jobLocation'] ?? 'Unknown Location',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.work, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                data['jobEmploymentType'] ?? 'Not specified',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                data['jobSalaryRange'] ?? 'Not specified',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(data['jobDescription'] ?? 'No description available'),
                          const SizedBox(height: 16),
                          Text(
                            'Responsibilities:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (data['jobResponsibilities'] != null)
                            ...List<String>.from(data['jobResponsibilities']).map(
                                  (responsibility) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(responsibility)),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Qualifications:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (data['jobQualifications'] != null)
                            ...List<String>.from(data['jobQualifications']).map(
                                  (qualification) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(qualification)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        // Expansion indicator
                        Center(
                          child: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}