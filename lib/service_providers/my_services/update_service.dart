import 'dart:async';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:dormlanders/service_providers/my_services/offered_services.dart';
import 'package:dormlanders/services/firebase_services.dart';
import 'package:dormlanders/services/provider_services.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_modal_confirmation.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_text_field.dart';

class UpdateService extends StatefulWidget {
  final String receiveServiceID;

  const UpdateService({
    super.key,
    required this.receiveServiceID,
  });

  @override
  State<UpdateService> createState() => _UpdateServiceState();
}

class _UpdateServiceState extends State<UpdateService> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // CONTROLLERS
  final _availabilityController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _maximumTenantsController = TextEditingController();
  final _currentTenantsController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _imageURLController = TextEditingController();


  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // VARIABLE DECLARATIONS
  bool isAvailable = false;
  String? selectedValue;
  bool isLoading = true;
  PlatformFile? selectedImage;
  String? imageURL;
  String? oldImageURL;

  // LIST FOR SERVICE TYPE
  late List<String> serviceType = [
    'Free WiFi',
    'No Free WiFi',
  ];

  // FOCUS NODE DECLARATION
  final _serviceNameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _discountFocusNode = FocusNode();
  final _maximumTenantsFocusNode = FocusNode();
  final _currentTenantsFocusNode = FocusNode();

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    getUserServices();
    _serviceDescriptionController.addListener(_enforceWordLimit);
  }

  // DISPOSE
  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    _availabilityController.dispose();
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _maximumTenantsController.dispose();
    _currentTenantsController.dispose();
    _serviceTypeController.dispose();
    _imageURLController.dispose();
    _serviceDescriptionController.removeListener(_enforceWordLimit);
    super.dispose();
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

        if (_isConnectedToInternet) {
          _showConnectedSnackBar();
        } else {
          _showDisconnectedSnackBar();
        }
      },
    );
  }

  void _showDisconnectedSnackBar() {
    if (!_isConnectedToInternet) {
      // Check if a disconnected snack bar is already being displayed
      if (!isDisconnectedSnackBarVisible) {
        // showFloatingSnackBarWithIcon(
        //   context,
        //   'No internet connection',
        //   Icons.wifi_off_rounded,
        //   10,
        // );
        // Set the flag to indicate that the disconnected snack bar is being displayed
        isDisconnectedSnackBarVisible = true;

        // Restart the app after 10 seconds unless connection is restored
        _exitTimer = Timer(const Duration(seconds: 15), () async {
          await InternetConnectionChecker().hasConnection
              ? _exitTimer.cancel()
              : SystemNavigator.pop();
        });
      }
    }
  }

  void _showConnectedSnackBar() {
    if (isDisconnectedSnackBarVisible) {
      // If a disconnected snack bar is being displayed, hide it
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Reset the flag
      isDisconnectedSnackBarVisible = false;
    }

    // showFloatingSnackBarWithIcon(
    //   context,
    //   'Connected to the internet',
    //   Icons.wifi_rounded,
    //   5,
    // );
  }



  // METHOD THAT WILL GET THE PROVIDER'S SERVICES
  void getUserServices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await FirebaseService.getUserServices(widget.receiveServiceID);

      if (mounted) {
        setState(() {
          isAvailable = data['availability'] ?? false;
          selectedValue = data['serviceType'];
          _serviceTypeController.text = selectedValue!;
          if (data['imageURL'] != null) {
            imageURL = data['imageURL'];
            oldImageURL = imageURL;
          } else {
            imageURL = "images/no_image.jpeg";
          }

          // ASSIGN INITIAL VALUE TO THE CONTROLLERS
          _availabilityController.text = data['availability'].toString();
          _serviceNameController.text = data['serviceName'];
          _serviceDescriptionController.text = data['serviceDescription'];
          _maximumTenantsController.text = data['maximumTenant'].toString();
          _currentTenantsController.text = data['currentTenant'].toString();
          _priceController.text = data['price'].toString();
          _discountController.text = data['discount'].toString();
          _serviceTypeController.text = data['serviceType'];
          _imageURLController.text = data['imageURL'];

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user services: $e');
      // Handle the error (show a snackbar, alert, etc.)
    }
  }



  // METHOD THAT WILL HANDLE THE IMAGE SELECTION FROM THE LOCAL STORAGE
  void handleImageSelection() async {
    final selected = await ProviderServices.selectImage();
    if (selected != null) {
      setState(() {
        selectedImage = selected;
      });
    }
  }

  // METHOD THAT WILL UPDATE THE SERVICE'S DATA
  void handleUpdateService() async {
    await FirebaseService.updateService(
      context: context,
      formKey: formKey,
      isAvailable: isAvailable,
      serviceName: _serviceNameController.text,
      serviceDescription: _serviceDescriptionController.text,
      maximumTenants: int.tryParse(_maximumTenantsController.text) ?? 0,
      currentTenants: int.tryParse(_currentTenantsController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0.0,
      discount: int.tryParse(_discountController.text) ?? 0,
      serviceType: _serviceTypeController.text,
      serviceID: widget.receiveServiceID,
      selectedImage: selectedImage,
      oldImageURL: oldImageURL,
    );
  }

  void _enforceWordLimit() {
    String text = _serviceDescriptionController.text;
    int wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    // Define the maximum allowed word count
    int maxWordCount = 30; // Change this value to your desired maximum

    if (wordCount > maxWordCount) {
      // Truncate the text to the maximum word count
      List<String> words =
      text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      String newText =
          '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
      _serviceDescriptionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        showConfirmationModal(
          context,
          'You are about to discard this update.',
          'Discard',
          const MyServices(),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              showConfirmationModal(
                context,
                'You are about to discard this update.',
                'Discard',
                const MyServices(),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 25,
            ),
          ),
          centerTitle: true,
          title: const CustomTextDisplay(
            receivedText: "Update information",
            receivedTextSize: 18,
            receivedTextWeight: FontWeight.w600,
            receivedLetterSpacing: 0,
            receivedTextColor: Color(0xFF3C3C40),
          ),
        ),
        body: isLoading
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 60,
                  height: 60,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Color(0xFF0D6D52)],
                  ),
                ),
              )
            : ListView(
                children: <Widget>[
                  // FORM
                  Form(
                    key: formKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: AVAILABILITY
                          const CustomTextDisplay(
                            receivedText: "Availability",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // AVAILABILITY SWITCH
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 1.5,
                                  color: isAvailable
                                      ? const Color(0xFF0D6D52)
                                      : const Color(0xFFe91b4f),
                                ),
                                color: isAvailable
                                    ? const Color(0xFF0D6D52).withOpacity(0.1)
                                    : const Color(0xFFe91b4f).withOpacity(0.1)),
                            height: 60,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // Space between items
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    isAvailable ? "Available" : "Unavailable",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: isAvailable
                                          ? const Color(0xFF0D6D52)
                                          : const Color(0xFFe91b4f),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: isAvailable,
                                    onChanged: (value) {
                                      setState(() {
                                        isAvailable = value;
                                        _availabilityController.text =
                                            value.toString();
                                      });
                                    },
                                    activeColor: const Color(0xFF0D6D52),
                                    inactiveThumbColor: const Color(0xFF242424),
                                    inactiveTrackColor: Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: SERVICE NAME
                          const CustomTextDisplay(
                            receivedText: "Service Name",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: SERVICE NAME
                          CustomTextField(
                            controller: _serviceNameController,
                            currentFocusNode: _serviceNameFocusNode,
                            nextFocusNode: _descriptionFocusNode,
                            keyBoardType: null,
                            inputFormatters: null,
                            validatorText: "Service name is required",
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Service name is required";
                              }
                              return null;
                            },
                            hintText: "Enter service name",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: SERVICE DESCRIPTION
                          const CustomTextDisplay(
                            receivedText: "Service Description",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: DESCRIPTION
                          CustomTextField(
                            controller: _serviceDescriptionController,
                            currentFocusNode: _descriptionFocusNode,
                            nextFocusNode: _priceFocusNode,
                            keyBoardType: TextInputType.multiline,
                            inputFormatters: null,
                            validatorText: "Description is required",
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Description is required";
                              }
                              // Split the input string into words using spaces and count them
                              int wordCount = value
                                  .trim()
                                  .split(RegExp(r'\s+'))
                                  .where((word) => word.isNotEmpty)
                                  .length;

                              // DEFINE MAXIMUM ALLOWED WORDS
                              int maxWordCount = 30;

                              if (wordCount > maxWordCount) {
                                // Truncate the input text to the maximum word count
                                List<String> words =
                                value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
                                String truncatedText =
                                    '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
                                _serviceDescriptionController.text = truncatedText;
                                return "Description must be less than $maxWordCount words";
                              }
                              return null;
                            },
                            hintText: "Description here...",
                            minLines: 1,
                            maxLines: 5,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // MAXIMUM NUMBER OF TENANTS

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: SERVICE NAME
                          const CustomTextDisplay(
                            receivedText: "Maximum Number of Tenants",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: SERVICE NAME
                          CustomTextField(
                            controller: _maximumTenantsController,
                            currentFocusNode: _maximumTenantsFocusNode,
                            nextFocusNode: _currentTenantsFocusNode,
                            keyBoardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validatorText: "Maximum number of tenants is required",
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Maximum number of tenants is required";
                              }
                              return null;
                            },
                            hintText: "Enter maximum number of tenants",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),


                          // CURRENT NUMBER OF TENANTS
                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: SERVICE NAME
                          const CustomTextDisplay(
                            receivedText: "Current Number of Tenants",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: SERVICE NAME
                          CustomTextField(
                            controller: _currentTenantsController,
                            currentFocusNode: _currentTenantsFocusNode,
                            nextFocusNode: _priceFocusNode,
                            keyBoardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validatorText: "Current number of tenants is required",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Current number of tenants is required";
                              }

                              // Parse the data
                              final currentTenants = int.tryParse(_currentTenantsController.text);
                              final maximumTenants = int.tryParse(_maximumTenantsController.text);

                              if (currentTenants == null || maximumTenants == null) {
                                return "Invalid input";
                              }

                              if (currentTenants > maximumTenants) {
                                return "Current tenants exceed the maximum allowed.";
                              }

                              return null;
                            },
                            hintText: "Enter current number of tenants",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // PRICE AND DISCOUNT
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // LABEL: PRICE
                                    const CustomTextDisplay(
                                      receivedText: "Price",
                                      receivedTextSize: 15,
                                      receivedTextWeight: FontWeight.w500,
                                      receivedLetterSpacing: 0,
                                      receivedTextColor: Color(0xFF242424),
                                    ),

                                    // SIZED BOX: SPACING
                                    const SizedBox(height: 2),

                                    // TEXT FIELD: PRICE
                                    CustomTextField(
                                      controller: _priceController,
                                      currentFocusNode: _priceFocusNode,
                                      nextFocusNode: _discountFocusNode,
                                      validatorText: "Price is required",
                                      keyBoardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Price is required";
                                        }
                                        return null;
                                      },
                                      hintText: "0000",
                                      minLines: 1,
                                      maxLines: 1,
                                      isPassword: false,
                                    ),
                                  ],
                                ),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // LABEL: DISCOUNT
                                    const CustomTextDisplay(
                                      receivedText: "Discount",
                                      receivedTextSize: 15,
                                      receivedTextWeight: FontWeight.w500,
                                      receivedLetterSpacing: 0,
                                      receivedTextColor: Color(0xFF242424),
                                    ),

                                    // SIZED BOX: SPACING
                                    const SizedBox(height: 2),

                                    // TEXT FIELD: DISCOUNT
                                    CustomTextField(
                                      controller: _discountController,
                                      currentFocusNode: _discountFocusNode,
                                      nextFocusNode: null,
                                      validatorText: "Discount is required",
                                      keyBoardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Discount is required";
                                        }
                                        return null;
                                      },
                                      hintText: "%",
                                      minLines: 1,
                                      maxLines: 1,
                                      isPassword: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: SERVICE DESCRIPTION
                          const CustomTextDisplay(
                            receivedText: "Service Type",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // DROP DOWN: SERVICE TYPE
                          DropdownButtonFormField2<String>(
                            value: selectedValue,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D6D52),
                                  width: 1.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2.0,
                                ),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFBDBDC7),
                                  // Set color for enabled state
                                  width: 1.5, // Set width for enabled state
                                ),
                              ),
                            ),
                            hint: Text(
                              selectedValue ?? 'Service Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: selectedValue != 'Service Type'
                                    ? Colors.black
                                    : const Color(0xFF6c7687),
                              ),
                            ),
                            items: serviceType
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF3C3C40),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select service type.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              //Do something when selected item is changed.
                              setState(() {
                                selectedValue = value.toString();
                                _serviceTypeController.text = value.toString();
                              });
                            },
                            onSaved: (value) {
                              _serviceTypeController.text = value.toString();
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 15),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF3C3C40),
                              ),
                              iconSize: 26,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: DISPLAY PHOTO
                          const CustomTextDisplay(
                            receivedText: "Display photo",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // UPLOAD IMAGE CONTAINER
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFBDBDC7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFBDBDC7),
                                // Set color for enabled state
                                width: 1.5, // Set width for enabled state
                              ),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 120),
                            ),
                            onPressed: () {
                              if (selectedImage == null && imageURL == null) {
                                handleImageSelection();
                              }
                            },
                            child: selectedImage != null || imageURL != null
                                ? Stack(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: selectedImage != null
                                            ? Image.file(
                                                File(selectedImage!.path!),
                                                // Use the path of the selected image
                                                width: double.infinity,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                imageURL!,
                                                width: double.infinity,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    "images/no_image.jpeg",
                                                    fit: BoxFit.cover,
                                                    height: 120,
                                                    width: double.infinity,
                                                  );
                                                },
                                              ),
                                      ),
                                      Positioned(
                                        right: 11,
                                        top: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImage = null;
                                              imageURL = null;
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(5),
                                              child: const Icon(
                                                Icons.clear_rounded,
                                                color: Color(0xFFF5F5F5),
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          color: Colors.grey,
                                        ),
                                        CustomTextDisplay(
                                          receivedText: "Add photo",
                                          receivedTextSize: 15,
                                          receivedTextWeight: FontWeight.normal,
                                          receivedLetterSpacing: 0,
                                          receivedTextColor: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // NOTICE
                          RichText(
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "Your offered services are public and can be seen "
                                      "by anyone on MentalBoost. ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF8C8C8C),
                                  ),
                                ),
                                TextSpan(
                                  text: "Learn more",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C8C8C),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 20),

                          // BUTTON: SAVE PHONE NUMBER
                          PrimaryCustomButton(
                            buttonText: "Publish",
                            onPressed: handleUpdateService,
                            buttonHeight: 55,
                            buttonColor: const Color(0xFF193147),
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            fontColor: Colors.white,
                            elevation: 1,
                            borderRadius: 10,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
