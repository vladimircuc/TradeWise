//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import awesome_notifications
import awesome_notifications_core
import cloud_firestore
import file_selector_macos
import firebase_auth
import firebase_core
import path_provider_foundation
import shared_preferences_foundation
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AwesomeNotificationsPlugin.register(with: registry.registrar(forPlugin: "AwesomeNotificationsPlugin"))
  AwesomeNotificationsCorePlugin.register(with: registry.registrar(forPlugin: "AwesomeNotificationsCorePlugin"))
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  FLTFirebaseAuthPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAuthPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
