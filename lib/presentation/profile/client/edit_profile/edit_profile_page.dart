import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/head_bar.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/request/client/client_request_model.dart';
import 'package:foody/data/models/response/client/client_response_model.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/presentation/camera/bloc/camera_bloc.dart';
import 'package:foody/presentation/camera/bloc/camera_page.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final int clientId;

  const EditProfilePage({super.key, required this.clientId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  File? _profileImageFile;
  ClientResponseModel? _currentClient;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPasswordVisible = false;
  bool _imageRemoved = false;
  String? _selectedGender;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientData() async {
    setState(() => _isLoading = true);
    final result = await context.read<ClientRepository>().getClientById(
          widget.clientId,
        );
    result.fold(
      (error) => setState(() {
        _isLoading = false;
        _errorMessage = error;
      }),
      (client) {
        _currentClient = client;
        _nameController.text = client.name ?? '';
        _usernameController.text = client.username ?? '';
        _emailController.text = client.email ?? '';
        _selectedGender = client.gender;
        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
        _imageRemoved = false;
      });
    }
  }

  Future<void> _takePicture() async {
    Navigator.pop(context);
    final imageFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => CameraBloc()..add(InitializeCamera()),
          child: const CameraPage(),
        ),
      ),
    );

    if (imageFile != null) {
      setState(() {
        _profileImageFile = imageFile;
        _imageRemoved = false;
      });
    }
  }

  void _removePicture() {
    Navigator.pop(context);
    setState(() {
      _profileImageFile = null;
      _imageRemoved = true;
    });
  }

  // DIUBAH: Pop-up disederhanakan dengan menghapus pratinjau avatar
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252525),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildListTile(
                title: 'Choose from library',
                assetPath: 'assets/icons/picture.svg',
                onTap: _pickImageFromGallery,
              ),
              _buildListTile(
                title: 'Take photo',
                assetPath: 'assets/icons/camera.svg',
                onTap: _takePicture,
              ),
              _buildListTile(
                title: 'Remove current picture',
                assetPath: 'assets/icons/trash.svg',
                onTap: _removePicture,
                isDestructive: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildListTile({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.white;
    return ListTile(
      leading: SvgPicture.asset(
        assetPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      onTap: onTap,
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak cocok!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? base64Image;
    if (_imageRemoved) {
      base64Image = '';
    } else if (_profileImageFile != null) {
      final bytes = await _profileImageFile!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final requestModel = ClientRequestModel(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      gender: _selectedGender,
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
      imgProfile: base64Image,
    );

    final result = await context.read<ClientRepository>().updateClient(
          widget.clientId,
          requestModel,
        );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      },
    );

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HeadBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/iconsBack.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleText: 'Edit Profile',
        currentRoute: '/editProfile',
        onTabSelected: (_) {},
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          _buildProfilePicture(radius: 50),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showImageSourceActionSheet,
            child: const Text(
              'Edit Picture',
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(label: 'Name', controller: _nameController),
          _buildTextField(label: 'Username', controller: _usernameController),
          _buildTextField(label: 'Email', controller: _emailController),
          _buildGenderDropdown(),
          _buildPasswordField(
            label: 'Password Baru',
            controller: _passwordController,
            hint: 'Kosongkan jika tidak ganti',
          ),
          _buildPasswordField(
            label: 'Konfirmasi',
            controller: _confirmPasswordController,
            hint: 'Konfirmasi password baru',
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  // DIUBAH: Widget ini sekarang menggunakan Image.memory untuk menampilkan data base64
  Widget _buildProfilePicture({required double radius}) {
    ImageProvider? backgroundImage;
    if (_profileImageFile != null) {
      backgroundImage = FileImage(_profileImageFile!);
    } else if (!_imageRemoved &&
        _currentClient?.imgProfile != null &&
        _currentClient!.imgProfile!.isNotEmpty) {
      try {
        backgroundImage = MemoryImage(base64Decode(_currentClient!.imgProfile!));
      } catch (e) {
        print("Error decoding base64 image in EditProfilePage: $e");
        backgroundImage = null;
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[800],
      backgroundImage: backgroundImage,
      child: backgroundImage == null
          ? SvgPicture.asset(
              'assets/icons/profile_fill.svg',
              height: radius,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }

  // Sisa kode di bawah ini tidak ada perubahan
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              style: TextStyle(
                color: readOnly ? Colors.grey[400] : Colors.white,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 8, top: 4),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              'Gender',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (String? newValue) {
                setState(() => _selectedGender = newValue);
              },
              selectedItemBuilder: (BuildContext context) {
                return <String>['L', 'P'].map<Widget>((String item) {
                  return Text(
                    item == 'L' ? 'Laki-laki' : 'Perempuan',
                    style: const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
              items: const [
                DropdownMenuItem(
                  value: 'L',
                  child: Text(
                    'Laki-laki',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: 'P',
                  child: Text(
                    'Perempuan',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
