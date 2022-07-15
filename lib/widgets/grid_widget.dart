import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GridWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
        ),
        itemCount: 50,
        itemBuilder: (context, index) => buildImageCard(index),
      );

  Widget buildImageCard(int index) => Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        child: Container(
          width: 250,
          height: 250,
          margin: const EdgeInsets.all(8),
          child: ClipRect(
              child: Image.network(
            'https://source.unsplash.com/random?sig=$index',
            fit: BoxFit.cover,
          )),
        ),
      );
}
