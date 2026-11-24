import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:splitwise/models/invited_member.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> memberIds;
  final List<String> invitedEmails; // Keep for backward compatibility
  final List<InvitedMember> invitedMembers; // New field for invited members with names

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.memberIds = const [],
    this.invitedEmails = const [], // Keep for backward compatibility
    this.invitedMembers = const [], // New field for invited members with names
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'invitedEmails': invitedEmails, // Keep for backward compatibility
      'invitedMembers': invitedMembers.map((member) => member.toMap()).toList(),
    };
  }

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    if (kDebugMode) {
      print('Group data from Firestore: $data');
    } // Debug print
    
    // Handle invited members - check if new format exists, otherwise use legacy format
    List<InvitedMember> invitedMembers = [];
    List<String> invitedEmails = List<String>.from(data['invitedEmails'] ?? []);
    
    if (data['invitedMembers'] != null) {
      invitedMembers = (data['invitedMembers'] as List)
          .map((memberData) => InvitedMember.fromMap(memberData as Map<String, dynamic>))
          .toList();
    } else if (invitedEmails.isNotEmpty) {
      // Convert legacy email-only format to new format with email as name
      invitedMembers = invitedEmails
          .map((email) => InvitedMember(name: email.split('@')[0], email: email))
          .toList();
    }
    
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      invitedEmails: invitedEmails, // Keep for backward compatibility
      invitedMembers: invitedMembers,
    );
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    // Handle invited members - check if new format exists, otherwise use legacy format
    List<InvitedMember> invitedMembers = [];
    List<String> invitedEmails = List<String>.from(map['invitedEmails'] ?? []);
    
    if (map['invitedMembers'] != null) {
      invitedMembers = (map['invitedMembers'] as List)
          .map((memberData) => InvitedMember.fromMap(memberData as Map<String, dynamic>))
          .toList();
    } else if (invitedEmails.isNotEmpty) {
      // Convert legacy email-only format to new format with email as name
      invitedMembers = invitedEmails
          .map((email) => InvitedMember(name: email.split('@')[0], email: email))
          .toList();
    }
    
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      creatorId: map['creatorId'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      invitedEmails: invitedEmails, // Keep for backward compatibility
      invitedMembers: invitedMembers,
    );
  }
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    List<String>? memberIds,
    List<String>? invitedEmails,
    List<InvitedMember>? invitedMembers,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      invitedEmails: invitedEmails ?? this.invitedEmails,
      invitedMembers: invitedMembers ?? this.invitedMembers,
    );
  }
  
  // Helper method to get all invited emails for backward compatibility
  List<String> get allInvitedEmails {
    final emails = <String>{};
    emails.addAll(invitedEmails);
    emails.addAll(invitedMembers.map((member) => member.email));
    return emails.toList();
  }
}
