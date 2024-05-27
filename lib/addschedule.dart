import 'package:flutter/material.dart';
import 'package:dailyplanner/models/user_model.dart';
import 'package:dailyplanner/user_controller.dart';
import 'package:intl/intl.dart';

class AddSchedulePage extends StatefulWidget {
  final String username;

  AddSchedulePage({required this.username});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _activityDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _activityDate) {
      setState(() {
        _activityDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate() &&
        _activityDate != null &&
        _startTime != null &&
        _endTime != null) {
      final int id = DateTime.now().millisecondsSinceEpoch;
      final DateTime startDateTime = DateTime(
        _activityDate!.year,
        _activityDate!.month,
        _activityDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final DateTime endDateTime = DateTime(
        _activityDate!.year,
        _activityDate!.month,
        _activityDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final newActivity = Activity(
        id,
        _titleController.text,
        _descriptionController.text,
        _activityDate!,
        startDateTime,
        endDateTime,
        _locationController.text,
      );

      await UserController.addActivity(widget.username, newActivity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule saved successfully')),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
    }
  }


  Widget _buildInputCard({required String label, required Widget child}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xFF8f14b8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            SizedBox(height: 8.0),
            child,
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Schedule', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _activityDate == null
                        ? 'Select Date'
                        : DateFormat.yMMMd().format(_activityDate!),
                    style: TextStyle(fontSize: 16, color: Colors.white60),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 8),
                _buildInputCard(
                  label: 'Title',
                  child: TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter title',
                      hintStyle: TextStyle(color: Colors.white60),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                _buildInputCard(
                  label: 'Description',
                  child: TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.white60),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ),
                _buildInputCard(
                  label: 'Location',
                  child: TextFormField(
                    controller: _locationController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.white60),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputCard(
                        label: 'Start Time',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _startTime == null
                                ? 'Select Start Time'
                                : _startTime!.format(context),
                            style: TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                          trailing: Icon(Icons.access_time, color: Colors.white, size: 20),
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildInputCard(
                        label: 'End Time',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _endTime == null
                                ? 'Select End Time'
                                : _endTime!.format(context),
                            style: TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                          trailing: Icon(Icons.access_time, color: Colors.white, size: 20),
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveActivity,
                    child: Text('Save Schedule', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      backgroundColor: Color(0xFF8f14b8),
                      textStyle: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
