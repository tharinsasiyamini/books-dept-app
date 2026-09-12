import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_api_model.dart';
import '../models/album_api_model.dart';
import '../models/photo_api_model.dart';

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  final ApiService _apiService = ApiService();

  Future<List<UserApiModel>>? _usersFuture;
  Future<List<AlbumApiModel>>? _albumsFuture;
  Future<List<PhotoApiModel>>? _photosFuture;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Demonstration'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Albums'),
              Tab(text: 'Photos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(),
            _buildAlbumsTab(),
            _buildPhotosTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _usersFuture = _apiService.getUsers();
              });
            },
            child: const Text('Load Users API'),
          ),
        ),
        Expanded(
          child: _usersFuture == null
              ? const Center(child: Text('Press button to load Users.'))
              : FutureBuilder<List<UserApiModel>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Unable to load data. Please try again.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text('\${user.email} | \${user.phone}'),
                          leading: CircleAvatar(child: Text(user.id.toString())),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlbumsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _albumsFuture = _apiService.getAlbums();
              });
            },
            child: const Text('Load Albums API (Catalogue Source)'),
          ),
        ),
        Expanded(
          child: _albumsFuture == null
              ? const Center(child: Text('Press button to load Albums.'))
              : FutureBuilder<List<AlbumApiModel>>(
                  future: _albumsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Unable to load data. Please try again.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No albums found.'));
                    }

                    // Displaying only top 20 to avoid long list
                    final albums = snapshot.data!.take(20).toList();
                    return ListView.builder(
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return ListTile(
                          title: Text(album.title),
                          subtitle: Text('Album ID: \${album.id} | User ID: \${album.userId}'),
                          leading: const Icon(Icons.album),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _photosFuture = _apiService.getPhotos();
              });
            },
            child: const Text('Load Photos API'),
          ),
        ),
        Expanded(
          child: _photosFuture == null
              ? const Center(child: Text('Press button to load Photos.'))
              : FutureBuilder<List<PhotoApiModel>>(
                  future: _photosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Unable to load data. Please try again.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No photos found.'));
                    }

                    // Displaying only top 20
                    final photos = snapshot.data!.take(20).toList();
                    return ListView.builder(
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return ListTile(
                          leading: Image.network(
                            photo.thumbnailUrl,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                          title: Text(photo.title),
                          subtitle: Text('Photo ID: \${photo.id}'),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
