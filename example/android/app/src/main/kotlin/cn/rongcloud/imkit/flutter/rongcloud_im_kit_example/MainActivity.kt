package cn.rongcloud.imkit.flutter.rongcloud_im_kit_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.util.Log

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        try {
            super.configureFlutterEngine(flutterEngine)
            GeneratedPluginRegistrant.registerWith(flutterEngine)
        } catch (e: Exception) {
            Log.e("Flutter", "配置 FlutterEngine 失败", e)
            e.printStackTrace()
        }
    }
}