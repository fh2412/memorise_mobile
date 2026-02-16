import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../view_models/user_card_view_model.dart';
import '../../../domain/models/user_model.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isFront = true;

  final TextEditingController _codeController = TextEditingController();

  void _toggleFlip() {
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserCardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = viewModel.user;
        if (user == null) {
          return const Center(child: Text("No user data found"));
        }

        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutBack,
          tween: Tween<double>(begin: 0, end: _isFront ? 0 : pi),
          builder: (context, double value, child) {
            // Flip logic: if rotation > 90 deg, show the back
            final isBack = value > pi / 2;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(value),
              alignment: Alignment.center,
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(pi), // Flip the back content back to readable
                      child: _buildCardFrame(
                        context,
                        _buildBackSide(user, viewModel),
                      ),
                    )
                  : _buildCardFrame(context, _buildFrontSide(user)),
            );
          },
        );
      },
    );
  }

  // Common frame for both sides
  Widget _buildCardFrame(BuildContext context, Widget content) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      child: Card(
        elevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(padding: const EdgeInsets.all(20.0), child: content),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                onPressed: _toggleFlip,
                icon: Icon(_isFront ? Icons.qr_code : Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontSide(MemoriseUser user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Image
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: user.profilePic.isNotEmpty
              ? NetworkImage(user.profilePic)
              : null,
          child: user.profilePic.isEmpty
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(width: 20),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAccountBadge(user.accountType),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "@${user.username}",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide(MemoriseUser user, UserCardViewModel viewModel) {
    // Assuming friendCode is added to model or just using userId for now
    final friendCode = user.userId.substring(0, 8).toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QR Code
        QrImageView(
          data: user.userId,
          version: QrVersions.auto,
          size: 100.0,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 20),
        // QR Actions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Friend Code",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SelectableText(
                friendCode,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountBadge(AccountType type) {
    Color color;
    switch (type) {
      case AccountType.PRO:
        color = Colors.amber.shade700;
        break;
      case AccountType.UNLIMITED:
        color = Colors.deepPurple;
        break;
      case AccountType.FREE:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        type.name,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
