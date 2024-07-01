import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(NinjaApp());
}

class NinjaApp extends StatefulWidget {
  @override
  _NinjaAppState createState() => _NinjaAppState();
}

class _NinjaAppState extends State<NinjaApp> {
  List<List<dynamic>> ninjas = [];
  bool isLoading = true;
  List<bool> yesSelections = [];
  List<bool> noSelections = [];
  List<int> yesCounts = [];
  List<int> noCounts = [];
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    try {
      final String csvData = await rootBundle.loadString('assets/ninjas.csv');
      setState(() {
        ninjas = CsvToListConverter().convert(csvData);
        // Remove the header row
        if (ninjas.isNotEmpty) {
          ninjas.removeAt(0);
        }
        isLoading = false;
        // Initialize the selections, counts, and controllers
        yesSelections = List<bool>.filled(ninjas.length, false);
        noSelections = List<bool>.filled(ninjas.length, false);
        yesCounts = List<int>.filled(ninjas.length, 0);
        noCounts = List<int>.filled(ninjas.length, 0);
        controllers = List<TextEditingController>.generate(ninjas.length, (_) => TextEditingController());
      });
    } catch (e) {
      // Handle the error by showing a message or logging
      print('Error loading CSV: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateCount(int index, bool isYes) {
    setState(() {
      if (isYes) {
        yesCounts[index]++;
        if (noSelections[index]) {
          noCounts[index]--;
        }
      } else {
        noCounts[index]++;
        if (yesSelections[index]) {
          yesCounts[index]--;
        }
      }
    });
  }

  void resetCounts() {
    setState(() {
      yesSelections = List<bool>.filled(ninjas.length, false);
      noSelections = List<bool>.filled(ninjas.length, false);
      yesCounts = List<int>.filled(ninjas.length, 0);
      noCounts = List<int>.filled(ninjas.length, 0);
      for (var controller in controllers) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Umfrage'),
          backgroundColor: Colors.deepOrange,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: resetCounts,
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.orange[100],
                child: ListView.builder(
                  itemCount: ninjas.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        ninjas[index][0], // Name
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ja: ${yesCounts[index]}, Nein: ${noCounts[index]}\nNotizen: ${controllers[index].text}', // Rank and Village with counters and notes
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                          TextField(
                            controller: controllers[index],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Deine Anmerkungen',
                            ),
                          ),
                        ],
                      ),
                      tileColor: Colors.orange[50],
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: yesSelections[index],
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null && value) {
                                  yesSelections[index] = true;
                                  noSelections[index] = false;
                                  updateCount(index, true);
                                } else {
                                  yesSelections[index] = false;
                                  updateCount(index, false);
                                }
                              });
                            },
                          ),
                          Text('Ja'),
                          Checkbox(
                            value: noSelections[index],
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null && value) {
                                  noSelections[index] = true;
                                  yesSelections[index] = false;
                                  updateCount(index, false);
                                } else {
                                  noSelections[index] = false;
                                  updateCount(index, true);
                                }
                              });
                            },
                          ),
                          Text('Nein'),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
