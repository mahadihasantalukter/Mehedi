import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class StudentImageUploadPage extends StatefulWidget {
  const StudentImageUploadPage({super.key});

  @override
  State<StudentImageUploadPage> createState() => _StudentImageUploadPageState();
}

class _StudentImageUploadPageState extends State<StudentImageUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  
  XFile? _pickedFile; 
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_formKey.currentState!.validate() && _pickedFile != null) {
      final uri = Uri.parse('http://192.168.0.190/flutter_api/upload.php');
      
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['studentId'] = _studentIdController.text;
      
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fileToUpload', 
            await _pickedFile!.readAsBytes(),
            filename: _pickedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('fileToUpload', _pickedFile!.path),
        );
      }
      
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print('Upload successful: $respStr');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ছবি সফলভাবে আপলোড হয়েছে!')),
        );
      } else {
        final respStr = await response.stream.bytesToString();
        print('Upload failed: $respStr');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ছবি আপলোড ব্যর্থ হয়েছে!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে শিক্ষার্থীর আইডি এবং একটি ছবি নির্বাচন করুন।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ছবি আপলোড করুন')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'শিক্ষার্থীর আইডি'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'দয়া করে শিক্ষার্থীর আইডি দিন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              if (_pickedFile == null)
                const Text('কোনো ছবি নির্বাচন করা হয়নি।')
              else
                kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: _pickedFile!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return Image.memory(snapshot.data!, height: 200);
                          } else if (snapshot.hasError) {
                            return const Text('ছবি লোড করতে ব্যর্থ হয়েছে।');
                          }
                          return const CircularProgressIndicator();
                        },
                      )
                    : Image.file(
                        File(_pickedFile!.path),
                        height: 200,
                      ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('গ্যালারি থেকে ছবি বাছাই করুন'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('আপলোড করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}