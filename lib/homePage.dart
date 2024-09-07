
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postmans_gpt_gui/emailRequest.dart';
import 'package:postmans_gpt_gui/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDialogVisible=false;
  bool isSendMinuteAge=false;
  var mail = TextEditingController();
  var to = TextEditingController();
  var from = TextEditingController();
  var subject = TextEditingController();

  Future<void> deleteData() async {
    var sp = await SharedPreferences.getInstance();
    sp.remove("mailAddress");
    sp.remove("password");
  }
  Future<void> sendImage(XFile imageFile) async {
    var url = Uri.parse('http://192.168.0.241:8080/send-file');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      Map<String,String> headers = <String,String>{
      'to': to.text,
      'subject': subject.text,
      'from':from.text
    };
    request.headers.addAll(headers);
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('FILE Send Success.');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filePic() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage!= null) {
          isDialogVisible=true;
          await sendImage(pickedImage);
    } else {
      print('Dont Selected!');
    }
  }

  Future<void> dataControl() async {
    var sp = await SharedPreferences.getInstance();
    from.text= sp.getString("mailAddress")!;
  }
  Future<void> postRequest() async {
    String url = "http://192.168.0.241:8080/send-email";
    Map<String, String> headers = {"Content-Type": "application/json"};

     EmailRequest emailRequest = EmailRequest(to.text, subject.text, mail.text, from.text);
      http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(emailRequest.toJson()),
    );
    if (response.statusCode == 200) {
      print("Succes Post From Flutter: ${response.body}");
    } else {
      print("Error Post From Flutter: ${response.statusCode}, ${response.reasonPhrase}");
    }
    mail.value=TextEditingValue.empty;
    to.value=TextEditingValue.empty;
    subject.value=TextEditingValue.empty;
  }

  @override
  void initState() {
     dataControl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.blueAccent,

        title: const Text("Home"),
        actions: [
            IconButton(
            icon: const Icon(
            Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              deleteData();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: "")));
            },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children:  [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue
              ),
                child: Text(
                  "Accounts"
                ),
            ),
            ListTile(
              title: SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(from.text),
                    ],
                  ),
                ),
              ),
              onTap: () {

              },
            )

          ],
        ),
      ),
      body:  Center(
        child: SizedBox(
          height: 480,
          width: 400,
          child: Card(
            shadowColor: Colors.black54,
            color: Colors.lightBlue,
            elevation: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: to,
                    decoration: const InputDecoration(
                        label: Text("To"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25))
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: from,
                    decoration: const InputDecoration(
                        label: Text("From"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25))
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: subject,
                    decoration: const InputDecoration(
                        label: Text("Subject"),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  TextField(
                    controller: mail,
                    decoration: const InputDecoration(
                        label: Text("Mail"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))
                      )
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          postRequest();
                        },
                        child: const Text(
                          "Send",
                          style: TextStyle(
                              color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 25.0
                          ),
                        )

                    ),
                    ElevatedButton(
                        onPressed: () {
                          filePic();

                        },
                        child: const Text(
                          "Select && Send Image",
                          style: TextStyle(
                              color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 15.0
                          ),
                        )

                    ),
                    Column(
                      children: [
                        const Text("Send Later"),
                        CheckboxMenuButton(value: isSendMinuteAge, onChanged: (value) {
                                setState(() {
                                  isSendMinuteAge=value!;
                                });
                           }, child: const Text("",style: TextStyle(
                          fontSize: 10
                        ),)),
                      ],
                    )
                  ],
                ),

              ],
            ),
          ),
        ),
        
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
