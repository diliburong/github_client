import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:window_to_front/window_to_front.dart';

import 'github_oauth_credentials.dart';
import 'github_login.dart';
import 'github_summary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Github Client'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(
      builder: (context, httpClient) {
        // make to app to top.
        // WindowToFront.activate();

        return FutureBuilder<CurrentUser>(
            future: viewerDetail(httpClient.credentials.accessToken),
            builder: (context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: Center(
                  child: GithubSummary(
                    gitHub: _getGitHub(httpClient.credentials.accessToken),
                  ),
                ),
              );
            });
      },
      githubClientId: githubClientId,
      githubClientSecret: githubClientSecret,
      githubScopes: githubScopes,
    );
  }
}

GitHub _getGitHub(String accessToken) {
  return GitHub(auth: Authentication.withToken(accessToken));
}

Future<CurrentUser> viewerDetail(String accessToken) async {
  final gitHub = GitHub(auth: Authentication.withToken(accessToken));

  return gitHub.users.getCurrentUser();
}
