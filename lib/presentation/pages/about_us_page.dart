import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About RaktaSetu'),
        backgroundColor: AppTheme.bloodRed,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('About RaktaSetu'),
            _buildSectionContent(
              'RaktaSetu is a comprehensive mobile application dedicated to connecting blood donors with recipients in need. Our platform facilitates a seamless and efficient process for finding voluntary blood donors in a timely manner, bridging a critical gap in healthcare.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Our Mission'),
            _buildSectionContent(
              'Our mission is to save lives by creating a robust network of blood donors and ensuring that no one suffers due to a shortage of blood. We aim to promote voluntary blood donation and raise awareness about its importance.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Key Features'),
            _buildFeatureItem(
              Icons.search,
              'Find Donors',
              'Quickly search for blood donors by location and blood group.',
            ),
            _buildFeatureItem(
              Icons.bloodtype,
              'Request Blood',
              'Post a blood request and notify nearby donors instantly.',
            ),
            _buildFeatureItem(
              Icons.location_on,
              'Blood Bank Locator',
              'Find nearby blood banks with ease.',
            ),
            _buildFeatureItem(
              Icons.check_circle_outline,
              'Eligibility Checker',
              'Check if you are eligible to donate blood through a simple questionnaire.',
            ),
            const SizedBox(height: 32),
            _buildVquintLogoSection(),
            const SizedBox(height: 16),
            _buildVquintSection(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.bloodRed.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Raktasetu.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'RaktaSetu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.bloodRed,
            ),
          ),
          const Text(
            'Connecting Lifesavers',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.bloodRed, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVquintLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.bloodRed,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/vquint_logo.jpeg', // Make sure you have this logo in your assets
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVquintSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Developed by Vquint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This application was proudly developed by Vquint, delivering innovative solutions for our clients.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWebsiteLink('vquint.com', 'https://www.vquint.com'),
              const SizedBox(width: 16),
              _buildWebsiteLink('vquint.in', 'https://vquint.in/'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLink(String title, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.bloodRed,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'RaktaSetu v1.0.0',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
