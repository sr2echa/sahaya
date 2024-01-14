import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'getPermissions.dart';
// import 'home.dart';

class GetPhoneNumber extends StatefulWidget {
  @override
  State<GetPhoneNumber> createState() => _GetPhoneNumberState();
}

class _GetPhoneNumberState extends State<GetPhoneNumber> {

  TextEditingController controller = TextEditingController();
  String initialCountry = 'IN';
  bool buttonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/background/main.png"),
        fit: BoxFit.cover,
      )
    ),
    child:Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.125
            ),
            child: Column(            
              children: [
                
                SizedBox(height: 85),
                
                Image.asset(
                  "assets/icon/icon.png",
                  height: 90,  
                ),

                SizedBox(height: 5),
                
                Text(
                  "S A H A Y A",
                  style: GoogleFonts.getFont(
                    'Lexend',
                    fontWeight: FontWeight.w700,
                    fontSize: 23
                  )
                ),

                SizedBox(height: 59),
                
                Container(
                  // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),  
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    // border: Border.all(width: 1, color: Colors.black),
                    // borderRadius: BorderRadius.circular(15),
                  ), 
                  child: IntlPhoneField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      counter: Offstage(),
                      labelText: '  Phone Number',
                      border: OutlineInputBorder(
                        
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 3.0),
                        // borderSide: BorderSide.none,
                      ),
                      focusedBorder:OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      )
                    ),
                    initialCountryCode: initialCountry,
                    showDropdownIcon: true,
                    dropdownIconPosition:IconPosition.leading,
                    onChanged: (phone) {
                      setState(() {
                        // buttonEnabled = phone.number.length >= 10;
                        buttonEnabled = phone.completeNumber.length >= 10;   
                      });
                    },
                    controller: controller,
                  ),
                ),

                SizedBox(height: 18),
                
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 60,  
                  child: ElevatedButton(
                    onPressed: buttonEnabled
                      ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('phoneNumber', controller.text);
                        
                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(builder: (context) => Home())  
                        // );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => GetPermissions()),
                        );
                      }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )  
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        fontSize: 18, 
                        color: Colors.white
                      ), 
                    ),
                  ),
                ),

                Spacer(),

                TextButton(
                  onPressed: () async {
                    const url = 'https://github.com/sr2echa/sahaya/blob/main/TERMS.md';
                    await launchUrl(Uri.parse(url));
                  },
                  child: Text(
                    "Terms & Conditions",
                    // style: TextStyle(color: Colors.grey),
                    style: GoogleFonts.getFont(
                      'JetBrains Mono',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey
                    )
                  ) 
                )

              ],
            ),
          ),
        ),
      )
    );
  }
}