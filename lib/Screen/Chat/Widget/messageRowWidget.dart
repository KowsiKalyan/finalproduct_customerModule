import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/chatProvider.dart';

class MessageRow extends StatefulWidget {
  String? status;
  Function update;
  String? id;
  MessageRow({
    Key? key,
    required this.update,
    required this.id,
    required this.status,
  }) : super(key: key);

  @override
  State<MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  _imgFromGallery(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      context.read<ChatProvider>().files =
          result.paths.map((path) => File(path!)).toList();
      widget.update();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.status != '4'
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              color: Theme.of(context).colorScheme.white,
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _imgFromGallery(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: context.read<ChatProvider>().msgController,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'Write message...')!,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (context
                              .read<ChatProvider>()
                              .msgController
                              .text
                              .trim()
                              .isNotEmpty ||
                          context.read<ChatProvider>().files.isNotEmpty) {
                        context.read<ChatProvider>().sendMessage(
                              context
                                  .read<ChatProvider>()
                                  .msgController
                                  .text
                                  .trim(),
                              context,
                              widget.update,
                              widget.id,
                            );
                      }
                    },
                    backgroundColor: colors.primary,
                    elevation: 0,
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
