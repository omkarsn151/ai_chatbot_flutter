import 'dart:io';
import 'package:ai_chatbot/providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/image_picker.dart';
import '../widgets/messages_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _messageController;

  bool isLoading = false;
  final apikey = dotenv.env['API_KEY'] ?? '';
  XFile? _selectedImage;

  void _pickImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() => _selectedImage = pickedImage);
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> deleteChatHistory() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await ref.read(chatProvider).deleteChatHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GeminiAI',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[400]?.withOpacity(0.6),
        elevation: 14,
        shadowColor: Colors.black,
        actions: [
          if (user?.photoURL != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'delete') {
                deleteChatHistory();
              } else if (value == 'signout') {
                ref.read(authProvider).signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Clear chat'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Log Out'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 4),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.purple.shade300],
        )),
        child: Column(
          children: [
            Expanded(
              child: MessagesList(
                userId: FirebaseAuth.instance.currentUser!.uid,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 4)
                  ]),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Ask anything...',
                            border: InputBorder.none,
                            prefixIcon: _selectedImage != null
                                ? Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_selectedImage!.path),
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : null,
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                        if (_selectedImage != null)
                          Positioned(
                            left: 0,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    onPressed: isLoading ? null : sendMessage,
                    icon: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[500]!),
                            ),
                          )
                        : Icon(Icons.send_rounded, color: Colors.blue[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImage == null) return;

    setState(() => isLoading = true);
    try {
      await ref.read(chatProvider).sendMessage(
            apiKey: apikey,
            image: _selectedImage,
            promptText: message,
          );
      if (mounted) {
        setState(() {
          isLoading = false;
          _selectedImage = null; // Clear the selected image after sending
        });
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
