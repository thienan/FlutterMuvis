import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttermuvis/domain/interactor/get_movie.dart';

import 'package:fluttermuvis/domain/interactor/interactors_provider.dart';
import 'package:fluttermuvis/domain/interactor/get_detail.dart';
import 'package:fluttermuvis/domain/interactor/get_credits.dart';
import 'package:fluttermuvis/domain/interactor/set_favorite.dart';
import 'package:fluttermuvis/domain/model/movie.dart';
import 'package:fluttermuvis/domain/model/detail.dart';
import 'package:fluttermuvis/domain/model/cast.dart';
import 'package:fluttermuvis/domain/model/backdrop_size.dart';
import 'package:fluttermuvis/presentation/res/theme_colors.dart';
import 'package:fluttermuvis/presentation/res/drawables.dart';
import 'package:fluttermuvis/presentation/pages/detail/detail_header.dart';
import 'package:fluttermuvis/presentation/pages/detail/detail_description.dart';
import 'package:fluttermuvis/presentation/pages/detail/detail_overview.dart';
import 'package:fluttermuvis/presentation/pages/detail/credits_view.dart';
import 'package:fluttermuvis/presentation/pages/utils/snackbar_factory.dart';
import 'package:fluttermuvis/presentation/widgets/vertical_padding.dart';

const int _BIG_BACKDROP_DELAY = 1000;
const double _EXPANDED_HEADER_HEIGHT = 180.0;
const double _BOTTOM_PADDING = 200.0;
const double _HEADER_COLLAPSED_PIXELS = 125.0;
const double _FAB_ICON_SIZE = 20.0;

class DetailPage extends StatefulWidget {

  final Movie _movie;
  final SnackbarFactory _snackbarFactory = new SnackbarFactory();

  DetailPage(this._movie);

  @override
  State<StatefulWidget> createState() => new _DetailPageState();

}

class _DetailPageState extends State<DetailPage> {

  Movie _movieState;
  BuildContext _scaffoldContext;
  Detail _detail;
  List<Cast> _credits;
  BackdropSize _backdropSize = BackdropSize.SMALL;
  ScrollController _scrollController;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _movieState = widget._movie;
    _scrollController = new ScrollController();
    _scrollController.addListener(_onScrollChange);
    _reloadMovie();
    _loadDetail();
    _loadCredits();
    _loadBigBackdropWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ThemeColors.lime,
      body: new Builder(builder: (context) {
        _scaffoldContext = context;
        return new CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            _createHeader(),
            _createContent()
          ],
        );
      }),
      floatingActionButton: _createFab(),
    );
  }

  Widget _createHeader() {
    return new SliverAppBar(
      title: _getToolbarTitle(),
      flexibleSpace: new FlexibleSpaceBar(
        background: new DetailHeader(_movieState.getBackdropPath(_backdropSize)),
      ),
      expandedHeight: _EXPANDED_HEADER_HEIGHT,
      floating: false,
      pinned: true,
      actions: <Widget>[
        new Icon(
          Icons.share,
          color: Colors.white,
        )
      ]
    );
  }

  Widget _getToolbarTitle() {
    return new Opacity(
      child: new Text(_movieState.title),
      opacity: _toolbarTextOpacity(),
    );
  }

  Widget _createContent() {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        <Widget>[
          new DetailDescription(_movieState, _detail),
          new DetailOverview(_movieState.overview),
          new CreditsView(_credits),
          new VerticalPadding(_BOTTOM_PADDING)
        ]
      ),
    );
  }

  Widget _createFab() {
    return new FloatingActionButton(
      onPressed: _onFabClick,
      backgroundColor: ThemeColors.strawberry,
      child: _createFabIcon(),
    );
  }

  Widget _createFabIcon() {
    return new Image.asset(
      _movieState.isFavorite ? Drawables.IC_FAB_UNFAV : Drawables.IC_FAB_FAV,
      width: _FAB_ICON_SIZE,
      height: _FAB_ICON_SIZE,
    );
  }

  void _reloadMovie() {
    GetMovie getMovie = InteractorsProvider.getMovieInteractor();
    getMovie.id = _movieState.id;
    getMovie.execute()
      .then(_onMovieReloaded);
  }

  void _onMovieReloaded(Movie movie) {
    setState(() {
      _movieState = movie;
    });
  }

  void _loadDetail() {
    GetDetail getDetail = InteractorsProvider.getDetailInteractor();
    getDetail.id = _movieState.id;
    getDetail.execute()
      .then(_onDetailLoadSuccess)
      .catchError(_onError);
  }

  void _onDetailLoadSuccess(Detail detail) {
    setState(() {
      _detail = detail;
    });
  }

  void _loadCredits() {
    GetCredits getCredits = InteractorsProvider.getCreditsInteractor();
    getCredits.id = _movieState.id;
    getCredits.execute()
      .then(_onCreditsLoadSuccess)
      .catchError(_onError);
  }

  void _onCreditsLoadSuccess(List<Cast> credits) {
    setState(() {
      _credits = credits;
    });
  }

  void _loadBigBackdropWithDelay() {
    new Future.delayed(new Duration(milliseconds: _BIG_BACKDROP_DELAY), () {
      setState(() {
        _backdropSize = BackdropSize.BIG;
      });
    });
  }

  void _onScrollChange() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
      print(_scrollPosition);
    });
  }

  double _toolbarTextOpacity() {
    var opacity = _scrollPosition / _HEADER_COLLAPSED_PIXELS;
    return opacity < 0.0 ? 0.0 : opacity > 1.0 ? 1.0 : opacity;
  }

  void _onFabClick() {
    SetFavorite setFavorite = InteractorsProvider.getFavoriteInteractor();
    setFavorite.id = _movieState.id;
    setFavorite.execute()
      .then(_onSetFavoriteSuccess)
      .catchError(_onError);
  }

  void _onSetFavoriteSuccess(Movie movie) {
    setState((){
      _movieState = movie;
    });
    widget._snackbarFactory.show(
      _scaffoldContext,
      movie.isFavorite ? "Favorited!" : "Unfavorited!"
    );
  }


  void _onError(dynamic error) => print(error);

}
