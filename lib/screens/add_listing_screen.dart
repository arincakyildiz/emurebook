import 'package:flutter/material.dart';
import 'package:emurebook/services/book_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Set<String> _selectedExchangeTypes = {'Sell'}; // Default to Sell
  String _selectedCondition = 'Good'; // Default to Good

  final _bookService = BookService();

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addBook() async {
    if (titleController.text.isEmpty ||
        authorController.text.isEmpty ||
        priceController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
      }
      return;
    }

    if (_selectedExchangeTypes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one exchange type')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _bookService.addBook(
        titleController.text,
        authorController.text,
        double.parse(priceController.text),
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        imageFile: _selectedImage,
        exchangeType: _selectedExchangeTypes.join(', '), // Join multiple types
        condition: _selectedCondition,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _showImagePickerOptions,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Book Image',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select from gallery or camera',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a brief description of the book...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price (₺) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Condition Selection
            const Text(
              'Book Condition *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCondition,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: [
                    DropdownMenuItem(
                      value: 'Like New',
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          const Text('Like New'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EXCELLENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Good',
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up,
                              color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          const Text('Good'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'GOOD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Fair',
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[600], size: 20),
                          const SizedBox(width: 8),
                          const Text('Fair'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FAIR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCondition = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getConditionDescription(_selectedCondition),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Exchange Type Selection
            const Text(
              'Exchange Type *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select one or both options:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(Icons.sell, color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        const Text('Sell'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SELL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text('Sell your book for money'),
                    value: _selectedExchangeTypes.contains('Sell'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedExchangeTypes.add('Sell');
                        } else {
                          _selectedExchangeTypes.remove('Sell');
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(Icons.swap_horiz,
                            color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text('Exchange'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EXCHANGE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text('Exchange with another book'),
                    value: _selectedExchangeTypes.contains('Exchange'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedExchangeTypes.add('Exchange');
                        } else {
                          _selectedExchangeTypes.remove('Exchange');
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_selectedExchangeTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select at least one exchange type',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _addBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D66F4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Book',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConditionDescription(String condition) {
    switch (condition) {
      case 'Like New':
        return 'Minimal wear, looks almost new';
      case 'Good':
        return 'Some wear but still in good condition';
      case 'Fair':
        return 'Noticeable wear but still functional';
      default:
        return '';
    }
  }
}
