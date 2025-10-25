import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common/widgets/connection_page_title.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../../common.dart';
import '../../common/formatter/id_formatter.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with SingleTickerProviderStateMixin, WindowListener {
  final _idController = IDTextEditingController();
  final RxBool _idInputFocused = false.obs;
  final FocusNode _idFocusNode = FocusNode();
  final TextEditingController _idEditingController = TextEditingController();

  bool isWindowMinimized = false;

  @override
  void initState() {
    super.initState();
    _idFocusNode.addListener(onFocusChanged);
    if (_idController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final lastRemoteId = await bind.mainGetLastRemoteId();
        if (lastRemoteId != _idController.id) {
          setState(() {
            _idController.id = lastRemoteId;
          });
        }
      });
    }
    Get.put<TextEditingController>(_idEditingController);
    Get.put<IDTextEditingController>(_idController);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _idController.dispose();
    windowManager.removeListener(this);
    _idFocusNode.removeListener(onFocusChanged);
    _idFocusNode.dispose();
    _idEditingController.dispose();
    if (Get.isRegistered<IDTextEditingController>()) Get.delete<IDTextEditingController>();
    if (Get.isRegistered<TextEditingController>()) Get.delete<TextEditingController>();
    super.dispose();
  }

  void onFocusChanged() {
    _idInputFocused.value = _idFocusNode.hasFocus;
    if (_idFocusNode.hasFocus) {
      final textLength = _idEditingController.value.text.length;
      _idEditingController.selection =
          TextSelection(baseOffset: 0, extentOffset: textLength);
    }
  }

  void onConnect() {
    var id = _idController.id;
    connect(context, id);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(13)),
          border: Border.all(color: Theme.of(context).colorScheme.background),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getConnectionPageTitle(context, false).marginOnly(bottom: 15),
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextField(
                        controller: _idEditingController,
                        focusNode: _idFocusNode,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(
                            fontFamily: 'WorkSans', fontSize: 22, height: 1.4),
                        maxLines: 1,
                        cursorColor: Theme.of(context).textTheme.titleLarge?.color,
                        decoration: InputDecoration(
                            filled: false,
                            counterText: '',
                            hintText: _idInputFocused.value
                                ? null
                                : translate('Enter Remote ID'),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 13)),
                        inputFormatters: [IDTextInputFormatter()],
                        onChanged: (v) => _idController.id = v,
                        onSubmitted: (_) => onConnect(),
                      )),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28.0,
                  child: ElevatedButton(
                    onPressed: onConnect,
                    child: Text(translate("Connect")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
