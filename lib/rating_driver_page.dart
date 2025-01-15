import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart'; // ملف الإعدادات حيث يتم تعريف عنوان الـ API.
import 'dart:typed_data'; // Required for Uint8List

class RatingDriverPage extends StatefulWidget {
  final double rating;
  final String email;
  const RatingDriverPage({super.key, required this.rating, required this.email});

  @override
  State<RatingDriverPage> createState() => _RatingDriverPageState();
}

class _RatingDriverPageState extends State<RatingDriverPage> {

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
    double rating = widget.rating; // قيمة التقييم

    int fullStars = rating.floor(); // النجوم الممتلئة
    int halfStars = (rating - fullStars) >= 0.5 ? 1 : 0; // النجوم نصف الممتلئة
    int emptyStars = 5 - fullStars - halfStars; // النجوم الفارغة

    return Scaffold(
      appBar: AppBar(
        title: Text('Rating',style: TextStyle(fontSize: 30),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // محاذاة العناصر في المنتصف عموديًا
              children: [
                // عرض الرقم
                Text(
                  rating.toStringAsFixed(1), // عرض التقييم بدقة 1
                  style: const TextStyle(
                    fontSize: 40, // حجم النص
                    fontWeight: FontWeight.bold, // سماكة النص
                    color: Colors.black, // لون النص
                  ),
                ),
                const SizedBox(height: 10), // مسافة بين الرقم والنجوم
                // عرض النجوم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // محاذاة النجوم في المنتصف
                  children: [
                    for (int i = 0; i < fullStars; i++)
                      const Icon(Icons.star, color: Colors.amber, size: 40),
                    for (int i = 0; i < halfStars; i++)
                      const Icon(Icons.star_half, color: Colors.amber, size: 40),
                    for (int i = 0; i < emptyStars; i++)
                      const Icon(Icons.star_border, color: Colors.amber, size: 40),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'based on $reviewsCount reviwes',
                  style: TextStyle(
                    fontSize: 15, // حجم النص
                    fontWeight: FontWeight.bold, // سماكة النص
                    color: Colors.grey[600], // لون النص
                  ),
                ),
              ],
            ),
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
