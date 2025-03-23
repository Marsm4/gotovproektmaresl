import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Импорт Supabase
import 'package:musik_player/ProfilePage.dart';
import 'package:musik_player/auth.dart';
import 'package:musik_player/database/auth.dart';
import 'package:musik_player/drawer.dart';
import 'package:musik_player/music/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key});

  @override
  _TrackListPageState createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  AuthService authService = AuthService();
  final SupabaseClient supabase = Supabase.instance.client; // Supabase клиент
  int currentTrackIndex = 0;
  List<Map<String, dynamic>> authors = []; // Список для хранения авторов
  bool isLoading = true; // Флаг загрузки данных

  List<Map<String, dynamic>> tracks = []; // Убрали final и изменили тип

  final List<Map<String, String>> playlists = [
    {'title': 'Плейлист 1'},
    {'title': 'Плейлист 2'},
    {'title': 'Плейлист 3'},
    {'title': 'Плейлист 4'},
    {'title': 'Плейлист 5'},
    {'title': 'Плейлист 6'},
  ];

  String searchQuery = '';

  bool isPlaying = true;

  List<Map<String, dynamic>> get filteredTracks => tracks
      .where((track) =>
          track['name_track']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          track['Auhror_list']['name_author']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    fetchAuthors(); // Загрузка данных при инициализации
    fetchTracks(); // Загрузка треков
  }

  // Метод для загрузки авторов из Supabase
  Future<void> fetchAuthors() async {
    try {
      final response = await supabase
          .from('author') // Название таблицы
          .select('id, created_at, name_author, image_author')
          .order('created_at', ascending: false);

      setState(() {
        authors = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке авторов: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Метод для загрузки треков из Supabase
  Future<void> fetchTracks() async {
    try {
      final response = await supabase.from('Track').select('''
      id, 
      created_at, 
      name_track, 
      image, 
      url_music,
      Auhror_list:author (id, name_author, image_author),
      genre_id:genre (id, name_genre)
    ''').order('created_at', ascending: false);

      print('Данные из Supabase: $response');
      if (response == null) {
        print('Ошибка: Пустой ответ от Supabase');
        return;
      }

      setState(() {
        tracks = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке треков: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Метод для переключения на следующий трек
  void nextTrack() {
    setState(() {
      if (currentTrackIndex < tracks.length - 1) {
        currentTrackIndex++;
      } else {
        currentTrackIndex =
            0; // Переход к первому треку, если достигнут конец списка
      }
    });
  }

  // Метод для переключения на предыдущий трек
  void previousTrack() {
    setState(() {
      if (currentTrackIndex > 0) {
        currentTrackIndex--;
      } else {
        currentTrackIndex = tracks.length -
            1; // Переход к последнему треку, если достигнуто начало списка
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = tracks.isNotEmpty ? tracks[currentTrackIndex] : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.blueGrey],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Список треков'),
          actions: [
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userEmail = prefs.getString('userEmail');
                final userName = prefs.getString('userName');
                final userAvatarUrl = prefs.getString('userAvatarUrl');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: () async {
                await authService.LogOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('IsLoggedIn', false);
                Navigator.popAndPushNamed(context, '/auth');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Поиск
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Поиск',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  const BorderSide(color: Colors.white54),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Плейлисты (заглушки)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Ваши плейлисты',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: playlists.map((playlist) {
                            return SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 50) / 2,
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.image,
                                        color: Colors.white, size: 40),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    playlist['title']!,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Исполнители
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Исполнители',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Отображение авторов
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              height: 130,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: authors.length,
                                itemBuilder: (context, index) {
                                  final author = authors[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            image: author['image_author'] !=
                                                    null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        author['image_author']),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: author['image_author'] == null
                                              ? const Icon(Icons.person,
                                                  color: Colors.white, size: 40)
                                              : null,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          author['name_author'] ??
                                              'Неизвестный',
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 30),
                      // Список треков
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Треки',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = filteredTracks[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.music_note,
                                  color: Colors.white),
                            ),
                            title: Text(
                              track['name_track'] ?? 'Нет трека',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${track['Auhror_list']['name_author'] ?? 'Нет исполнителя'} - ${track['genre_id']['name_genre'] ?? 'Нет жанра'}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerPage(
                                  nameSound: track['name_track'],
                                  author: track['Auhror_list']['name_author'],
                                  urlMusic: track['url_music'],
                                  urlPhoto: track['image'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                image: currentTrack?['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(currentTrack?['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: currentTrack?['image'] == null
                  ? const Icon(Icons.music_note, color: Colors.white)
                  : null,
            ),
            title: Text(
              currentTrack?['name_track'] ?? 'Нет трека',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${currentTrack?['Auhror_list']['name_author'] ?? 'Нет исполнителя'} - ${currentTrack?['genre_id']['name_genre'] ?? 'Нет жанра'}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: previousTrack,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PlayerPage(
                          nameSound: currentTrack?['name_track'] ?? 'Нет трека',
                          author: currentTrack?['Auhror_list']['name_author'] ??
                              'Нет исполнителя',
                          urlMusic: currentTrack?['url_music'] ?? '',
                          urlPhoto: currentTrack?['image'] ?? '',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                ),
                IconButton(
                  onPressed: nextTrack,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        drawer: DrawerPage(),
      ),
    );
  }
}
