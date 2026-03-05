// folder represents one suit folder row in the database
class Folder {
  final int? id;
  final String folderName;
  final String timestamp;

  Folder({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  // convert folder object to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_name': folderName,
      'timestamp': timestamp,
    };
  }

  // create folder object from map (database query result)
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      folderName: map['folder_name'],
      timestamp: map['timestamp'],
    );
  }

  // create a copy with modified fields
  Folder copyWith({
    int? id,
    String? folderName,
    String? timestamp,
  }) {
    return Folder(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'Folder{id: $id, folderName: $folderName, timestamp: $timestamp}';
  }
}