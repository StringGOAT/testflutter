import 'dart:io';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:get/get.dart' hide Trans;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_getx/controllers/task_controller.dart';
import 'package:sqflite_getx/ui/theme.dart';
import 'package:sqflite_getx/ui/utils/utility.dart';
import 'package:sqflite_getx/ui/widgets/button.dart';
import 'package:sqflite_getx/ui/widgets/input_field.dart';
import '../controllers/backup_controller.dart';
import '../models/crossesStringInfo.dart';
import '../models/stringInfo.dart';
import '../models/racketInfo.dart';
import '../models/task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:sqflite_getx/ui/racket_load_data.dart';

import 'image_detail_page.dart';
import 'string_load_data.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;

  const AddTaskPage({this.task, Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> tooltipRacketKey = GlobalKey<TooltipState>();
  final TaskController _taskController = Get.put(TaskController());
  final BackupController _backupController = Get.find<BackupController>();

  DateTime _selectedDate = DateTime.now();
  String _endTime = '9:30 PM';
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  int _selectedRemind = 5;

  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];

  String _selectedRacketNumbers = 'None'.tr;
  List<String> racketNumbersList = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  String _selectedStringPattern = 'None'.tr;
  List<String> stringPatternList = [
    '14 x 18', // @add 사용자 요청으로 추가
    '16 x 16', // @add 사용자 요청으로 추가
    '16 x 18',
    '16 x 19',
    '16 x 20',
    '18 x 16', // @add 사용자 요청으로 추가
    '18 x 18', // @add 사용자 요청으로 추가
    '18 x 19', // @add 사용자 요청으로 추가
    '18 x 20',
  ];

  String _selectedGripSize = 'None'.tr;
  List<String> gripSizeList = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  String _selectedStringType = 'None'.tr;
  List<String> stringTypeList = [
    // 'Natural Gut String',
    // 'Synthetic Gut String',
    // 'Multifilament String',
    // 'Polyester String',
    'Natural Gut'.tr,
    'Synthetic Gut'.tr,
    'Multifilament'.tr,
    'Polyester'.tr,
  ];

  String _selectedCrossesStringType = 'None'.tr;
  List<String> crossesStringTypeList = [
    // 'Natural Gut String',
    // 'Synthetic Gut String',
    // 'Multifilament String',
    // 'Polyester String',
    'Natural Gut'.tr,
    'Synthetic Gut'.tr,
    'Multifilament'.tr,
    'Polyester'.tr,
  ];

  String _selectedStringShape = 'None'.tr;
  List<String> stringShapeList = [
    'Rounded String'.tr,
    // 'Textured/Shaped String',
    'Shaped String'.tr,
  ];

  String _selectedCrossesStringShape = 'None'.tr;
  List<String> crossesStringShapeList = [
    'Rounded String'.tr,
    // 'Textured/Shaped String',
    'Shaped String'.tr,
  ];

  String _selectedRepeat = 'None'.tr;
  List<String> repeatList = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
  ];

  List<Color> stringColorList = [
    bluishClr,
    yellowClr,
    pinkClr,
  ];

  int _selectedColor = 0;
  int _selectedCorssesColor = 0;
  bool isHybridStringing = false;

  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image =
          await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (image == null) return;

      // final imageTemporary = File(image.path);
      final imagePermanent = await saveImagePermanently(image.path);

      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  @override
  void initState() {
    if (widget.task != null) {
      Task task = widget.task!;
      _taskController.racketBrandController.text = task.racketBrand!;
      _taskController.racketModelController.text = task.racketModel!;
      _taskController.stringBrandController.text = task.stringBrand!;
      _taskController.stringModelController.text = task.stringModel!;
      _taskController.stringTypeController.text =
          task.stringType!.tr; // @tr 수정 *** 드롭다운메뉴 번역
      _taskController.stringCrossesBrandController.text =
          task.stringCrossesBrand!;
      _taskController.stringCrossesModelController.text =
          task.stringCrossesModel!;
      _taskController.stringCrossesTypeController.text =
          task.stringCrossesType!.tr; // @tr 수정 *** 드롭다운메뉴 번역
      _taskController.headSizeController.text = task.headSize!;
      _taskController.stringShapeController.text =
          task.stringShape!.tr; // @tr 수정 *** 드롭다운메뉴 번역
      _taskController.stringCrossesShapeController.text =
          task.stringCrossesShape!.tr; // @tr 수정 *** 드롭다운메뉴 번역
      _taskController.dateController.text = task.date!;
      _selectedDate = DateFormat('MM/dd/yyyy').parse(task.date!);
      _taskController.startTimeController.text = task.startTime!;
      _startTime = _taskController.startTimeController.text;
      _taskController.endTimeController.text = task.endTime!;
      _endTime = _taskController.endTimeController.text;
      _taskController.remindController.text = '${task.remind} minutes early';
      _selectedRemind = task.remind!;
      _taskController.repeatController.text = task.repeat!;
      _selectedRepeat = _taskController.repeatController.text;
      _selectedColor = task.color!;
      _selectedCorssesColor = task.crossesColor ?? 0;
      isHybridStringing = task.hybridStringing!;
    }

    super.initState();
  }

  @override
  void dispose() {
    _taskController.racketBrandController.clear();
    _taskController.racketModelController.clear();
    _taskController.stringBrandController.clear();
    _taskController.stringModelController.clear();
    _taskController.stringTypeController.clear();
    _taskController.stringCrossesBrandController.clear();
    _taskController.stringCrossesModelController.clear();
    _taskController.stringCrossesTypeController.clear();
    _taskController.headSizeController.clear();
    _taskController.stringShapeController.clear();
    _taskController.stringCrossesShapeController.clear();
    _taskController.dateController.clear();
    _taskController.startTimeController.clear();
    _taskController.endTimeController.clear();
    _taskController.remindController.clear();
    _taskController.repeatController.clear();
    super.dispose();
  }

  String _stringValue = '';
  String _stringCrossesValue = '';

  void resetImage() {
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool singleScreen = MediaQuery.of(context).hinge == null &&
        MediaQuery.of(context).size.width < 1000;
    final folderPhoneWidth = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: SafeArea(
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (_, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(widget.task != null ? 'Edit Task' : 'Add Task',
                  //     style: headingStyle),
                  // SizedBox(height: 5.h),
                  Transform.translate(
                    offset: Offset(0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              // width: folderPhoneWidth ? 85 : 90.w,
                              // width: singleScreen ? 90.w : 85,
                              // height: 30.h,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: primaryClr,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: IntrinsicWidth(
                                stepWidth: 100,
                                child: Center(
                                    // child: Text('Racket',
                                    child: GestureDetector(
                                  onTap: () =>
                                      Get.to(() => const RacketLoadData()),
                                  child: Text('Racket'.tr,
                                      style: TextStyle(
                                          color: Colors.white,
                                          // fontSize: folderPhoneWidth ? 20 : 20.sp,
                                          fontSize: singleScreen ? 20.sp : 20,
                                          fontWeight: FontWeight.bold)),
                                )),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => showImageSource(context),
                          child: image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(125),
                                  child: Image.file(
                                    image!,
                                    // height: 55.h,
                                    // width: 55.w,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : widget.task != null &&
                                      widget.task!.image != null &&
                                      widget.task!.image!.isNotEmpty
                                  ? SizedBox(
                                      // width: 55.w,
                                      // height: 55.h,
                                      width: 50,
                                      height: 50,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(125),
                                        child: Utility.imageFromBase64String(
                                            widget.task!.image!),
                                        // child: Image.file(
                                        //   File(widget.task!.image!),
                                        //   height: 55.h,
                                        //   width: 55.w,
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                    )
                                  : Container(
                                      // height: 55.h,
                                      // width: 55.w,
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: singleScreen ? 1.w : 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.r),
                                      ),
                                      child: IntrinsicWidth(
                                        // stepWidth: 50,
                                        child: Center(
                                            // child: Text('Racket',
                                            child: Icon(CupertinoIcons.photo)),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                  MyInputField(
                    textInputAction: TextInputAction.next,
                    readOnly: false,
                    message: '',
                    suffixIcon: '',
                    keyboardType: TextInputType.text,
                    title: 'Brand',
                    hint: 'Add brand'.tr,
                    controller: _taskController.racketBrandController,
                  ),
                  // Text('Racket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.52,
                        child: MyInputField(
                          textInputAction: TextInputAction.next,
                          readOnly: false,
                          message: '',
                          suffixIcon: '',
                          keyboardType: TextInputType.text,
                          title: 'Name',
                          hint: 'Add name'.tr,
                          controller: _taskController.racketModelController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyInputField(
                          counterText: '',
                          maxLength: 3,
                          readOnly: false,
                          message: '',
                          suffixIcon: '',
                          keyboardType: TextInputType.number,
                          title: 'Size',
                          hint: '',
                          controller: _taskController.headSizeController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.to(() => const StringLoadData()),
                    child: Container(
                      // width: folderPhoneWidth ? 80 : 80.w,
                      // width: singleScreen ? 80.w : 80,
                      // height: 30.h,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: primaryClr,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: IntrinsicWidth(
                        stepWidth: 100,
                        child: Center(
                            child: Text('String'.tr,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontSize: folderPhoneWidth ? 20 : 20.sp,
                                    fontSize: singleScreen ? 20.sp : 20,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Add Cross'.tr,
                              style: singleScreen
                                  ? TextStyle(fontSize: 15)
                                  : TextStyle(fontSize: 18)),
                        ],
                      ),
                      // Text('Different string for crosses'),
                      FlutterSwitch(
                        // width: folderPhoneWidth ? 65 : 55.0.w,
                        width: singleScreen ? 55.0.w : 65,
                        height: 25.0.h,
                        valueFontSize: 12.0.sp,
                        toggleSize: 18.0.sp,
                        value: isHybridStringing,
                        onToggle: (val) {
                          setState(() {
                            isHybridStringing = val;
                            if (!isHybridStringing) {
                              _taskController.stringCrossesBrandController
                                  .clear();
                              _taskController.stringCrossesModelController
                                  .clear();
                              _taskController.stringCrossesTypeController
                                  .clear();
                              _taskController.stringCrossesShapeController
                                  .clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Visibility(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text(
                              'Main'.tr,
                              style: TextStyle(
                                  // fontSize: folderPhoneWidth ? 18 : 17.sp, fontWeight: FontWeight.bold),
                                  fontSize: singleScreen ? 17.sp : 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    visible: isHybridStringing,
                  ),
                  MyInputField(
                    textInputAction: TextInputAction.next,
                    readOnly: false,
                    message: '',
                    suffixIcon: '',
                    keyboardType: TextInputType.text,
                    title: 'Brand',
                    hint: 'Add brand'.tr,
                    controller: _taskController.stringBrandController,
                  ),
                  // MyInputFieldStringName(
                  MyInputField(
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        _stringValue = val;
                        // print('ㅇㅇㅇ $widget');
                      });
                    },
                    readOnly: false,
                    message: '',
                    suffixIcon: '',
                    keyboardType: TextInputType.text,
                    title: 'Name',
                    hint: 'Add name'.tr,
                    controller: _taskController.stringModelController,
                    // widget: _showColor(),
                    widget: _stringValue.isNotEmpty ||
                            _taskController
                                .stringModelController.text.isNotEmpty
                        ? _stringColor()
                        : Container(),
                  ),
                  MyInputField(
                      readOnly: true,
                      message: '',
                      suffixIcon: '',
                      keyboardType: TextInputType.text,
                      title: 'Type',
                      hint: _selectedStringType,
                      controller: _taskController.stringTypeController,
                      widget: SizedBox(
                        width: 120.w,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: DropdownButton(
                            isDense: true,
                            focusColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            dropdownColor: Get.isDarkMode
                                ? dropdownClrDarkMode
                                : dropdownClrLightMode,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            isExpanded: true,
                            // iconSize: folderPhoneWidth ? 35 : 32.sp,
                            iconSize: singleScreen ? 32.sp : 35,
                            elevation: 4,
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              setState(() {
                                // _selectedStringType = newValue!;
                                _selectedStringType = newValue!; // @수정
                                _taskController.stringTypeController.text =
                                    _selectedStringType.tr;
                              });
                            },
                            // style: folderPhoneWidth ? folderPhoneSubTitleStyle : subTitleStyle,
                            style: singleScreen
                                ? subTitleStyle
                                : folderPhoneSubTitleStyle,
                            items: stringTypeList
                                .map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                // value: value,
                                value: value, // @수정
                                child: Text(
                                  // value!.tr,
                                  value!.tr, // @tr추가
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                  MyInputField(
                      readOnly: true,
                      message: '',
                      suffixIcon: '',
                      keyboardType: TextInputType.text,
                      title: 'Shape',
                      hint: _selectedStringShape,
                      controller: _taskController.stringShapeController,
                      widget: SizedBox(
                        width: 120.w,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: DropdownButton(
                            isDense: true,
                            focusColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            dropdownColor: Get.isDarkMode
                                ? dropdownClrDarkMode
                                : dropdownClrLightMode,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            isExpanded: true,
                            // iconSize: folderPhoneWidth ? 35 : 32.sp,
                            iconSize: singleScreen ? 32.sp : 35,
                            elevation: 4,
                            underline: Container(height: 0),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStringShape = newValue!; // @수정
                                _taskController.stringShapeController.text =
                                    _selectedStringShape.tr;
                              });
                            },
                            // style: folderPhoneWidth ? folderPhoneSubTitleStyle : subTitleStyle,
                            style: singleScreen
                                ? subTitleStyle
                                : folderPhoneSubTitleStyle,
                            items: stringShapeList
                                .map<DropdownMenuItem<String>>((String? value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value!.tr, // @tr추가
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                  Visibility(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text('Cross'.tr,
                                style: TextStyle(
                                    // fontSize: folderPhoneWidth ? 18 : 17.sp, fontWeight: FontWeight.bold)),
                                    fontSize: singleScreen ? 17.sp : 18,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    visible: isHybridStringing,
                  ),
                  Visibility(
                    child: MyInputField(
                      textInputAction: TextInputAction.next,
                      readOnly: false,
                      message: '',
                      suffixIcon: '',
                      keyboardType: TextInputType.text,
                      title: 'Brand',
                      hint: 'Add name *Cross'.tr,
                      controller: _taskController.stringCrossesBrandController,
                    ),
                    visible: isHybridStringing,
                  ),
                  Visibility(
                    child: MyInputField(
                      textInputAction: TextInputAction.next,
                      onChanged: (val) {
                        setState(() {
                          _stringCrossesValue = val;
                        });
                      },
                      readOnly: false,
                      message: '',
                      suffixIcon: '',
                      keyboardType: TextInputType.text,
                      title: 'Name',
                      hint: 'Add name *Cross'.tr,
                      controller: _taskController.stringCrossesModelController,
                      widget: _stringCrossesValue.isNotEmpty ||
                              _taskController
                                  .stringCrossesModelController.text.isNotEmpty
                          ? _stringCrossesColor()
                          : Container(),
                    ),
                    visible: isHybridStringing,
                  ),
                  Visibility(
                    child: MyInputField(
                        readOnly: true,
                        message: '',
                        suffixIcon: '',
                        keyboardType: TextInputType.text,
                        title: 'Type',
                        hint: _selectedCrossesStringType,
                        controller: _taskController.stringCrossesTypeController,
                        widget: SizedBox(
                          width: 120.w,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: DropdownButton(
                              isDense: true,
                              focusColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              dropdownColor: Get.isDarkMode
                                  ? dropdownClrDarkMode
                                  : dropdownClrLightMode,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              isExpanded: true,
                              // iconSize: folderPhoneWidth ? 35 : 32.sp,
                              iconSize: singleScreen ? 32.sp : 35,
                              elevation: 4,
                              underline: Container(height: 0),
                              onChanged: (String? newValue) {
                                setState(() {
                                  // _selectedCrossesStringType = newValue!;
                                  _selectedCrossesStringType = newValue!; // @수정
                                  _taskController.stringCrossesTypeController
                                      .text = _selectedCrossesStringType.tr;
                                });
                              },
                              // style: folderPhoneWidth ? folderPhoneSubTitleStyle : subTitleStyle,
                              style: singleScreen
                                  ? subTitleStyle
                                  : folderPhoneSubTitleStyle,
                              items: crossesStringTypeList
                                  .map<DropdownMenuItem<String>>(
                                      (String? value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value!.tr, // @tr추가
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )),
                    visible: isHybridStringing,
                  ),
                  Visibility(
                    child: MyInputField(
                        readOnly: true,
                        message: '',
                        suffixIcon: '',
                        keyboardType: TextInputType.text,
                        title: 'Shape',
                        hint: _selectedCrossesStringShape,
                        controller:
                            _taskController.stringCrossesShapeController,
                        widget: SizedBox(
                          width: 120.w,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: DropdownButton(
                              isDense: true,
                              focusColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              dropdownColor: Get.isDarkMode
                                  ? dropdownClrDarkMode
                                  : dropdownClrLightMode,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              isExpanded: true,
                              // iconSize: folderPhoneWidth ? 35 : 32.sp,
                              iconSize: singleScreen ? 32.sp : 35,
                              elevation: 4,
                              underline: Container(height: 0),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCrossesStringShape =
                                      newValue!; // @수정
                                  _taskController.stringCrossesShapeController
                                      .text = _selectedCrossesStringShape.tr;
                                });
                              },
                              // style: folderPhoneWidth ? folderPhoneSubTitleStyle : subTitleStyle,
                              style: singleScreen
                                  ? subTitleStyle
                                  : folderPhoneSubTitleStyle,
                              items: crossesStringShapeList
                                  .map<DropdownMenuItem<String>>(
                                      (String? value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value!.tr, // @ tr추가
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )),
                    visible: isHybridStringing,
                  ),
                  MyInputField(
                      readOnly: true,
                      message: '',
                      suffixIcon: '',
                      keyboardType: TextInputType.text,
                      title: 'Date',
                      hint: DateFormat.yMd().format(_selectedDate),
                      controller: _taskController.dateController,
                      widget: Padding(
                        padding: EdgeInsets.only(right: singleScreen ? 0 : 2.w),
                        child: IconButton(
                            onPressed: () {
                              // print('Hi there');
                              _getDateFromUser();
                            },
                            icon: Icon(Icons.calendar_today_outlined,
                                // color: Colors.grey, size: MediaQuery.of(context).size.width < 321 ? 22.sp : folderPhoneWidth ? 22 : 20.sp))),
                                color: Colors.grey,
                                size: MediaQuery.of(context).size.width < 321
                                    ? 22.sp
                                    : singleScreen
                                        ? 20.sp
                                        : 22)),
                      )),

                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // _colorPallete(),
                      // Text('Add String'),
                      Expanded(
                        child: MyButton(
                          label: widget.task != null ? 'Update' : 'Create',
                          // ***
                          // onTap: () => _validateDate(),
                          // onTap: () => isHybridStringing ? _validateDate() : _validateHybrid(),
                          onTap: () => isHybridStringing
                              ? _validateHybrid()
                              : _validateDate(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<ImageSource?> showImageSource(BuildContext context) async {
    return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (context) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                      Get.back();
                    },
                    child: Text('Camera')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      Get.back();
                    },
                    child: Text('Gallery')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      _taskController.delete(task!.image);
                      resetImage();
                      Get.back();
                    },
                    child: Text('Reset')),
              ],
            ));
  }

  buildMessageButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _validateDate();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      foregroundColor: Colors.white,
      backgroundColor: bluishClr,
      elevation: 0,
      icon: Icon(Icons.add),
      label: Text(widget.task != null ? 'Update' : 'Create'),
    );
  }

  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  _validateDate() async {
    if (widget.task != null) {
      Task task = widget.task!;
      DateTime taskDate = DateFormat('MM/dd/yyyy').parse(task.date!);
      if ((_taskController.racketBrandController.text != task.racketBrand ||
              _taskController.racketModelController.text != task.racketModel ||
              _taskController.stringBrandController.text != task.stringBrand ||
              _taskController.stringModelController.text != task.stringModel ||
              _taskController.stringTypeController.text !=
                  task.stringType!.tr || // tr 추가 시도
              _taskController.stringShapeController.text !=
                  task.stringShape!.tr || // tr 추가 시도
              _taskController.stringCrossesBrandController.text !=
                  task.stringCrossesBrand ||
              _taskController.stringCrossesModelController.text !=
                  task.stringCrossesModel ||
              _taskController.stringCrossesTypeController.text !=
                  task.stringCrossesType!.tr || // tr 추가 시도
              _taskController.stringCrossesShapeController.text !=
                  task.stringCrossesShape!.tr || // tr 추가 시도
              _taskController.headSizeController.text != task.headSize ||
              _selectedDate != taskDate ||
              _startTime != task.startTime ||
              _endTime != task.endTime ||
              _selectedRemind != task.remind ||
              _selectedColor != task.color ||
              _selectedCorssesColor != task.crossesColor ||
              _selectedRepeat != task.repeat ||
              isHybridStringing != task.hybridStringing ||
              image != null) &&
          (_taskController.racketBrandController.text.isNotEmpty &&
              _taskController.racketModelController.text.isNotEmpty &&
              _taskController.stringBrandController.text.isNotEmpty &&
              _taskController.stringModelController.text.isNotEmpty &&
              _taskController.stringTypeController.text.isNotEmpty &&
              _taskController.headSizeController.text.isNotEmpty &&
              _taskController.stringShapeController.text.isNotEmpty
          // image!.path.isNotEmpty // 여기를 지우면 업데이트가 되지만, 이미지가 사라짐
          )) {
        // update task in database
        await _updateTaskToDb();
        _backupController.saveTaskBackupPath();
        // _taskController.getTasks();
        Get.back();
      } else if (_taskController.racketBrandController.text.isEmpty ||
          _taskController.racketModelController.text.isEmpty ||
          _taskController.stringBrandController.text.isEmpty ||
          _taskController.stringModelController.text.isEmpty ||
          _taskController.stringTypeController.text.isEmpty ||
          _taskController.headSizeController.text.isEmpty ||
          _taskController.stringShapeController.text.isEmpty) {
        Get.snackbar('Required'.tr, 'All fields are required'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: darkGreyClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      } else {
        Get.snackbar('Required'.tr, 'Change something before updating'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: darkGreyClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      }
    } else {
      if (_taskController.racketBrandController.text.isNotEmpty &&
              _taskController.racketModelController.text.isNotEmpty &&
              _taskController.stringBrandController.text.isNotEmpty &&
              _taskController.stringModelController.text.isNotEmpty &&
              _taskController.stringTypeController.text.isNotEmpty &&
              _taskController.headSizeController.text.isNotEmpty &&
              _taskController.stringShapeController.text.isNotEmpty
          // && image != null
          ) {
        // add to database
        _addTaskToDb();
        _backupController.saveTaskBackupPath();

        _taskController.racketSaveDataToLocal(
            //@라켓 불러오기 추가
            RacketInfo(
              racketBrand: _taskController.racketBrandController.text,
              racketModel: _taskController.racketModelController.text,
              headSize: _taskController.headSizeController.text,
            ),
            false);

        _taskController.stringSaveDataToLocal(
            //@스트링 불러오기 추가
            StringInfo(
              stringBrand: _taskController.stringBrandController.text,
              stringModel: _taskController.stringModelController.text,
              stringType: _taskController.stringTypeController.text,
              stringShape: _taskController.stringShapeController.text,
            ),
            false);

        if (isHybridStringing) {
          _taskController.stringSaveDataToLocal(
              //@스트링 불러오기 추가
              StringInfo(
                stringBrand: _taskController.stringCrossesBrandController.text,
                stringModel: _taskController.stringCrossesModelController.text,
                stringType: _taskController.stringCrossesTypeController.text,
                stringShape: _taskController.stringCrossesShapeController.text,
              ),
              false);
        }
        // _taskController.crossesStringSaveDataToLocal(
        //   //@크로스 스트링 불러오기 추가
        //     CrossesStringInfo(
        //       stringCrossesBrand: _taskController.stringCrossesBrandController.text,
        //       stringCrossesModel: _taskController.stringCrossesModelController.text,
        //       stringCrossesType: _taskController.stringCrossesTypeController.text,
        //       stringCrossesShape: _taskController.stringCrossesShapeController.text,
        //     ),
        //     false);

        await _taskController.getTasks();
        Get.back();
      } else if (_taskController.racketBrandController.text.isEmpty ||
          _taskController.racketModelController.text.isEmpty ||
          _taskController.stringBrandController.text.isEmpty ||
          _taskController.stringModelController.text.isEmpty ||
          _taskController.stringTypeController.text.isEmpty ||
          _taskController.stringCrossesBrandController.text.isEmpty ||
          _taskController.stringCrossesModelController.text.isEmpty ||
          _taskController.stringCrossesTypeController.text.isEmpty ||
          _taskController.stringCrossesShapeController.text.isEmpty ||
          _taskController.headSizeController.text.isEmpty ||
          _taskController.stringShapeController.text.isEmpty) {
        Get.snackbar('Required'.tr, 'All fields are required'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: pinkClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      }
      // else if (image == null) {
      //   Get.snackbar('Required', 'Image is required to create task',
      //       snackPosition: SnackPosition.BOTTOM,
      //       backgroundColor:
      //           Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
      //       colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
      //       icon: const Icon(
      //         CupertinoIcons.exclamationmark_triangle,
      //         color: Colors.red,
      //       ));
      // }
    }
  }

  // @하이브리드 체크
  _validateHybrid() async {
    if (widget.task != null) {
      Task task = widget.task!;
      DateTime taskDate = DateFormat('MM/dd/yyyy').parse(task.date!);
      if ((_taskController.racketBrandController.text != task.racketBrand ||
              _taskController.racketModelController.text != task.racketModel ||
              _taskController.stringBrandController.text != task.stringBrand ||
              _taskController.stringModelController.text != task.stringModel ||
              _taskController.stringTypeController.text !=
                  task.stringType!.tr || // tr 추가 시도
              _taskController.stringShapeController.text !=
                  task.stringShape!.tr || // tr 추가 시도
              _taskController.stringCrossesBrandController.text !=
                  task.stringCrossesBrand ||
              _taskController.stringCrossesModelController.text !=
                  task.stringCrossesModel ||
              _taskController.stringCrossesTypeController.text !=
                  task.stringCrossesType!.tr || // tr 추가 시도
              _taskController.stringCrossesShapeController.text !=
                  task.stringCrossesShape!.tr || // tr 추가 시도
              _taskController.headSizeController.text != task.headSize ||
              _selectedDate != taskDate ||
              _startTime != task.startTime ||
              _endTime != task.endTime ||
              _selectedRemind != task.remind ||
              _selectedColor != task.color ||
              _selectedCorssesColor != task.crossesColor ||
              _selectedRepeat != task.repeat ||
              isHybridStringing != task.hybridStringing ||
              image != null) &&
          (_taskController.racketBrandController.text.isNotEmpty &&
              _taskController.racketModelController.text.isNotEmpty &&
              _taskController.stringBrandController.text.isNotEmpty &&
              _taskController.stringModelController.text.isNotEmpty &&
              _taskController
                  .stringTypeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController
                  .stringShapeController.text.tr.isNotEmpty && // tr 추가시도
              //---
              _taskController.stringCrossesBrandController.text.isNotEmpty &&
              _taskController.stringCrossesModelController.text.isNotEmpty &&
              _taskController
                  .stringCrossesTypeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController
                  .stringCrossesShapeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController.headSizeController.text.isNotEmpty)) {
        // update task in database
        await _updateTaskToDb();
        _backupController.saveTaskBackupPath();
        // _taskController.getTasks();
        Get.back();
      } else if (_taskController.racketBrandController.text.isEmpty ||
          _taskController.racketModelController.text.isEmpty ||
          _taskController.stringBrandController.text.isEmpty ||
          _taskController.stringModelController.text.isEmpty ||
          _taskController.stringTypeController.text.tr.isEmpty || // tr 추가시도
          _taskController.stringShapeController.text.tr.isEmpty || // tr 추가시도

          // ------
          _taskController.stringCrossesBrandController.text.isEmpty ||
          _taskController.stringCrossesModelController.text.isEmpty ||
          _taskController
              .stringCrossesTypeController.text.tr.isEmpty || // tr 추가시도
          _taskController
              .stringCrossesShapeController.text.tr.isEmpty || // tr 추가시도
          _taskController.headSizeController.text.isEmpty) {
        Get.snackbar('Required'.tr, 'All fields are required'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: darkGreyClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      } else {
        Get.snackbar('Required'.tr, 'Change something before updating'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: darkGreyClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      }
    } else {
      if (_taskController.racketBrandController.text.isNotEmpty &&
              _taskController.racketModelController.text.isNotEmpty &&
              _taskController.stringBrandController.text.isNotEmpty &&
              _taskController.stringModelController.text.isNotEmpty &&
              _taskController
                  .stringTypeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController
                  .stringShapeController.text.tr.isNotEmpty && // tr 추가시도

              //----
              _taskController.stringCrossesBrandController.text.isNotEmpty &&
              _taskController.stringCrossesModelController.text.isNotEmpty &&
              _taskController
                  .stringCrossesTypeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController
                  .stringCrossesShapeController.text.tr.isNotEmpty && // tr 추가시도
              _taskController.headSizeController.text.isNotEmpty
          // && image != null
          ) {
        // add to database
        _addTaskToDb();
        _backupController.saveTaskBackupPath();

        _taskController.racketSaveDataToLocal(
            //@라켓 불러오기 추가
            RacketInfo(
              racketBrand: _taskController.racketBrandController.text,
              racketModel: _taskController.racketModelController.text,
              headSize: _taskController.headSizeController.text,
            ),
            false);

        _taskController.stringSaveDataToLocal(
            //@스트링 불러오기 추가
            StringInfo(
              stringBrand: _taskController.stringBrandController.text,
              stringModel: _taskController.stringModelController.text,
              stringType: _taskController.stringTypeController.text,
              stringShape: _taskController.stringShapeController.text,
            ),
            false);

        if (isHybridStringing) {
          _taskController.stringSaveDataToLocal(
              //@스트링 불러오기 추가
              StringInfo(
                stringBrand: _taskController.stringCrossesBrandController.text,
                stringModel: _taskController.stringCrossesModelController.text,
                stringType: _taskController.stringCrossesTypeController.text,
                stringShape: _taskController.stringCrossesShapeController.text,
              ),
              false);
        }
        // _taskController.crossesStringSaveDataToLocal(
        //   //@크로스 스트링 불러오기 추가
        //     CrossesStringInfo(
        //         stringCrossesBrand: _taskController.stringCrossesBrandController.text,
        //         stringCrossesModel: _taskController.stringCrossesModelController.text,
        //         stringCrossesType: _taskController.stringCrossesTypeController.text,
        //         stringCrossesShape: _taskController.stringCrossesShapeController.text,
        //     ),
        //     false);

        await _taskController.getTasks();
        Get.back();
      } else if (_taskController.racketBrandController.text.isEmpty ||
          _taskController.racketModelController.text.isEmpty ||
          _taskController.stringBrandController.text.isEmpty ||
          _taskController.stringModelController.text.isEmpty ||
          _taskController.stringTypeController.text.tr.isEmpty || // tr 추가시도
          _taskController.stringShapeController.text.tr.isEmpty || // tr 추가시도
          _taskController.stringCrossesBrandController.text.isEmpty ||
          _taskController.stringCrossesModelController.text.isEmpty ||
          _taskController
              .stringCrossesTypeController.text.tr.isEmpty || // tr 추가시도
          _taskController
              .stringCrossesShapeController.text.tr.isEmpty || // tr 추가시도
          _taskController.headSizeController.text.isEmpty) {
        Get.snackbar('Required'.tr, 'All fields are required'.tr,
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.white,
            backgroundColor:
                Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            // colorText: pinkClr,
            colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
            icon: const Icon(
              // Icons.warning_amber_rounded,
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
            ));
      }
      // else if (image == null) {
      //   Get.snackbar('Required', 'Image is required to create task',
      //       snackPosition: SnackPosition.BOTTOM,
      //       backgroundColor:
      //           Get.isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
      //       colorText: Get.isDarkMode ? darkGreyClr : Colors.white70,
      //       icon: const Icon(
      //         CupertinoIcons.exclamationmark_triangle,
      //         color: Colors.red,
      //       ));
      // }
    }
  }

  _addTaskToDb() async {
    Uint8List imageList = Uint8List(0);
    if (image != null) {
      imageList = await image!.readAsBytes();
    }

    String stringType = ""; //@translate
    String stringCrossesType = "";
    String stringShape = "";
    String stringCrossesShape = "";

    int value = await _taskController.addTask(
        task: Task(
      // image: image?.path,
      image: Utility.base64String(imageList),
      racketBrand: _taskController.racketBrandController.text,
      racketModel: _taskController.racketModelController.text,
      stringBrand: _taskController.stringBrandController.text,
      stringModel: _taskController.stringModelController.text,
      stringType: _taskController.stringTypeController.text,
      stringCrossesBrand: _taskController.stringCrossesBrandController.text,
      stringCrossesModel: _taskController.stringCrossesModelController.text,
      stringCrossesType: _taskController.stringCrossesTypeController.text,
      stringCrossesShape: _taskController.stringCrossesShapeController.text,
      headSize: _taskController.headSizeController.text,
      stringShape: _taskController.stringShapeController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      crossesColor: _selectedCorssesColor,
      recordTime: DateTime.now().millisecondsSinceEpoch,
      isCompleted: 0,
      hybridStringing: isHybridStringing,
    ));
    // print('My id is ' '$value');
  }

  String shapeTypeLanguageConverter(String controllerText) {
    String shapeType = "";

    if (controllerText == "丸みのあるストリング" ||
        controllerText == "원형 스트링" ||
        controllerText == "Rounded String") {
      shapeType = "Rounded String";
    } else if (controllerText == "形状のあるストリング" ||
        controllerText == "각 스트링" ||
        controllerText == "Shaped String") {
      shapeType = "Shaped String";
    } else {
      // shapeType = "None";
      shapeType = ""; // @수정 add string에서 None 비활성화
    }

    return shapeType;
  }

  Future<void> _updateTaskToDb() async {
    Uint8List imageList = Uint8List(0);
    if (image == null) {
      imageList = Utility.dataFromBase64String(widget.task!.image!);
    } else {
      imageList = await image!.readAsBytes();
    }

    String stringType = ""; //@translate
    String stringCrossesType = "";
    String stringShape = "";
    String stringCrossesShape = "";

    int value = await _taskController.updateTask(
      task: Task(
        id: widget.task?.id,
        // image: image?.path,
        image: Utility.base64String(imageList),
        racketBrand: _taskController.racketBrandController.text,
        racketModel: _taskController.racketModelController.text,
        stringBrand: _taskController.stringBrandController.text,
        stringModel: _taskController.stringModelController.text,
        stringType: stringType,
        stringCrossesBrand: _taskController.stringCrossesBrandController.text,
        stringCrossesModel: _taskController.stringCrossesModelController.text,
        stringCrossesType: stringCrossesType,
        stringCrossesShape: stringCrossesShape,
        headSize: _taskController.headSizeController.text,
        stringShape: stringShape,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        crossesColor: _selectedCorssesColor,
        recordTime: DateTime.now().millisecondsSinceEpoch,
        isCompleted: 0,
        hybridStringing: isHybridStringing,
        averageRating: widget.task!.averageRating,
      ),
    );
    // print('My id is ' '$value');
  }

  _showColor() {
    return _taskController.stringModelController.text.isNotEmpty
        ? _stringColor()
        : Container();
  }

  _stringColor() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: GestureDetector(
        onTap: () =>
            showCupertinoDialog(context: this.context, builder: createDialog),
        child: CircleAvatar(
          radius: 12.r,
          backgroundColor: Colors.grey[500],
          child: CircleAvatar(
            // radius: _selectedColor == 13
            radius: _selectedColor == 14
                ? (Get.isDarkMode ? 11.r : 12.r)
                // : _selectedColor == 14
                : _selectedColor == 15
                    ? (Get.isDarkMode ? 12.r : 11.r)
                    : null,
            backgroundColor: _selectedColor == 0
                ? redClr
                : _selectedColor == 1
                    ? pinkClr
                    : _selectedColor == 2
                        ? redOrangeClr
                        : _selectedColor == 3
                            ? OrangeClr
                            : _selectedColor == 4
                                ? yellow2Clr
                                : _selectedColor == 5
                                    ? yellowClr
                                    : _selectedColor == 6
                                        ? lightGreen
                                        : _selectedColor == 7
                                            ? greenClr
                                            : _selectedColor == 8
                                                ? blueGreenClr
                                                : _selectedColor == 9
                                                    ? skyClr
                                                    : _selectedColor == 10
                                                        ? bluishClr
                                                        : _selectedColor == 11
                                                            ? blueClr
                                                            : _selectedColor ==
                                                                    12
                                                                ? purpleClr
                                                                : _selectedColor ==
                                                                        13
                                                                    ? greyClr
                                                                    : _selectedColor ==
                                                                            14
                                                                        ? darkBlackClr
                                                                        : _selectedColor ==
                                                                                15
                                                                            ? white
                                                                            : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget createDialog(BuildContext context) =>
      StatefulBuilder(builder: (context, bSetState) {
        bool singleScreen = MediaQuery.of(context).hinge == null &&
            MediaQuery.of(context).size.width < 1000;
        // print(MediaQuery.of(context).size.width);
        return CupertinoAlertDialog(
          title: Text('String Color'.tr,
              // style: TextStyle(fontSize: singleScreen ? 20.sp : 22),
              style: singleScreen ? dialogTitleStyle : dialogSingleTitleStyle),
          content: Padding(
            padding: EdgeInsets.only(
                left: 12.w, right: 12.w, top: singleScreen ? 10.w : 5.w),
            child: Center(
              child: Wrap(
                children: List<Widget>.generate(16, (int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        bSetState(() {
                          _selectedColor = index;
                          debugPrint('$index');
                          // print('$index');
                        });
                      });
                    },
                    child: Padding(
                      // padding: EdgeInsets.only(left: 10.w, right: 1.w, top: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.grey[500],
                        child: CircleAvatar(
                          // radius: 15,
                          // radius: index == 13
                          radius: index == 14
                              ? (Get.isDarkMode ? 14.r : 15.r)
                              // : index == 14
                              : index == 15
                                  ? 15.r
                                  : 15.r,
                          backgroundColor: index == 0
                              ? redClr
                              : index == 1
                                  ? pinkClr
                                  : index == 2
                                      ? redOrangeClr
                                      : index == 3
                                          ? OrangeClr
                                          : index == 4
                                              ? yellow2Clr
                                              : index == 5
                                                  ? yellowClr
                                                  : index == 6
                                                      ? lightGreen
                                                      : index == 7
                                                          ? greenClr
                                                          : index == 8
                                                              ? blueGreenClr
                                                              : index == 9
                                                                  ? skyClr
                                                                  : index == 10
                                                                      ? bluishClr
                                                                      : index ==
                                                                              11
                                                                          ? blueClr
                                                                          : index == 12
                                                                              ? purpleClr
                                                                              : index == 13
                                                                                  ? greyClr
                                                                                  : index == 14
                                                                                      ? darkBlackClr
                                                                                      : index == 15
                                                                                          ? white
                                                                                          : Colors.grey,
                          child: _selectedColor == index
                              ? Icon(
                                  Icons.done,
                                  color:
                                      // _selectedColor == 14 ? darkBlackClr : white,
                                      _selectedColor == 15
                                          ? darkBlackClr
                                          : white,
                                  // size: 16.sp,
                                  size: singleScreen ? 16 : 16.sp,
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'.tr,
                  /*
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 322
                          ? 14
                          : singleScreen
                              ? 16
                              : 18.w)),
              */
                  style: MediaQuery.of(context).size.width < 322
                      ? dialogSmallYesStyle
                      : singleScreen
                          ? dialogYesStyle
                          : dialogSingleYesStyle),
              onPressed: () {
                Get.back();
              },
            )
          ],
        );
      });

  _stringCrossesColor() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: GestureDetector(
        onTap: () => showCupertinoDialog(
            context: this.context, builder: createCrossesDialog),
        child: CircleAvatar(
          radius: 12.r,
          backgroundColor: Colors.grey[500],
          child: CircleAvatar(
            radius: _selectedCorssesColor == 14
                ? (Get.isDarkMode ? 11.r : 12.r)
                : _selectedCorssesColor == 15
                    ? (Get.isDarkMode ? 12.r : 11.r)
                    : null,
            backgroundColor: _selectedCorssesColor == 0
                ? redClr
                : _selectedCorssesColor == 1
                    ? pinkClr
                    : _selectedCorssesColor == 2
                        ? redOrangeClr
                        : _selectedCorssesColor == 3
                            ? OrangeClr
                            : _selectedCorssesColor == 4
                                ? yellow2Clr
                                : _selectedCorssesColor == 5
                                    ? yellowClr
                                    : _selectedCorssesColor == 6
                                        ? lightGreen
                                        : _selectedCorssesColor == 7
                                            ? greenClr
                                            : _selectedCorssesColor == 8
                                                ? blueGreenClr
                                                : _selectedCorssesColor == 9
                                                    ? skyClr
                                                    : _selectedCorssesColor ==
                                                            10
                                                        ? bluishClr
                                                        : _selectedCorssesColor ==
                                                                11
                                                            ? blueClr
                                                            : _selectedCorssesColor ==
                                                                    12
                                                                ? purpleClr
                                                                : _selectedCorssesColor ==
                                                                        13
                                                                    ? greyClr
                                                                    : _selectedCorssesColor ==
                                                                            14
                                                                        ? darkBlackClr
                                                                        : _selectedCorssesColor ==
                                                                                15
                                                                            ? white
                                                                            : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget createCrossesDialog(BuildContext context) =>
      StatefulBuilder(builder: (context, bSetState) {
        bool singleScreen = MediaQuery.of(context).hinge == null &&
            MediaQuery.of(context).size.width < 1000;
        return CupertinoAlertDialog(
          title: Text('String Color'.tr,
              // style: TextStyle(fontSize: singleScreen ? 20.sp : 22),
              style: singleScreen ? dialogTitleStyle : dialogSingleTitleStyle),
          content: Center(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 12.w, right: 12.w, top: singleScreen ? 10.w : 5.w),
              child: Wrap(
                children: List<Widget>.generate(16, (int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        bSetState(() {
                          _selectedCorssesColor = index;
                          debugPrint('$index');
                          // print('$index');
                        });
                      });
                    },
                    child: Padding(
                      // padding: EdgeInsets.only(left: 16.w, right: 1.w, top: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.grey[500],
                        child: CircleAvatar(
                          // radius: index == 13
                          radius: index == 14
                              ? (Get.isDarkMode ? 14.r : 15.r)
                              // : index == 14
                              : index == 15
                                  ? 15.r
                                  : 15.r,
                          backgroundColor: index == 0
                              ? redClr
                              : index == 1
                                  ? pinkClr
                                  : index == 2
                                      ? redOrangeClr
                                      : index == 3
                                          ? OrangeClr
                                          : index == 4
                                              ? yellow2Clr
                                              : index == 5
                                                  ? yellowClr
                                                  : index == 6
                                                      ? lightGreen
                                                      : index == 7
                                                          ? greenClr
                                                          : index == 8
                                                              ? blueGreenClr
                                                              : index == 9
                                                                  ? skyClr
                                                                  : index == 10
                                                                      ? bluishClr
                                                                      : index ==
                                                                              11
                                                                          ? blueClr
                                                                          : index == 12
                                                                              ? purpleClr
                                                                              : index == 13
                                                                                  ? greyClr
                                                                                  : index == 14
                                                                                      ? darkBlackClr
                                                                                      : index == 15
                                                                                          ? white
                                                                                          : Colors.grey,
                          child: _selectedCorssesColor == index
                              ? Icon(
                                  Icons.done,
                                  color: _selectedCorssesColor == 15
                                      ? darkBlackClr
                                      : white,
                                  // size: 16.sp,
                                  size: singleScreen ? 16 : 16.sp,
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'.tr,
                  /*
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 322
                          ? 14
                          : singleScreen
                              ? 16
                              : 18.w)),
              */
                  style: MediaQuery.of(context).size.width < 322
                      ? dialogSmallYesStyle
                      : singleScreen
                          ? dialogYesStyle
                          : dialogSingleYesStyle),
              onPressed: () {
                Get.back();
              },
            )
          ],
        );
      });

  _colorPallete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: titleStyle,
        ),
        SizedBox(height: 8.h),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                  debugPrint('$index');
                  // print('$index');
                });
              },
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : yellowClr,
                  child: _selectedColor == index
                      ? Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 16.sp,
                        )
                      : Container(),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  _appBar(BuildContext context) {
    bool singleScreen = MediaQuery.of(context).hinge == null &&
        MediaQuery.of(context).size.width < 1000;
    final folderPhoneWidth = MediaQuery.of(context).size.width > 500;
    return AppBar(
      centerTitle: true,
      title: Text(
        widget.task != null ? 'Edit'.tr : 'Add'.tr,
        style: TextStyle(color: Get.isDarkMode ? white : darkGreyClr),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: singleScreen ? EdgeInsets.zero : EdgeInsets.only(left: 20.w),
          child: Icon(
            Icons.arrow_back_ios,
            // size: folderPhoneWidth ? 20 : 20.sp,
            size: singleScreen ? 20.sp : 20,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      // actions: [
      //   InkWell(
      //     child: Icon(
      //       // Icons.bar_chart,
      //       CupertinoIcons.chart_bar_alt_fill,
      //       color: Get.isDarkMode ? Colors.white : Colors.black,
      //     ),
      //     onTap: () async {
      //       await Get.to(() => const ChartsPage());
      //       Get.back();
      //     },
      //   ),
      //   const SizedBox(
      //     width: 20,
      //   ),
      // ],
    );
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showRoundedDatePicker(
      context: this.context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2099),
      borderRadius: 16,
      height: MediaQuery.of(this.context).size.height * 0.42,
      customWeekDays: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"],
      // theme: ThemeData.dark(),
      // theme: ThemeData(
      //   primaryColor: Get.isDarkMode ? Colors.grey.shade200 : blueClr,
      //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
      //       .copyWith(secondary: Colors.black),
      // ),
      theme: ThemeData(
        // primaryColor: Get.isDarkMode ? Colors.black45 : blueClr,
        // primaryColor: Get.isDarkMode ? Color(0xFF191919) : blueClr,
        // primaryColor: Get.isDarkMode ? Color(0xFF191919) : Color(0xFF296694),
        primaryColor: Get.isDarkMode ? Color(0xFF191919) : primaryClr,
        // accentColor: Get.isDarkMode ? Color(0xFF296694) : Color(0xFF296694),
        accentColor: primaryClr,
        // dialogBackgroundColor: Get.isDarkMode ? Color(0xFF4B4C4C) : Colors.white,
        dialogBackgroundColor:
            Get.isDarkMode ? Color(0xFF272A2A) : Colors.white,
        textTheme: TextTheme(
          caption: TextStyle(
              color: Get.isDarkMode ? Colors.white38 : Colors.black87),
        ),
      ),
      styleYearPicker: MaterialRoundedYearPickerStyle(
          textStyleYear:
              TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr)),
      styleDatePicker: MaterialRoundedDatePickerStyle(
          colorArrowNext: Get.isDarkMode ? Colors.white54 : darkGreyClr,
          colorArrowPrevious: Get.isDarkMode ? Colors.white54 : darkGreyClr,
          textStyleMonthYearHeader:
              TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr),
          // textStyleDayOnCalendar: TextStyle(color: Get.isDarkMode ? Colors.white54 : Colors.black45),
          textStyleDayOnCalendar: TextStyle(
              color: Get.isDarkMode ? Colors.white70 : Colors.black45),
          paddingMonthHeader: EdgeInsets.all(10),
          textStyleButtonNegative:
              TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr),
          textStyleButtonPositive:
              TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr)),
    );

    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
        _taskController.dateController.text =
            DateFormat.yMd().format(_selectedDate);
        // debugPrint(_selectedDate);
        // print(_selectedDate);
      });
    } else {
      debugPrint("it's null or something is wrong");
      // print("it's null or something is wrong");
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker(isStartTime);
    String formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      debugPrint('Time canceld');
      // print('Time canceld');
    } else if (isStartTime == true) {
      setState(() {
        _startTime = formatedTime;
        _taskController.startTimeController.text = formatedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = formatedTime;
        _taskController.endTimeController.text = formatedTime;
      });
    }
  }

  _showTimePicker(bool isStartTime) {
    DateTime dateTime = DateFormat.jm().parse(widget.task != null
        ? isStartTime
            ? _startTime
            : _endTime
        : _startTime);
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: this.context,
      initialTime: TimeOfDay(
        hour: dateTime.hour,
        minute: dateTime.minute,
      ),
    );
  }
}
