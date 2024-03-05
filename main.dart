import 'dart:convert'; // Add this line

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

void main() {
  runApp(const MyApp());
}

class Flashcard {
  String question;
  String answer;
  String imagePath;
  final String folder; // New property to store the folder name

  Flashcard(this.question, this.answer, this.imagePath, this.folder);
}

class Folder {
  final String name;
  final List<Flashcard> flashcards;

  Folder(this.name, this.flashcards);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainByte',
      theme: ThemeData(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(primary: Colors.pink),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Folder> folders = []; // List to hold folders

  void addFlashcard(String question, String answer, String imagePath, String folderName) {
    if (question.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        var folder = folders.firstWhere((f) => f.name == folderName);
        folder.flashcards.add(Flashcard(question, answer, imagePath, folderName));
      });
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Flashcard added successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Both question and answer are required'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void addFolder(String folderName) {
    if (folderName.isNotEmpty) {
      setState(() {
        folders.add(Folder(folderName, []));
      });
      Navigator.pop(context); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Folder name is required'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Column(
            children: [
              const Text(
                'BrainByte',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Folders',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Colors.pink),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return ListTile(
            title: Text(folder.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardPage(folder: folder),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Open a dialog to add a new folder
              showDialog(
                context: context,
                builder: (context) {
                  String folderName = '';

                  return AlertDialog(
                    title: const Text('Create New Folder'),
                    content: TextField(
                      onChanged: (value) => folderName = value,
                      decoration: const InputDecoration(labelText: 'Folder Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => addFolder(folderName),
                        child: const Text('Create'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.create_new_folder),
            heroTag: null,
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Open a dialog to add a new flashcard
              showDialog(
                context: context,
                builder: (context) {
                  String question = '';
                  String answer = '';
                  String imagePath = '';
                  String selectedFolder = folders.isNotEmpty ? folders.first.name : ''; // Default to the first folder if exists

                  return AlertDialog(
                    title: const Text('Add Flashcard'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (folders.isNotEmpty)
                          DropdownButtonFormField<String>(
                            value: selectedFolder,
                            onChanged: (value) => selectedFolder = value!,
                            items: folders.map((folder) {
                              return DropdownMenuItem(
                                value: folder.name,
                                child: Text(folder.name),
                              );
                            }).toList(),
                          ),
                        TextField(
                          onChanged: (value) => question = value,
                          decoration: const InputDecoration(labelText: 'Question'),
                        ),
                        TextField(
                          onChanged: (value) => answer = value,
                          decoration: const InputDecoration(labelText: 'Answer'),
                        ),
                        TextField(
                          onChanged: (value) => imagePath = value,
                          decoration: const InputDecoration(labelText: 'Image Path'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => addFlashcard(question, answer, imagePath, selectedFolder),
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}

class FlashcardPage extends StatefulWidget {
  final Folder folder;
  final bool showQuestionFirst;

  const FlashcardPage({Key? key, required this.folder, this.showQuestionFirst = true}) : super(key: key);

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int currentIndex = 0;
  bool showQuestion = true;

  void editFlashcard(BuildContext context, Flashcard flashcard) {
    String editedQuestion = flashcard.question;
    String editedAnswer = flashcard.answer;
    String editedImagePath = flashcard.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => editedQuestion = value,
                decoration: const InputDecoration(labelText: 'Question'),
                controller: TextEditingController(text: flashcard.question),
              ),
              TextField(
                onChanged: (value) => editedAnswer = value,
                decoration: const InputDecoration(labelText: 'Answer'),
                controller: TextEditingController(text: flashcard.answer),
              ),
              TextField(
                onChanged: (value) => editedImagePath = value,
                decoration: const InputDecoration(labelText: 'Image Path'),
                controller: TextEditingController(text: flashcard.imagePath),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  flashcard.question = editedQuestion;
                  flashcard.answer = editedAnswer;
                  flashcard.imagePath = editedImagePath;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: widget.folder.flashcards.length,
              controller: PageController(viewportFraction: 0.8),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final flashcard = widget.folder.flashcards[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      showQuestion = !showQuestion;
                    });
                  },
                  child: FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    flipOnTouch: false,
                    front: Card(
                      color: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              showQuestion ? flashcard.question : flashcard.answer,
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            if (flashcard.imagePath.isNotEmpty) // Show image if imagePath is not empty
                              Image.asset(
                                flashcard.imagePath,
                                height: 100, // Adjust height as needed
                              ),
                          ],
                        ),
                      ),
                    ),
                    back: Card(
                      color: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              showQuestion ? flashcard.answer : flashcard.question,
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            if (flashcard.imagePath.isNotEmpty) // Show image if imagePath is not empty
                              Image.asset(
                                flashcard.imagePath,
                                height: 100, // Adjust height as needed
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex - 1) % widget.folder.flashcards.length;
                  });
                },
                child: const Text('Previous'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex + 1) % widget.folder.flashcards.length;
                  });
                },
                child: const Text('Next'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  editFlashcard(context, widget.folder.flashcards[currentIndex]);
                },
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
