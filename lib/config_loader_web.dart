// Only for web
import 'dart:js_util' as js_util;
import 'dart:html' as html;

Future<Map<String, dynamic>> loadConfig() async {
  // Wait until window.config is populated
  await Future.doWhile(() async {
    await Future.delayed(Duration(milliseconds: 100));
    final jsConfig = js_util.getProperty(html.window, 'config');
    return js_util.getProperty(jsConfig, 'postsUrl') == null;
  });

  final jsConfig = js_util.getProperty(html.window, 'config');
  return {
    'postsUrl': js_util.getProperty(jsConfig, 'postsUrl'),
    'usersUrl': js_util.getProperty(jsConfig, 'usersUrl'),
  };
}
