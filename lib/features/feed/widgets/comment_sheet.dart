import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/repositories/audio_repository.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final repository = Get.find<AudioRepository>();
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.fetchComments(widget.postId),
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (_, index) {
                  final comment = comments[index];

                  return ListTile(
                    title: Text(comment.text),
                    subtitle: Text("Reply available"),
                  );
                },
              ),
            ),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () async {
                await repository.createComment(
                  postId: widget.postId,
                  text: controller.text,
                );
                Navigator.pop(context);
              },
              child: const Text("ارسال"),
            ),
          ],
        );
      },
    );
  }
}
