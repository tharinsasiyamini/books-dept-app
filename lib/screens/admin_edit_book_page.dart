import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../services/database_helper.dart';

class AdminEditBookPage extends StatefulWidget {
  final Book book;
  const AdminEditBookPage({super.key, required this.book});

  @override
  State<AdminEditBookPage> createState() => _AdminEditBookPageState();
}

class _AdminEditBookPageState extends State<AdminEditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;

  String? _selectedCategory;
  String? _imagePath;
  bool _isSaving = false;

  final List<String> _categories = [
    'BEST SELLERS',
    'FEATURED',
    'FAVORITE',
    'NEW ARRIVALS'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author ?? '');
    _priceController = TextEditingController(text: widget.book.price.toString());
    _stockController = TextEditingController(text: widget.book.stock.toString());
    _descController = TextEditingController(text: widget.book.description ?? '');
    
    // Check if the current category is in our allowed list
    if (widget.book.language != null && _categories.contains(widget.book.language)) {
      _selectedCategory = widget.book.language;
    }
    
    _imagePath = widget.book.imageURL;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    final updatedBook = Book(
      bookID: widget.book.bookID,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      description: _descController.text.trim(),
      imageURL: _imagePath,
      language: _selectedCategory, 
    );

    await DatabaseHelper.instance.updateBook(updatedBook);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Book',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48), // balance back button
                  ],
                ),
                const SizedBox(height: 32),

                // Cover Image Upload
                Row(
                  children: [
                    const Text('Book Cover ( ', style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined),
                          const SizedBox(width: 4),
                          Text(
                            _imagePath != null ? 'Change Image' : 'Upload Image',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: _imagePath != null ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(' )', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField('Book Title :- ', _titleController),
                _buildTextField('Author :- ', _authorController),

                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('Category :-', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: const Text('[ Select Category ▼ ]'),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          },
                          validator: (val) => val == null ? 'Select category' : null,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildTextField('Price :- Rs. ', _priceController, isNumber: true),
                _buildTextField('Stock Quantity :- ', _stockController, isNumber: true),
                _buildTextField('Description :- ', _descController, maxLines: 3),

                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    OutlinedButton(
                      onPressed: _isSaving ? null : _saveBook,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Update Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                if (isNumber && double.tryParse(val) == null) return 'Invalid number';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
