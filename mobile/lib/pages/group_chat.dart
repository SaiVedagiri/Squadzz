import 'package:flutter/material.dart';
import 'package:image/comps/styles.dart';
import 'package:image/comps/widgets.dart';

class ChatPage extends StatelessWidget {
  final String id;
  const ChatPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade400,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: const Text('John Doe'),
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chats',
                  style: Styles.h1(),
                ),
                const Spacer(),
                Text(
                  'Last seen: 04:50',
                  style: Styles.h1().copyWith(fontSize: 12,fontWeight: FontWeight.normal,color: Colors.white70),
                ),

                const Spacer(),
                const SizedBox(width: 50,)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: Styles.friendsBox(),

              child: ListView.builder(
                itemCount: 5,
                reverse: true,
                itemBuilder: (context, i) {
                  return ChatWidgets.messagesCard(i,'Firebase projects are containers for your app Apps in a project share features like Real-time Database and Analytics','04:51 pm');
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child:ChatWidgets.messageField(onSubmit: (controller){controller.clear();}) ,
          )

        ],
      ),
    );
  }
}