import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

// Replace with your local IP if testing on physical device/emulator (e.g., '10.0.2.2:3000' for Android emulator)
const String baseUrl = 'http://localhost:3000/contacts';

final contactProvider = StateNotifierProvider<ContactNotifier, List<Contact>>((
  ref,
) {
  return ContactNotifier();
});

class ContactNotifier extends StateNotifier<List<Contact>> {
  ContactNotifier() : super([]) {
    fetchContacts();
  }

  // READ
  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        state = data.map((e) => Contact.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching: $e");
    }
  }

  // CREATE
  Future<void> addContact(String name, String phone, File? image) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['name'] = name;
    request.fields['phone'] = phone;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final newContact = Contact.fromJson(json.decode(response.body));
        state = [newContact, ...state]; // Add to top of list
      }
    } catch (e) {
      print("Error adding: $e");
    }
  }

  // DELETE
  Future<void> deleteContact(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        state = state.where((c) => c.id != id).toList();
      }
    } catch (e) {
      print("Error deleting: $e");
    }
  }
}
