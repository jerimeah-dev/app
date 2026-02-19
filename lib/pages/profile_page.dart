import 'dart:io';
import 'package:app/models/user_model.dart';
import 'package:app/notifiers/async_state.dart';
import 'package:app/ui/common/widgets/app_shimmer.dart';
import 'package:app/ui/common/widgets/editable_text.dart';
import 'package:app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/profile_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = context.read<AuthNotifier>();

      if (auth.currentUser != null) {
        _displayController.text = auth.currentUser!.displayName;
        _bioController.text = auth.currentUser!.bio ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthNotifier>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: const [
            _ProfileAvatarSection(),
            SizedBox(height: 32),
            _DisplayNameSection(),
            SizedBox(height: 20),
            _BioSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ProfileNotifier>().updateProfile(
      displayName: _displayController.text.trim(),
      bio: _bioController.text.trim(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    await context.read<ProfileNotifier>().updateAvatar(File(picked.path));
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection();

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileNotifier, ({UserModel? user, bool uploading})>(
      selector: (_, notifier) =>
          (user: notifier.user, uploading: notifier.isAvatarUploading),
      builder: (_, data, __) {
        final user = data.user;
        final isUploading = data.uploading;

        if (user == null) {
          return const Center(child: AppShimmer(height: 120, width: 120));
        }

        return Center(
          child: GestureDetector(
            onTap: isUploading
                ? null
                : () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (picked == null) return;

                    await context.read<ProfileNotifier>().updateAvatar(
                      File(picked.path),
                    );
                  },
            child: Stack(
              alignment: Alignment.center,
              children: [
                UserAvatar(user: user, size: 60, viewable: false),
                if (isUploading) const AppShimmer(height: 120, width: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisplayNameSection extends StatelessWidget {
  const _DisplayNameSection();

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileNotifier, String?>(
      selector: (_, notifier) => notifier.user?.displayName,
      builder: (_, displayName, __) {
        return EditableTextField(
          initialValue: displayName,
          placeholder: "Display Name",
          onSave: (value) async {
            await context.read<ProfileNotifier>().updateProfile(
              displayName: value,
              bio: context.read<ProfileNotifier>().user?.bio ?? '',
            );
          },
        );
      },
    );
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection();

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileNotifier, String?>(
      selector: (_, notifier) => notifier.user?.bio,
      builder: (_, bio, __) {
        return EditableTextField(
          initialValue: bio,
          placeholder: "Add a bio...",
          expandable: true,
          maxLines: 4,
          onSave: (value) async {
            await context.read<ProfileNotifier>().updateProfile(
              displayName:
                  context.read<ProfileNotifier>().user?.displayName ?? '',
              bio: value,
            );
          },
        );
      },
    );
  }
}
