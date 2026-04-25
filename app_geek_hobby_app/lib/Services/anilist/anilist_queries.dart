/// GraphQL queries for AniList API
class AniListQueries {
  /// GraphQL query for searching anime
  static const String search = '''
    query(\$search: String, \$page: Int, \$perPage: Int, \$type: MediaType) {
      Page(page: \$page, perPage: \$perPage) {
        pageInfo {
          total
          currentPage
          lastPage
          hasNextPage
        }
        media(search: \$search, type: \$type, sort: [SEARCH_MATCH, POPULARITY_DESC]) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          nextAiringEpisode {
            episode
          }
          coverImage {
            large
          }
          averageScore
          popularity
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  /// GraphQL query for anime relations
  static const String relations = '''
    query(\$id: Int) {
      Media(id: \$id, type: ANIME) {
        id
        title {
          romaji
          english
        }
        relations {
          edges {
            relationType
            node {
              id
              title {
                romaji
                english
              }
              format
              episodes
              duration
              seasonYear
              nextAiringEpisode {
                episode
              }
              coverImage {
                large
              }
              studios(isMain: true) {
                nodes {
                  name
                }
              }
            }
          }
        }
      }
    }
  ''';

  /// GraphQL query for trending anime
  static const String trending = '''
    query(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(type: ANIME, sort: TRENDING_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          nextAiringEpisode {
            episode
          }
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  /// GraphQL query for most popular anime
  static const String popular = '''
    query(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(type: ANIME, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          nextAiringEpisode {
            episode
          }
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  /// GraphQL query for upcoming/coming soon anime
  static const String comingSoon = '''
    query(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(type: ANIME, status: NOT_YET_RELEASED, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          nextAiringEpisode {
            episode
          }
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  /// GraphQL query for anime by genre
  static const String byGenre = '''
    query(\$genre: String, \$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(type: ANIME, genre: \$genre, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          nextAiringEpisode {
            episode
          }
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';
}
