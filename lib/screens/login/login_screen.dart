import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AuthController _auth;

  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _auth = Get.put(AuthController());

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);

    ever(_auth.errorText, (String? err) {
      if (err != null) {
        HapticFeedback.mediumImpact();
        _shakeCtrl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _shakeCtrl.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient fon - ko'k ranglar
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF1A3A6B),
                  Color(0xFF1E4D8C),
                ],
              ),
            ),
          ),
          // Dekorativ doiralar
          Positioned(
            top: -120,
            right: -80,
            child: _decorativeCircle(300, Colors.blue.withOpacity(0.12)),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _decorativeCircle(350, Colors.blue.withOpacity(0.08)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: -50,
            child: _decorativeCircle(150, Colors.lightBlue.withOpacity(0.06)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E4D8C),
                                Color(0xFF0A1628),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Talaba App',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Akkauntingizga kiring',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 44),
                        AnimatedBuilder(
                          animation: _shake,
                          builder: (context, child) {
                            final offset = _shakeOffset(_shake.value) * 10;
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Colors.white.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 50,
                                  offset: const Offset(0, 20),
                                ),
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 80,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Input field
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFF0F4FF),
                                        Color(0xFFE3EBFF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A1628),
                                      letterSpacing: 0.5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'ID raqamingiz',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1E4D8C),
                                              Color(0xFF0A1628),
                                            ],
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.badge_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      prefixIconConstraints:
                                      const BoxConstraints(
                                        minWidth: 50,
                                        minHeight: 50,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF1E4D8C),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 4,
                                      ),
                                    ),
                                    onSubmitted: (_) =>
                                        _auth.login(_controller.text),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Error message
                                Obx(() => AnimatedSwitcher(
                                  duration:
                                  const Duration(milliseconds: 250),
                                  child: _auth.errorText.value != null
                                      ? Padding(
                                    key: ValueKey(
                                        _auth.errorText.value),
                                    padding:
                                    const EdgeInsets.only(
                                      top: 8,
                                      left: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding:
                                          const EdgeInsets.all(
                                              4),
                                          decoration:
                                          const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _auth.errorText.value!,
                                            style: const TextStyle(
                                              color: Color(
                                                  0xFFE74C3C),
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                )),
                                const SizedBox(height: 20),
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: Obx(() => ElevatedButton(
                                    onPressed: _auth.isLoading.value
                                        ? null
                                        : () => _auth.login(
                                        _controller.text),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFF1E4D8C),
                                      disabledBackgroundColor:
                                      const Color(0xFF1E4D8C)
                                          .withOpacity(0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                      ),
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      child: _auth.isLoading.value
                                          ? SizedBox(
                                        key: const ValueKey(
                                            'loading'),
                                        width: 24,
                                        height: 24,
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                            Colors.white
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      )
                                          : Row(
                                        key: const ValueKey(
                                            'label'),
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: const [
                                          Text(
                                            'Kirish',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons
                                                .arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Footer
                        Column(
                          children: [
                            Text(
                              'ID raqamingizni bilmasangiz,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'o\'qituvchingizga murojaat qiling',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  double _shakeOffset(double t) {
    return _sin4(t) * (1 - t);
  }

  double _sin4(double t) {
    const cycles = 4;
    return (t * cycles * 2 * 3.14159).remainder(2 * 3.14159) < 3.14159
        ? 1
        : -1;
  }
}