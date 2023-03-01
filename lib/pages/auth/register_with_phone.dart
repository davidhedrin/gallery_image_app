import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:country_picker/country_picker.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/providers/auth_provider.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:delivery_food_app/widgets/app_bar_widget.dart';
import 'package:delivery_food_app/widgets/auth_widget/text_widget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterWithPhoneNumber extends StatefulWidget {
  const RegisterWithPhoneNumber({ Key? key }) : super(key: key);

  @override
  _RegisterWithPhoneNumberState createState() => _RegisterWithPhoneNumberState();
}

class _RegisterWithPhoneNumberState extends State<RegisterWithPhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController no_phoneController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController co_passwordController = TextEditingController();
  bool _isLoading = false, _isIcon = false;

  void setFormatNumber(){
    if(no_phoneController.text.length >= 10){
      _isIcon = true;
    }else{
      _isIcon = false;
    }
  }

  Country selectCountry = Country(
      phoneCode: "62",
      countryCode: "ID",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Indonesia",
      example: "Indonesia",
      displayName: "Indonesia",
      displayNameNoCountryCode: "ID",
      e164Key: ""
  );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Color(0xFF181A20),
        appBar: MyAppBar(
          appBar: AppBar(),
          leading:  GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: Dimentions.font30,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: FadeInDown(
              child: Padding(
                padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
                child: Column(
                  children: [
                    Image.asset(Assets.imageRegister, width: Dimentions.imageSize170,),
                    SizedBox(height: Dimentions.height15,),

                    Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimentions.font25, color: Colors.white),),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimentions.height10, horizontal: Dimentions.width20),
                      child: Text('Lenkapi data diri anda, Kode OTP akan dikirim.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: Dimentions.font14, color: Colors.white70),),
                    ),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          MyTextFieldReg(
                            controller: namaController,
                            hintText: "Masukkan Nama",
                            validator: (value){
                              if(value!.isEmpty){
                                return '*masukkan nama lengkap';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: Dimentions.height15,),

                          MyTextFieldReg(
                            controller: emailController,
                            hintText: "Masukkan Alamat Email",
                            validator: (value){
                              if(value!.isEmpty){
                                return '*masukkan alamat email';
                              }
                              if(!EmailValidator.validate(value)){
                                return '*alamat email tidak sesuai';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: Dimentions.height15,),

                          MyTextFieldReg(
                            controller: passwordController,
                            hintText: "Masukkan Password",
                            typeInput: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: (value){
                              if(value!.isEmpty){
                                return '*masukkan password';
                              }
                              if(value.length<6){
                                return 'minimal 6 karakter';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: Dimentions.height15,),

                          MyTextFieldReg(
                            controller: co_passwordController,
                            hintText: "Konfirmasi Password",
                            typeInput: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: (value){
                              if(value!.isEmpty){
                                return '*masukkan konfri password';
                              }
                              if(value.length<6){
                                return '*minimal 6 karakter';
                              }
                              if(passwordController.text != co_passwordController.text){
                                return '*password tidak cocok';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: Dimentions.height15,),

                          TextFormField(
                            controller: no_phoneController,
                            validator: (value){
                              if(value!.isEmpty){
                                return '*masukkan nomor ponsel';
                              }
                              if(value.length < 10){
                                return '*nomor ponsel tidak sah';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]'),
                              ),
                              FilteringTextInputFormatter.deny(
                                RegExp(r'^0+'),
                              ),
                            ],
                            onChanged: (phone){
                              setState(() {
                                setFormatNumber();
                              });
                            },
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            style: TextStyle(
                              fontSize: Dimentions.font20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
                              enabledBorder:  OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: "812-xxxx-xxxx",
                              hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20),
                              suffixIcon: !_isIcon ? Icon(Icons.phone_android) : Icon(Icons.check_circle,color: Colors.green,),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: Dimentions.width15, top: Dimentions.screenHeight/62, right: Dimentions.width5),
                                child: InkWell(
                                  onTap: (){
                                    showCountryPicker(
                                        context: context,
                                        countryListTheme:  CountryListThemeData(
                                          bottomSheetHeight: Dimentions.heightSize400,
                                        ),
                                        onSelect: (value){
                                          setState(() {
                                            selectCountry = value;
                                          });
                                        }
                                    );
                                  },
                                  child: Text(
                                    "${selectCountry.flagEmoji} +${selectCountry.phoneCode}",
                                    style: TextStyle(
                                      fontSize: Dimentions.font20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    MaterialButton(
                      minWidth: double.infinity,
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            _isIcon = false;
                          });

                          String number = "+${selectCountry.phoneCode}"+no_phoneController.text;
                          var modelUser = UserModel(
                            nama_lengkap: namaController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            phone: number,
                            flag_active: "Y",
                            user_type: "USR",
                            create_date: DateTime.now(),
                          );
                          await auth.verifyPhone(
                            context: context,
                            number: number,
                            data: modelUser,
                          ).then((value){
                            if(value){
                              namaController.clear();
                              emailController.clear();
                              passwordController.clear();
                              co_passwordController.clear();
                              no_phoneController.clear();
                            }else{
                              no_phoneController.clear();
                            }
                          });
                        }else{
                          showAwsBar(context: context, contentType: ContentType.help, msg: "Lengkapi Semua Data", title: "");
                        }
                      },
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimentions.screenHeight/156.21)
                      ),
                      padding: EdgeInsets.symmetric(vertical: Dimentions.height20, horizontal: Dimentions.width30),
                      child: _isLoading  ? Container(
                        width: Dimentions.width20,
                        height: Dimentions.height20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      ) :
                      Text("Daftar Sekarang", style: TextStyle(fontSize: Dimentions.font16, color: Colors.white),),
                    ),

                    SizedBox(height: Dimentions.height15,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah mempunyai akun?', style: TextStyle(color: Colors.white70, fontSize: Dimentions.font13),),
                        SizedBox(width: Dimentions.screenWidth/78.54,),
                        InkWell(
                          onTap: () {
                            Get.toNamed(RouteHalper.getLoginPage());
                          },
                          child: Text('Login', style: TextStyle(color: Colors.blueAccent, fontSize: Dimentions.font13, fontWeight: FontWeight.bold),),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}