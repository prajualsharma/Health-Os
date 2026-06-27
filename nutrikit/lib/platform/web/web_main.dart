import 'package:flutter_web_plugins/url_strategy.dart';

/// Web-specific setup: clean URLs without the leading `#`.
void configurePlatform() {
  usePathUrlStrategy();
}
