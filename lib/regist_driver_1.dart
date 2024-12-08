import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:project1/regist_driver_2.dart';
import 'package:provider/provider.dart';

import 'driver_data_model.dart';

class DriverRegistrationPage extends StatefulWidget {
  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();

  final List<String> carMakes = ['Audi', 'BMW', 'Mercedes', 'Toyota', 'Honda'];
  String? selectedCarMake;

  final List<Map<String, dynamic>> colors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Gray', 'color': Colors.grey},
    {'name': 'Other', 'color': null},
  ];

  String? selectedColorName;
  Color selectedCustomColor = Colors.black;

  void saveCarDetails() {
    if (_formKey.currentState!.validate() && selectedCarMake != null) {
      Provider.of<DriverDataModel>(context, listen: false).setCarDetails(
        carMake: selectedCarMake!,
        plateNumber: _plateNumberController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration',style: TextStyle(color:Color.fromARGB(230, 41, 84, 115) ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator added here
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40, // عرض الدائرة
                      height: 40, // ارتفاع الدائرة
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // لتكون الشكل دائرة
                        border: Border.all(
                          color: Colors.orange, // تحديد لون الحدود البرتقالي
                          width: 2, // عرض الحدود
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '1', // نص فارغ داخل الدائرة
                          style: TextStyle(color: Colors.orange,fontSize: 20,fontWeight: FontWeight.bold), // يمكنك تحديد لون النص هنا إذا رغبت
                        ),
                      ),
                    ),
                    SizedBox(width:5,),
                    Container(
                      width: 100, // تحديد عرض الخط
                      height: 2, // تحديد سمك الخط
                      color: Colors.orange, // لون الخط
                    ),
                    SizedBox(width:5,),
                    Container(
                      width: 40, // عرض الدائرة
                      height: 40, // ارتفاع الدائرة
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // لتكون الشكل دائرة
                        border: Border.all(
                          color: Colors.orange, // تحديد لون الحدود البرتقالي
                          width: 2, // عرض الحدود
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '2', // نص فارغ داخل الدائرة
                          style: TextStyle(color: Colors.orange,fontSize: 20,fontWeight: FontWeight.bold), // يمكنك تحديد لون النص هنا إذا رغبت
                        ),
                      ),
                    ),
                    SizedBox(width:5,),
                    Container(
                      width: 100, // تحديد عرض الخط
                      height: 2, // تحديد سمك الخط
                      color: Colors.orange, // لون الخط
                    ),
                    SizedBox(width:5,),
                    Container(
                      width: 40, // عرض الدائرة
                      height: 40, // ارتفاع الدائرة
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // لتكون الشكل دائرة
                        border: Border.all(
                          color: Colors.orange, // تحديد لون الحدود البرتقالي
                          width: 2, // عرض الحدود
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '3', // نص فارغ داخل الدائرة
                          style: TextStyle(color: Colors.orange,fontSize: 20,fontWeight: FontWeight.bold), // يمكنك تحديد لون النص هنا إذا رغبت
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Step 1 of 3',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color:Color(0xFF616161)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add your vehicle',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color:Color.fromARGB(230, 41, 84, 115)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your vehicle must be 2005 or newer and at least 4 doors and not salvaged.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const Text('Model',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Color(0xFF616161)),),
                const SizedBox(height: 11),
                DropdownButtonFormField<String>(
                  items: carMakes.map((make) {
                    return DropdownMenuItem<String>(
                      value: make,
                      child: Text(make),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCarMake = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'e.g., Audi',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2), // اللون والسمك عند عدم التفاعل
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:Color.fromARGB(230, 41, 84, 115), width: 2), // اللون والسمك عند التفاعل
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the make of the vehicle';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Year',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8), // المسافة بين النص والحقل
                          TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(
                              labelText: 'e.g., 2014',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(230, 41, 84, 115), width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the year of the vehicle';
                              }
                              if (int.tryParse(value) == null || int.parse(value) < 2005) {
                                return 'Year must be 2005 or newer';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Color',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8), // المسافة بين النص والحقل
                          DropdownButtonFormField<Map<String, dynamic>>(
                            items: colors.map((colorItem) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: colorItem,
                                child: Row(
                                  children: [
                                    if (colorItem['color'] != null)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        color: colorItem['color'],
                                        margin: const EdgeInsets.only(right: 8),
                                      ),
                                    Text(colorItem['name']),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedColorName = value?['name'];
                              });

                              if (selectedColorName == 'Other') {
                                _openColorPicker(context);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'e.g. Black',
                              labelStyle: TextStyle(color: Colors.grey), // تغيير لون النص هنا
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(230, 41, 84, 115), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (selectedColorName == 'Other') ...[
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: selectedCustomColor,
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      const Text('Custom Color Selected'),
                    ],
                  ),
                ],
                const SizedBox(height: 35),
                const Text('License Plate Number',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Color(0xFF616161)),),
                const SizedBox(height: 11),
                TextFormField(
                  controller: _plateNumberController,
                  decoration: const InputDecoration(
                    labelText: 'e.g. 6WED298',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2), // اللون والسمك عند عدم التفاعل
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:Color.fromARGB(230, 41, 84, 115), width: 2), // اللون والسمك عند التفاعل
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license plate number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child:ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final chosenColor = selectedColorName == 'Other'
                            ? selectedCustomColor
                            : colors.firstWhere((color) =>
                        color['name'] == selectedColorName)['color'];
                        print('Vehicle Make: $selectedCarMake');
                        print('Vehicle Model: ${_modelController.text}');
                        print('Vehicle Year: ${_yearController.text}');
                        print('Vehicle Color: $chosenColor');
                        print('License Plate Number: ${_plateNumberController.text}');
                        saveCarDetails();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VehicleInsuranceUpload()),
                        );
                      }
                      else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VehicleInsuranceUpload()),
                        );
                        
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Color.fromARGB(230, 41, 84, 115), // لون الخلفية (يمكنك تغييره)
                      foregroundColor: Colors.white, // لون النص
                      textStyle: TextStyle(
                        fontSize: 25, // حجم النص
                        fontWeight: FontWeight.bold, // سمك النص
                      ),
                      minimumSize: Size(double.infinity, 60), // الحد الأدنى للعرض والارتفاع (50 هو الارتفاع)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // حواف مربعة (بدون انحناء)
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedCustomColor,
              onColorChanged: (color) {
                setState(() {
                  selectedCustomColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
