import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../providers/instagram_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _codeController = TextEditingController();
  bool _waitingForCode = false;
  bool _showManualEntry = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openInstagramAuth() async {
    final url = Uri.parse(InstagramConfig.authorizationUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() => _waitingForCode = true);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open browser.'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim().replaceAll('#_', '');
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<InstagramProvider>().handleAuthCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstagramProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Connect Instagram',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _waitingForCode
                          ? 'Authorize in the browser. You\'ll be redirected back automatically.'
                          : 'Sign in with your Instagram account to see your profile information and posts.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF3797EF)),
                            SizedBox(height: 16),
                            Text(
                              'Connecting your account…',
                              style: TextStyle(color: Colors.white60, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      if (!_waitingForCode)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _openInstagramAuth,
                            icon: const Icon(LucideIcons.logIn, size: 20),
                            label: const Text(
                              'Log in with Instagram',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3797EF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                      if (_waitingForCode) ...[
                        // Auto-redirect in progress
                        if (!_showManualEntry) ...[
                          const Icon(
                            LucideIcons.externalLink,
                            color: Colors.white38,
                            size: 32,
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => setState(() => _showManualEntry = true),
                            child: const Text(
                              'Not redirecting? Paste code manually',
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _openInstagramAuth,
                            child: const Text(
                              'Reopen browser',
                              style: TextStyle(
                                color: Color(0xFF3797EF),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],

                        // Manual fallback
                        if (_showManualEntry) ...[
                          TextField(
                            controller: _codeController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Paste authorization code here',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: const Color(0xFF1C1C1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _submitCode(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3797EF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Connect',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],

                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 60),
                    const Text(
                      'Requires a Meta Developer App with\nInstagram Login configured.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
