import 'package:core/core.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/services/server_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class EditDialog extends StatefulWidget {
  final ServerModel serverModel;

  const EditDialog({super.key, required this.serverModel});

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final controller = Get.find<HomeController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EditDialogForm form = EditDialogForm();
  ServerService serverService = Global.getIt();

  @override
  void initState() {
    super.initState();
    form.setFormData(widget.serverModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('编辑-${widget.serverModel.name}'),
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

    await controller.updateServer(widget.serverModel, formData);

    Get.back();
  }

  Form _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: form.name,
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
            initialValue: form.server,
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
            initialValue: form.username,
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
            initialValue: form.password,
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
    );
  }
}

class EditDialogForm {
  String name = "";
  String server = "";
  String username = "";
  String password = "";

  EditDialogForm();

  Map<String, String> getFormData() {
    return {
      "name": name,
      "server": server,
      "username": username,
      "password": password,
    };
  }

  void setFormData(ServerModel serverModel) {
    name = serverModel.name;
    server = serverModel.url;
    username = serverModel.username;
    password = serverModel.password;
  }
}
