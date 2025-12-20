// user_management_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin_provider.dart';

class UserManagementSection extends StatelessWidget {
  const UserManagementSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 24),
                // Add/Edit Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: provider.formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: provider.nameController,
                            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: provider.emailController,
                            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                            readOnly: provider.editingUserId != null,
                          ),
                          const SizedBox(height: 16),
                          if (provider.editingUserId == null)
                            TextFormField(
                              controller: provider.passwordController,
                              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                              obscureText: true,
                              validator: (v) => (v?.length ?? 0) < 6 ? 'Minimum 6 characters' : null,
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: provider.roleController,
                            decoration: const InputDecoration(
                              labelText: 'Role (e.g., job_seeker, recruiter, admin)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: provider.userLevelController,
                            decoration: const InputDecoration(labelText: 'User Level (free/pro)', border: OutlineInputBorder()),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: provider.isLoading ? null : () => provider.addOrEditUser(context),
                                child: provider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(provider.editingUserId == null ? 'Add User' : 'Update User'),
                              ),
                              const SizedBox(width: 12),
                              if (provider.editingUserId != null)
                                TextButton(
                                  onPressed: provider.clearForm,
                                  child: const Text('Cancel'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Users Table
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final users = snapshot.data!.docs;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 56,
                          dataRowHeight: 64,
                          columns: const [
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Level', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: users.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final firestoreDocId = doc.id;
                            final status = data['account_status'] ?? 'active';

                            return DataRow(cells: [
                              DataCell(Text(data['name'] ?? '-')),
                              DataCell(Text(data['email'] ?? '-')),
                              DataCell(Text(data['role'] ?? '-')),
                              DataCell(Text(data['user_lvl'] ?? '-')),
                              DataCell(
                                Chip(
                                  label: Text(status.toUpperCase()),
                                  backgroundColor: status == 'active' ? Colors.green[100] : Colors.red[100],
                                  labelStyle: TextStyle(
                                    color: status == 'active' ? Colors.green[800] : Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit User',
                                      onPressed: () => provider.editUser(data, firestoreDocId),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        status == 'active' ? Icons.block : Icons.check_circle,
                                        color: Colors.orange,
                                      ),
                                      tooltip: status == 'active' ? 'Suspend User' : 'Activate User',
                                      onPressed: () => provider.suspendUser(firestoreDocId, status),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.key, color: Colors.purple),
                                      tooltip: 'Reset Password',
                                      onPressed: () => provider.resetPassword(data['email'] ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),

                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}