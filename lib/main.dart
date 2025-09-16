import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:sando_diary/pages/about_page.dart';
import 'package:sando_diary/pages/posts/posts_right_detail_pane.dart';
import 'package:sando_diary/pages/posts/posts_right_list_pane.dart';
import 'package:sando_diary/pages/posts/posts_shell.dart';
import 'package:sando_diary/theme/custom_decoration.dart';
import 'package:sando_diary/pages/guestbook_page.dart';
import 'package:sando_diary/pages/project_list_page.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print('Failed to sign in anonymously: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await signInAnonymously();

  // 웹에서 # 제거(권장)
  setUrlStrategy(PathUrlStrategy());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 라우터 구성
    final router = GoRouter(
      initialLocation: '/posts',
      routes: [
        // 바깥 Shell: 상단 공통 레이아웃
        ShellRoute(
          builder: (context, state, child) =>
              _RootScaffold(child: child, state: state),
          routes: [
            // 안쪽 Shell: Posts 섹션 2-컬럼 레이아웃
            ShellRoute(
              // 이 Shell이 "좌측 패널 + 우측 child"를 그립니다.
              builder: (context, state, child) => PostsShell(child: child),

              routes: [
                // 우측 child = 목록
                GoRoute(
                  path: '/posts',
                  builder: (context, state) => PostsRightListPane(),
                ),

                GoRoute(
                  path: '/category/:cat', // 카테고리 필터 목록
                  builder: (context, state) => PostsRightListPane(),
                ),
                GoRoute(
                  path: '/tag/:tag', // 태그 필터 목록
                  builder: (context, state) => PostsRightListPane(),
                ),

                // 우측 child = 상세 (slug 기반)
                GoRoute(
                  path: '/posts/:slug',
                  builder: (context, state) => PostsRightDetailPane(
                    slug: state.pathParameters['slug']!,
                  ),
                ),
              ],
            ),

            // 나머지 라우트들
            GoRoute(path: '/projects', builder: (_, __) => const Projectpage()),
            GoRoute(path: '/about', builder: (_, __) => AboutPage()),
            GoRoute(path: '/guestbook', builder: (_, __) => GuestBook()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

/// 공통 레이아웃(한 페이지 고정) — 상단 커스텀 앱바 + 반응형 드로어
class _RootScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;
  const _RootScaffold({required this.child, required this.state});

  // 현재 경로 기준으로 선택된 메뉴 계산
  int get _selectedIndex {
    final seg = state.uri.pathSegments;
    if (seg.isEmpty) return 0;
    final first = seg.first;
    switch (first) {
      case 'posts':
        return 0;
      case 'projects':
        return 1;
      case 'about':
        return 2;
      case 'guestbook':
        return 3;
      default:
        return 0;
    }
  }

  String get _selectedMenuLabel {
    switch (_selectedIndex) {
      case 0:
        return 'Posts';
      case 1:
        return 'Projects';
      case 2:
        return 'About';
      case 3:
        return 'GuestBook';
      default:
        return 'Posts';
    }
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/posts');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/about');
        break;
      case 3:
        context.go('/guestbook');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = AppBar().preferredSize.height;

    PreferredSizeWidget _desktopHeader(double height) {
      return PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              color: const Color(0xFF30383f),
              height: height + 55,
              width: MediaQuery.of(context).size.width,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  "Sando`s Diary",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            Container(), // spacer
            Positioned(
                top: 80.0,
                left: 20.0,
                right: 20.0,
                child: Container(
                  color: const Color(0xFF30383f),
                  height: height / 2,
                )),
            Positioned(
              top: 40.0,
              left: 20.0,
              right: 20.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderButton(
                    label: 'Posts',
                    color: const Color(0xFF9581f5),
                    activeBarColor: const Color(0xFFAA9AF7),
                    isActive: _selectedIndex == 0,
                    height: height,
                    onTap: () => _go(context, 0),
                  ),
                  const SizedBox(width: 10),
                  _HeaderButton(
                    label: 'Projects',
                    color: const Color(0xFF75F8AE),
                    activeBarColor: const Color(0xFFBBF5D4),
                    isActive: _selectedIndex == 1,
                    height: height,
                    onTap: () => _go(context, 1),
                  ),
                  const SizedBox(width: 10),
                  _HeaderButton(
                    label: 'About',
                    color: const Color(0xFFE1F970),
                    activeBarColor: const Color(0xFFECF6BD),
                    isActive: _selectedIndex == 2,
                    height: height,
                    onTap: () => _go(context, 2),
                  ),
                  const SizedBox(width: 10),
                  _HeaderButton(
                    label: 'GuestBook',
                    color: const Color(0xFF99D6F9),
                    activeBarColor: const Color(0xFFBEE7FE),
                    isActive: _selectedIndex == 3,
                    height: height,
                    onTap: () => _go(context, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 반응형: 큰 화면은 커스텀 헤더, 작은 화면은 AppBar + Drawer
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width > 600) {
          // 데스크톱/태블릿 — 커스텀 헤더 유지
          return Scaffold(
            appBar: _desktopHeader(height),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: child,
            ),
          );
        } else {
          // 모바일 — 기본 AppBar + Drawer
          return Scaffold(
            appBar: AppBar(title: Text(_selectedMenuLabel)),
            endDrawer: Drawer(
              backgroundColor: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(flex: 1, child: SizedBox()),
                      const Flexible(
                          flex: 5, child: ColoredBox(color: Color(0xFF30383f))),
                    ],
                  ),
                  ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        height: 180,
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        child: const Center(
                          child: Text(
                            '   Sando`s Diary',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                      _DrawerButton(
                        label: 'Posts',
                        icon: Icons.list,
                        baseColor: const Color(0xFF9581f5),
                        stripeColor: const Color(0xFFAA9AF7),
                        onTap: () {
                          context.go('/posts');
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 5),
                      _DrawerButton(
                        label: 'Projects',
                        icon: Icons.book_outlined,
                        baseColor: const Color(0xFF75F8AE),
                        stripeColor: const Color(0xFFBBF5D4),
                        onTap: () {
                          context.go('/projects');
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 5),
                      _DrawerButton(
                        label: 'About',
                        icon: Icons.account_box_outlined,
                        baseColor: const Color(0xFFE1F970),
                        stripeColor: const Color(0xFFECF6BD),
                        onTap: () {
                          context.go('/about');
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 5),
                      _DrawerButton(
                        label: 'GuestBook',
                        icon: Icons.edit_outlined,
                        baseColor: const Color(0xFF99D6F9),
                        stripeColor: const Color(0xFFBEE7FE),
                        onTap: () {
                          context.go('/guestbook');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: child,
            ),
          );
        }
      },
    );
  }
}

/// 데스크톱 상단 버튼(기존 스타일 유지)
class _HeaderButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color activeBarColor;
  final bool isActive;
  final double height;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.label,
    required this.color,
    required this.activeBarColor,
    required this.isActive,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: isActive ? height + 40 : (height / 2) + 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: 1, color: Colors.black),
          boxShadow: AppShadows.customBaseBoxShadow,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(child: Text(label)),
            Visibility(
              visible: isActive,
              child: Container(height: 25, color: activeBarColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 모바일 Drawer 버튼(기존 스타일 유지)
class _DrawerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color baseColor;
  final Color stripeColor;
  final VoidCallback onTap;

  const _DrawerButton({
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.stripeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        border: Border.all(width: 1, color: Colors.black),
        boxShadow: AppShadows.customBaseBoxShadow,
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon),
            ),
            Expanded(
              child: Container(
                color: stripeColor,
                padding: const EdgeInsets.all(12),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('404 Not Found'));
  }
}

/// 게시물 상세(임시 예시 — 실제 상세 위젯으로 교체 가능)
class PostDetailPage extends StatelessWidget {
  final int postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Post Detail • ID: $postId',
          style: const TextStyle(fontSize: 18)),
    );
  }
}
