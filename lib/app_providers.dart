import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'providers/engine_provider.dart';
import 'providers/download_progress_provider.dart';
import 'providers/theme_provider.dart';

class RongCloudAppProviders {
  static Widget of(Widget child,
      {List<SingleChildWidget>? additionalProviders}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RCKEngineProvider()),
        ChangeNotifierProvider(create: (_) => RCKDownloadProgressProvider()),
        ChangeNotifierProvider(create: (_) => RCKThemeProvider()),
        if (additionalProviders != null) ...additionalProviders,
      ],
      child: child,
    );
  }
}
