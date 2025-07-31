import 'package:flutter/material.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';

class ModernInfoHubScreen extends StatefulWidget {
  const ModernInfoHubScreen({super.key});

  @override
  State<ModernInfoHubScreen> createState() => _ModernInfoHubScreenState();
}

class _ModernInfoHubScreenState extends State<ModernInfoHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;

  final List<InfoSection> _sections = [
    InfoSection(
      title: "Privacy Policy",
      icon: Icons.security_rounded,
      color: const Color(0xFF6366F1),
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      content: AppStrings.privacyPolicyText,
    ),
    InfoSection(
      title: "About Us",
      icon: Icons.info_outline_rounded,
      color: const Color(0xFF10B981),
      gradient: const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      content: AppStrings.aboutustext,
    ),
    InfoSection(
      title: "Help & Support",
      icon: Icons.support_agent_rounded,
      color: const Color(0xFFF59E0B),
      gradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      content:
          "At SynapseRide, we are committed to providing a safe, seamless, and reliable carpooling experience for you all. Our support team is always here to help you with any issues you may encounter—whether it's regarding ride scheduling, account management, or general inquiries. We value your feedback and aim to resolve every concern promptly and efficiently. You can reach out to us directly through the app or via email, and we'll do our best to assist you at the earliest. Your satisfaction and trust matter most to us, and we're here to support you every step of the way.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSectionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: CustomAppBar(
        title: "Info Hub",
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Animated Header Cards
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                onPageChanged: _onSectionTap,
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final isSelected = index == _selectedIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: isSelected ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: section.gradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: section.color.withOpacity(0.3),
                          blurRadius: isSelected ? 20 : 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _onSectionTap(index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    section.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  section.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // Page Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _sections.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: index == _selectedIndex ? 20 : 6,
                    decoration: BoxDecoration(
                      color: index == _selectedIndex
                          ? _sections[_selectedIndex].color
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Content Area with Animated Transitions
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _sections[_selectedIndex].color.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _sections[_selectedIndex].color.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _sections[_selectedIndex]
                                    .color
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _sections[_selectedIndex].icon,
                                color: _sections[_selectedIndex].color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sections[_selectedIndex].title,
                                style: TextStyle(
                                  color: _sections[_selectedIndex].color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Animated Divider
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _sections[_selectedIndex].color,
                                _sections[_selectedIndex]
                                    .color
                                    .withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Content with Custom Scrollbar
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 4,
                            radius: const Radius.circular(2),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                _sections[_selectedIndex].content,
                                style: AppTextStyles.bodyMediumwhite?.copyWith(
                                  height: 1.6,
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class InfoSection {
  final String title;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final String content;

  InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.content,
  });
}
