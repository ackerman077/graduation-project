import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/doctor_image_widget.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../cubit/doctors_cubit.dart';
import '../../../../core/models/city.dart';
import '../../../../core/models/governorate.dart';
import '../../../../core/routing/routes.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCityId;
  String? _selectedCityName;
  int? _selectedGovernorateId;
  String? _selectedGovernorateName;

  List<City> _availableCities = [];
  bool _isLoadingCities = false;

  List<Governorate> _availableGovernorates = [];
  bool _isLoadingGovernorates = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<DoctorsCubit>();

        cubit.loadDoctors();

        setState(() {
          _isLoadingCities = true;
          _isLoadingGovernorates = true;
        });
        cubit.loadCities();
        cubit.loadGovernorates();

        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && _isLoadingCities) {
            setState(() {
              _isLoadingCities = false;
            });
          }
          if (mounted && _isLoadingGovernorates) {
            setState(() {
              _isLoadingGovernorates = false;
            });
          }
        });
      }
    });
  }

  void _extractCitiesFromDoctors(List<dynamic> doctors) {
    final Set<City> uniqueCities = {};

    for (final doctor in doctors) {
      if (doctor.city != null) {
        Map<String, dynamic>? cityData;

        if (doctor.city is Map<String, dynamic>) {
          cityData = doctor.city as Map<String, dynamic>;
        } else if (doctor.city is String) {
          cityData = {'id': uniqueCities.length + 1, 'name': doctor.city};
        }

        if (cityData != null && cityData['name'] != null) {
          final cityName = cityData['name'].toString().trim();
          if (cityName.isNotEmpty) {
            final cityId = cityData['id'] is int
                ? cityData['id']
                : int.tryParse(cityData['id'].toString()) ??
                      uniqueCities.length + 1;

            uniqueCities.add(
              City(
                id: cityId,
                name: cityName,
                governrateId: cityData['governrate_id'],
              ),
            );
          }
        }
      }
    }

    setState(() {
      _availableCities = uniqueCities.toList();
      _isLoadingCities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: DependencyInjection.get<DoctorsCubit>(),
      child: BlocListener<DoctorsCubit, DoctorsState>(
        listener: (context, state) {
          if (state is DoctorsLoaded) {
            if (state.availableCitiesObjects.isNotEmpty) {
              setState(() {
                _availableCities = state.availableCitiesObjects;
                _isLoadingCities = false;
              });
            }

            if (state.availableGovernorates.isNotEmpty) {
              setState(() {
                _availableGovernorates = state.availableGovernorates;
                _isLoadingGovernorates = false;
              });
            }

            if (_availableCities.isEmpty && state.doctors.isNotEmpty) {
              _extractCitiesFromDoctors(state.doctors);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Doctors'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: ColorsManager.primaryBlue,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[50]!, Colors.grey[100]!],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: Column(
              children: [
                _buildCompactFiltersSection(context),

                Expanded(child: _buildDoctorsList(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFiltersSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.w),
          bottomRight: Radius.circular(20.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactSearchBar(),

          SizedBox(height: 8.h),

          _buildCompactFilterChips(context),

        ],
      ),
    );
  }

  Widget _buildCompactSearchBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _selectedCityName != null
              ? 'Search in $_selectedCityName...'
              : _selectedGovernorateName != null
              ? 'Search in $_selectedGovernorateName...'
              : 'Search doctors by name...',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: ColorsManager.textLight,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.w),
            child: Icon(
              Icons.search_rounded,
              size: 18.w,
              color: ColorsManager.primaryBlue,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.all(8.w),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 18.w,
                      color: ColorsManager.textLight,
                    ),
                    onPressed: _clearSearchFilter,
                    style: IconButton.styleFrom(
                      minimumSize: Size(32.w, 32.w),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w),
            borderSide: const BorderSide(
              color: ColorsManager.primaryBlue,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
        ),
        onChanged: _performSearch,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: ColorsManager.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCompactFilterChips(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_availableCities.isNotEmpty) ...[_buildModernCityChips()],
              if (_availableGovernorates.isNotEmpty) ...[
                SizedBox(height: 6.h),
                _buildModernGovernorateChips(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorsList(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: ColorsManager.primaryBlue),
                SizedBox(height: 16),
                Text(
                  'Loading doctors...',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorsManager.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DoctorsError) {
          return AppErrorWidget(
            errorMessage: state.message,
            onRetry: _reloadDoctorsWithCurrentFilters,
          );
        }

        if (state is DoctorsLoaded) {
          final doctorsToShow = state.isSearching
              ? state.searchResults
              : state.doctors;

          if (doctorsToShow.isEmpty) {
            if (state.isSearching) {
              return _buildSearchEmptyState(state.searchQuery);
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: ColorsManager.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No doctors found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or search terms',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedCityId != null && _selectedCityId != 0) {
                context.read<DoctorsCubit>().filterDoctors(
                  cityId: _selectedCityId,
                );
              } else if (_selectedGovernorateId != null &&
                  _selectedGovernorateId != 0) {
                context.read<DoctorsCubit>().filterDoctorsByGovernorate(
                  _selectedGovernorateId!,
                );
              } else {
                context.read<DoctorsCubit>().loadDoctors();
              }
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: doctorsToShow.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final doctor = doctorsToShow[index];
                return _buildModernDoctorCard(context, doctor);
              },
            ),
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: ColorsManager.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'No doctors available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please try again later',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorsManager.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.w, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No results found for "$searchQuery"',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Container(
            width: 100.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: ColorsManager.primaryBlue,
              borderRadius: BorderRadius.circular(18.w),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18.w),
              onTap: _clearSearchFilter,
              child: Center(
                child: Text(
                  'Clear Search',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDoctorCard(BuildContext context, dynamic doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.doctorDetailScreen,
          arguments: doctor,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: Colors.grey[200]!.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey[300]!.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorsManager.lightBlue,
                    ColorsManager.primaryBlue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: DoctorImageWidget(
                  networkImageUrl: doctor.image,
                  doctorId: doctor.id,
                  width: 70.w,
                  height: 70.w,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12.w),
                  errorWidget: Icon(
                    Icons.person,
                    size: 35.w,
                    color: ColorsManager.primaryBlue,
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name ?? 'Unknown Doctor',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: ColorsManager.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6.h),

                  if (doctor.specialization != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(
                        doctor.specialization!.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.primaryBlue,
                        ),
                      ),
                    ),

                  SizedBox(height: 8.h),

                  if (doctor.city != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.w,
                          color: ColorsManager.textLight,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            doctor.city!.name ?? '',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: ColorsManager.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 8.h),

                  if (doctor.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16.w,
                          color: ColorsManager.warning,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          doctor.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorsManager.textPrimary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (doctor.appointPrice != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(
                        color: ColorsManager.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '\$${doctor.appointPrice!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.success,
                      ),
                    ),
                  ),

                SizedBox(height: 8.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryBlue,
                    borderRadius: BorderRadius.circular(12.w),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.trim().isEmpty) {
      _clearSearchFilter();
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchQuery == query) {
        context.read<DoctorsCubit>().searchDoctors(query);
      }
    });
  }

  void _clearSearchFilter() {
    setState(() {
      _searchQuery = '';
    });
    _searchController.clear();
    context.read<DoctorsCubit>().clearSearch();
    context.read<DoctorsCubit>().loadDoctors();
  }

  void _onCitySelected(City city) {
    if (!mounted) return;

    setState(() {
      _selectedCityId = city.id;
      _selectedCityName = city.name;
      _searchQuery = '';
      _searchController.clear();
      _selectedGovernorateId = null;
      _selectedGovernorateName = null;
    });

    context.read<DoctorsCubit>().clearSearch();

    if (city.id == 0) {
      context.read<DoctorsCubit>().loadDoctors();
    } else {
      context.read<DoctorsCubit>().filterDoctors(cityId: city.id);
    }
  }

  void _onGovernorateSelected(Governorate governorate) {
    if (!mounted) return;

    setState(() {
      _selectedGovernorateId = governorate.id;
      _selectedGovernorateName = governorate.name;
      _searchQuery = '';
      _searchController.clear();
      _selectedCityId = null;
      _selectedCityName = null;
    });

    context.read<DoctorsCubit>().clearSearch();

    if (governorate.id == 0) {
      context.read<DoctorsCubit>().loadDoctors();
    } else {
      context.read<DoctorsCubit>().filterDoctorsByGovernorate(governorate.id);
    }
  }

  void _reloadDoctorsWithCurrentFilters() {
    if (_selectedCityId != null && _selectedCityId != 0) {
      context.read<DoctorsCubit>().filterDoctors(cityId: _selectedCityId);
    } else if (_selectedGovernorateId != null && _selectedGovernorateId != 0) {
      context.read<DoctorsCubit>().filterDoctorsByGovernorate(
        _selectedGovernorateId!,
      );
    } else {
      context.read<DoctorsCubit>().loadDoctors();
    }
  }

  Widget _buildModernCityChip(City city, {bool isSelected = false}) {
    final isCurrentlySelected = isSelected || _selectedCityId == city.id;

    return GestureDetector(
      onTap: () => _onCitySelected(city),
      child: Container(
        constraints: BoxConstraints(minHeight: 36.h, minWidth: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: isCurrentlySelected ? ColorsManager.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(18.w),
          border: isCurrentlySelected
              ? null
              : Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
        ),
        child: Center(
          child: Text(
            city.name,
            style: TextStyle(
              color: isCurrentlySelected
                  ? Colors.white
                  : ColorsManager.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildModernCityChips() {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildModernCityChip(
            const City(id: 0, name: 'All'),
            isSelected: _selectedCityId == null || _selectedCityId == 0,
          ),
          ..._availableCities.map(_buildModernCityChip),
        ],
      ),
    );
  }

  Widget _buildModernGovernorateChip(
    Governorate governorate, {
    bool isSelected = false,
  }) {
    final isCurrentlySelected =
        isSelected || _selectedGovernorateId == governorate.id;

    return GestureDetector(
      onTap: () => _onGovernorateSelected(governorate),
      child: Container(
        constraints: BoxConstraints(minHeight: 36.h, minWidth: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: isCurrentlySelected ? ColorsManager.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(18.w),
          border: isCurrentlySelected
              ? null
              : Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
        ),
        child: Center(
          child: Text(
            governorate.name,
            style: TextStyle(
              color: isCurrentlySelected
                  ? Colors.white
                  : ColorsManager.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildModernGovernorateChips() {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildModernGovernorateChip(
            const Governorate(id: 0, name: 'All'),
            isSelected:
                _selectedGovernorateId == null || _selectedGovernorateId == 0,
          ),
          ..._availableGovernorates.map(_buildModernGovernorateChip),
        ],
      ),
    );
  }
}
