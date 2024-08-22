import 'package:ai_chatbot/providers/get_all_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'message_tile.dart';

class MessagesList extends ConsumerWidget {
  const MessagesList({super.key, required this.userId });


  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final messageData = ref.watch(getAllMessagesProvider(userId));
    return messageData.when(
        data: (messages){
          return ListView.builder (
            reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index){
                final message = messages.elementAt(index);
                return MessageTile(message: message, isOutgoing: message.isMine,);
              }
          );

        },
        error: (error, stackTrace){
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: (){
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

  }
}
