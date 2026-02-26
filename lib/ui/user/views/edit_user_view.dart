import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/auth/views/logout_view.dart';
import 'package:provider/provider.dart';
import '../view_models/edit_user_view_model.dart';

class EditUserDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserDialog({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  @override
  void initState() {
    super.initState();
    // Initialize the VM with current data on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditUserViewModel>().init(widget.userData);
    });
  }

  void _handleSave(EditUserViewModel vm) async {
    final success = await vm.saveUser(widget.userId);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<EditUserViewModel>(
      builder: (context, vm, child) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SizedBox(
            width:
                double.maxFinite, // Ensures the dialog doesn't shrink too much
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: vm.nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  TextField(
                    controller: vm.bioController,
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // DOB Picker Styled as an Input
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: vm.selectedDob ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) vm.updateDob(picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Birthdate",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        vm.selectedDob == null
                            ? "Select Date"
                            : "${vm.selectedDob!.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: vm.selectedGender,
                    items: ["Male", "Female", "Other"]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: vm.updateGender,
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      prefixIcon: Icon(Icons.transgender),
                    ),
                  ),
                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        vm.errorMessage!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const LogoutButton(),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                // SAVE BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _handleSave(vm),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
