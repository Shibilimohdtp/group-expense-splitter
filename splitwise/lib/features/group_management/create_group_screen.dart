import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/models/group.dart';
import 'package:splitwise/models/invited_member.dart';
import 'package:splitwise/services/auth_service.dart';
import 'package:splitwise/services/group_service.dart';

import 'package:splitwise/widgets/common/action_bottom_bar.dart';
import 'package:splitwise/widgets/common/animated_wrapper.dart';
import 'package:splitwise/widgets/create_group/group_info_section.dart';
import 'package:splitwise/widgets/create_group/members_section.dart';
import 'package:splitwise/widgets/feedback/status_snackbar.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? group;
  const CreateGroupScreen({super.key, this.group});

  @override
  CreateGroupScreenState createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  final List<InvitedMember> _members = [];
  bool get _isEditMode => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name);
    _descriptionController =
        TextEditingController(text: widget.group?.description);
    if (_isEditMode) {
      // Convert existing invited emails to InvitedMember objects
      for (String email in widget.group!.invitedEmails) {
        _members.add(InvitedMember(name: email.split('@')[0], email: email));
      }
      // Also add any existing InvitedMember objects
      _members.addAll(widget.group!.invitedMembers);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final groupService = GroupService();
        if (_isEditMode) {
          final updatedGroup = widget.group!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            invitedMembers: _members,
          );
          await groupService.updateGroup(updatedGroup);
          if (mounted) {
            StatusSnackbar.showSuccess(
              context,
              message: 'Group updated successfully!',
            );
            Navigator.of(context).pop(true);
          }
        } else {
          final authService = Provider.of<AuthService>(context, listen: false);
          final currentUser = authService.currentUser;

          if (currentUser == null) {
            throw Exception('No user logged in. Please sign in again.');
          }

          // Create the group first
          final group = await groupService.createGroup(
            _nameController.text.trim(),
            _descriptionController.text.trim(),
            currentUser.uid,
          );

          if (group != null) {
            // If there are members to add
            if (_members.isNotEmpty) {
              try {
                // Add members one by one and catch individual errors
                for (InvitedMember member in _members) {
                  try {
                    await groupService.inviteMember(group.id, member.email);
                  } catch (memberError) {
                    // Log the error but continue with other members
                    if (kDebugMode) {
                      print('Error adding member ${member.email}: $memberError');
                    }
                    // Optionally show a warning for this specific member
                    if (mounted) {
                      StatusSnackbar.showError(
                        context,
                        message: 'Could not add ${member.name}',
                        details: memberError.toString(),
                      );
                    }
                  }
                }
              } catch (membersError) {
                // If there's a general error with adding members, log it
                if (kDebugMode) {
                  print('Error adding members: $membersError');
                }
                // But still consider the group creation successful
              }
            }

            if (mounted) {
              // Show success message before popping
              StatusSnackbar.showSuccess(
                context,
                message: 'Group created successfully!',
              );
              // Delay navigation slightly to allow snackbar to be seen
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              });
            }
          } else {
            throw Exception('Failed to create group. Please try again.');
          }
        }
      } catch (e) {
        if (mounted) {
          StatusSnackbar.showError(
            context,
            message: _isEditMode
                ? 'Failed to update group'
                : 'Failed to create group',
            details: e.toString(),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _addMember(InvitedMember member) {
    // Check if member with same email already exists
    if (_members.any((m) => m.email == member.email)) {
      StatusSnackbar.showError(context,
          message: 'This email is already added to the group');
      return;
    }

    // Add the member
    setState(() {
      _members.add(member);
    });

    // Show a small confirmation
    StatusSnackbar.showInfo(
      context,
      message: '${member.name} added to group',
    );
  }

  void _removeMember(InvitedMember member) {
    setState(() {
      _members.remove(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          _isEditMode ? 'Edit Group' : 'Create New Group',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
          iconSize: 20,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: [
            _buildAnimatedSection(
              index: 0,
              child: GroupInfoSection(
                nameController: _nameController,
                descriptionController: _descriptionController,
                nameValidator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
                descriptionValidator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),
            _buildAnimatedSection(
              index: 1,
              child: MembersSection(
                members: _members,
                onAddMember: _addMember,
                onRemoveMember: _removeMember,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ActionBottomBar(
        actionText: _isEditMode ? 'Save Changes' : 'Create Group',
        onAction: _submit,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return AnimatedWrapper.staggered(
      index: index,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: child,
      ),
    );
  }
}
