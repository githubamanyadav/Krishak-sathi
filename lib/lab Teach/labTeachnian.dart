import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Technician App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LabTechnicianPage(),
    );
  }
}

class LabTechnicianPage extends StatefulWidget {
  @override
  _LabTechnicianPageState createState() => _LabTechnicianPageState();
}

class _LabTechnicianPageState extends State<LabTechnicianPage> {
  int _selectedIndex = 0;
  List<Map<String, String>> acceptedRequests = [];
  List<Map<String, String>> pendingRequests = [
    {
      "farmerName": "shivanshu kumar",
      "farmerAddress": "123 Greenfield Lane, District A",
      "slotDate": "2024-12-20",
      "slotTime": "10:00 AM",
      "labName": "Agro Lab A",
    },
    {
      "farmerName": "Aman yadav",
      "farmerAddress": "456 Bluehill Road, District B",
      "slotDate": "2024-12-21",
      "slotTime": "02:00 PM",
      "labName": "Agro Lab B",
    }
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      LabTechnicianBody(
        onAccept: _storeAcceptedRequest,
        requests: pendingRequests,
      ),
      Center(
        child: Text(
          'Accepted Requests',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _storeAcceptedRequest(Map<String, String> request) {
    setState(() {
      acceptedRequests.add(request);
      pendingRequests.remove(request);
      _selectedIndex = 1;
      _updateSettingsPage();
    });
  }

  void _deleteRequest(int index) {
    setState(() {
      acceptedRequests.removeAt(index);
      _updateSettingsPage();
    });
  }

  void _updateSettingsPage() {
    _pages[1] = ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: acceptedRequests.length,
      itemBuilder: (context, index) {
        final req = acceptedRequests[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text('Farmer: ${req['farmerName']}'),
            subtitle: Text(
                'Lab: ${req['labName']}\nSlot: ${req['slotDate']} at ${req['slotTime']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRequest(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lab Technician Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Accepted',
          ),
        ],
      ),
    );
  }
}

class LabTechnicianBody extends StatelessWidget {
  final Function(Map<String, String>) onAccept;
  final List<Map<String, String>> requests;

  LabTechnicianBody({required this.onAccept, required this.requests});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Farmer: ${request['farmerName']}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  "Address: ${request['farmerAddress']}",
                ),
                Text(
                  "Slot Date: ${request['slotDate']}",
                ),
                Text(
                  "Slot Time: ${request['slotTime']}",
                ),
                Text(
                  "Lab: ${request['labName']}",
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _acceptTask(context, request);
                  },
                  child: Text("Accept", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DB83D),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acceptTask(BuildContext context, Map<String, String> request) {
    onAccept(request);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Accepted task for ${request['farmerName']}")),
    );
  }
}
