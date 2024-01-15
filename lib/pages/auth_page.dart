import 'package:flutter/material.dart';
import 'package:flutter_launchpad/services/auth_service.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/inputs/base_text_field.dart';
import 'package:flutter_launchpad/widgets/inputs/basic_button.dart';
import 'package:provider/provider.dart';

class AuthenticationPage extends StatefulWidget {
  final bool? isWeb;
  final bool isSignUp;
  final Function? onAuthCancel;
  const AuthenticationPage(
      {super.key,
      this.onAuthCancel,
      this.isWeb = true,
      required this.isSignUp});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isSignUp = false;

  bool hidePw = true;

  @override
  void initState() {
    isSignUp = widget.isSignUp;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    widget.onAuthCancel!();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child:
                          const Icon(Icons.close, color: AppStyles.iconColor)),
                ),
                SizedBox(width: 30),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSignUp = true;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: isSignUp
                            ? AppStyles.actionButtonColor
                            : AppStyles.panelColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('SIGN UP',
                        style: AppStyles.poppinsBold22.copyWith(
                            color: isSignUp ? Colors.white : Colors.white60)),
                  ),
                ),
                SizedBox(width: 30),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSignUp = false;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: !isSignUp
                            ? AppStyles.actionButtonColor
                            : AppStyles.panelColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('SIGN IN',
                        style: AppStyles.poppinsBold22.copyWith(
                            color: !isSignUp ? Colors.white : Colors.white60)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            // child: Container(
            //   width: widget.isWeb!
            //       ? MediaQuery.of(context).size.width * .3
            //       : MediaQuery.of(context).size.width * .9,
            //   padding: const EdgeInsets.all(10),
            //   height: 50,
            //   decoration: BoxDecoration(
            //       color: AppStyles.panelColor,
            //       borderRadius: BorderRadius.circular(12)),
            //   child: TextField(
            //     cursorHeight: 24,
            //     maxLength: 30,
            //     cursorColor: Colors.black,
            //     controller: emailController,
            //     style: AppStyles.poppinsBold.copyWith(fontSize: 18),
            //     maxLines: 1,
            //     expands: false,
            //     decoration: InputDecoration(
            //       hintText: 'Email...',
            //       hintStyle: AppStyles.poppinsBold.copyWith(
            //           fontSize: 16,
            //           color: const Color.fromARGB(255, 73, 91, 99)),
            //       fillColor: AppStyles.panelColor,
            //       border: InputBorder.none,
            //       disabledBorder: InputBorder.none,
            //       counter: SizedBox(),
            //     ),
            //   ),
            // ),
            child: Container(
              width: MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * .3
                  : MediaQuery.of(context).size.width * .8,
              child: BasicTextField(
                autofocus: true,
                controller: emailController,
                hintText: 'email',
              ),
            ),
          ),
          SizedBox(height: 36),
          // Container(
          //   width: widget.isWeb!
          //       ? MediaQuery.of(context).size.width * .3
          //       : MediaQuery.of(context).size.width * .9,
          //   height: 50,
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //       color: AppStyles.panelColor,
          //       borderRadius: BorderRadius.circular(12)),
          //   child: TextField(
          //     cursorHeight: 24,
          //     maxLength: 50,
          //     cursorColor: Colors.black,
          //     controller: passwordController,
          //     obscureText: hidePw,
          //     style: AppStyles.poppinsBold.copyWith(fontSize: 18),
          //     maxLines: 1,
          //     expands: false,
          //     decoration: InputDecoration(
          //       hintText: isSignUp ? 'Create password...' : 'Enter password...',
          //       hintStyle: AppStyles.poppinsBold.copyWith(
          //           fontSize: 16, color: const Color.fromARGB(255, 73, 91, 99)),
          //       fillColor: AppStyles.panelColor,
          //       border: InputBorder.none,
          //       disabledBorder: InputBorder.none,
          //       counter: const SizedBox(),
          //       suffixIcon: GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               hidePw = !hidePw;
          //             });
          //           },
          //           child: hidePw == true
          //               ? const Icon(Icons.remove_red_eye,
          //                   color: AppStyles.iconColor)
          //               : const Icon(Icons.visibility_off_rounded,
          //                   color: AppStyles.iconColor)),
          //     ),
          //   ),
          // ),
          Container(
            width: MediaQuery.of(context).size.width > 800
                ? MediaQuery.of(context).size.width * .3
                : MediaQuery.of(context).size.width * .8,
            child: BasicTextField(
              controller: passwordController,
              obscure: true,
              hintText: 'password',
            ),
          ),
          SizedBox(height: 36),
          Consumer<AuthService>(
              builder: (ctx, auth, _) => BasicButton(
                  isMobile: PlatformServices.isWebMobile,
                  onClick: () async {
                    if (isSignUp) {
                      await auth.signUpWithEmail(
                          email: emailController.text,
                          password: passwordController.value.text.trim());
                      // setState(() {});
                      //signup
                    } else {
                      //signin
                      await auth.signInWithEmail(
                          email: emailController.text,
                          password: passwordController.value.text.trim());
                      // setState(() {});
                    }
                  },
                  label: isSignUp ? 'SIGN UP' : "SIGN IN"))
        ],
      ),
    );
  }
}
