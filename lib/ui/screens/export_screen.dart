import 'package:flutter/material.dart';
import 'package:spendulum/models/export_job.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/export_service.dart';
import 'package:provider/provider.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _email = '';
  ExportType _exportType = ExportType.csv;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Data'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildDateRangePicker(),
            SizedBox(height: 16),
            _buildEmailField(),
            SizedBox(height: 16),
            _buildExportTypeSelector(),
            SizedBox(height: 24),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date Range',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _startDate?.toString().split(' ')[0] ?? '',
                ),
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(true),
                validator: (value) {
                  if (_startDate == null) {
                    return 'Please select start date';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _endDate?.toString().split(' ')[0] ?? '',
                ),
                decoration: InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(false),
                validator: (value) {
                  if (_endDate == null) {
                    return 'Please select end date';
                  }
                  if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                    return 'End date must be after start date';
                  }
                  if (_startDate != null &&
                      _endDate!.difference(_startDate!).inDays > 365) {
                    return 'Date range cannot exceed 1 year';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => _email = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildExportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export Format', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SegmentedButton<ExportType>(
          segments: [
            ButtonSegment(
              value: ExportType.csv,
              label: Text('CSV'),
              icon: Icon(Icons.description),
            ),
            ButtonSegment(
              value: ExportType.excel,
              label: Text('Excel'),
              icon: Icon(Icons.table_chart),
            ),
          ],
          selected: {_exportType},
          onSelectionChanged: (Set<ExportType> selected) {
            setState(() {
              _exportType = selected.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleExport,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
      child: _isLoading ? CircularProgressIndicator() : Text('Export Data'),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleExport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final exportJob = ExportJob(
        startDate: _startDate!,
        endDate: _endDate!,
        email: _email,
        exportType: _exportType,
      );

      final exportService = Provider.of<ExportService>(context, listen: false);
      await exportService.createExportJob(exportJob);

      // Show success dialog
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Started'),
          content: Text(
            'Your export has been scheduled. You will receive an email at $_email once the export is complete.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      AppLogger.error('Error scheduling export', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule export. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
