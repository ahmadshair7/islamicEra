import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/permission_service.dart';
import '../../../data/services/share_service.dart';

/// Share Location Screen
/// Allows users to share their GPS location via Gmail and WhatsApp
/// Features: Islamic theme, Google Maps, animated UI elements
class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen>
    with SingleTickerProviderStateMixin {
  // Services
  final LocationService _locationService = LocationService();
  final PermissionService _permissionService = PermissionService();
  final ShareService _shareService = ShareService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  // State
  bool _isLoadingLocation = false;
  bool _isSending = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  String? _errorMessage;
  String? _successMessage;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Default map position (Makkah)
  static const LatLng _defaultPosition = LatLng(21.4225, 39.8262);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Get current location with permission handling
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Check and request permission
    final permissionResult = await _permissionService.requestLocationPermission();

    if (!permissionResult.isGranted) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = permissionResult.message;
      });

      if (permissionResult.isPermanentlyDenied) {
        _showSettingsDialog();
      }
      return;
    }

    // Get location
    try {
      final position = await _locationService.getCurrentPosition();
      
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _successMessage = 'Location fetched successfully!';
        
        // Add marker
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        };
      });

      // Animate camera to position
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Show dialog to open app settings
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange.shade700),
            const SizedBox(width: 10),
            const Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Location permission is required to share your location. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Validate input fields
  String? _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter the recipient\'s name.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter an email address.';
    }
    if (!_shareService.isValidEmail(_emailController.text.trim())) {
      return 'Please enter a valid email address.';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Please enter a WhatsApp phone number.';
    }
    if (!_shareService.isValidPhoneNumber(_phoneController.text.trim())) {
      return 'Please enter a valid phone number (digits only, e.g., 919876543210).';
    }
    if (_currentPosition == null) {
      return 'Please get your current location first.';
    }
    return null;
  }

  /// Send location via Gmail and WhatsApp
  Future<void> _sendLocation() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final locationUrl = _locationService.generateGoogleMapsUrl(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final result = await _shareService.sendLocation(
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      recipientName: _nameController.text.trim(),
      locationUrl: locationUrl,
    );

    setState(() {
      _isSending = false;
      if (result.success) {
        _successMessage = result.message;
      } else {
        _errorMessage = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(child: _buildHeader()),
                  
                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Input Fields
                          _buildInputSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Get Location Button
                          _buildGetLocationButton(),
                          
                          const SizedBox(height: 24),
                          
                          // Google Map
                          _buildMapSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Messages
                          if (_errorMessage != null) _buildErrorMessage(),
                          if (_successMessage != null) _buildSuccessMessage(),
                          
                          const SizedBox(height: 16),
                          
                          // Send Location Button
                          _buildSendButton(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Share Location',
                    style: GoogleFonts.amiri(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بِسْمِ اللَّهِ',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipient Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 20),
          
          // Full Name
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            hint: 'Enter recipient\'s name',
          ),
          const SizedBox(height: 16),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            hint: 'Enter Gmail address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'WhatsApp Number',
            icon: Icons.phone_outlined,
            hint: 'e.g., 919876543210 (no + symbol)',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGetLocationButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFC4A030)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoadingLocation ? null : _getCurrentLocation,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A1A1A),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location, color: Color(0xFF1A1A1A)),
                      const SizedBox(width: 10),
                      Text(
                        'Get Current Location',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _defaultPosition,
            zoom: _currentPosition != null ? 16.0 : 5.0,
          ),
          markers: _markers,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSending ? null : _sendLocation,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'Send Location',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
