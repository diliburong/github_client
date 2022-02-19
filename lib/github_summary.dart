import 'package:flutter/material.dart';
import 'package:github/github.dart';

class GithubSummary extends StatefulWidget {
  const GithubSummary({required this.gitHub, Key? key}) : super(key: key);
  final GitHub gitHub;

  @override
  _GithubSummaryState createState() => _GithubSummaryState();
}

class _GithubSummaryState extends State<GithubSummary> {
  int _selectedIndex = 0;
  Color c = const Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(
                Icons.favorite,
              ),
              label: SelectableText('Repositories'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.star),
              label: SelectableText('Assigned Issues'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.access_alarms),
              label: SelectableText('Pull Requests'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              RepositoriesList(gitHub: widget.gitHub),
              AssignedIssuesList(gitHub: widget.gitHub),
              PullRequestsList(gitHub: widget.gitHub)
            ],
          ),
        ),
      ],
    );
  }
}

class RepositoriesList extends StatefulWidget {
  const RepositoriesList({
    Key? key,
    required this.gitHub,
  }) : super(key: key);

  final GitHub gitHub;

  @override
  _RepositoriesListState createState() => _RepositoriesListState();
}

class _RepositoriesListState extends State<RepositoriesList> {
  @override
  void initState() {
    super.initState();

    _repositories = widget.gitHub.repositories.listRepositories().toList();
  }

  late Future<List<Repository>> _repositories;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Repository>>(
      future: _repositories,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: SelectableText('${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var repositories = snapshot.data;

        return ListView.builder(
          itemBuilder: (context, index) {
            var repository = repositories![index];

            return ListTile(
              title: SelectableText(
                  '${repository.owner?.login ?? ''}/${repository.name}'),
              subtitle: SelectableText(repository.description),
            );
          },
          itemCount: snapshot.data!.length,
        );
      },
    );
  }
}

class AssignedIssuesList extends StatefulWidget {
  const AssignedIssuesList({
    Key? key,
    required this.gitHub,
  }) : super(key: key);

  final GitHub gitHub;

  @override
  _AssignedIssuesListState createState() => _AssignedIssuesListState();
}

class _AssignedIssuesListState extends State<AssignedIssuesList> {
  @override
  initState() {
    super.initState();
    _assignedIssues = widget.gitHub.issues.listByUser().toList();
  }

  late Future<List<Issue>> _assignedIssues;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Issue>>(
      future: _assignedIssues,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: SelectableText('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var assignedIssues = snapshot.data;
        return ListView.builder(
          itemBuilder: (context, index) {
            var assignedIssue = assignedIssues![index];
            return ListTile(
              title: SelectableText(assignedIssue.title),
              subtitle: SelectableText('${_nameWithOwner(assignedIssue)} '
                  'Issue #${assignedIssue.number} '
                  'opened by ${assignedIssue.user?.login ?? ''}'),
              // onTap: () => _launchUrl(context, assignedIssue.htmlUrl),
            );
          },
          itemCount: assignedIssues!.length,
        );
      },
    );
  }

  String _nameWithOwner(Issue assignedIssue) {
    final endIndex = assignedIssue.url.lastIndexOf('/issues/');
    return assignedIssue.url.substring(29, endIndex);
  }
}

class PullRequestsList extends StatefulWidget {
  const PullRequestsList({required this.gitHub, Key? key}) : super(key: key);
  final GitHub gitHub;

  @override
  _PullRequestsListState createState() => _PullRequestsListState();
}

class _PullRequestsListState extends State<PullRequestsList> {
  @override
  initState() {
    super.initState();
    _pullRequests = widget.gitHub.pullRequests
        .list(RepositorySlug('diliburong', 'koa2-blog'))
        .toList();
  }

  late Future<List<PullRequest>> _pullRequests;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PullRequest>>(
      future: _pullRequests,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: SelectableText('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var pullRequests = snapshot.data;
        return ListView.builder(
          itemBuilder: (context, index) {
            var pullRequest = pullRequests![index];
            return ListTile(
              title: SelectableText(pullRequest.title ?? ''),
              subtitle: SelectableText('flutter/flutter '
                  'PR #${pullRequest.number} '
                  'opened by ${pullRequest.user?.login ?? ''} '
                  '(${pullRequest.state?.toLowerCase() ?? ''})'),
              // onTap: () => _launchUrl(context, pullRequest.htmlUrl ?? ''),
            );
          },
          itemCount: pullRequests!.length,
        );
      },
    );
  }
}
