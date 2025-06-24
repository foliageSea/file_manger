import 'package:core/core.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/services/server_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final controller = Get.find<HomeController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AddDialogForm form = AddDialogForm();
  ServerService serverService = Global.getIt();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增'),
      content: SingleChildScrollView(child: _buildForm()),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('取消'),
        ),
        TextButton(onPressed: _handleSubmit, child: const Text('提交')),
      ],
    );
  }

  void _handleSubmit() async {
    var validate = formKey.currentState?.validate();
    if (validate != true) {
      return;
    }
    formKey.currentState?.save();

    var formData = form.getFormData();

    await controller.addServer(formData);

    Get.back();
  }

  Form _buildForm() {
    return Form(
      key: formKey,
      child: SizedBox(
        width: 350,
        child: Column(
          children: [
            TextFormField(
              validator: FormValidatorUtil.required,
              onSaved: (value) {
                form.name = value!;
              },
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '请输入名称',
              ),
            ),
            TextFormField(
              validator: FormValidatorUtil.required,
              onSaved: (value) {
                form.server = value!;
              },

              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: '请输入服务器地址',
              ),
            ),
            TextFormField(
              validator: FormValidatorUtil.required,
              onSaved: (value) {
                form.username = value!;
              },
              decoration: const InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
              ),
            ),
            TextFormField(
              obscureText: true,
              validator: FormValidatorUtil.required,
              onSaved: (value) {
                form.password = value!;
              },
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
              ),
            ),
          ].insertSizedBoxBetween(height: 16),
        ),
      ),
    );
  }
}

class AddDialogForm {
  String name = "";
  String server = "";
  String username = "";
  String password = "";

  AddDialogForm();

  Map<String, String> getFormData() {
    return {
      "name": name,
      "server": server,
      "username": username,
      "password": password,
    };
  }
}
