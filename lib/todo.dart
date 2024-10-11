import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _submitdata() async {
    String task = _textEditingController.text.toString().trim();

    if (task.isNotEmpty) {
      DocumentReference docRef = firestore.collection('task').doc();

      await docRef.set({
        'task': task,
        'isChecked': false,
        'taskId': docRef.id,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );

      _textEditingController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task')),
      );
    }
  }

  Future<void> _deleteTask(String task) async {
    try {
      await firestore.collection('task').doc(task).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the task')),
      );
    }
  }

  Future<void> _editTask(String taskId, String task) async {
    TextEditingController _editController = TextEditingController();
    _editController.text = task;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Task",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _editController,
                  decoration: InputDecoration(
                    hintText: 'Update your task',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        String updatedTask = _editController.text.trim();
                        if (updatedTask.isNotEmpty) {
                          await firestore.collection('task').doc(taskId).update({
                            'task': updatedTask,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid task'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color to white
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Text(
                "My TODO's",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Add Your Task',
                  filled: true,
                  fillColor: Colors.grey[200], // Light grey background
                  prefixIcon: const Icon(Icons.add, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitdata,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('task')
                    .orderBy('created_at', descending: false)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                                                  ),
                        child: ListTile(
                          leading: InkWell(
                            onTap: () async {
                              bool val = data[index]['isChecked'];
                              await firestore.collection("task").doc(data[index].id).update({
                                "isChecked": !val,
                              });
                            },
                            child: Icon(
                              data[index]['isChecked'] == false
                                  ? Icons.check_box_outline_blank
                                  : Icons.check_box,
                              color: data[index]['isChecked'] ? Colors.green : Colors.black,
                            ),
                          ),
                          title: Text(
                            data[index]['task'],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              decoration: data[index]['isChecked']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  _editTask(data[index].id, data[index]['task']);
                                },
                                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              ),
                              IconButton(
                                onPressed: () {
                                  _deleteTask(data[index].id);
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


























// class TodoScreen extends StatefulWidget {
//   const TodoScreen({super.key});
//
//   @override
//   State<TodoScreen> createState() => _TodoScreenState();
// }
//
// class _TodoScreenState extends State<TodoScreen> {
//
//   final TextEditingController _textEditingController = TextEditingController();
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//
//
//   Future<void> _submitdata() async {
//     String task = _textEditingController.text.toString().trim();
//
//     if (task.isNotEmpty) {
//       DocumentReference docRef = firestore.collection('task').doc();
//
//       await docRef.set({
//         'task': task,
//         'isChecked':false,
//         'taskId': docRef.id,
//         'created_at': Timestamp.now(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Task added successfully')),
//       );
//
//       // Clear text field after adding task
//       _textEditingController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a task')),
//       );
//     }
//   }
//
//
//   Future<void> _deleteTask(String task) async {
//     try {
//       await firestore.collection('task').doc(task).delete();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Task deleted successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to delete the task')),
//       );
//     }
//   }
//
//
//
//   Future<void> _editTask(String taskId, String task) async {
//     TextEditingController _editController = TextEditingController();
//     _editController.text = task;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Edit Task"),
//           content: TextField(
//             controller: _editController,
//             decoration: const InputDecoration(
//               hintText: 'Update your task',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog without updating
//               },
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String updatedTask = _editController.text.trim();
//                 if (updatedTask.isNotEmpty) {
//                   // Update the task in Firestore
//                   await firestore.collection('task').doc(taskId).update({
//                     'task': updatedTask,
//                   });
//
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Task updated successfully')),
//                   );
//                   Navigator.of(context).pop(); // Close the dialog after updating
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please enter a valid task')),
//                   );
//                 }
//               },
//               child: const Text("Update"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       body: Container(
//         child: Column(
//           children: [
//             const SizedBox(height: 50),
//             const Center(
//               child: Text(
//                 "My TODO's",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _textEditingController,
//                 // Connect the controller to the TextField
//                 decoration: InputDecoration(
//                   hintText: 'Add Your Task',
//                   prefixIcon: const Icon(Icons.add),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),
//             ElevatedButton(
//               onPressed: _submitdata,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//               ), // Add the task when pressed
//               child: const Text(
//                 'Add',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 50),
//
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: firestore.collection('task').orderBy('created_at', descending: false).snapshots(),
//                 builder:
//                     (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   var data = snapshot.data!.docs;
//
//                   return ListView.builder(
//                     itemCount: data.length,
//                     itemBuilder: (BuildContext context, int index) {
//
//
//                       return ListTile(
//                         leading: InkWell(onTap:()async{
//                          bool val= data[index]['isChecked'];
//                          if(val==true){
//                            await FirebaseFirestore.instance.collection("task").doc(data[index].id).update({
//                              "isChecked":false,
//                            });
//                          }
//                          else{
//                            await FirebaseFirestore.instance.collection("task").doc(data[index].id).update({
//                              "isChecked":true,
//                            });
//                          }
//
//                     },child: Icon(data[index]['isChecked']==false?Icons.check_box_outline_blank:Icons.check_box)),
//                         title: Text(data[index]['task'], style:TextStyle(color: Colors.green,decoration:data[index]['isChecked']==true? TextDecoration.lineThrough:TextDecoration.none)),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             IconButton(onPressed: () {
//
//                               _editTask(data[index].id, data[index]['task']);
//                               // Navigator.push(context, MaterialPageRoute(builder: (context)=> PopUpEdit()));
//                               print("edit clicked");
//                             },
//                               icon: const Icon(Icons.edit),
//                               color: Colors.blueGrey,),
//                             const SizedBox(width: 5,),
//                             IconButton(onPressed: () {
//                               _deleteTask(data[index].id);
//                               print("Delete clicked");
//                             },
//                               icon: const Icon(Icons.delete),
//                               color: Colors.red,),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   }




