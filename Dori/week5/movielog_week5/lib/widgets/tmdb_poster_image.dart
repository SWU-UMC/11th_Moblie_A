import 'package:flutter/material.dart';
class TmdbPosterImage extends StatelessWidget {
  const TmdbPosterImage({super.key, required this.path, this.width, this.height});
  final String? path;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) return _fallback();
    return Image.network('https://image.tmdb.org/t/p/w500$p', width:width,height:height,fit:BoxFit.cover,errorBuilder:(_,_,_)=>_fallback());
  }
  Widget _fallback() => Container(width:width,height:height,color:Colors.black12,alignment:Alignment.center,child:const Icon(Icons.image_not_supported_outlined,size:40));
}
