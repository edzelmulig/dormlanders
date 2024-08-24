import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchTextController;
  final VoidCallback onBackPress;
  final FocusNode searchFocusNode;
  final Function onEditingComplete;

  const CustomSearchBar({
    super.key,
    required this.searchTextController,
    required this.onBackPress,
    required this.searchFocusNode,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      centerTitle: null,
      backgroundColor: Colors.white,
      leading: Padding(
          padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: onBackPress,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 23,
            color: Color(0xFF7C7C7D),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: SizedBox(
          height: 45,
          child: TextFormField(
            cursorColor: const Color(0xFF279778),
            controller: searchTextController,
            focusNode: searchFocusNode,
            decoration: InputDecoration(
              isDense: true,
              fillColor: const Color(0xFFF1F0F5),
              filled: true,
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 5),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7C7C7D),
                  size: 25,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  searchTextController.clear();
                },
                icon: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(1),
                      child: Icon(
                        Icons.clear_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              hintText: "Search service or location",
              hintStyle: const TextStyle(
                color: Color(0xFF7C7C7D),
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 0,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
            ),
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.shade300,
          height: 1.0,
        ),
      ),
    );
  }
}
