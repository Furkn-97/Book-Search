import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDetailsPage extends StatelessWidget {
  final Map book;
  final Function(Map) onFavorite;

  BookDetailsPage({required this.book, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final info = book['volumeInfo'];
    final saleInfo = book['saleInfo'];
    final accessInfo = book['accessInfo'];

    return Scaffold(
      appBar: AppBar(title: Text(info['title'] ?? 'Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(info['imageLinks']?['thumbnail'] ?? '',
                height: 250, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(info['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(info['subtitle'] ?? '', style: TextStyle(fontSize: 18)),
            Text('Authors: ${info['authors']?.join(', ') ?? 'Unknown'}'),
            Text('Published: ${info['publishedDate'] ?? 'Unknown'}'),
            Text('Page Count: ${info['pageCount'] ?? 'Unknown'}'),
            Text('Dimensions: ${info['dimensions']?['height'] ?? 'Unknown'}'),
            Text('Language: ${info['language'] ?? 'Unknown'}'),
            SizedBox(height: 8),
            Text('Description: ${info['description'] ?? 'No Description'}'),
            SizedBox(height: 16),
            Text('Buy Link: ${saleInfo['buyLink'] ?? 'Unavailable'}'),
            Text(
                'PDF Download: ${accessInfo['pdf']?['downloadLink'] ?? 'Unavailable'}'),
            Text(
                'EPUB Download: ${accessInfo['epub']?['downloadLink'] ?? 'Unavailable'}'),
          ],
        ),
      ),
    );
  }
}
