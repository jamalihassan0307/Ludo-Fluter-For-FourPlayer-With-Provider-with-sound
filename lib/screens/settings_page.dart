import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ludo_flutter/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  // Demo settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';

  // Theme options
  final List<String> _themes = ['Light', 'Dark', 'System'];

  // Language options
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Hindi'];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  void _loadUserSettings() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      setState(() {
        // _selectedTheme = user.settings['theme'] ?? 'System';
        // _selectedLanguage = user.settings['language'] ?? 'English';
      });
    }
  }

  Future<void> _updateSettings(String key, dynamic value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.user;
      if (currentUser == null) return;

      // Update in Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'settings.$key': value,
      });

      // Update user in provider
      await userProvider.setUser(currentUser.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update setting: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<UserProvider>().signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();

      // Sign out
      await context.read<UserProvider>().signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to delete account';
      if (e.code == 'requires-recent-login') {
        message = 'Please log in again before deleting your account';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    LudoColor.blue.withOpacity(0.8),
                    LudoColor.green.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // User Profile Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: LudoColor.blue.withOpacity(0.2),
                                child: Text(
                                  'AH',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: LudoColor.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ali Hassan',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: LudoColor.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'jamalihassan0307@gmail.com',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: LudoColor.yellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pro Player',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: LudoColor.yellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: LudoColor.blue,
                                ),
                                onPressed: () {
                                  // Edit profile action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit profile coming soon')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Settings Content
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView(
                          children: [
                            // Game Stats
                            _buildSectionHeader('Game Statistics'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard('Games', '42', Icons.sports_esports),
                                _buildStatCard('Wins', '28', Icons.emoji_events),
                                _buildStatCard('Win Rate', '67%', Icons.trending_up),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Game Settings
                            _buildSectionHeader('Game Settings'),
                            _buildSettingSwitch(
                              'Sound',
                              'Enable game sounds',
                              Icons.volume_up,
                              _soundEnabled,
                              (value) {
                                setState(() {
                                  _soundEnabled = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sound setting updated')),
                                );
                              },
                            ),
                            _buildSettingSwitch(
                              'Vibration',
                              'Enable vibration feedback',
                              Icons.vibration,
                              _vibrationEnabled,
                              (value) {
                                setState(() {
                                  _vibrationEnabled = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vibration setting updated')),
                                );
                              },
                            ),
                            _buildSettingSwitch(
                              'Notifications',
                              'Enable game notifications',
                              Icons.notifications,
                              _notificationsEnabled,
                              (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notification setting updated')),
                                );
                              },
                            ),

                            // Appearance Settings
                            _buildSectionHeader('Appearance'),
                            _buildDropdownSetting(
                              'Theme',
                              'Choose app theme',
                              Icons.palette,
                              _selectedTheme,
                              _themes,
                              (value) {
                                setState(() {
                                  _selectedTheme = value!;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Theme setting updated')),
                                );
                              },
                            ),
                            _buildDropdownSetting(
                              'Language',
                              'Choose app language',
                              Icons.language,
                              _selectedLanguage,
                              _languages,
                              (value) {
                                setState(() {
                                  _selectedLanguage = value!;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Language setting updated')),
                                );
                              },
                            ),

                            // Account Settings
                            _buildSectionHeader('Account'),
                            _buildAccountOption(
                              'Change Password',
                              'Update your account password',
                              Icons.lock_outline,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Change password coming soon')),
                                );
                              },
                            ),
                            _buildAccountOption(
                              'Privacy Policy',
                              'Read our privacy policy',
                              Icons.privacy_tip_outlined,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Privacy policy coming soon')),
                                );
                              },
                            ),
                            _buildAccountOption(
                              'Terms of Service',
                              'Read our terms of service',
                              Icons.description_outlined,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Terms of service coming soon')),
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            // Sign Out Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _signOut,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LudoColor.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'SIGN OUT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // App Version
                            Center(
                              child: Text(
                                'App Version 1.0.0',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: LudoColor.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LudoColor.blue,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LudoColor.blue,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LudoColor.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: LudoColor.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: LudoColor.blue,
        ),
      ),
    );
  }

  Widget _buildDropdownSetting<T>(
    String title,
    String subtitle,
    IconData icon,
    T value,
    List<T> items,
    Function(T?) onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LudoColor.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: LudoColor.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LudoColor.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: LudoColor.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
