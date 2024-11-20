import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  final Locale locale;
  final Function(String) changeLanguage;

  const OnboardingScreen({super.key, required this.locale, required this.changeLanguage});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          debugPrint("Navigating to LoginScreen");
          return const Login();
        },
      ),
    );
  }

  void skipToLogin() {
    navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = widget.locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(languageCode == 'en' ? 'Onboarding' : 'الشاشة التوجيهية'),
        actions: [
          // Language selection icon
          PopupMenuButton<String>(
            onSelected: widget.changeLanguage, // استخدام الدالة الممررة
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              PopupMenuItem<String>(
                value: 'ar',
                child: Text('عربي'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // صورة الخلفية
            Positioned.fill(
              child: Image.asset(
                'imagess/${demo_data[_pageIndex].image}',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: demo_data.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                        if (index == demo_data.length - 1) {
                          Future.delayed(
                            const Duration(seconds: 3),
                                () => skipToLogin(),
                          );
                        }
                      },
                      itemBuilder: (context, index) => OnboardContent(
                        image: demo_data[index].image,
                        title: languageCode == 'en'
                            ? demo_data[index].titleEn
                            : demo_data[index].titleAr,
                        description: languageCode == 'en'
                            ? demo_data[index].descriptionEn
                            : demo_data[index].descriptionAr,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      demo_data.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: DotIndicator(isActive: index == _pageIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // زر "Skip"
            Positioned(
              top: 20.0,
              right: 20.0,
              child: TextButton(
                onPressed: skipToLogin,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(
                      color: Color.fromARGB(230, 41, 84, 115), width: 3),
                ),
                child: Text(
                  languageCode == 'en' ? 'Skip |>>' : 'تخطي |>>',
                  style: const TextStyle(
                      color: Color.fromARGB(230, 41, 84, 115),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// باقي الكود كما هو


class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 15 : 11,
      width: isActive ? 15 : 11,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : primaryColor.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class Onboard {
  final String image;
  final String titleEn, titleAr;
  final String descriptionEn, descriptionAr;

  Onboard({
    required this.image,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
  });
}

final List<Onboard> demo_data = [
  Onboard(
    image: "w3.jpg",
    titleEn: "Wassalni Ma'ak",
    titleAr: "وصلني معك",
    descriptionEn: "Make Your Life Easy",
    descriptionAr: "اجعل حياتك أسهل",
  ),
  Onboard(
    image: "page1.jpg",
    titleEn: "REGISTER AS A PASSENGER OR DRIVER",
    titleAr: "سجل كراكب أو سائق",
    descriptionEn:
    "Need a ride or want to drive? Join Wassalni Ma'ak for flexible, safe travel.",
    descriptionAr: "تحتاج إلى رحلة أو تريد القيادة؟ انضم إلى وصلني معك للسفر المريح والآمن.",
  ),
  Onboard(
    image: "page2.jpg",
    titleEn: "JOIN AS A PROFESSIONAL, SHOWCASE YOUR EXPERTISE",
    titleAr: "انضم كمهني، واظهر خبراتك",
    descriptionEn:
    "Have a profession? Display your services and connect with clients easily!",
    descriptionAr: "لديك مهنة؟ اعرض خدماتك وتواصل مع العملاء بسهولة!",
  ),
  Onboard(
    image: "page3.jpg",
    titleEn: "YOUR SAFETY IS OUR PRIORITY",
    titleAr: "سلامتك هي أولويتنا",
    descriptionEn:
    "Wassalni Ma'ak connects you securely with others, with ratings and trusted payments.",
    descriptionAr: "وصلني معك يربطك بأمان مع الآخرين، مع التقييمات والمدفوعات الموثوقة.",
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 30,
              color: primaryColor,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: primaryColor,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
