import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/profile_picture_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/data/models/profile_update_request.dart';
import '../../../../core/routing/routes.dart';
import '../../cubit/profile_cubit.dart';
import '../../../../core/di/dependency_injection.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female'];

  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();
  late final ProfilePictureService _profilePictureService;

  @override
  void initState() {
    super.initState();
    _profilePictureService = DependencyInjection.get<ProfilePictureService>();

    _selectedImageFile = _profilePictureService.profilePicture;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final user = authState.user;
      LoggerService.logAuth(
        'Loading user data: ${user.name}, ${user.email}, ${user.phone}, ${user.gender}',
      );
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _selectedGender = user.genderAsString;
      LoggerService.logAuth('Selected gender: $_selectedGender');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, Routes.homeScreen);
            }
          });
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthSuccess) {
            _loadUserData();
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return Scaffold(
              backgroundColor: ColorsManager.background,
              appBar: _buildAppBar(),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePictureSection(),
                      SizedBox(height: 20.h),
                      _buildPersonalInfoForm(),
                      SizedBox(height: 24.h),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ColorsManager.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Personal Information',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                margin: EdgeInsets.only(
                  left: 8.w,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.lightBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                          _selectedImageFile!,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.person,
                          size: 50.w,
                          color: ColorsManager.primaryBlue,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: ColorsManager.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: _changeProfilePicture,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Tap to change profile picture',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'You can update your name and phone number below',
              style: TextStyle(
                fontSize: 13.sp,
                color: ColorsManager.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),

            AppTextFormField(
              controller: _nameController,
              hintText: 'Enter your full name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextFormField(
                controller: _emailController,
                enabled: false,
                style: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            AppTextFormField(
              controller: _phoneController,
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                final cleanPhone = value.replaceAll(RegExp('[^0-9]'), '');
                if (cleanPhone.isEmpty || cleanPhone.length > 11) {
                  return 'Phone number must be between 1-11 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(color: ColorsManager.inputBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      items: _genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: ColorsManager.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedGender = newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileUpdateLoading;

        return SizedBox(
          width: double.maxFinite,
          height: 56.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.w),
              ),
              elevation: 0,
              padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _changeProfilePicture() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        final croppedFile = await _cropImage(pickedFile.path);

        if (croppedFile != null && mounted) {
          final imageFile = File(croppedFile.path);
          setState(() {
            _selectedImageFile = imageFile;
          });

          _profilePictureService.setProfilePicture(imageFile);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: ColorsManager.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: true,
          ),
        ],
      );
      return croppedFile;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cleanPhone = _phoneController.text.replaceAll(
          RegExp('[^0-9]'),
          '',
        );

        final String formattedPhone = cleanPhone;

        LoggerService.logAuth(
          'Phone number before cleaning: ${_phoneController.text}',
        );
        LoggerService.logAuth('Phone number after cleaning: $cleanPhone');
        LoggerService.logAuth('Phone number formatted: $formattedPhone');
        LoggerService.logAuth('Phone number length: ${formattedPhone.length}');

        final currentUser =
            (context.read<AuthCubit>().state as AuthSuccess).user;
        final currentGender = currentUser.gender.toLowerCase() == 'male'
            ? 0
            : 1;
        final newGender = _selectedGender.toLowerCase() == 'male' ? 0 : 1;

        final changedFields = <String, dynamic>{};

        if (_nameController.text.trim() != currentUser.name) {
          changedFields['name'] = _nameController.text.trim();
        }
        if (formattedPhone != currentUser.phone) {
          changedFields['phone'] = formattedPhone;
        }
        if (_selectedGender.toLowerCase() != currentUser.gender.toLowerCase()) {
          changedFields['gender'] = newGender;
        }

        Map<String, dynamic> updateData;
        String updateType;

        if (changedFields.containsKey('name') &&
            changedFields.containsKey('phone')) {
          updateData = ProfileUpdateRequest.getNamePhoneUpdate(
            newName: _nameController.text.trim(),
            newPhone: formattedPhone,
            currentGender: currentGender,
            currentEmail: currentUser.email,
            userId: currentUser
                .id,
          );
          updateType = 'name and phone';
        } else if (changedFields.containsKey('name')) {
          updateData = ProfileUpdateRequest.getNameUpdate(
            newName: _nameController.text.trim(),
            currentPhone: currentUser.phone,
            currentGender: currentGender,
            currentEmail: currentUser.email,
            userId: currentUser
                .id,
          );
          updateType = 'name only';
        } else if (changedFields.containsKey('phone')) {
          updateData = ProfileUpdateRequest.getPhoneUpdate(
            currentName: currentUser.name,
            newPhone: formattedPhone,
            currentGender: currentGender,
            currentEmail: currentUser.email,
            userId: currentUser
                .id,
          );
          updateType = 'phone only';
        } else {
          updateData = {};
          updateType = 'none';
        }

        LoggerService.logAuth(
          'Current user data: ${currentUser.name}, ${currentUser.email}, ${currentUser.phone}, ${currentUser.gender}',
        );
        LoggerService.logAuth('Changed fields only: $changedFields');
        LoggerService.logAuth('Update type: $updateType');
        LoggerService.logAuth('Smart update data (no email): $updateData');

        if (_nameController.text.trim().isEmpty || formattedPhone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in name and phone number'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (formattedPhone.isEmpty || formattedPhone.length > 11) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number must be between 1-11 digits'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (changedFields.isNotEmpty) {
          LoggerService.logAuth(
            'Fields changed: $changedFields, sending $updateType update to VCare API',
          );
          context.read<ProfileCubit>().updateProfilePartial(updateData);
        } else {
          LoggerService.logAuth('No fields changed, skipping update');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes detected'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
