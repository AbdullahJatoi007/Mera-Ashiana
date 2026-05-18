import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/services/property_service.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../shared/helpers/internet_helper.dart';

class PropertiesScreen extends StatefulWidget {
  final List<Listing>? listings;
  final String? title;

  const PropertiesScreen({super.key, this.listings, this.title});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final ScrollController _controller = ScrollController();

  List<Listing> _listings = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get isFilteredView =>
      widget.listings != null && widget.listings!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadInitial();

    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadInitial() async {
    _page = 1;
    _hasMore = true;
    _listings.clear();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    bool connected = await InternetHelper.hasInternetConnection();
    if (!connected) return;

    final newItems = await PropertyService.fetchProperties(
      page: _page,
      limit: 20,
    );

    setState(() {
      _listings.addAll(newItems);
      _isLoading = false;
      _page++;

      if (newItems.length < 20) {
        _hasMore = false;
      }
    });
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accentYellow,
        onRefresh: _refresh,
        child: ListView.separated(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: _listings.length + (_isLoading ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            if (index < _listings.length) {
              return _buildProjectCard(context, _listings[index], isDark);
            }

            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Listing listing, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(propertyId: listing.id),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  listing.images.isNotEmpty ? listing.images[0] : '',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppDarkColors.textPrimary
                              : AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.location,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
