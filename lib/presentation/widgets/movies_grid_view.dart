import 'package:flutter/material.dart';

import 'movie_item.dart';

import '../../domain/model/movie.dart';

const int _NUM_COLUMNS = 3;
const double _ITEM_ASPECT_RATIO = 1/2;

class MoviesGridView extends StatelessWidget {

  final List<Movie> _movies;
  final OnMovieClickListener _onMovieClick;

  MoviesGridView(this._movies, this._onMovieClick);

  @override
  Widget build(BuildContext context) {
    return new GridView.count(
        crossAxisCount: _NUM_COLUMNS,
        childAspectRatio: _ITEM_ASPECT_RATIO,
        children: new List.generate(_movies.length, (index) {
          return new MovieItem(_movies[index], _onMovieClick);
        })
    );
  }

}