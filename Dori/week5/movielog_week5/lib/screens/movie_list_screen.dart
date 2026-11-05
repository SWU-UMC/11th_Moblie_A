import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_models/movie_view_models.dart';
import '../widgets/tmdb_poster_image.dart';
import 'my_page_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override State<MovieListScreen> createState() => _MovieListScreenState();
}
class _MovieListScreenState extends State<MovieListScreen> {
  int tab = 1;
  @override Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create:(c)=>MovieHomeViewModel(c.read<TmdbMovieService>())..load()),
      ChangeNotifierProvider(create:(c)=>MovieListViewModel(c.read<TmdbMovieService>())..loadInitial()),
    ],
    child: Scaffold(
      backgroundColor:const Color(0xFFFAF9F6),
      appBar:AppBar(title:Text(['홈','영화','마이'][tab]),backgroundColor:const Color(0xFFFAF9F6)),
      body:IndexedStack(index:tab,children:const [_HomeTab(),_MovieTab(),MyPageScreen()]),
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const [
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'홈'),
        NavigationDestination(icon:Icon(Icons.movie_outlined),label:'영화'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'마이'),
      ]),
    ),
  );
}
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override Widget build(BuildContext context) => Consumer<MovieHomeViewModel>(builder:(c,vm,_)=>
    _StatusBody(status:vm.status,onRetry:vm.load,success:ListView(children:[
      const Padding(padding:EdgeInsets.all(16),child:Text('인기 영화 TOP 5',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold))),
      SizedBox(height:270,child:ListView.separated(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),itemCount:vm.movies.length,separatorBuilder:(_,_)=>const SizedBox(width:12),itemBuilder:(c,i)=>SizedBox(width:145,child:_MovieTile(movie:vm.movies[i])))),
    ])));
}
class _MovieTab extends StatelessWidget {
  const _MovieTab();
  @override Widget build(BuildContext context) => Consumer<MovieListViewModel>(builder:(c,vm,_)=>Column(children:[
    SizedBox(height:52,child:ListView(scrollDirection:Axis.horizontal,children:[
      _genreChip(vm,null,'전체'),
      for(final g in vm.genres) _genreChip(vm,g.id,g.name),
    ])),
    Expanded(child:_StatusBody(status:vm.status,onRetry:()=>vm.selectGenre(vm.selectedGenreId),success:GridView.builder(
      padding:const EdgeInsets.all(16),itemCount:vm.movies.length,
      gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:18,childAspectRatio:.56),
      itemBuilder:(c,i)=>_MovieTile(movie:vm.movies[i]),
    ))),
  ]));
  Widget _genreChip(MovieListViewModel vm,int? id,String label)=>Padding(
    padding:const EdgeInsets.symmetric(horizontal:4,vertical:5),child:ChoiceChip(
      label:Text(label),selected:vm.selectedGenreId==id,
      onSelected:vm.status==LoadStatus.loading?null:(_)=>vm.selectGenre(id),
    ),
  );
}
class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.status,required this.onRetry,required this.success});
  final LoadStatus status;
  final VoidCallback onRetry;
  final Widget success;
  @override Widget build(BuildContext context) => switch(status) {
    LoadStatus.loading => const Center(child:CircularProgressIndicator()),
    LoadStatus.empty => const Center(child:Text('영화가 없어요.')),
    LoadStatus.error => Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('영화를 불러오지 못했어요.'),const SizedBox(height:12),ElevatedButton(onPressed:onRetry,child:const Text('다시 시도'))])),
    LoadStatus.success => success,
  };
}
class _MovieTile extends StatelessWidget {
  const _MovieTile({required this.movie});
  final TmdbMovieDto movie;
  @override Widget build(BuildContext context) => InkWell(
    onTap:()=>showDialog<void>(context:context,builder:(c)=>AlertDialog(
      title:Text(movie.title),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(movie.overview.isEmpty?'줄거리 정보가 없어요.':movie.overview),
        const SizedBox(height:12),Text('TMDB movieId: ${movie.id}'),
        const SizedBox(height:8),const Text('평점 기능 연동 시 이 ID를 전달합니다.'),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('닫기'))],)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(12),child:SizedBox(width:double.infinity,child:TmdbPosterImage(path:movie.posterPath)))),
      const SizedBox(height:5),Text(movie.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold)),
      Text('★ ${movie.voteAverage.toStringAsFixed(1)}',style:const TextStyle(fontSize:12)),
    ]),
  );
}
