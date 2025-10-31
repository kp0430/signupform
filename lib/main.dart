import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun Signup App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _selectedAvatar; // emoji selected by user
  final List<String> _avatars = ['😊', '🚀', '🐶', '🦄', '🌈'];

  double _progress = 0;
  double _passwordStrength = 0;
  String _strengthLabel = 'Weak';
  List<String> _badges = [];

  // Animation controllers for shake/bounce
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  void _triggerBounce() {
    _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
  }

  void _updateProgress() {
    double newProgress = 0;
    if (_nameController.text.isNotEmpty) newProgress += 0.2;
    if (_emailController.text.contains('@')) newProgress += 0.2;
    if (_passwordController.text.length >= 6) newProgress += 0.2;
    if (_confirmController.text == _passwordController.text &&
        _confirmController.text.isNotEmpty) newProgress += 0.2;
    if (_selectedAvatar != null) newProgress += 0.2;
    setState(() => _progress = newProgress);
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.3) return Colors.red;
    if (_passwordStrength < 0.7) return Colors.orange;
    return Colors.green;
  }

  Widget _animatedField({required Widget child}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeController, _bounceController]),
      builder: (context, _) {
        double dx = sin(_shakeAnimation.value * pi * 2) * 4;
        double scale = 1 + _bounceAnimation.value;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }

  void _validateField(bool isValid) {
    if (isValid) {
      _triggerBounce();
    } else {
      _triggerShake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Us Today for the Cash Money!'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // PROGRESS BAR
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.purple[100],
                  color: Colors.purple,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  "${(_progress * 100).toInt()}% complete",
                  style: const TextStyle(color: Colors.purple),
                ),
                const SizedBox(height: 20),

                // Name Field 
                _animatedField(
                  child: TextFormField(
                    controller: _nameController,
                    onChanged: (_) => _updateProgress(),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final isValid = value != null && value.isNotEmpty;
                      _validateField(isValid);
                      return isValid ? null : 'Please enter your name';
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field 
                _animatedField(
                  child: TextFormField(
                    controller: _emailController,
                    onChanged: (_) => _updateProgress(),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      bool isValid = value != null &&
                          value.isNotEmpty &&
                          value.contains('@');
                      _validateField(isValid);
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field 
                _animatedField(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _passwordStrength = 0;
                          _strengthLabel = 'Weak';
                        } else if (value.length < 6) {
                          _passwordStrength = 0.3;
                          _strengthLabel = 'Weak';
                        } else if (value.length < 10) {
                          _passwordStrength = 0.6;
                          _strengthLabel = 'Medium';
                        } else {
                          _passwordStrength = 1.0;
                          _strengthLabel = 'Strong';
                          if (!_badges.contains("Strong Password Master")) {
                            _badges.add("Strong Password Master");
                          }
                        }
                        _updateProgress();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      bool isValid = value != null && value.length >= 6;
                      _validateField(isValid);
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _passwordStrength,
                  color: _getStrengthColor(),
                  backgroundColor: Colors.grey[200],
                  minHeight: 6,
                ),
                Text("Strength: $_strengthLabel",
                    style: const TextStyle(color: Colors.purple)),
                const SizedBox(height: 16),

                // Confirm Password 
                _animatedField(
                  child: TextFormField(
                    controller: _confirmController,
                    onChanged: (_) => _updateProgress(),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      bool isValid = value != null &&
                          value == _passwordController.text &&
                          value.isNotEmpty;
                      _validateField(isValid);
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Avatar Picker
                const Text(
                  'Choose an Avatar:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: _avatars.map((avatar) {
                    final isSelected = _selectedAvatar == avatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                          _updateProgress();
                        });
                        _triggerBounce();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.purple[100]
                              : Colors.grey[200],
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Achievement Badges
                Wrap(
                  spacing: 8,
                  children: _badges
                      .map((badge) => Chip(
                            label: Text(badge),
                            backgroundColor: Colors.purple[100],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedAvatar == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an avatar'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final now = TimeOfDay.now();
                      if (now.hour < 12 &&
                          !_badges.contains("The Early Bird Special")) {
                        _badges.add("The Early Bird Special");
                      }
                      if (_progress == 1.0 &&
                          !_badges.contains("Profile Completed")) {
                        _badges.add("Profile Completed");
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen(
                            name: _nameController.text,
                            avatar: _selectedAvatar!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
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

class WelcomeScreen extends StatefulWidget {
  final String name;
  final String avatar;

  const WelcomeScreen({super.key, required this.name, required this.avatar});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _confetti.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.purple,
                Colors.pink,
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.avatar, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome, ${widget.name}!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We’re glad to have you here 🎉',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
