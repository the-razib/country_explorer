import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/country_model.dart';
import '../../controllers/country_controller.dart';

/// Beautiful card widget for displaying country information
class CountryCardWidget extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const CountryCardWidget({
    Key? key,
    required this.country,
    required this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag Section
            _buildFlagSection(context),
            
            // Country Information Section
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  /// Build the flag section with image and favorite button
  Widget _buildFlagSection(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          // Flag Image
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: CachedNetworkImage(
              imageUrl: country.flags.png,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) => _buildErrorWidget(),
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          
          // Favorite Button
          if (showFavoriteButton) _buildFavoriteButton(),
          
          // Region Badge
          _buildRegionBadge(),
        ],
      ),
    );
  }

  /// Build shimmer loading placeholder for flag image
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  /// Build error widget when flag image fails to load
  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 32,
            color: Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            'Flag not available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build favorite button overlay
  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GetBuilder<CountryController>(
        builder: (controller) {
          final isFavorite = controller.isFavorite(country);
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => controller.toggleFavorite(country),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 20,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build region badge overlay
  Widget _buildRegionBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          country.region,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Build the information section
  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Country Name
            Text(
              country.name.common,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Capital
            if (country.capital.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      country.capital.first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 4),
            
            // Population
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    country.formattedPopulation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Languages or Area
            if (country.languages.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      country.mainLanguage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of country card for list view
class CountryListTileWidget extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const CountryListTileWidget({
    Key? key,
    required this.country,
    required this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        
        // Flag
        leading: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: country.flags.png,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.flag_outlined, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.flag_outlined, color: Colors.grey),
            ),
          ),
        ),
        
        // Country Info
        title: Text(
          country.name.common,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.capital.isNotEmpty)
              Text(
                'Capital: ${country.capital.first}',
                style: theme.textTheme.bodySmall,
              ),
            Text(
              'Population: ${country.formattedPopulation}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        
        // Favorite Button
        trailing: showFavoriteButton
            ? GetBuilder<CountryController>(
                builder: (controller) {
                  final isFavorite = controller.isFavorite(country);
                  return IconButton(
                    onPressed: () => controller.toggleFavorite(country),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
