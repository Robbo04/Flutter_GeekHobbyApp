import 'package:app_geek_hobby_app/Classes/item.dart';
import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Enums/genres/video_genre.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/movie_age.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Movie> moviesListTest = [
      Movie(name: 'MovieName', studio: 'StudioName', yearReleased: 2004, genres: [VideoGenre.action, VideoGenre.adventure], director: 'DirectorName', duration: 120, ageRating: MovieAgeRating.pg, imdbRating: 7.5,),
      Movie(name: 'AnotherMovie', studio: 'AnotherStudio', yearReleased: 2010, genres: [VideoGenre.comedy, VideoGenre.drama], director: 'AnotherDirector', duration: 90, ageRating: MovieAgeRating.fifteen, imdbRating: 6.8,),
      Movie(name: 'ThirdMovie', studio: 'ThirdStudio', yearReleased: 2015, genres: [VideoGenre.horror, VideoGenre.thriller], director: 'ThirdDirector', duration: 100, ageRating: MovieAgeRating.eighteen, imdbRating: 8.0,),
      Movie(name: 'FourthMovie', studio: 'FourthStudio', yearReleased: 2020, genres: [VideoGenre.sciFi, VideoGenre.fantasy], director: 'FourthDirector', duration: 110, ageRating: MovieAgeRating.pg, imdbRating: 7.2,),
    ]; // Replace with actual data source

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moviesListTest.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moviesListTest[index].name,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Explore Page Content Here'),
          ),
        ],
      ),
    );
  }
}