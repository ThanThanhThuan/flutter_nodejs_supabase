import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'providers/contact_provider.dart';
import 'models/contact.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Slivers & Riverpod',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactProvider);

    return Scaffold(
      // --- SLIVER STRUCTURE STARTS HERE ---
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar (Floats and snaps)
          const SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("THAN - Contacts"),
              centerTitle: true,
              background: Image(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1519389950473-47ba0277781c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Sliver List (The content)
          contacts.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text("No contacts yet")),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final contact = contacts[index];
                    return Dismissible(
                      key: ValueKey(contact.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        ref
                            .read(contactProvider.notifier)
                            .deleteContact(contact.id);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: contact.imageUrl != null
                                ? NetworkImage(contact.imageUrl!)
                                : null,
                            child: contact.imageUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                        ),
                      ),
                    );
                  }, childCount: contacts.length),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactModal(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper to show the add form
  void _showAddContactModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddContactForm(),
      ),
    );
  }
}

class AddContactForm extends ConsumerStatefulWidget {
  const AddContactForm({super.key});

  @override
  ConsumerState<AddContactForm> createState() => _AddContactFormState();
}

class _AddContactFormState extends ConsumerState<AddContactForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    await ref
        .read(contactProvider.notifier)
        .addContact(
          _nameController.text,
          _phoneController.text,
          _selectedImage,
        );
    if (mounted) {
      Navigator.pop(context); // Close modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  _selectedImage == null ? "Pick an Image" : "Image Selected",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Save Contact"),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
