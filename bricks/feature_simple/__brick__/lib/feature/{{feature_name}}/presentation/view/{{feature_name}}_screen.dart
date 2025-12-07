import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/feature/{{feature_name}}/presentation/controller/{{feature_name}}_controller.dart';

class {{feature_name.pascalCase()}}Screen extends GetView<{{feature_name.pascalCase()}}Controller> {
  const {{feature_name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{{feature_name.pascalCase()}}'),
      ),
      body: Obx(
        () {
          final data = controller.{{model_name.camelCase()}}List;
          if (data.isEmpty && controller.status == ControllerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.isEmpty) {
            return const Center(child: Text('No data'));
          }
          return RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.title ?? 'Untitled'),
                    subtitle: Text(item.description ?? ''),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

