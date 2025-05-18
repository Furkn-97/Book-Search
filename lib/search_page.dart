import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'book_detail_page.dart';
import 'favorites_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  List books = [];
  List favorites = [];
  int startIndex = 0;
  bool isLoading = false;
  bool hasMore = true; // track if more results available
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // close to bottom - load more
        if (!isLoading && hasMore) {
          loadMoreBooks();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> searchBooks() async {
    setState(() {
      books.clear();
      startIndex = 0;
      hasMore = true;
    });
    await loadMoreBooks();
  }

  Future<void> loadMoreBooks() async {
    if (!hasMore) return;

    setState(() => isLoading = true);

    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=${_controller.text}&startIndex=$startIndex&maxResults=10'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newBooks = data['items'] ?? [];

      setState(() {
        books.addAll(newBooks);
        startIndex += newBooks.length as int;
        isLoading = false;
        // If less than maxResults returned, no more data
        if (newBooks.length < 10) {
          hasMore = false;
        }
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void openBookDetails(Map book) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              BookDetailsPage(book: book, onFavorite: toggleFavorite)),
    );
  }

  void toggleFavorite(Map book) {
    setState(() {
      if (favorites.contains(book)) {
        favorites.remove(book);
      } else {
        favorites.add(book);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                      favorites: favorites, onBookTap: openBookDetails)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search Books',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchBooks,
                ),
              ),
              onSubmitted: (_) => searchBooks(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: books.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == books.length) {
                    // loading indicator at bottom
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final book = books[index]['volumeInfo'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                          book['imageLinks']?['thumbnail'] ?? '',
                          fit: BoxFit.cover),
                      title: Text(book['title'] ?? 'No Title'),
                      subtitle: Text(
                          '${book['subtitle'] ?? ''}\nAuthors: ${book['authors']?.join(', ') ?? 'Unknown'}\nPublished: ${book['publishedDate'] ?? 'Unknown'}'),
                      trailing: IconButton(
                        icon: Icon(favorites.contains(books[index])
                            ? Icons.favorite
                            : Icons.favorite_border),
                        onPressed: () => toggleFavorite(books[index]),
                      ),
                      onTap: () => openBookDetails(books[index]),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
