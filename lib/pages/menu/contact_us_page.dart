// lib/pages/menu/contact_us_page.dart
import 'package:dentistify/widgets/common/custom_button.dart';
import 'package:dentistify/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contact Info Cards
              _buildContactCard(
                context,
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'support@eustudent.com',
              ),
              const SizedBox(height: KConstants.paddingM),
              _buildContactCard(
                context,
                icon: Icons.phone_outlined,
                title: 'Phone',
                subtitle: '+1 234 567 8900',
              ),
              const SizedBox(height: KConstants.paddingM),
              _buildContactCard(
                context,
                icon: Icons.location_on_outlined,
                title: 'Address',
                subtitle: 'Brussels, Belgium',
              ),

              const SizedBox(height: KConstants.paddingXL),

              Text(
                'Send us a message',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: KConstants.paddingL),

              CustomTextField(
                controller: _nameController,
                label: 'Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: KConstants.paddingM),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: KConstants.paddingM),

              CustomTextField(
                controller: _messageController,
                label: 'Message',
                prefixIcon: Icons.message_outlined,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),

              const SizedBox(height: KConstants.paddingL),

              CustomButton(
                text: 'Send Message',
                onPressed: _handleSubmit,
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkPrimary, AppColors.darkAccent]
                      : AppColors.primaryGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KConstants.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(KConstants.radiusL),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(KConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: KConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: KConstants.paddingXS),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
