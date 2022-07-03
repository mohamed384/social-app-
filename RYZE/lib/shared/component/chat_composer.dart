import 'package:flutter/material.dart';

Container buildChatComposer() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Colors.white,
    height: 100,
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.grey[500],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message ...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
                Icon(
                  Icons.attach_file,
                  color: Colors.grey[500],
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.mic,
            color: Colors.white,
          ),
        )
      ],
    ),
  );
}
