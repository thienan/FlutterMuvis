import 'dart:async';

import 'package:fluttermuvis/data/api.dart';
import 'package:fluttermuvis/data/repository.dart';
import 'package:fluttermuvis/domain/model/movie.dart';
import 'package:fluttermuvis/domain/model/detail.dart';
import 'package:fluttermuvis/domain/model/cast.dart';

const int _DEFAULT_YEAR = 2017;

class RepositoryImpl extends Repository {

  Api _api;

  RepositoryImpl(this._api);

  Future<List<Movie>> getMovies(int page) => _api.getMovies(_DEFAULT_YEAR, page);

  Future<Detail> getDetail(int id) => _api.getMovieDetail(id);

  Future<List<Cast>> getCredits(int id) => _api.getCredits(id);

  Future<Movie> setFavorite(Movie movie) {
    return new Future(() => movie.clone(favorite: !movie.isFavorite));
  }

}