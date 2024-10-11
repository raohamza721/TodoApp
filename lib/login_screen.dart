import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/create_account_screen.dart';
import 'package:todoapp/expense_screen.dart';

class loginScreen extends StatefulWidget{

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  @override
  Widget build(BuildContext context) {


   final TextEditingController _emailController = TextEditingController();
   final TextEditingController _passwordController = TextEditingController();


   Future<void> _login() async {

     String email = _emailController.text.trim();
     String password = _passwordController.text.trim();

     try {
       UserCredential userCredential = await FirebaseAuth.instance
           .signInWithEmailAndPassword(
         email: email,
         password: password,
       );

       User? user = userCredential.user;
       if (user != null) {
         String userId = user.uid; // Get the userID

         // Navigate to DashboardScreen and pass the userID
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (context) => ExpenseScreen(),
           ),
         );

         // Show success message
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Login successful!')),
         );
       }
     } on FirebaseAuthException catch (e) {


       String message;
       if (e.code == 'user-not-found') {
         message = 'No user found for that email.';
       } else if (e.code == 'wrong-password') {
         message = 'Wrong password provided.';
       } else {
         message = 'Login failed. Please try again.';
       }

       // Show error message
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(message)),
       );
     }
   }





    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(

          children: [
            const SizedBox(height: 50),
            const Text('Login ', style:  TextStyle(
              fontSize: 50,
            ),),
            const SizedBox(height: 50),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),

              ),
            ),
            const SizedBox(height: 10),

        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Enter Yout Password',
            border: OutlineInputBorder(),

          ),
        ),

            const SizedBox(height: 50,),

            ElevatedButton(onPressed: (){
              _login();
              print('Buttton pressed');
            },
                child: const Text('Login',style: TextStyle(
                  color: Colors.white
                ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))

              ),

            ),

            ElevatedButton(onPressed: (){

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CreateAccountScreen()));
            },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.black,
              ), child: const Text("Register",style: TextStyle(
                color: Colors.white))
            )


          ],
        ),
      ),
    );
  }
}