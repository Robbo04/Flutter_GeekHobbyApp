import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/enums/platforms/game_platform.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';
import 'package:app_geek_hobby_app/widgets/common/user_rating_bar.dart';

class GameDisplay extends StatefulWidget {
  final Game game;

  const GameDisplay({super.key, required this.game});

  @override
  State<GameDisplay> createState() => _GameDisplayState();
}

class _GameDisplayState extends State<GameDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;
  late bool completed;
  bool _showRatingSlider = false;

  @override
  void initState() {
    super.initState();
    owned = widget.game.owned;
    wishlisted = widget.game.wishlist;
    userRating = widget.game.userRating;
    completed = widget.game.completed;
  }

  Future<void> updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.game.owned = owned;
      widget.game.wishlist = wishlisted;
      if (!owned) {
        completed = false;
        widget.game.completed = false;
      }
    });

    await widget.game.save();

    final ownedBox = Hive.box<int>('games_owned_collection_id');
    final wishlistBox = Hive.box<int>('games_wishlist_collection_id');
    final backlogBox = Hive.box<int>('games_backlog_collection_id');
    final completedBox = Hive.box<int>('games_completed_collection_id');
    final id = widget.game.id;

    if (owned) {
      await ownedBox.put(id, id);
      await wishlistBox.delete(id);
      if (completed) {
        await completedBox.put(id, id);
        await backlogBox.delete(id);
      } else {
        await backlogBox.put(id, id);
        await completedBox.delete(id);
      }
    } else {
      await ownedBox.delete(id);
      await backlogBox.delete(id);
      await completedBox.delete(id);
    }
  }

  Future<void> updateWishlist(bool value) async {
    setState(() {
      wishlisted = value;
      widget.game.wishlist = wishlisted;
    });

    try {
      if (value) {
        await CollectionsService.instance.addToWishlist(widget.game);
      } else {
        await CollectionsService.instance.removeFromWishlist(widget.game);
      }
    } catch (e, st) {
      debugPrint('CollectionsService wishlist error: $e\n$st');
      setState(() {
        wishlisted = !value;
        widget.game.wishlist = wishlisted;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update wishlist: $e')),
        );
      }
    }
  }

  Future<void> updateCompleted(bool value) async {
    setState(() {
      completed = value;
      widget.game.completed = value;
    });
    await widget.game.save();

    final completedBox = Hive.box<int>('games_completed_collection_id');
    final backlogBox = Hive.box<int>('games_backlog_collection_id');
    final id = widget.game.id;

    if (completed) {
      await completedBox.put(id, id);
      await backlogBox.delete(id);
    } else {
      await completedBox.delete(id);
      if (owned) {
        await backlogBox.put(id, id);
      } else {
        await backlogBox.delete(id);
      }
    }
  }

  Future<void> updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.game.userRating = rating;
    });
    await widget.game.save();
  }

  String? _getPlatformLogoPath(GamePlatform platform) {
    switch (platform) {
      case GamePlatform.pc:
        return 'assets/logos/platforms/Logo_Windows.svg';
      case GamePlatform.playstation:
        return 'assets/logos/platforms/Logo_Playstation.svg';
      case GamePlatform.xbox:
        return 'assets/logos/platforms/Logo_Xbox.svg';
      case GamePlatform.nintendo:
        return 'assets/logos/platforms/Logo_Nintendo.svg';
      case GamePlatform.mobile:
        return null;
      case GamePlatform.vr:
        return 'assets/logos/platforms/Logo_Meta.svg';
      case GamePlatform.other:
        return null;
    }
  }

  String _statusText() {
    if (completed) return 'Completed';
    if (owned) return 'Playing';
    if (wishlisted) return 'Wishlisted';
    return 'Not Started';
  }

  double _metacriticProgress() {
    final score = widget.game.metacriticRating;
    if (score <= 0) return 0;
    return (score.clamp(0, 100)) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heroImage = widget.game.imageUrl;
    final genres = widget.game.genres
        .map((g) => g.toString().split('.').last)
        .join(' • ');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Game details'),
        backgroundColor: colorScheme.scrim.withOpacity(0.35),
        foregroundColor: const Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: heroImage != null && heroImage.isNotEmpty
                ? Image.network(heroImage, fit: BoxFit.cover)
                : Container(color: const Color(0xFF0F172A)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: colorScheme.scrim.withOpacity(0.34)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.scrim.withOpacity(0.16),
                    colorScheme.scrim.withOpacity(0.74),
                  ],
                ),
              ),
            ),
          ),
          ListView(
            padding: AppSpacing.paddingAll16,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF0F172A),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusPill(
                            colorA: const Color(0xFF7C3AED),
                            colorB: const Color(0xFF4C1D95),
                            icon: completed
                                ? Icons.check_circle
                                : owned
                                ? Icons.sports_esports
                                : wishlisted
                                ? Icons.bookmark
                                : Icons.pause_circle_outline,
                            text: _statusText(),
                          ),
                          if (widget.game.metacriticRating > 0)
                            _StatusPill(
                              colorA: const Color(0xFF2563EB),
                              colorB: const Color(0xFF1D4ED8),
                              icon: Icons.bar_chart,
                              text:
                                  'Metacritic ${widget.game.metacriticRating}/100',
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg + 2),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 206,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.scrim.withOpacity(0.34),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (heroImage != null && heroImage.isNotEmpty)
                                  Image.network(heroImage, fit: BoxFit.cover)
                                else
                                  Container(color: const Color(0xFF1F2937)),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                            const Color(0x00000000),
                                            colorScheme.scrim.withOpacity(0.86),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        18,
                                        12,
                                        12,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${widget.game.yearReleased} • $genres',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFFFFFFF,
                                              ).withOpacity(0.85),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg + 2),
                      AppTitleText(
                        widget.game.name,
                        selectable: true,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md + 2),
                      if (widget.game.metacriticRating > 0) ...[
                        Row(
                          children: [
                            const Text(
                              'Metacritic',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${widget.game.metacriticRating}/100',
                              style: TextStyle(
                                color: const Color(0xFFFFFFFF).withOpacity(0.88),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(
                              value: _metacriticProgress(),
                              backgroundColor: const Color(
                                0xFFFFFFFF,
                              ).withOpacity(0.18),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md + 2),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _ActionPillButton(
                              icon: owned
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              label: owned ? 'Owned' : 'Own',
                              onPressed: () => updateOwned(!owned),
                            ),
                          ),
                          AppSpacing.horizontalSm,
                          Expanded(
                            child: Opacity(
                              opacity: owned ? 0.45 : 1.0,
                              child: _ActionPillButton(
                                icon: wishlisted
                                    ? Icons.bookmark
                                    : Icons.bookmark_add_outlined,
                                label: wishlisted
                                    ? 'Wishlisted'
                                    : 'Wishlist',
                                onPressed: owned
                                    ? null
                                    : () => updateWishlist(!wishlisted),
                              ),
                            ),
                          ),
                          AppSpacing.horizontalSm,
                          Expanded(
                            child: Opacity(
                              opacity: owned ? 1.0 : 0.45,
                              child: _ActionPillButton(
                                icon: Icons.star,
                                label: userRating > 0
                                    ? '$userRating/100'
                                    : 'Rate',
                                iconColor: colorScheme.tertiary,
                                onPressed: owned
                                    ? () => setState(
                                        () => _showRatingSlider =
                                            !_showRatingSlider,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (owned) ...[
                        AppSpacing.verticalSm,
                        _ActionPillButton(
                          icon: completed
                              ? Icons.verified
                              : Icons.hourglass_bottom,
                          label: completed ? 'Completed' : 'Incomplete',
                          onPressed: () => updateCompleted(!completed),
                        ),
                      ],
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _showRatingSlider
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm + 2),
                          child: UserRatingSlider(
                            initialRating: userRating,
                            onChanged: updateUserRating,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalLg,
              _InfoPanel(
                title: 'Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Studio', value: widget.game.studio),
                    _InfoRow(
                      label: 'Release Year',
                      value: widget.game.yearReleased.toString(),
                    ),
                    _InfoRow(
                      label: 'Age Rating',
                      value: widget.game.ageRating.toString().split('.').last,
                    ),
                    _InfoRow(
                      label: 'Genres',
                      value: genres.replaceAll(' • ', ', '),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalMd,
              _InfoPanel(
                title: 'Platforms',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.game.platforms.map((platform) {
                    final logoPath = _getPlatformLogoPath(platform);
                    if (logoPath != null) {
                      return Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(logoPath),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.24),
                        ),
                      ),
                      child: Text(
                        platform.toString().split('.').last,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color colorA;
  final Color colorB;
  final IconData icon;
  final String text;

  const _StatusPill({
    required this.colorA,
    required this.colorB,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm + 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: [colorA, colorB]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onPrimary),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback? onPressed;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFFFFFFF).withOpacity(0.80),
            border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor ?? const Color(0xFF0F172A), size: 20),
              AppSpacing.horizontalSm,
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: const Color(0xFFFFFFFF).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
