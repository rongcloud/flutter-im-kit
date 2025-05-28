import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'views_github/setup_page.dart';
import 'views_github/demo_conversation_list_page.dart';
import 'views_github/demo_chat_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RongCloudAppProviders.of(
      MaterialApp(
        title: 'RongCloud IM Kit Quick Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SetupPage(),
        routes: {
          '/conversation_list': (context) => const DemoConversationListPage(),
          '/chat': (context) => const DemoChatPage(),
        },
      ),
    );
  }
}
