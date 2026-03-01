import 'package:flutter/material.dart';
import '../../domain/entities/track.dart';

class PlayerArtwork extends StatelessWidget {
  final Track? track;
  final bool isPartnerOnline;
  final String? meAvatar;
  final String? partnerAvatar;
  final String meLabel;
  final String partnerLabel;

  const PlayerArtwork({
    super.key,
    this.track,
    this.isPartnerOnline = true,
    this.meAvatar,
    this.partnerAvatar,
    this.meLabel = 'M',
    this.partnerLabel = 'V',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight.clamp(
          0.0,
          MediaQuery.of(context).size.width * 0.85,
        );

        if (track == null) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(Icons.music_note, color: Colors.white24, size: 80),
            ),
          );
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(track!.thumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Stack(
                        children: [
                          _buildAvatarItem(
                            meLabel,
                            Colors.pink,
                            true,
                            meAvatar,
                          ),
                          Positioned(
                            left: 22,
                            child: _buildAvatarItem(
                              partnerLabel,
                              Colors.blue,
                              isPartnerOnline,
                              partnerAvatar,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPartnerOnline
                              ? Colors.greenAccent
                              : Colors.white24,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        isPartnerOnline ? 'Sync: Dual' : 'Sync: Solo',
                        style: TextStyle(
                          color: isPartnerOnline
                              ? Colors.greenAccent
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarItem(
    String label,
    Color color,
    bool online,
    String? avatarUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: online
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : null,
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
