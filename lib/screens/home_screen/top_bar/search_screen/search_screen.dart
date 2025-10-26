import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/screens/home_screen/top_bar/search_screen/user_tag.dart';
import 'package:joy_way/widgets/user_infor_container/list_suggestion_user.dart';

// Services & models
import '../../../../../services/firebase_services/profile_services/search_profile.dart';

// UI
import '../../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../../widgets/animated_container/flashing_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();


  List<BasicUserInfo> _results = const [];
  bool _loading = false;
  String _error = '';
  String _lastQuery = '';
  late final AnimationController _ctl;
  late final Animation<double> _backT;
  late final Animation<double> _searchT;
  Timer? _typingTimer;
  static const _debounce = Duration(milliseconds: 500);
  int _req = 0;
  void _debouncedSearch(String q) {
    _typingTimer?.cancel();
    final query = q.trim();
    _typingTimer = Timer(_debounce, () => _performSearch(query));
  }
  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _lastQuery = '';
        _loading = false;
        _error = '';
      });
      return;
    }
    if (query == _lastQuery) return;
    _lastQuery = query;
    final myReq = ++_req;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final search = SearchProfile();
      // 1) Tìm danh sách UID theo từ khóa (username)
      final uids = await search.searchUserIdsByUserName(keyword: query);
      // 2) Dùng UID để lấy thông tin thẻ user
      final data = await search.getUserTagsByUids(uids);
      if (!mounted || myReq != _req) return;
      setState(() {
        _results = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || myReq != _req) return;
      setState(() {
        _loading = false;
        _error = 'Search failed';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _searchT = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    _backT = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _ctl.forward();
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // TOP BAR
          Container(
            height: 100,
            width: specs.screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: specs.black240, width: 1),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // BACK
                AnimatedBuilder(
                  animation: _backT,
                  child: CustomAnimatedButton(
                    onTap: () => Navigator.pop(context),
                    height: 40,
                    width: 30,
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    child: const Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/other_icons/angle-left.png"),
                        size: 22,
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    final left = lerpDouble(-50, 20, _backT.value)!;
                    return Positioned(top: 40, left: left, child: child!);
                  },
                ),

                // SEARCH BOX
                AnimatedBuilder(
                  animation: _searchT,
                  builder: (context, _) {
                    final left =
                    lerpDouble(specs.screenWidth - 60, 60, _searchT.value)!;
                    final width =
                    lerpDouble(45, specs.screenWidth - 80, _searchT.value)!;
                    final searchWidth = lerpDouble(
                        0, specs.screenWidth - 140, _searchT.value)!;
                    return Positioned(
                      top: 40,
                      left: left,
                      child: Container(
                        width: width,
                        height: 45,
                        decoration: BoxDecoration(
                          color: specs.black240,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 3.5),
                            FlashingContainer(
                              onTap: () => _performSearch(_controller.text),
                              height: 38,
                              width: 38,
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.black,
                              flashingColor: specs.black200,
                              child: const Center(
                                child: ImageIcon(
                                  AssetImage(
                                      "assets/icons/other_icons/search.png"),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 3.5),
                            Container(
                              height: 45,
                              width: searchWidth,
                              padding: const EdgeInsets.only(
                                  bottom: 13.5, left: 5, right: 8),
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search by username",
                                  hintStyle: GoogleFonts.outfit(
                                      color: specs.black200, fontSize: 14),
                                ),
                                onChanged: _debouncedSearch,
                                textInputAction: TextInputAction.search,
                                onSubmitted: _performSearch,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // BODY
          Expanded(child: _buildBody(specs)),
        ],
      ),
    );
  }

  Widget _buildBody(GeneralSpecifications specs) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: GoogleFonts.outfit(color: Colors.red, fontSize: 14),
        ),
      );
    }

    // Chưa gõ gì hiển thị gợi ý
    if (_lastQuery.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          ListSuggestionUser(),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: specs.black240, width: 1)),
            ),
          ),
        ],
      );
    }

    // Có query rỗng kết quả
    if (_results.isEmpty) {
      return Center(
        child: Text(
          'No results',
          style: GoogleFonts.outfit(color: specs.black100, fontSize: 14),
        ),
      );
    }

    // Hiển thị danh sách UserTagInformation
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: specs.black240),
      itemBuilder: (_, i) {
        final u = _results[i];
        final initial =
        (u.userName.isNotEmpty ? u.userName[0] : '?').toUpperCase();
        return UserTag(userTagInformation: u);
      },
    );
  }
}
