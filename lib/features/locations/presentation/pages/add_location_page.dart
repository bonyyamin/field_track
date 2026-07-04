import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/geofence_radius_slider.dart';
import '../widgets/map_placeholder_widget.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController(text: '25.2048');
  final TextEditingController _lngController = TextEditingController(text: '55.2708');

  late double _radiusM;
  bool _isActive = true;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    final defaultRadius = context.read<SettingsCubit>().state.defaultGeofenceRadius;
    _radiusM = defaultRadius.toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location services are disabled.'),
              action: SnackBarAction(
                label: 'Enable',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions are permanently denied.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _latController.text = position.latitude.toStringAsFixed(4);
      _lngController.text = position.longitude.toStringAsFixed(4);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current location captured!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _onSaveLocation() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
    final lng = double.tryParse(_lngController.text.trim()) ?? 0.0;

    final location = LocationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationName: name,
      latitude: lat,
      longitude: lng,
      radiusM: _radiusM,
      isActive: _isActive,
    );

    context.read<LocationBloc>().add(AddLocation(location));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inputBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New location',
          style: AppTextStyles.h2.copyWith(color: titleColor, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            );
            context.pop();
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorLight,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Preview Widget
                MapPlaceholderWidget(radiusM: _radiusM),
                const SizedBox(height: 16),
                // "Use my current location" Outlined Button with dashed look
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isGettingLocation ? null : _fetchCurrentLocation,
                    icon: _isGettingLocation
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          )
                        : Icon(Icons.my_location, color: primaryColor, size: 20),
                    label: Text(
                      'Use my current location',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Location Name Field
                Text(
                  'Location name',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.bodyMedium.copyWith(color: titleColor),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please enter location name' : null,
                  decoration: _inputDecoration(
                    hintText: 'e.g. Downtown Branch',
                    inputBg: inputBg,
                    borderColor: borderColor,
                    titleColor: titleColor,
                    labelColor: labelColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Latitude & Longitude Side-by-Side
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: labelColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _latController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(color: titleColor),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(
                              hintText: '25.2048',
                              inputBg: inputBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              labelColor: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Longitude',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: labelColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lngController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(color: titleColor),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Required' : null,
                            decoration: _inputDecoration(
                              hintText: '55.2708',
                              inputBg: inputBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              labelColor: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Geofence Radius Slider Section
                GeofenceRadiusSlider(
                  radiusM: _radiusM,
                  onChanged: (val) {
                    setState(() => _radiusM = val);
                  },
                ),
                const SizedBox(height: 20),
                // Active Switch Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active',
                          style: AppTextStyles.h4.copyWith(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Workers can check in here',
                          style: AppTextStyles.bodySmall.copyWith(color: labelColor),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                      activeTrackColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _isActive = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Save Location Button
                BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    final isSubmitting = state is LocationSubmitting;

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _onSaveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : AppColors.onPrimaryLight,
                                ),
                              )
                            : Text(
                                'Save location',
                                style: AppTextStyles.button.copyWith(
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : AppColors.onPrimaryLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color inputBg,
    required Color borderColor,
    required Color titleColor,
    required Color labelColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: labelColor),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primaryLight,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
    );
  }
}