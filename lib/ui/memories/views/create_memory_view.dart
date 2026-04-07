import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/memories/view_models/create_memory_view_model.dart';
import 'package:provider/provider.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming repository is provided elsewhere
    // viewModel = MemoryCreationViewModel(repository);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemoryCreationViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Memory")),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stepper(
            currentStep: viewModel.currentStep,
            onStepContinue: viewModel.nextStep,
            onStepCancel: viewModel.previousStep,
            onStepTapped: (step) => viewModel.setStep(step),
            steps: [
              Step(
                isActive: viewModel.currentStep >= 0,
                title: const Text("Basic Info"),
                content: const SizedBox(
                  height: 100,
                  child: Text("Metadata fields go here"),
                ),
              ),
              Step(
                isActive: viewModel.currentStep >= 1,
                title: const Text("Friends"),
                content: const SizedBox(
                  height: 100,
                  child: Text("Friend selection goes here"),
                ),
              ),
              Step(
                isActive: viewModel.currentStep >= 2,
                title: const Text("Photos"),
                content: const SizedBox(
                  height: 100,
                  child: Text("Photo uploader goes here"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
