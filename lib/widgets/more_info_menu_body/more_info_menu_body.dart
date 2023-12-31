import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/constants/style.dart';
import 'package:storify/models/playlist.dart';
import 'package:storify/services/firebase_db.dart';
import 'package:storify/services/playlist_actions.dart';
import 'package:storify/services/spotify_auth.dart';
import 'package:storify/widgets/_common/custom_flat_text_button.dart';

class MoreInfoMenuBody extends StatelessWidget {
  const MoreInfoMenuBody({Key? key, required this.playlist}) : super(key: key);
  final Playlist? playlist;

  Future<void> _onOpenInSpotify() async {
    final url = playlist?.externalUrl;
    if (url != null) {
      await PlaylistActions.openInSpotify(url);
    }
  }

  Future<void> _onShareAsLink() async {
    final currentPlaylist = playlist;
    if (currentPlaylist != null) {
      await PlaylistActions.shareAsLink(currentPlaylist);
    }
  }

  Future<void> _onSavePlaylist(BuildContext context) async {
    final spotifyAuth = context.read<SpotifyAuth>();
    final currentPlaylist = playlist;
    final currentUser = spotifyAuth.user;
    if (currentPlaylist != null && currentUser != null) {
      await PlaylistActions.savePlaylist(currentUser.id, currentPlaylist);
    }
  }

  Future<void> _onUnsavePlaylist(BuildContext context) async {
    final spotifyAuth = context.read<SpotifyAuth>();
    final currentUser = spotifyAuth.user;
    final currentPlaylist = playlist;

    if (currentPlaylist != null && currentUser != null) {
      await PlaylistActions.unsavePlaylist(currentUser.id, currentPlaylist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _firebaseDB = FirebaseDB();
    final userId = context.watch<SpotifyAuth>().user!.id;
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 96.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildPlaylistInfo(),
          Column(
            children: <Widget>[
              CustomFlatTextButton(
                text: 'OPEN IN SPOTIFY',
                onPressed: _onOpenInSpotify,
                leadingWidget: Image.asset(
                  'images/spotify.png',
                  width: 32.0,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              CustomFlatTextButton(
                text: 'SHARE AS LINK',
                onPressed: _onShareAsLink,
                leadingWidget: Icon(
                  Icons.link,
                  color: CustomColors.primaryTextColor,
                  size: 32.0,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              StreamBuilder<bool>(
                stream: _firebaseDB.isPlaylistSavedStream(
                    userId: userId, playlistId: playlist?.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final isPlaylistSaved = snapshot.data!;
                    return CustomFlatTextButton(
                      text: isPlaylistSaved
                          ? 'REMOVE FROM SAVED'
                          : 'SAVE PLAYLIST',
                      onPressed: isPlaylistSaved
                          ? () => _onUnsavePlaylist(context)
                          : () => _onSavePlaylist(context),
                      leadingWidget: Icon(
                        isPlaylistSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: CustomColors.primaryTextColor,
                        size: 32.0,
                      ),
                    );
                  } else {
                    return Container(
                      height: 48.0,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Column _buildPlaylistInfo() {
    final playlistImage = playlist?.playlistImageUrl;
    final avatarImageUrl = playlist?.owner.avatarImageUrl;

    return Column(
      children: <Widget>[
        if (playlistImage != null)
          CircleAvatar(
              radius: 54.0,
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(
                playlistImage,
              )),
        SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            playlist?.name ?? '',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.bannerText.copyWith(letterSpacing: -2.0),
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('By', style: TextStyles.light.copyWith(fontSize: 14.0)),
            SizedBox(
              width: 8.0,
            ),
            if (avatarImageUrl != null) ...[
              CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(
                    avatarImageUrl,
                  )),
              SizedBox(
                width: 8.0,
              )
            ],
            Text(playlist?.owner.name ?? '(User Not Found)',
                style: TextStyles.primary.copyWith(fontSize: 16.0)),
          ],
        )
      ],
    );
  }
}
