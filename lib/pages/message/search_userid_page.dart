import 'package:flutter/material.dart';

class SearchUseridPage extends StatefulWidget {
  const SearchUseridPage({Key? key}) : super(key: key);

  @override
  State<SearchUseridPage> createState() => _SearchUseridPageState();
}

class _SearchUseridPageState extends State<SearchUseridPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Temukan user', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
