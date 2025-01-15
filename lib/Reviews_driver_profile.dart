import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart'; // ملف الإعدادات حيث يتم تعريف عنوان الـ API.
import 'dart:typed_data'; // Required for Uint8List

class ReviewsForDriver extends StatefulWidget {
  final String email;
  const ReviewsForDriver({super.key, required this.email});

  @override
  State<ReviewsForDriver> createState() => _ReviewsForDriverState();
}

class _ReviewsForDriverState extends State<ReviewsForDriver> {

  Map<String, Uint8List?> profilePictures = {};

  Future<void> fetchProfilePicture(String email) async {
    if (profilePictures.containsKey(email)) return; // إذا كانت الصورة مخزنة مسبقًا، لا تقم بطلب جديد

    final url = Uri.parse('$profile_picture?email=$email');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['profilePicture'] != null) {
          final base64String = data['profilePicture']; // النص الأساسي (Base64)
          final decodedBytes = base64Decode(base64String); // تحويل النص إلى Uint8List

          setState(() {
            profilePictures[email] = decodedBytes; // تخزين البيانات كـ Uint8List
          });
        }
      } else {
        print('Failed to fetch profile picture for $email');
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<Map<String, dynamic>?> getAverageRating() async {
    final String endpoint = '$average_rate/${widget.email}';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        // تحويل الاستجابة إلى JSON
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // لا توجد تقييمات
        print('No reviews found for this user');
        return null;
      } else {
        // طباعة أي خطأ آخر
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }


  int reviewsCount = 0; // متغير جلوبال لتخزين عدد التقييمات

  Future<List<dynamic>?> getReviewsFromTo() async {
    final url = Uri.parse('$get_rev_from_to/${widget.email}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // تحليل البيانات إذا كان الطلب ناجحًا
        final data = jsonDecode(response.body);
        reviewsCount = data.length; // تحديث المتغير الجلوبال
        print('Number of reviews: $reviewsCount'); // طباعة عدد التقييمات
        return data; // إرجاع قائمة التقييمات
      } else if (response.statusCode == 404) {
        // إذا لم يتم العثور على تقييمات
        print('No reviews found for the specified email.');
        return [];
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching reviews: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Reviews',style: TextStyle(fontSize: 25),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "This page is dedicated to viewing feedback from people who have interacted with you. It helps you reflect, improve yourself, or address any inquiries regarding specific feedback.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: getAverageRating(), // استدعاء دالة الحصول على التقييم
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(230, 24, 83, 131),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(230, 24, 83, 131),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      // تحويل قيمة التقييم من String إلى double
                      final averageRating = snapshot.data?['averageRating'];
                      if (averageRating != null) {
                        double rating = double.tryParse(averageRating.toString()) ?? 0.0;

                        int fullStars = rating.floor(); // النجوم الممتلئة
                        int halfStars = (rating - fullStars) >= 0.5 ? 1 : 0; // النجوم نصف الممتلئة
                        int emptyStars = 5 - fullStars - halfStars; // النجوم الفارغة

                        return GestureDetector(
                          onTap: () {
                            // إضافة السلوك عند الضغط إذا لزم الأمر
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // محاذاة العناصر في المنتصف عموديًا
                            crossAxisAlignment: CrossAxisAlignment.center, // محاذاة العناصر في المنتصف أفقيًا
                            children: [
                              // عرض الرقم في السطر الأول
                              Text(
                                '$rating', // عرض التقييم كرقم
                                style: TextStyle(
                                  fontSize: 30, // حجم النص
                                  fontWeight: FontWeight.bold, // سماكة النص
                                  color: Color.fromARGB(230, 24, 83, 131), // لون النص
                                ),
                              ),
                              SizedBox(height: 5), // مسافة صغيرة بين الرقم والنجمات
                              // عرض النجمات في السطر الثاني
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center, // محاذاة النجوم في المنتصف
                                children: [
                                  for (int i = 0; i < fullStars; i++)
                                    Icon(Icons.star, color: Colors.amber, size: 30),
                                  for (int i = 0; i < halfStars; i++)
                                    Icon(Icons.star_half, color: Colors.amber, size: 30),
                                  for (int i = 0; i < emptyStars; i++)
                                    Icon(Icons.star_border, color: Colors.amber, size: 30),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text('No rating available');
                      }
                    } else {
                      return Text('No data available');
                    }
                  },
                ),
              ),
            ],
          ),
          Divider(
            height: 32,
            thickness: 2,
            color: Colors.grey,
          ),
          SizedBox(height: 15,),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: getReviewsFromTo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final reviews = snapshot.data!;
                  if (reviews.isEmpty) {
                    return const Center(child: Text('No reviews available.'));
                  }
                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final email = review['reviewerEmail']; // افترض أن الإيميل موجود داخل بيانات المراجعة

                      // جلب صورة البروفايل عند الحاجة
                      fetchProfilePicture(email);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: profilePictures[email] != null
                                  ? MemoryImage(profilePictures[email]!) // استخدم MemoryImage مع Uint8List
                                  : null,
                              backgroundColor: Colors.grey.shade200,
                              child: profilePictures[email] == null
                                  ? Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade600,
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // توظيف Column لضبط التوزيع بشكل عمودي
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // اسم المراجع
                                  Text(
                                    review['reviewerName'],
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 8), // مسافة بين الاسم والتقييم
                                  // التقييم (الرقم والنجمات)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // النجوم
                                      Row(
                                        children: [
                                          for (int i = 0; i < review['rating']; i++)
                                            const Icon(Icons.star, color: Colors.amber, size: 22),
                                          for (int i = review['rating']; i < 5; i++)
                                            const Icon(Icons.star_border, color: Colors.amber, size: 22),
                                        ],
                                      ),
                                      const SizedBox(width: 8), // مسافة بين النجوم والرقم
                                      // الرقم
                                      Text(
                                        review['rating'].toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8), // مسافة بين التقييم والملاحظات
                                  // ملاحظات المراجع
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0), // تحديد padding من اليسار
                                    child: Align(
                                      alignment: Alignment.centerLeft, // التأكد من أن النص يبدأ من أقصى اليسار
                                      child: Text(
                                        review['notes'],
                                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
