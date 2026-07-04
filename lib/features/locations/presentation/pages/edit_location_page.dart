import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/constants/app_icon.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/app_toast.dart';
import '../../domain/entities/location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/geofence_radius_slider.dart';
import '../widgets/map_placeholder_widget.dart';

class EditLocationPage extends StatefulWidget {
  final LocationEntity location;

  const EditLocationPage({
    super.key,
    required this.location,
  });

  @override
  State<EditLocationPage> createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  late double _radiusM;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location.locationName);
    _latController = TextEditingController(text: widget.location.latitude.toString());
    _lngController = TextEditingController(text: widget.location.longitude.toString());
    _radiusM = widget.location.radiusM;
    _isActive = widget.location.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onUpdateLocation() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final lat = double.tryParse(_latController.text.trim()) ?? widget.location.latitude;
    final lng = double.tryParse(_lngController.text.trim()) ?? widget.location.longitude;

    final updated = LocationEntity(
      id: widget.location.id,
      locationName: name,
      latitude: lat,
      longitude: lng,
      radiusM: _radiusM,
      isActive: _isActive,
    );

    context.read<LocationBloc>().add(UpdateLocation(updated));
  }

  void _onConfirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Text(
            'Delete location',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.location.locationName}"? This action cannot be undone.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<LocationBloc>().add(DeleteLocation(widget.location.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

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
          'Edit location',
          style: AppTextStyles.h2.copyWith(color: titleColor, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationSuccess) {
            AppToast.show(
              context,
              message: state.message,
            );
            context.pop();
          } else if (state is LocationError) {
            AppToast.show(
              context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Preview Widget
                    MapPlaceholderWidget(radiusM: _radiusM),
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
                    // Action Buttons: Update Location & Delete Location
                    BlocBuilder<LocationBloc, LocationState>(
                      builder: (context, state) {
                        final isSubmitting = state is LocationSubmitting;

                        return Column(
                          children: [
                            // Update Location Button (Primary filled)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : _onUpdateLocation,
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
                                        'Update location',
                                        style: AppTextStyles.button.copyWith(
                                          color: isDark
                                              ? AppColors.onPrimaryDark
                                              : AppColors.onPrimaryLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Delete Location Button (Red Outlined Danger Button)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: isSubmitting ? null : _onConfirmDelete,
                                icon: Image.asset(AppIcon.trash, width: 20, height: 20, color: errorColor),
                                label: Text(
                                  'Delete location',
                                  style: AppTextStyles.button.copyWith(
                                    color: errorColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: errorColor, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      ),
    ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color inputBg,
    required Color borderColor,
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