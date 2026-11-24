import 'package:flutter/material.dart';
import 'package:splitwise/models/invited_member.dart';
import 'package:splitwise/widgets/create_group/add_member_dialog.dart';

class MembersSection extends StatelessWidget {
  final List<InvitedMember> members;
  final Function(InvitedMember) onAddMember;
  final Function(InvitedMember) onRemoveMember;

  const MembersSection({
    super.key,
    required this.members,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(
            context,
            colorScheme,
            textTheme,
            icon: Icons.group_add_rounded,
            title: 'Add Members',
            subtitle: 'Invite members to the group',
            primaryColor: colorScheme.secondary,
            badgeText: '${members.length} added',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAddMemberButton(context),
                const SizedBox(height: 16),
                _buildMembersList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required String badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.05),
            primaryColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              badgeText,
              style: textTheme.labelSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddMemberDialog(context),
        icon: Icon(
          Icons.person_add_rounded,
          color: colorScheme.secondary,
          size: 20,
        ),
        label: Text(
          'Add Member',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.secondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          backgroundColor: colorScheme.secondary.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final member = await showDialog<InvitedMember>(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
    
    if (member != null) {
      onAddMember(member);
    }
  }

  Widget _buildMembersList(BuildContext context) {
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.no_accounts_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No members added',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap "Add Member" to invite people to your group.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: members.map((member) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text(
              member.email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              onPressed: () => onRemoveMember(member),
            ),
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
          ),
        );
      }).toList(),
    );
  }
}
