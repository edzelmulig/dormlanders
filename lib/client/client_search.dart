import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/client/client_provider_profile.dart';
import 'package:dormlanders/models/provider_model.dart';
import 'package:dormlanders/services/client_services.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/utils/shimmer_client_home_page.dart';
import 'package:dormlanders/widgets/provider_info_card.dart';
import 'package:dormlanders/widgets/custom_search_bar.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class ClientSearchBar extends StatefulWidget {
  final double clientLatitude;
  final double clientLongitude;
  final String clientImageURL;

  const ClientSearchBar({
    super.key,
    required this.clientLatitude,
    required this.clientLongitude,
    required this.clientImageURL,
  });

  @override
  State<ClientSearchBar> createState() => _ClientSearchBarState();
}

class _ClientSearchBarState extends State<ClientSearchBar> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  final _searchText = TextEditingController();
  late FocusNode _searchFocusNode;
  final List _allResults = [];
  List _resultList = [];
  List<ServiceProvider> providers = [];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _searchFocusNode = FocusNode();
    _searchText.addListener(_onSearchChanged);
    // Request focus for the search field after the build method completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  // CHECK CONNECTION
  Future<void> _checkConnection() async {
    _connectionSubscription = InternetConnectionChecker().onStatusChange.listen(
          (status) {
        // Check if the context is still mounted
        if (!mounted) return;

        setState(() {
          _isConnectedToInternet = status == InternetConnectionStatus.connected;
        });
      },
    );
  }

  _onSearchChanged() {
    //print(_searchText.text);
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchText.text != "") {
      for (var providerSnapShot in _allResults) {
        var name = providerSnapShot['displayName'].toString().toLowerCase();
        var street = providerSnapShot['street'].toString().toLowerCase();
        var barangay = providerSnapShot['barangay'].toString().toLowerCase();
        var city = providerSnapShot['city'].toString().toLowerCase();
        var province = providerSnapShot['province'].toString().toLowerCase();
        var serviceName =
            providerSnapShot['serviceName'].join(" ").toLowerCase();

        if (name.contains(_searchText.text.toLowerCase()) ||
            city.contains(_searchText.text.toLowerCase()) ||
            serviceName.contains(_searchText.text.toLowerCase())) {
          showResults.add(providerSnapShot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultList = showResults;
    });
  }

  getProviderStream() async {
    try {
      // FETCH ALL SERVICE PROVIDERS
      List<ServiceProvider> serviceData =
          await ClientServices.fetchAllProviders(
              widget.clientLatitude, widget.clientLongitude);

      if (!mounted) return;

      setState(() {
        providers = serviceData;
      });

      // TRANSFORM ServiceProvider OBJECT TO MAP STRUCTURE
      final List<Map<String, dynamic>> providerDataList =
          serviceData.map((provider) {
        return {
          'userID': provider.userID,
          'displayName': provider.providerName,
          'imageURL': provider.providerImage,
          'street': provider.providerStreet,
          'barangay': provider.providerBarangay,
          'city': provider.providerCity,
          'province': provider.providerProvince,
          'distance': provider.distance,
          'serviceName': provider.serviceNames,
        };
      }).toList();

      // // PRINTING
      // for(var provider in providerDataList) {
      //   print(provider);
      //   print("============");
      //   print(provider['serviceName']);
      //   print("+++++++++++++");
      // }

      if (mounted) {
        setState(() {
          _allResults.addAll(providerDataList);
        });
      }
    } catch (error) {
      print("Error fetching service data: $error");
    }

    if (!mounted) return;
    if (_searchText.text.isNotEmpty) {
      searchResultList();
    }
  }

  @override
  void dispose() {
    _exitTimer.cancel();
    _searchFocusNode.dispose();
    _searchText.removeListener(_onSearchChanged);
    _connectionSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getProviderStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if(!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F0F5),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomSearchBar(
            searchTextController: _searchText,
            onBackPress: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            searchFocusNode: _searchFocusNode,
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
          ),
        ),
        body: _searchText.text.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: _resultList.isEmpty
                ? const ServiceShimmer(itemCount: 3, containerHeight: 100,)
                :ListView.builder(
                  itemCount: _resultList.length,
                  itemBuilder: (context, index) {

                    // Create a ServiceProvider instance from the map
                    Map<String, dynamic> providerData = _resultList[index];

                    ServiceProvider currentProvider = ServiceProvider(
                      userID: providerData['userID'],
                      providerName: providerData['displayName'],
                      providerImage: providerData['imageURL'],
                      providerStreet: providerData['street'] ?? 'N/A',
                      providerBarangay: providerData['barangay'] ?? 'N/A',
                      providerCity: providerData['city'] ?? 'N/A',
                      providerProvince: providerData['province'] ?? 'N/A',
                      distance: providerData['distance'],
                      serviceNames: providerData['serviceName'],
                    );

                    return ProviderInfoCard(
                      providerID: currentProvider.userID,
                      providerName: currentProvider.providerName,
                      providerProfile: currentProvider.providerImage,
                      providerStreet: currentProvider.providerStreet,
                      providerBarangay: currentProvider.providerBarangay,
                      providerCity: currentProvider.providerCity,
                      providerProvince: currentProvider.providerProvince,
                      distance: currentProvider.distance,
                      leftPadding: 15,
                      topPadding: 0,
                      rightPadding: 15,
                      bottomPadding: 13,
                      onPressed: () {
                        navigateWithSlideFromRight(
                          context,
                          ClientProviderProfile(
                            providerID: currentProvider.userID,
                            providerDistance: currentProvider.distance,
                            clientLatitude: widget.clientLatitude,
                            clientLongitude: widget.clientLongitude,
                            clientImageURL: widget.clientImageURL,
                            providerInfo: null,
                            providerLocation: null,
                          ),
                          1.0,
                          0.0,
                        );
                      },
                    );
                  },
                ),
              )
            : const Center(
                child: CustomTextDisplay(
                  receivedText: "Type something to search",
                  receivedTextSize: 15,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Colors.grey,
                ),
              ),
      ),
    );
  }
}
