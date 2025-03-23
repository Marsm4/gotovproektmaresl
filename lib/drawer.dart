import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6, // Ширина Drawer (60% экрана)
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade400, // Светлый голубой
                Colors.blue.shade700, // Темный голубой
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero, // Убираем отступы у ListView
            children: [
              // Верхний компонент Drawer с более темным градиентом
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade600, // Более темный голубой
                      Colors.blue.shade900, // Самый темный голубой
                    ],
                  ),
                ),
                child: DrawerHeader(
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Прозрачный фон
                    ),
                    accountName: const Text(
                      "Марсель",
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: const Text(
                      "mars@mail.ru",
                      style: TextStyle(color: Colors.white70),
                    ),
                    currentAccountPicture: Container(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        maxRadius: 20,
                        minRadius: 10,
                        backgroundImage: NetworkImage(
                          "https://dilvfoapurgghqtsggml.supabase.co/storage/v1/object/public/Storage//profile.jpg",
                        ),
                      ),
                    ),
                    otherAccountsPictures: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              // Остальные элементы Drawer
              ListTile(
                title: const Text(
                  "Моя музыка",
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.music_note, color: Colors.white),
                onTap: () {
                  // Действие при нажатии на "Моя музыка"
                },
              ),
              ListTile(
                title: const Text(
                  "Плейлисты",
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.featured_play_list, color: Colors.white),
                onTap: () {
                  // Действие при нажатии на "Плейлисты"
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}