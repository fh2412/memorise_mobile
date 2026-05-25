import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:provider/provider.dart';
import '../view_models/edit_memory_view_model.dart';

class EditMemoryDialog extends StatefulWidget {
  final Memory memory;

  const EditMemoryDialog({super.key, required this.memory});

  @override
  State<EditMemoryDialog> createState() => _EditMemoryDialogState();
}

class _EditMemoryDialogState extends State<EditMemoryDialog> {
  @override
  void initState() {
    super.initState();
    // Initialize the VM with current memory data on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditMemoryViewModel>().init(widget.memory);
    });
  }

  void _handleSave(EditMemoryViewModel vm) async {
    final success = await vm.saveMemory(widget.memory.memoryId);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  void _handleDelete(EditMemoryViewModel vm) async {
    // 1. Read your favorite state (Assume your VM or Model tracks if it's pinned)
    final isFavourite =
        widget.memory.shareToken != null; // Substitute with actual flag check

    // 2. Fire VM call
    final success = await vm.deleteMemory(
      widget.memory.memoryId,
      isFavourite: isFavourite,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<EditMemoryViewModel>(
      builder: (context, vm, child) {
        return AlertDialog(
          title: const Text("Edit Memory"),
          content: SizedBox(
            width:
                double.maxFinite, // Ensures the dialog doesn't shrink too much
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE FIELD
                  TextField(
                    controller: vm.titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TEXT / DESCRIPTION FIELD
                  TextField(
                    controller: vm.textController,
                    decoration: const InputDecoration(
                      labelText: "Story / Description",
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // START DATE PICKER
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: vm.selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) vm.updateStartDate(picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Start Date",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        vm.selectedStartDate == null
                            ? "Select Start Date"
                            : "${vm.selectedStartDate!.toLocal()}".split(
                                ' ',
                              )[0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // END DATE PICKER
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            vm.selectedEndDate ??
                            vm.selectedStartDate ??
                            DateTime.now(),
                        firstDate: vm.selectedStartDate ?? DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) vm.updateEndDate(picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "End Date",
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      child: Text(
                        vm.selectedEndDate == null
                            ? "Select End Date"
                            : "${vm.selectedEndDate!.toLocal()}".split(' ')[0],
                      ),
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

                  // DESTRUCTIVE ACTION BUTTON (Replacing Logout)
                  OutlinedButton.icon(
                    onPressed: vm.isLoading ? null : () => _handleDelete(vm),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text("Delete Memory"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(
                        color: colorScheme.error.withOpacity(0.5),
                      ),
                      minimumSize: const Size.fromHeight(
                        48,
                      ), // Match system block sizes
                    ),
                  ),
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
                // CANCEL BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () => Navigator.pop(context),
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
