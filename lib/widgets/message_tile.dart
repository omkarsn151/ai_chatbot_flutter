import 'package:flutter/material.dart';

import '/models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isOutgoing ? Colors.blue[400]?.withOpacity(0.8) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: isOutgoing
              ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2
                )
          ]
              : [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width*.70
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isOutgoing ? Colors.white : Colors.white,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 10),
              message.imgUrl != null
                  ? Image.network(message.imgUrl!)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}


