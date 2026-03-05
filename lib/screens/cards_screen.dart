// cardsScreen shows all cards inside a selected folder
import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart'; // Required for the Add/Edit navigation

class CardsScreen extends StatefulWidget {
  final Folder folder;
  
  const CardsScreen({Key? key, required this.folder}) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepository = CardRepository();
  List<PlayingCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      // load all cards for the active folder from the repository
      final cards = await _cardRepository.getCardsByFolderId(widget.folder.id!);
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load cards. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Are you sure you want to delete the ${card.cardName} of ${card.suit}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cardRepository.deleteCard(card.id!);
        if (!mounted) return;
        _loadCards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${card.cardName} deleted')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete card. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCardImage(PlayingCard card) {
    if (card.imageUrl == null || card.imageUrl!.isEmpty) {
      return const Icon(Icons.style, size: 50); // fallback placeholder when no image is set
    }
    // use asset images for fast, offline loading
    return Image.asset(
      card.imageUrl!,
      width: 50,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.folderName} Cards'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _cards.isEmpty
            ? const Center(child: Text('No cards in this folder.'))
            : ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: _buildCardImage(card),
                      title: Text('${card.cardName} of ${card.suit}'),
                      subtitle: Text(card.suit),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              // navigate to add/edit screen with the existing card data
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditCardScreen(
                                    card: card, 
                                    folderId: widget.folder.id!
                                  ),
                                ),
                              );
                              if (result == true) _loadCards(); // Refresh if saved
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCard(card),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // navigate to add/edit screen for a new card
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCardScreen(
                folderId: widget.folder.id!
              ),
            ),
          );
          if (result == true) _loadCards(); // Refresh if saved
        },
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }
}