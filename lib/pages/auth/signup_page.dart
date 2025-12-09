// lib/pages/auth/signup_page.dart
import 'package:dentistify/widgets/common/custom_button.dart';
import 'package:dentistify/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/kconstants.dart';
import '../../core/utils/validators.dart';
import '../dashboard/dashboard_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: KConstants.animationSlow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: KConstants.animationNormal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(KConstants.paddingL),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: KConstants.paddingL),

                      // Title
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: KConstants.paddingS),

                      Text(
                        'Join thousands of students in Europe',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.validateName,
                      ),

                      const SizedBox(height: KConstants.paddingM),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),

                      const SizedBox(height: KConstants.paddingM),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.validatePassword,
                      ),

                      const SizedBox(height: KConstants.paddingM),

                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Signup Button
                      CustomButton(
                        text: AppStrings.signup,
                        onPressed: _handleSignup,
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkSecondary, AppColors.darkPrimary]
                              : AppColors.secondaryGradient,
                        ),
                      ),

                      const SizedBox(height: KConstants.paddingL),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppStrings.login,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }
}
