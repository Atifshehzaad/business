import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_helper.dart';

class AddBusinessScreen extends StatefulWidget {
  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _servicesController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final business = {
        'name': _nameController.text,
        'address': _addressController.text,
        'services': _servicesController.text,
        'thumbnail': _selectedImage != null ? _selectedImage!.path : null,
      };
      await DBHelper.instance.insertBusiness(business);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business added successfully!')),
      );
      Navigator.pop(context); // Navigate back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Business'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Business Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter the business name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter the address' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _servicesController,
                decoration: InputDecoration(
                  labelText: 'Services (JSON format)',
                  hintText: '[{"name": "Service1", "price": "\$10"}]',
                ),
                validator: (value) => value!.isEmpty
                    ? 'Please provide services in JSON format'
                    : null,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 50),
                )
                    : Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
