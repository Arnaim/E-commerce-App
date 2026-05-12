import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../models/product_model.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Skincare';
  
  final List<File> _images = [];
  bool _isUploading = false;
  final _storageService = StorageService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      setState(() => _isUploading = true);
      try {
        final user = ref.read(userModelProvider).value!;
        
        // 1. Upload Images
        final urls = await _storageService.uploadProductImages(user.uid, _images);
        
        // 2. Create Product
        final product = ProductModel(
          id: '',
          sellerId: user.uid,
          sellerName: user.displayName,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          imageUrls: urls,
          stock: int.parse(_stockController.text.trim()),
          createdAt: DateTime.now(),
          isActive: true,
        );

        await ref.read(productProvider).addProduct(product);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    } else if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: _isUploading 
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Uploading product...')],
          ))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Price (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid price' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(labelText: 'Stock'),
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || int.tryParse(val) == null ? 'Invalid stock' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['Skincare', 'Makeup', 'Hair', 'Fragrance'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('List Product'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return InkWell(
              onTap: _pickImage,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_images[index], width: 120, height: 120, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => setState(() => _images.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
