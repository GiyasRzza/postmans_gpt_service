import 'package:flutter/material.dart';
import 'package:postmans_gpt_gui/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> readLogin() async {
    var sp = await SharedPreferences.getInstance();
    String? userName=sp.getString("mailAddress");
    String? password = sp.getString("password") ;
    if(userName!.isNotEmpty && password!.isNotEmpty){
      return true;
    }
    else{
      return false;
    }

  }0
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mail Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
        home: const MyHomePage(title: "")
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    var mailAddress = TextEditingController();
    var password = TextEditingController();
    Future<void> createUser() async {
      var url = Uri.parse('http://192.168.0.241:8080/create-user');
      var request = http.MultipartRequest('POST', url);
      Map<String,String> headers = <String,String>{
        'mail':mailAddress.text
      };
      request.headers.addAll(headers);
      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          print('User Created.');
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
    Future<void> loginControl() async {
      var mail = mailAddress.text;
      var pass = password.text;
      if (mail.isNotEmpty && pass.isNotEmpty) {
        var sp = await SharedPreferences.getInstance();
        sp.setString("mailAddress", mail);
        sp.setString("password", pass);
        createUser();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>const HomePage()));
      }
    }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.blueAccent,

        title: const Text("GPT Postman"),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 200,
                height: 200,
                child: Image.asset("images/mail.png")
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: mailAddress,
                decoration: const InputDecoration(
                  label: Text("Enter Mail Address"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    )
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                controller: password,
                decoration: const InputDecoration(
                    label: Text("Password"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    )
                ),

              ),
            ),
            ElevatedButton(
                onPressed: () {
                  loginControl();
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 25.0
                  ),
                )

            )

          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
