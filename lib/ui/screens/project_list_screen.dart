import 'package:chinese_english_term_corrector/ui/screens/projectscreen/project_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import '../../repositories/project_repository.dart';
import '../../models/project.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectRepository>(context, listen: false).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectsScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: l10n.importProjectTooltip,
            onPressed: _importProject,
          ),
        ],
      ),
      body: Consumer<ProjectRepository>(
        builder: (context, projectRepo, child) {
          if (projectRepo.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectRepo.error != null) {
            return Center(
              child: Text(
                l10n.errorWithMessage(projectRepo.error!),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (projectRepo.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noProjectsMessage,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateProjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newProject),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.totalProjects(projectRepo.projects.length),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: projectRepo.projects.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final project = projectRepo.projects[index];
                    return ProjectListItem(
                      project: project,
                      onTap: () => _openProject(project),
                      onDelete: () => _deleteProject(project.id),
                      onExport: () => _exportProject(project),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newProject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                hintText: l10n.projectNameHint,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptional,
                hintText: l10n.descriptionHint,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final projRepo = Provider.of<ProjectRepository>(
                  context,
                  listen: false,
                );
                projRepo
                    .createProject(
                  nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null,
                )
                    .then((project) {
                  Navigator.of(context).pop();
                  _openProject(project);
                });
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _openProject(Project project) {
    final projectRepo = Provider.of<ProjectRepository>(
      context,
      listen: false,
    );
    projectRepo.selectProject(project.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectScreen(project: project),
      ),
    );
  }

  Future<void> _deleteProject(String projectId) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final projectRepo = Provider.of<ProjectRepository>(
        context,
        listen: false,
      );
      await projectRepo.deleteProject(projectId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.projectDeleted)),
      );
    }
  }

  Future<void> _exportProject(Project project) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final projectRepo = Provider.of<ProjectRepository>(
        context,
        listen: false,
      );
      final jsonContent = await projectRepo.exportProject(project);

      final result = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportProjectDialogTitle,
        fileName: '${project.name.replaceAll(' ', '_')}_project.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportSuccess)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    }
  }

  Future<void> _importProject() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        final projectRepo = Provider.of<ProjectRepository>(
          context,
          listen: false,
        );
        final project = await projectRepo.importProject(content);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importSuccess),
          ),
        );

        _openProject(project);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    }
  }
}

class ProjectListItem extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const ProjectListItem({
    Key? key,
    required this.project,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.folder, color: Colors.white),
      ),
      title: Text(
        project.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.description != null && project.description!.isNotEmpty)
            Text(
              project.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text(
            l10n.projectDetails(
                project.documents.length, _formatDate(project.updatedAt)),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') {
            onDelete();
          } else if (value == 'export') {
            onExport();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                const Icon(Icons.file_download, size: 18),
                const SizedBox(width: 8),
                Text(l10n.exportAction),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.deleteAction,
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
