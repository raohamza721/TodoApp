//
//
// import 'package:flutter/material.dart';
//
//
//
// class PopupCardButton2 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//               content: SizedBox(
//                 height: 200,
//                 width: 300,
//                 child: Column(
//                   children: [
//                     Text(
//                       "This is a pop-up card!",
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 20),
//                     Text("You can put any content you like here."),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(); // Close the dialog
//                       },
//                       child: Text("Close"),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//       child: Text("Show Pop-up Card"),
//     );
//   }
// }
