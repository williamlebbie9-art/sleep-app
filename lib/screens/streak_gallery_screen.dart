import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class StreakGalleryScreen extends StatefulWidget {
  final Map<String, String> photoEntries;

  const StreakGalleryScreen({super.key, required this.photoEntries});

  @override
  State<StreakGalleryScreen> createState() => _StreakGalleryScreenState();
}

class _StreakGalleryScreenState extends State<StreakGalleryScreen> {
  static const _vaultPasswordKey = 'streak_vault_password';

  late Map<String, String> _photoEntries;
  bool _vaultVisible = false;
  bool _vaultPasswordWasReset = false;

  @override
  void initState() {
    super.initState();
    _photoEntries = Map<String, String>.from(widget.photoEntries);
  }

  bool _isVaultKey(String key) => key.startsWith('vault_photo_');

  String _toVaultKey(String key) {
    if (_isVaultKey(key)) {
      return key;
    }
    return 'vault_$key';
  }

  String _fromVaultKey(String key) {
    if (!_isVaultKey(key)) {
      return key;
    }
    return key.replaceFirst('vault_', '');
  }

  Future<bool> _ensureVaultPasswordSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPassword = prefs.getString(_vaultPasswordKey);
    if (existingPassword != null && existingPassword.isNotEmpty) {
      return true;
    }

    if (!mounted) return false;
    final createdPassword = await _showSetPasswordDialog();
    if (createdPassword == null || createdPassword.isEmpty) {
      return false;
    }

    await prefs.setString(_vaultPasswordKey, createdPassword);
    return true;
  }

  Future<bool> _verifyVaultPassword() async {
    _vaultPasswordWasReset = false;
    final prefs = await SharedPreferences.getInstance();
    final existingPassword = prefs.getString(_vaultPasswordKey);
    if (existingPassword == null || existingPassword.isEmpty) {
      return false;
    }

    final inputController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Unlock Vault'),
              content: TextField(
                controller: inputController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Enter password',
                  errorText: errorText,
                ),
                onSubmitted: (_) {
                  if (inputController.text == existingPassword) {
                    Navigator.pop(context, true);
                  } else {
                    setDialogState(() {
                      errorText = 'Incorrect password';
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final resetConfirmed =
                        await _showResetVaultPasswordDialog();
                    if (!resetConfirmed) {
                      return;
                    }
                    await prefs.remove(_vaultPasswordKey);
                    _vaultPasswordWasReset = true;
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Vault password reset. Set a new one.'),
                        ),
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context, false);
                  },
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (inputController.text == existingPassword) {
                      Navigator.pop(context, true);
                    } else {
                      setDialogState(() {
                        errorText = 'Incorrect password';
                      });
                    }
                  },
                  child: const Text('Unlock'),
                ),
              ],
            );
          },
        );
      },
    );
    inputController.dispose();
    return result == true;
  }

  Future<bool> _showResetVaultPasswordDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Vault Password'),
        content: const Text(
          'Reset your vault password? You will set a new password next.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<String?> _showSetPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set Vault Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Create a password to protect your hidden vault.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final password = passwordController.text.trim();
                    final confirm = confirmController.text.trim();

                    if (password.isEmpty) {
                      setDialogState(() {
                        errorText = 'Password is required';
                      });
                      return;
                    }
                    if (password.length < 4) {
                      setDialogState(() {
                        errorText = 'Use at least 4 characters';
                      });
                      return;
                    }
                    if (password != confirm) {
                      setDialogState(() {
                        errorText = 'Passwords do not match';
                      });
                      return;
                    }

                    Navigator.pop(context, password);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    confirmController.dispose();
    return result;
  }

  Future<void> _moveToVault(String key, String path) async {
    final setupDone = await _ensureVaultPasswordSetup();
    if (!setupDone) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final vaultKey = _toVaultKey(key);
    await prefs.remove(key);
    await prefs.setString(vaultKey, path);
    setState(() {
      _photoEntries.remove(key);
      _photoEntries[vaultKey] = path;
      _vaultVisible = true;
    });
  }

  Future<void> _restoreFromVault(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final photoKey = _fromVaultKey(key);
    await prefs.remove(key);
    await prefs.setString(photoKey, path);
    setState(() {
      _photoEntries.remove(key);
      _photoEntries[photoKey] = path;
    });
  }

  Widget _buildGrid(
    List<MapEntry<String, String>> items, {
    required bool vault,
  }) {
    if (items.isEmpty) {
      return Text(vault ? 'Vault is empty.' : 'No check-in photos yet.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        return GestureDetector(
          onLongPress: () async {
            if (vault) {
              await _restoreFromVault(entry.key, entry.value);
            } else {
              await _moveToVault(entry.key, entry.value);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(entry.value), fit: BoxFit.cover),
              if (vault)
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.lock, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryItems =
        _photoEntries.entries.where((entry) => !_isVaultKey(entry.key)).toList()
          ..sort((a, b) => b.key.compareTo(a.key));
    final vaultItems =
        _photoEntries.entries.where((entry) => _isVaultKey(entry.key)).toList()
          ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () async {
            final wantsToReveal = !_vaultVisible;
            if (wantsToReveal) {
              final setupDone = await _ensureVaultPasswordSetup();
              if (!setupDone) {
                return;
              }
              final verified = await _verifyVaultPassword();
              if (!verified) {
                if (_vaultPasswordWasReset) {
                  final setupDoneAfterReset = await _ensureVaultPasswordSetup();
                  if (!setupDoneAfterReset) {
                    return;
                  }
                  final reverified = await _verifyVaultPassword();
                  if (!reverified) {
                    return;
                  }
                } else {
                  return;
                }
              }
            }

            setState(() => _vaultVisible = !_vaultVisible);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _vaultVisible
                      ? 'Vault revealed. Long-press a photo to hide it.'
                      : 'Vault hidden.',
                ),
              ),
            );
          },
          child: const Text('Streak Gallery'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gallery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildGrid(galleryItems, vault: false),
            if (_vaultVisible) ...[
              const SizedBox(height: 20),
              const Text(
                'Hidden Vault',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildGrid(vaultItems, vault: true),
            ],
          ],
        ),
      ),
    );
  }
}
