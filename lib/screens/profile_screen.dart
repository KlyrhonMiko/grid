import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/instagram_provider.dart';
import '../models/instagram_post.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      final val = count / 1000000;
      return val == val.roundToDouble()
          ? '${val.round()}M'
          : '${val.toStringAsFixed(1)}M';
    }
    if (count >= 10000) {
      final val = count / 1000;
      return val == val.roundToDouble()
          ? '${val.round()}K'
          : '${val.toStringAsFixed(1)}K';
    }
    if (count >= 1000) {
      return count.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return count.toString();
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Disconnect Instagram'),
        content: const Text(
          'This will remove your connected account. You can reconnect anytime.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InstagramProvider>().disconnect();
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstagramProvider>(
      builder: (context, provider, _) {
        final user = provider.user;
        final posts = provider.posts;

        return Scaffold(
          body: RefreshIndicator(
            color: const Color(0xFF3797EF),
            onRefresh: () => provider.refresh(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFF0D1015),
                  elevation: 0,
                  centerTitle: false,
                  pinned: false,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, size: 28),
                    onPressed: () {},
                  ),
                  title: Text(
                    user?.username ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.ellipsisVertical, size: 22),
                      color: const Color(0xFF1C1C1E),
                      onSelected: (value) {
                        if (value == 'disconnect') _showDisconnectDialog();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'disconnect',
                          child: Row(
                            children: [
                              Icon(LucideIcons.logOut, size: 18, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 12, bottom: 4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: ClipOval(
                                child: user?.profilePictureUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: user!.profilePictureUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            LucideIcons.user,
                                            color: Colors.white54,
                                            size: 40,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            LucideIcons.user,
                                            color: Colors.white54,
                                            size: 40,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          LucideIcons.user,
                                          color: Colors.white54,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user?.name case final name? when name.isNotEmpty)
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 28),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatColumn(
                                          _formatCount(user?.mediaCount ?? 0),
                                          'posts',
                                        ),
                                        _buildStatColumn(
                                          _formatCount(user?.followersCount ?? 0),
                                          'followers',
                                        ),
                                        _buildStatColumn(
                                          _formatCount(user?.followsCount ?? 0),
                                          'following',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user?.biography case final bio?
                                when bio.isNotEmpty) ...[
                              Text(
                                bio,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                            ],
                            if (user?.website case final site?
                                when site.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.link,
                                    size: 14,
                                    color: Color(0xFF0095F6),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      site,
                                      style: const TextStyle(
                                        color: Color(0xFF0095F6),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3797EF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Follow',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF262626),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Message',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF262626),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.userPlus,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 1,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.white60,
                      labelColor: Colors.white,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      tabs: [
                        Tab(
                          icon: Icon(
                            LucideIcons.layoutGrid,
                            size: 22,
                            color: _tabController.index == 0
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            LucideIcons.clapperboard,
                            size: 22,
                            color: _tabController.index == 1
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            LucideIcons.repeat,
                            size: 22,
                            color: _tabController.index == 2
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            LucideIcons.contactRound,
                            size: 22,
                            color: _tabController.index == 3
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pinned: false,
                ),

                // Posts grid tab
                if (_tabController.index == 0 && posts.isNotEmpty)
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _PostTile(post: posts[index]),
                      childCount: posts.length,
                    ),
                  ),

                // Posts grid empty state
                if (_tabController.index == 0 && posts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.camera,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Share Photos and Videos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'When you share photos and videos, they will appear on your profile.',
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Share your first photo or video',
                              style: TextStyle(
                                color: Color(0xFF0095F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Other tabs placeholder
                if (_tabController.index != 0)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          _tabController.index == 1
                              ? 'Reels'
                              : _tabController.index == 2
                                  ? 'Reposts'
                                  : 'Tagged',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w400,
            height: 0.8,
          ),
        ),
      ],
    );
  }
}

class _PostTile extends StatelessWidget {
  final InstagramPost post;

  const _PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final url = post.displayUrl;
    if (url.isEmpty) {
      return Container(color: Colors.grey[900]);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[900]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: const Icon(LucideIcons.imageOff, color: Colors.white24, size: 24),
          ),
        ),
        if (post.isVideo)
          const Positioned(
            top: 6,
            right: 6,
            child: Icon(LucideIcons.play, color: Colors.white, size: 18),
          ),
        if (post.isCarousel)
          const Positioned(
            top: 6,
            right: 6,
            child: Icon(LucideIcons.layers, color: Colors.white, size: 18),
          ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF0D1015), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
