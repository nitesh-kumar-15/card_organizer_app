// addEditCardScreen lets the user create or edit a single card
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final PlayingCard? card;
  final int folderId; // the folder we are currently viewing

  const AddEditCardScreen({Key? key, this.card, required this.folderId}) : super(key: key);

  @override
  _AddEditCardScreenState createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepository = CardRepository();
  final FolderRepository _folderRepository = FolderRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageController;
  
  String _selectedSuit = 'Hearts';
  int? _selectedFolderId;
  List<Folder> _folders = [];
  bool _isLoading = true;

  final List<String> _suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.cardName ?? '');
    _imageController = TextEditingController(text: widget.card?.imageUrl ?? '');
    _selectedSuit = widget.card?.suit ?? _suits.first;
    _selectedFolderId = widget.card?.folderId ?? widget.folderId;
    
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    // load folders so the user can assign the card to any folder
    final folders = await _folderRepository.getAllFolders();
    setState(() {
      _folders = folders;
      // ensure the selected folder id exists in the dropdown list
      if (!_folders.any((f) => f.id == _selectedFolderId) && _folders.isNotEmpty) {
        _selectedFolderId = _folders.first.id;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final newCard = PlayingCard(
        id: widget.card?.id,
        cardName: _nameController.text.trim(),
        suit: _selectedSuit,
        imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
        folderId: _selectedFolderId!,
      );

      if (widget.card == null) {
        await _cardRepository.insertCard(newCard);
      } else {
        await _cardRepository.updateCard(newCard);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // return true to signal a refresh is needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name',
                  hintText: 'e.g., Ace, 2, King',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a card name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: const InputDecoration(
                  labelText: 'Suit Selection',
                  border: OutlineInputBorder(),
                ),
                items: _suits.map((suit) {
                  return DropdownMenuItem(
                    value: suit,
                    child: Text(suit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSuit = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedFolderId,
                decoration: const InputDecoration(
                  labelText: 'Folder Assignment',
                  border: OutlineInputBorder(),
                ),
                items: _folders.map((folder) {
                  return DropdownMenuItem<int>(
                    value: folder.id,
                    child: Text(folder.folderName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFolderId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image Path',
                  hintText: 'assets/cards/hearts_ace.png',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}