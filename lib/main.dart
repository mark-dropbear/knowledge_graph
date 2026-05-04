import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:knowledge_graph/app.dart';
import 'package:knowledge_graph/injection_container.dart' as di;
import 'package:knowledge_graph/ui/router/app_router.dart';

import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print(
        '${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}',
      );
    }
  });
}

void main() {
  _setupLogging();
  usePathUrlStrategy();

  di.init();

  // Initialize view models immediately so the unified graph is populated
  // from the local data store when the app starts, before users navigate to
  // specific tabs. This ensures modals and detail views have all data.
  di.sl<PeopleViewModel>().initialize();
  di.sl<OrganizationsViewModel>().initialize();
  di.sl<ThingsViewModel>().initialize();

  runApp(MainApp(router: appRouter));
}
